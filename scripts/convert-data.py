#!/usr/bin/python3

# This scripts converts experimental datalogs created by older
# versions of the program into the newest format.

# versions with existing recorded data:
# 2017-09-04 e766e6d just one file? skip for now
# 2017-09-05 f86dda7 original CSV format
# 2017-11-20 8663824 no files? skip for now
# 2018-08-31 1bb5bec current JSON format

import os
import json
import sys

path = sys.argv[1]
filename = os.path.basename(path)

old = open(path)
old_version = old.readline().strip().split()[3]

if old_version == 'f86dda7':
    new_version = '1bb5bec'
    new_path = os.path.join(os.path.dirname(path), new_version)
    os.makedirs(new_path, exist_ok=True)
    new = open(os.path.join(new_path, filename), 'w')

    # header stuff
    print(f'# program version: {new_version} (converted from {old_version})', file=new)

    eyetracker = old.readline().strip()
    print(eyetracker, file=new)

    # identical monitors were used for all tests, so hardcode size and resolution
    physicalSize = {'width': 521, 'height': 293}
    print(f'# screen size: {physicalSize["width"]} {physicalSize["height"]}', file=new)
    print(f'# screen resolution: 1920 1080', file=new)

    def convert_gaze(fields):
        def make_float(s):
            return s if s is None else float(s)
        def make_coords(data, base, coords):
            return {c: make_float(data[f'{base}_{c}']) for c in coords}

        trans = {
            'true': True,
            'false': False,
            'NaN': None,
        }
        data = {k: trans.get(v, v) for k, v in fields.items()}
        return {
            data['eye']: {
                'eye_trackbox': make_coords(data, 'eye_trackbox', 'xyz'),
                'eye_ucs': make_coords(data, 'eye_ucs', 'xyz'),
                'eye_valid': data['eye_valid'],
                'gaze_screen': make_coords(data, 'gaze_screen', 'xy'),
                'gaze_ucs': make_coords(data, 'gaze_ucs', 'xyz'),
                'gaze_valid': data['gaze_valid'],
                'pupil_diameter': make_float(data['pupil_diameter']),
                'pupil_valid': data['pupil_valid'],
            },
        }

    def convert_test(time, fields, test):
        action = fields[0]
        data = {'type': action}

        # nominal test duration was not recorded, so take the
        # actual time difference between successive steps and
        # update previous entry
        if action in {'done', 'step'} and test is not None:
            if test is not None:
                test['test']['task']['duration'] = (time - test['time']) // 1000

        if action == 'step':
            step, name = int(fields[1]), fields[2]
            data['step'] = step

            task = {
                'name': name,
                'start': 0 if test is None else test['test']['task']['start'] + test['test']['task']['duration'],
            }
            if name == 'blank':
                pass
            elif name == 'message':
                task['audio'] = fields[3]
                if len(fields) > 4:
                    task['align'] = fields[4]
                if len(fields) > 5:
                    task['text'] = fields[5]
            elif name == 'imgpair':
                task['left'] = fields[3]
                task['right'] = fields[4]
            elif name == 'saccade':
                task['delay'] = int(fields[3])
                task['direction'] = fields[4]
                task['offset'] = float(fields[5])
                # some practice files encoded type and where fields incorrectly, fix it here
                task['type'] = 'step' if fields[6] == 'false' else fields[6]
                task['where'] = 'pro' if len(fields) <= 7 or fields[7] == 'pro' else 'anti'
            elif name == 'pursuit':
                task['direction'] = fields[3]
                task['offset'] = float(fields[4])
                task['period'] = int(fields[5])
            else:
                raise Exception(f'unhandled test step: {fields}')
            data['task'] = task

        elif action == 'data':
            task_data = {}
            if test['test']['task']['name'] == 'saccade':
                task_data['fixation'] = fields[1] == 'true'
                task_data['target'] = fields[2] == 'true'
                if test['test']['task']['direction'] == 'x':
                    task_data['x'] = 0.5 + 10*test['test']['task']['offset'] / physicalSize['width']
                    task_data['y'] = 0.5
                else:
                    task_data['x'] = 0.5
                    task_data['y'] = 0.5 + 10*test['test']['task']['offset'] / physicalSize['height']
            elif test['test']['task']['name'] == 'pursuit':
                task_data['x'] = float(fields[1])
                task_data['y'] = float(fields[2])
            else:
                print(test)
                print(fields)
            data['data'] = task_data

        return data

    # get eyetracker data header
    columns = old.readline().strip().split()[3:]

    # gaze currently being constructed
    gaze = {}
    # currently active test
    current_test = None

    # keep all entries in memory and sort by time before writing
    entries = []
    for line in old:
        values = line.strip().split('\t')
        time, event, data = int(values[0]), values[1], values[2:]

        if event == 'gaze':
            fields = dict(zip(columns, data))
            gaze.update(convert_gaze(fields))
            if 'left' in gaze and 'right' in gaze:
                gaze['eyetracker_time'] = int(fields['eyetracker_time'])
                gaze['time'] = time
                entries.append({'time': time, 'type': event, event: gaze})
                gaze = {}

        elif event == 'test':
            test = convert_test(time, data, current_test)
            entries.append({'time': time, 'type': event, event: test})
            if test['type'] == 'step':
                current_test = entries[-1]

    # write to new file
    for entry in sorted(entries, key=lambda e: e['time']):
        print(f'{entry["time"]}\t{json.dumps(entry)}', file=new)
    new.close()

old.close()
