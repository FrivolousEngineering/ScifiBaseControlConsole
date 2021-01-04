import QtQuick 2.0
import SDK 1.0

Item
{
    id: base
    property double angleSize: 15
    property double sideBarWidth: 35
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
        id: requiredResourcesBar
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

        Column
        {
            anchors.fill: parent
            spacing: 2
            anchors.topMargin: 2
            anchors.bottomMargin: requiredResourcesBar.angleSize
            anchors.leftMargin: 3
            anchors.rightMargin: 2
            Text
            {
                text: "req"
                font: Qt.font({
                    family: "Roboto",
                    pixelSize: 10,
                    bold: true,
                    capitalization: Font.AllUppercase
                });
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.right: parent.right
            }
            Rectangle
            {
                height: 1
                color: "white"
                x: -2
                width: parent.width + 4
            }
            Repeater
            {
                model: controller.resourcesRequired
                delegate: ResourceIndicator
                {
                    type: modelData.type
                    value: modelData.value
                }
            }
            Text
            {
                text: "OPT"
                font: Qt.font({
                    family: "Roboto",
                    pixelSize: 10,
                    bold: true,
                    capitalization: Font.AllUppercase
                });
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.right: parent.right
                visible: controller.optionalResourcesRequired.length > 0
            }


            Repeater
            {
                model: controller.optionalResourcesRequired
                delegate: ResourceIndicator
                {
                    type: modelData.type
                    value: modelData.value
                }
            }
        }
    }

    CutoffRectangle
    {
        id: main
        anchors
        {
            left: requiredResourcesBar.right
            right: receivedResourcesBar.left
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

            CutoffRectangle
            {
                id: temperatureItem
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 53
                anchors.margins: 2
                angleSize: 2
                Text
                {
                    id: tempText
                    height: contentHeight
                    text: "TEMP"
                    font: Qt.font({
                        family: "Roboto",
                        pixelSize: 8,
                        bold: true,
                        capitalization: Font.AllUppercase
                    });
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
                TemperatureBar
                {
                    id: temperature
                    anchors.top: tempText.bottom
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 2
                    anchors.topMargin: 0
                    anchors.bottomMargin: 6
                }
            }
            CutoffRectangle
            {
                id: performanceDialItem
                anchors.top: parent.top
                anchors.right: temperatureItem.left
                anchors.rightMargin: 3
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.margins: 2
                angleSize: 2
                height: 125
                visible: performanceDial.from != performanceDial.to
                Text
                {
                    id: performanceText
                    height: contentHeight
                    text: "PERFORMANCE"
                    font: Qt.font({
                        family: "Roboto",
                        pixelSize: 8,
                        bold: true,
                        capitalization: Font.AllUppercase
                    });
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
                CustomDial
                {
                    id: performanceDial
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.top: performanceText.bottom
                    anchors.topMargin: 1
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
                anchors.left: performanceDialItem.left
                anchors.right: performanceDialItem.right
                anchors.top: performanceDialItem.bottom
                anchors.topMargin: 3
                anchors.bottom: temperatureItem.bottom
                angleSize: 2

                Text
                {
                    id: modifierText
                    height: contentHeight
                    text: "MODIFIERS"
                    font: Qt.font({
                        family: "Roboto",
                        pixelSize: 8,
                        bold: true,
                        capitalization: Font.AllUppercase
                    });
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                Row
                {
                    spacing: 2
                    anchors
                    {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        rightMargin: 2
                        leftMargin: 2
                        top: modifierText.bottom
                        bottomMargin: parent.angleSize + 1
                    }
                    Repeater
                    {
                        model: controller.modifiers
                        delegate: Rectangle
                        {
                            height: parent.height
                            width: height
                        }
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
        id: receivedResourcesBar
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

        Column
        {
            anchors.fill: parent
            spacing: 2
            anchors.topMargin: 2
            anchors.bottomMargin: receivedResourcesBar.angleSize
            anchors.leftMargin: 3
            anchors.rightMargin: 2
            Text
            {
                text: "RECV"
                font: Qt.font({
                    family: "Roboto",
                    pixelSize: 10,
                    bold: true,
                    capitalization: Font.AllUppercase
                });
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.right: parent.right
            }
            Rectangle
            {
                height: 1
                color: "white"
                width: parent.width + 4
                x: -2
            }
            Repeater
            {
                model: controller.resourcesReceived
                delegate: ResourceIndicator
                {
                    type: modelData.type
                    value: modelData.value
                }
            }
        }
    }
}
