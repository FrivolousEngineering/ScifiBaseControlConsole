import QtQuick 2.0
import QtQuick.Shapes 1.0
import QtGraphicalEffects 1.0


Item
{
    id: base
    implicitHeight: 200
    implicitWidth: 50

    property double maxTemperature: 500
    property double minTemperature: 200
    property double currentTemperature: 300
    property double previousTemperature: 200
    property double historyTemperature: 200

    readonly property int boxCount: 7
    property int boxSpacing: 5
    property int boxBorderSize: 2
    property int arrowMargin: 4

    readonly property int boxHeight: (height - boxSpacing * boxCount - 1) / boxCount

    function calculateBoxIndex(temperature)
    {
        if(temperature <= minTemperature)
        {
            return boxCount - 1;
        }

        if(temperature >= maxTemperature)
        {
            return 0;
        }
        // It's within bounds.
        var relativeTemperature = maxTemperature - temperature
        var temperatureRange = maxTemperature - minTemperature
        var temperaturePerBox = temperatureRange / boxCount;
        return relativeTemperature / temperaturePerBox
    }

    function calculateArrowPosition(temperature)
    {
        if(currentTemperature < minTemperature)
        {
            return 1;
        }

        if(currentTemperature > maxTemperature)
        {
            return 0;
        }
        var relativeTemperature = maxTemperature - temperature
        var temperatureRange = maxTemperature - minTemperature
        return relativeTemperature / temperatureRange;
    }

    property int activeBoxIndex: calculateBoxIndex(currentTemperature)

    LinearGradient
    {
        anchors.fill: parent
        anchors.topMargin:boxBorderSize
        anchors.bottomMargin: boxBorderSize
        anchors.leftMargin: boxBorderSize + arrowMargin
        anchors.rightMargin: boxBorderSize + arrowMargin
        gradient: Gradient
        {
            GradientStop { position: 1.0; color: "blue" }
            GradientStop { position: 0.0; color: "red" }
            GradientStop { position: 0.5; color: "green" }
        }
        source: Column
        {
            spacing: boxSpacing
            Repeater
            {
                model: boxCount
                Rectangle
                {
                    width: 1// Just not 0. Everything else gives the right effect?
                    height: boxHeight
                }
            }
        }
    }

    Rectangle
    {
        // The selection rectangle
        border.width: boxBorderSize
        border.color: "white"
        color: "transparent"
        y: activeBoxIndex * boxHeight + activeBoxIndex * boxSpacing + activeBoxIndex
        Behavior on y
        {
            NumberAnimation { duration: 200 }
        }
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: arrowMargin
        anchors.leftMargin: arrowMargin
        height: boxHeight + border.width

        Text {
            text: currentTemperature.toFixed(1)
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
        }
    }

    Shape
    {
        id: leftTriangle
        width: 11
        height: 11
        ShapePath {
            strokeColor: "transparent"
            PathLine { x: 0; y: - 0.5 * leftTriangle.height }
            PathLine { x: leftTriangle.width; y: 0}
            PathLine { x: 0; y:  0.5 * leftTriangle.height }
            PathLine { x: 0; y: - 0.5 * leftTriangle.height }
        }
        Behavior on y {
            NumberAnimation { duration: 200 }
        }
        y: calculateArrowPosition(previousTemperature) * base.height - 0.5 * boxBorderSize
        opacity: 0.75
    }

    Shape
    {
        id: rightTriangle
        width: 11
        height: 11
        anchors.right: parent.right
        ShapePath {
            strokeColor: "transparent"
            PathLine { x: rightTriangle.width; y: - 0.5 * rightTriangle.height }
            PathLine { x: 0; y: 0}
            PathLine { x: rightTriangle.width; y:  0.5 * rightTriangle.height }
            PathLine { x: rightTriangle.width; y: - 0.5 * rightTriangle.height }
        }
        Behavior on y {
            NumberAnimation { duration: 200 }
        }
        y: calculateArrowPosition(historyTemperature) * base.height - 0.5 * boxBorderSize
        opacity: 0.75
    }
}
