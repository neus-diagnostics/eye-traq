#ifndef TOBII_H
#define TOBII_H

#include <QPointF>
#include <QVector3D>

#include <tobii/sdk/cpp/Types.hpp>
namespace tetio = tobii::sdk::cpp;

inline QPointF point2_to_qpoint(const tetio::Point2d &p)
{
	return QPointF{static_cast<float>(p.x), static_cast<float>(p.y)};
}

inline QVector3D point3_to_qvec(const tetio::Point3d &p)
{
	return QVector3D{
		static_cast<float>(p.x),
		static_cast<float>(p.y),
		static_cast<float>(p.z)
	};
}

#endif
