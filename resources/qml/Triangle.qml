import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Shapes 1.0


Shape
{
    id: base
    implicitWidth: 16
    implicitHeight: 16
    property color color: "purple"

    ShapePath
    {
        id: shapePath
        strokeWidth: 4
        fillColor: base.color
        strokeColor: base.color
        joinStyle: ShapePath.RoundJoin
        capStyle: ShapePath.RoundCap
        property var half: strokeWidth / 2
        startX: half
        startY: half
        PathLine { x: 0.5 * base.width; y: base.height - shapePath.half }
        PathLine { x: base.width - shapePath.half; y: shapePath.half }
        PathLine { x: shapePath.half; y: shapePath.half }
    }
}