import QtQuick 2.0
import QtQuick.Controls 2.2
import SDK 1.0
import QtQml 2.2

Item
{
    id: base
    property double angleSize: 15
    property double sideBarWidth: 35
    property double sideBarAngle: angleSize / 3
    property int borderSize: 2
    property int barSpacing: 2

    property int defaultSpacing: 3

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

    signal addModifierClicked(string nodeId)

    property font resourceFont: Qt.font({
        family: "Roboto",
        pixelSize: 10,
        bold: true,
        capitalization: Font.AllUppercase
    });

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
            id: reqColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: defaultSpacing
            anchors.topMargin: defaultSpacing
            anchors.leftMargin: defaultSpacing + 1
            anchors.rightMargin: defaultSpacing

            Text
            {
                text: "req"
                font: resourceFont
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.right: parent.right
            }
            Rectangle
            {
                height: 1
                color: "white"
                x: -defaultSpacing
                width: parent.width + 2 * defaultSpacing
            }
            Instantiator
            {
                model: controller.resourcesRequired
                asynchronous: true
                onObjectAdded:
                {
                    object.parent = reqColumn
                    object.opacity = 1 // Force the animation
                }
                onObjectRemoved: object.parent = null
                delegate: ResourceIndicator
                {
                    type: modelData.type
                    value: modelData.value
                    opacity: 0
                    Behavior on opacity { NumberAnimation { duration: 1000; easing.type: Easing.InOutCubic } }
                    width: sideBarWidth - (2 * defaultSpacing + 1)  // parent.width caused a binding issue sometimes..
                    height: sideBarWidth - (2 * defaultSpacing + 1)
                }
            }
        }
        Column
        {
            id: optColumn
            spacing: defaultSpacing
            anchors.top: reqColumn.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: defaultSpacing
            anchors.bottomMargin: requiredResourcesBar.angleSize
            anchors.leftMargin: defaultSpacing + 1
            anchors.rightMargin: defaultSpacing
            Text
            {
                text: "OPT"
                font: resourceFont
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.right: parent.right
                visible: controller.optionalResourcesRequired.length > 0
            }
            Rectangle
            {
                height: 1
                color: "white"
                x: -defaultSpacing
                width: parent.width + 2 * defaultSpacing
            }

            Instantiator
            {
                model: controller.optionalResourcesRequired
                asynchronous: true

                onObjectAdded:
                {
                    object.parent = optColumn
                    object.opacity = 1 // Force the animation
                }
                onObjectRemoved: object.parent = null

                delegate: ResourceIndicator
                {
                    type: modelData.type
                    value: modelData.value
                    opacity: 0
                    Behavior on opacity { NumberAnimation { duration: 1000; easing.type: Easing.InOutCubic } }
                    width: optColumn.width
                    height: optColumn.width
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


            BoxWithTitle
            {
                id: temperatureItem
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 53
                anchors.margins: defaultSpacing
                angleSize: 2
                titleText: "TEMP"
                TemperatureBar
                {
                    id: temperature
                    anchors.fill: parent
                    anchors.bottomMargin: 5
                }
            }
            BoxWithTitle
            {
                id: performanceDialItem
                anchors
                {
                    top: parent.top
                    right: temperatureItem.left
                    rightMargin: defaultSpacing + 1
                    left: parent.left
                    leftMargin: defaultSpacing + 2
                    margins: defaultSpacing
                }

                angleSize: 2
                height: 120
                visible: controller.hasSettablePerformance
                opacity: visible? 1: 0
                Behavior on opacity { NumberAnimation { duration: 1000; easing.type: Easing.InOutCubic } }

                titleText: "PERFORMANCE"

                Text
                {
                    id: efficiencyFactorLabel
                    font: Qt.font({
                            family: "Roboto",
                            pixelSize: 15,
                            bold: true,
                            capitalization: Font.AllUppercase
                        });
                    color: "white"
                    anchors.right: parent.right
                    anchors.bottom:parent.bottom

                    text: Math.round(controller.effectiveness_factor * 100) / 100
                }

                CustomDial
                {
                    id: performanceDial
                    anchors
                    {
                        left: parent.left
                        leftMargin: 5
                        right: parent.right
                        rightMargin: 4
                        top: parent.top
                        topMargin: 1
                    }

                    height: width

                    from: controller.min_performance
                    to: controller.max_performance
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

            BoxWithTitle
            {
                anchors.fill: performanceDialItem
                visible: !performanceDialItem.visible && ("amount_stored" in controller.additionalProperties)
                titleText: "STORAGE"

                Text
                {
                    property double amountStored: visible ? controller.additionalProperties["amount_stored"]["value"]: -1
                    property double maxAmountStored: visible? controller.additionalProperties["amount_stored"]["max_value"]: -1

                    Behavior on amountStored {
                        NumberAnimation {
                            duration: 1250
                            easing.type: Easing.InOutCubic
                        }
                    }

                    text: maxAmountStored > -1 ? Math.round(amountStored) + "\n" + Math.round(maxAmountStored): Math.round(amountStored)
                    font: Qt.font({
                        family: "Roboto",
                        pixelSize: 20,
                        bold: true,
                        capitalization: Font.AllUppercase
                    });
                    color: "white"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // We're not using the title box here, since we want a button that goes outside of the regular content
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
                    id: title
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

                ScrollView
                {
                    id: content
                    // Since we have to do some manual magic to get the scroll animation working with the manual buttons
                    // We need to do some bookkeeping ourselves.
                    property bool animationState: false

                    // Same as with the animstate, we need to manually create the animation object. We unfortunately cant use
                    // "Behavior on", since the contentItem doesn't exist on init of the scrollview
                    function setContentPosition(new_pos)
                    {
                        if(animationState)
                        {
                            return  // Previous animation is still running.
                        }
                        var anim = Qt.createQmlObject ('import QtQuick 2.3; PropertyAnimation { }', content);
                        anim.target = content.contentItem
                        anim.property = "contentX"
                        anim.from = content.contentItem.contentX
                        anim.to = Math.max(Math.min(content.contentWidth - content.availableWidth, new_pos), 0)
                        anim.duration = 200
                        animationState = Qt.binding(function() { return anim.running })
                        anim.restart();
                    }

                    anchors
                    {
                        top: title.bottom
                        left: parent.left
                        leftMargin: 2
                        right: addButton.left
                        bottom: parent.bottom
                        bottomMargin: 2
                        rightMargin: 2
                    }
                    clip: true
                    Row
                    {
                        spacing: defaultSpacing
                        width: parent.width - 2
                        height: parent.height - 1
                        x: 1
                        y: 1

                        Repeater
                        {
                            model: controller.modifiers

                            delegate: Modifier
                            {
                                name: modelData.name
                                abbreviation: modelData.abbreviation
                                duration: modelData.duration
                                width: 28 // Hack: For some reason the binding fails here...
                                height: 28
                            }
                        }
                    }
                }

                Button
                {
                    id: addButton
                    anchors
                    {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                        margins: defaultSpacing + 1
                        topMargin: 12
                    }
                    width: 10
                    background: CutoffRectangle
                    {
                        color: "white"
                        angleSize: 3
                        cornerSide: CutoffRectangle.Direction.Right
                        Text
                        {
                            font: resourceFont
                            text: "+"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                            width: parent.width
                        }
                        onHeightChanged: recalculatePoints() // Hack to ensure update is called correctly
                    }
                    contentItem: Item{}
                    onClicked: base.addModifierClicked(controller.id)
                }

                Button
                {
                    id: leftButton
                    width: 10
                    height: 10
                    anchors
                    {
                        left: parent.left
                        leftMargin: -defaultSpacing - 1
                        top: parent.top
                    }
                    background: Item {}
                    contentItem: Text
                    {
                        opacity: enabled ? 1.0 : 0.3
                        text: "<"
                        Behavior on opacity { NumberAnimation { duration: 150} }
                        color: "white"
                        font.weight: Font.Bold
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: content.setContentPosition(content.contentItem.contentX - content.availableWidth)
                    visible: content.availableWidth < content.contentWidth
                    enabled: content.contentItem.contentX > content.contentItem.originX
                }

                Button
                {
                    id: rightButton
                    width: 10
                    height: 10
                    anchors
                    {
                        right: parent.right
                        rightMargin: defaultSpacing + 1
                        top: parent.top
                    }
                    background: Item {}
                    contentItem: Text
                    {
                        opacity: enabled ? 1.0 : 0.3
                        text: ">"
                        Behavior on opacity { NumberAnimation { duration: 150} }
                        color: "white"
                        font.weight: Font.Bold
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: content.setContentPosition(content.contentItem.contentX + content.availableWidth)
                    enabled: content.contentWidth > content.contentItem.contentX + content.availableWidth
                    visible: content.availableWidth < content.contentWidth
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

            ProgressBar
            {
                id: healthProgressBar
                property alias progressColor: progressItem.color
                anchors
                {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    left: parent.left
                    leftMargin: 10
                    rightMargin: 10
                    topMargin: 2
                    bottomMargin: 2
                }
                value: controller.health / 100
                background: Rectangle
                {
                    implicitWidth: 200
                    implicitHeight: 6
                    color: "#333333"
                }
                contentItem: Item
                {
                    implicitWidth: 200
                    implicitHeight: 4

                    Rectangle
                    {
                        id: progressItem
                        width: healthProgressBar.visualPosition * parent.width
                        height: parent.height
                        color: "#17a81a"
                    }
                }

                SequentialAnimation
                {
                    id: warningAnimation
                    running: modelData.health < 25
                    PropertyAnimation { to: "red"; duration: 1500; target: healthProgressBar; property: "progressColor"; easing.type: Easing.InOutCubic}
                    PropertyAnimation { to: "#17a81a"; duration: 1500; target: healthProgressBar; property: "progressColor"; easing.type: Easing.InOutCubic}
                    loops: Animation.Infinite
                    alwaysRunToEnd: true
                }
            }
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
            id: recvColumn
            anchors.fill: parent
            spacing: defaultSpacing
            anchors.topMargin: defaultSpacing
            anchors.bottomMargin: receivedResourcesBar.angleSize
            anchors.leftMargin: defaultSpacing + 1
            anchors.rightMargin: defaultSpacing
            Text
            {
                text: "RECV"
                font: resourceFont
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.right: parent.right
            }
            Rectangle
            {
                height: 1
                color: "white"
                width: parent.width + 2 * defaultSpacing
                x: -defaultSpacing
            }
            Instantiator
            {
                model: controller.resourcesReceived
                onObjectAdded:
                {
                    object.parent = recvColumn
                    object.opacity = 1 // Force the animation
                    object.width = recvColumn.width
                    object.height = recvColumn.width
                }
                onObjectRemoved: object.parent = null
                asynchronous: true
                delegate: ResourceIndicator
                {
                    type: modelData.type
                    value: modelData.value
                    opacity: 0
                    Behavior on opacity { NumberAnimation { duration: 1000; easing.type: Easing.InOutCubic } }
                    width: recvColumn.width
                    height: recvColumn.width
                }
            }
        }
    }
    CutoffRectangle
    {
        id: producedResourcesBar
        anchors
        {
            left: parent.right
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
            id: producedColumn
            anchors.fill: parent
            spacing: defaultSpacing
            anchors.topMargin: defaultSpacing
            anchors.bottomMargin: producedResourcesBar.angleSize
            anchors.leftMargin: defaultSpacing + 1
            anchors.rightMargin: defaultSpacing
            Text
            {
                text: "PROD"
                font: resourceFont
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.right: parent.right
            }
            Rectangle
            {
                height: 1
                color: "white"
                width: parent.width + 2 * defaultSpacing
                x: -defaultSpacing
            }
            Instantiator
            {
                model: controller.resourcesProduced
                onObjectAdded:
                {
                    object.parent = producedColumn
                    object.opacity = 1 // Force the animation
                    object.width = producedColumn.width
                    object.height = producedColumn.width
                }
                onObjectRemoved: object.parent = null
                asynchronous: true
                delegate: ResourceIndicator
                {
                    type: modelData.type
                    value: modelData.value
                    opacity: 0
                    Behavior on opacity { NumberAnimation { duration: 1000; easing.type: Easing.InOutCubic } }
                    width: producedColumn.width
                    height: producedColumn.width
                }
            }
        }
    }
}
