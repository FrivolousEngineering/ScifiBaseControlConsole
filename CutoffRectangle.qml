import QtQuick.Shapes 1.0
import QtQuick 2.0


// The Cutoff rectangle works mostly like a regular rectangle, but provides the option to have Cutoff corners
Shape
{
    id: base
    implicitWidth: 200
    implicitHeight: 150

    property double angleSize: 15
    property alias color: shapePath.fillColor

    property int cornerSide: CutoffRectangle.Direction.All

    // Simple object to ensure that border.width and border.color work
    property BorderGroup border: BorderGroup { color: "#BA6300"; width: 1}

    enum Direction
    {
        Down = 0,
        Left = 1,
        Up = 2,
        Right = 3,
        All = 4,
        UpLeft = 5,
        UpRight = 6,
        DownLeft = 7,
        DownRight = 8,
        ExcludeBottomRight = 9,
        ExcludeTopRight = 10,
        None = 11
    }



    function recalculatePoints()
    {
        shapePath.pathElements = [] // Clear the previous path
        // Upper right Corner
        if(cornerSide == CutoffRectangle.Direction.Right || cornerSide == CutoffRectangle.Direction.Up || cornerSide == CutoffRectangle.Direction.All || cornerSide == CutoffRectangle.Direction.UpRight || cornerSide == CutoffRectangle.Direction.ExcludeBottomRight)
        {
            shapePath.pathElements.push(createPathLine(base.width - angleSize, 0))
        } else
        {
            shapePath.pathElements.push(createPathLine(base.width, 0))
        }
        shapePath.pathElements.push(createPathLine(base.width, angleSize))

        // Lower right corner
        if(cornerSide == CutoffRectangle.Direction.Right || cornerSide == CutoffRectangle.Direction.Down || cornerSide == CutoffRectangle.Direction.All || cornerSide == CutoffRectangle.Direction.DownRight || cornerSide == CutoffRectangle.Direction.ExcludeTopRight )
        {
            shapePath.pathElements.push(createPathLine(base.width, base.height - angleSize))
        }
        else
        {
            shapePath.pathElements.push(createPathLine(base.width, base.height))
        }
        shapePath.pathElements.push(createPathLine(base.width - angleSize, base.height))

        // Lower left corner
        if(cornerSide == CutoffRectangle.Direction.Left || cornerSide == CutoffRectangle.Direction.Down || cornerSide == CutoffRectangle.Direction.All || cornerSide == CutoffRectangle.Direction.DownLeft || cornerSide == CutoffRectangle.Direction.ExcludeBottomRight || cornerSide == CutoffRectangle.Direction.ExcludeTopRight)
        {
            shapePath.pathElements.push(createPathLine(angleSize, base.height))
        }
        else
        {
            shapePath.pathElements.push(createPathLine(0, base.height))
        }
        shapePath.pathElements.push(createPathLine(0, base.height - angleSize))

        // Upper left corner
        if(cornerSide == CutoffRectangle.Direction.Left || cornerSide == CutoffRectangle.Direction.Up || cornerSide == CutoffRectangle.Direction.All || cornerSide == CutoffRectangle.Direction.UpLeft || cornerSide == CutoffRectangle.Direction.ExcludeBottomRight || cornerSide == CutoffRectangle.Direction.ExcludeTopRight)
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
        var pathcurve = Qt.createQmlObject('import QtQuick 2.11; PathLine {}', shapePath);
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
        fillColor: "#333333"
        startX: angleSize
        startY: 0
    }
}