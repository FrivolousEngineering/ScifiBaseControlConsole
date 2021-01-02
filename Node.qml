import QtQuick 2.0
import SDK 1.0

Item
{
    id: base
    property double angleSize: 15
    property double sideBarWidth: 25
    property double sideBarAngle: angleSize / 3
    property int borderSize: 2
    property int barSpacing: 2

    property alias titleText: title_text.text
    property alias currentTemperature: temperature.currentTemperature
    property alias previousTemperature: temperature.previousTemperature
    property alias historyTemperature: temperature.historyTemperature
    property alias maxTemperature: temperature.maxTemperature
    property alias minTemperature: temperature.minTemperature
    property alias optimalTemperature: temperature.optimalTemperature
    property alias isTemperatureDependant: temperature.hasOptimalTemperature
    property alias maxSafeTemperature: temperature.maxSafeTemperature

    property var controller

    property font titleFont: Qt.font({
            family: "Roboto",
            pixelSize: angleSize - 3 * barSpacing,
            bold: true,
            capitalization: Font.AllUppercase
        });

    implicitWidth: 250
    implicitHeight: 200

    CutoffRectangle
    {
        id: input
        anchors
        {
            top: parent.top
            bottom: parent.bottom
            bottomMargin: parent.angleSize
            topMargin: parent.angleSize
        }
        angleSize: sideBarAngle
        cornerSide: CutoffRectangle.Direction.Left
        width: sideBarWidth
        border.width: borderSize
    }

    CutoffRectangle
    {
        id: main
        anchors
        {
            left: input.right
            right: output.left
            top: parent.top
            bottom: parent.bottom
        }
        angleSize: parent.angleSize
        border.width: borderSize

        Item
        {
            id: contentItem
            anchors
            {
                top: parent.top
                topMargin: angleSize
                left: parent.left
                bottom: parent.bottom
                right: parent.right
                bottomMargin: angleSize
            }

            TemperatureBar
            {
                id: temperature
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 2
            }

            CustomDial
            {
                id: performanceDial
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.right: temperature.left
                anchors.top: parent.top
                anchors.topMargin: 5
                height: width

                from: controller.min_performance
                to: controller.max_performance
                visible: from != to
                enabled: visible

                Behavior on currentValue {
                    NumberAnimation {
                        duration: 1000
                        easing.type: Easing.InOutCubic
                    }
                }

                Behavior on targetValue
                {
                    NumberAnimation {
                        duration: 1000
                        easing.type: Easing.InOutCubic
                    }
                }

                Binding
                {
                    target: performanceDial
                    property: "targetValue"
                    value: controller.targetPerformance
                    when: !performanceDial.pressed
                }

                currentValue: controller.performance

                onPressedChanged:
                {
                    if(!pressed) // Released
                    {
                        controller.setPerformance(value)
                    }
                }
            }

        }

        CutoffRectangle
        {
            id: healthBar
            color: "white"
            cornerSide: CutoffRectangle.Direction.Down
            anchors
            {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                leftMargin: barSpacing + 2 * borderSize + 1
                rightMargin: barSpacing + 2 * borderSize
                bottomMargin: barSpacing + borderSize
            }
            border.width: 0
            border.color: "transparent"

            angleSize: height
            height: base.angleSize - 2 * borderSize - 0.5 * barSpacing
        }

        CutoffRectangle
        {
            id: titleBar
            color: "white"
            cornerSide: CutoffRectangle.Direction.Up
            anchors
            {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: barSpacing + 2 * borderSize + 1
                rightMargin: barSpacing + 2 * borderSize
                topMargin: barSpacing + borderSize
            }
            border.width: 0
            border.color: "transparent"

            angleSize: height
            height: base.angleSize - 2 * borderSize - 0.5 * barSpacing

            Text
            {
                id: title_text
                text: "undefined"
                color: "black"
                font: titleFont
                horizontalAlignment: Text.AlignHCenter
                anchors
                {
                    left: parent.left
                    right: parent.right
                    leftMargin: angleSize
                    rightMargin: angleSize
                }
            }

        }
    }

    CutoffRectangle
    {
        id: output
        anchors
        {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            bottomMargin: parent.angleSize
            topMargin: parent.angleSize
        }

        angleSize: sideBarAngle
        cornerSide: CutoffRectangle.Direction.Right
        width: sideBarWidth
        border.width: borderSize
    }
}
