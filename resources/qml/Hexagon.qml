import QtQuick.Shapes 1.0
import QtQuick 2.11

Shape
{
    id: base
    implicitWidth: 200
    implicitHeight: 200

    height: 0.866025404 * width
    property alias color: shapePath.fillColor
    // Simple object to ensure that border.width and border.color work
    property BorderGroup border: BorderGroup { color: "#BA6300"; width: 1}
    property var size: width

    ShapePath
    {
        id: shapePath
        strokeWidth: base.border.width
        strokeColor: base.border.color
        startX: 0
        startY: 0.433012702 * size
        fillColor: "#333333"

        PathLine {x: 0.25 * size; y: 0 * size}
        PathLine {x: 0.75 * size; y: 0 * size}
        PathLine {x: 1 * size; y: 0.433012702 * size}
        PathLine {x: 0.75 * size; y: 0.866025404* size}
        PathLine {x: 0.25 * size; y: 0.866025404 * size}
        PathLine {x: 0 * size; y: 0.433012702 * size}
    }
}