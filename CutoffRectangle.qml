import QtQuick.Shapes 1.13
import QtQuick 2.13


// The Cutoff rectangle works mostly like a regular rectangle, but provides the option to have Cutoff corners
Shape
{
    id: base
    implicitWidth: 200
    implicitHeight: 150

    property int angleSize: 15

    property int cornerSide: CutoffRectangle.Direction.All

    // Simple object to ensure that border.width and border.color work
    property BorderGroup border: BorderGroup { color: "#BA6300"; width: 3}

    enum Direction
    {
        Down = 0,
        Left = 1,
        Up = 2,
        Right = 3,
        All = 4
    }

    function recalculatePoints()
    {
        shapePath.pathElements = [] // Clear the previous path

        if(cornerSide == CutoffRectangle.Direction.Right || cornerSide == CutoffRectangle.Direction.Up || cornerSide == CutoffRectangle.Direction.All )
        {
            shapePath.pathElements.push(createPathLine(base.width - angleSize, 0))
        } else
        {
            shapePath.pathElements.push(createPathLine(base.width, 0))
        }
        shapePath.pathElements.push(createPathLine(base.width, angleSize))

        if(cornerSide == CutoffRectangle.Direction.Right || cornerSide == CutoffRectangle.Direction.Down || cornerSide == CutoffRectangle.Direction.All )
        {
            shapePath.pathElements.push(createPathLine(base.width, base.height - angleSize))
        }
        else
        {
            shapePath.pathElements.push(createPathLine(base.width, base.height))
        }

        shapePath.pathElements.push(createPathLine(base.width - angleSize, base.height))

        if(cornerSide == CutoffRectangle.Direction.Left || cornerSide == CutoffRectangle.Direction.Down || cornerSide == CutoffRectangle.Direction.All )
        {
            shapePath.pathElements.push(createPathLine(angleSize, base.height))
        }
        else
        {
            shapePath.pathElements.push(createPathLine(0, base.height))
        }
        shapePath.pathElements.push(createPathLine(0, base.height - angleSize))

        if(cornerSide == CutoffRectangle.Direction.Left || cornerSide == CutoffRectangle.Direction.Up || cornerSide == CutoffRectangle.Direction.All )
        {
            shapePath.pathElements.push(createPathLine(0, base.angleSize))
        }
        else
        {
            shapePath.pathElements.push(createPathLine(0, 0))
        }
        shapePath.pathElements.push(createPathLine(angleSize, 0))
    }

    function createPathLine(x, y)
    {
        var pathcurve = Qt.createQmlObject('import QtQuick 2.12; PathLine {}', shapePath);
        pathcurve.x = x
        pathcurve.y = y
        return pathcurve
    }

    Component.onCompleted: recalculatePoints()

    ShapePath
    {
        id: shapePath
        strokeWidth: base.border.width
        strokeColor: base.border.color

        startX: angleSize
        startY: 0
    }
}