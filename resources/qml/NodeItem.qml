import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQml 2.2
import SDK 1.0


Control
{
    id: base

    signal clicked()

    property alias titleText: titleTextLabel.text
    property alias content: contentHolder.children
    property alias iconSource: icon.source

    property int titleBarHeight: 32
    property int cornerRadius: 10
    property int borderSize: 2
    property int defaultMargin: 8
    property int iconSize: 16
    property color backgroundColor: "#050732"
    property color textColor: backgroundColor
    property color iconColor: textColor
    property string viewMode: "Overview"


    property var controller: null

    states: [
        State
        {
            id: overheatState
            name: "Overheat"
            when: viewMode == "Overheat"
            property real current_temp: Math.round(controller.historyData["temperature"][controller.historyData["temperature"].length - 1] * 100) / 100
            property real previous_temp: Math.round(controller.historyData["temperature"][controller.historyData["temperature"].length - 2] * 100) / 100
            property real no_show_range: 0.1
            PropertyChanges
            {
                target: base
                nodeColor:
                {
                    if(controller.temperature < controller.max_safe_temperature * 0.8)
                    {
                        return "white"
                    }
                    return interpolateColor((controller.temperature - (controller.max_safe_temperature * 0.8)) / (controller.max_safe_temperature * 0.2), Qt.rgba(1,0,0,1), Qt.rgba(1,1,1,1))
                }
            }
            PropertyChanges
            {
                target: statusIcon
                visible: true
                state:
                {
                    if(overheatState.current_temp + overheatState.no_show_range > overheatState.previous_temp && overheatState.current_temp - overheatState.no_show_range < overheatState.previous_temp)
                    {
                        return "neutral"
                    }
                    if (overheatState.current_temp > overheatState.previous_temp)
                    {
                        return "up"
                    }
                    return "down"
                }
            }
        },
        State
        {
            name: "Health"
            when: viewMode == "Health"

            PropertyChanges
            {
                target: base
                nodeColor: interpolateColor(controller.health / 100., Qt.rgba(0,1,0,1), Qt.rgba(1,0,0,1))
            }
            PropertyChanges
            {
                target: statusIcon
                visible: true
                upColor: statusIcon.greenColor
                downColor: statusIcon.redColor
                state:
                {
                    var current_health = Math.round(controller.historyData["health"][controller.historyData["health"].length - 1] * 100) / 100
                    var previous_health = Math.round(controller.historyData["health"][controller.historyData["health"].length - 2] * 100) / 100
                    if(current_health == previous_health)
                    {
                        return "neutral"
                    }
                    if (current_health > previous_health)
                    {
                        return "up"
                    }
                    return "down"
                }
            }
        },
        State
        {
            name: "Efficiency"
            when: viewMode == "Efficiency"

            PropertyChanges
            {
                target: base
                nodeColor: interpolateColor(controller.effectiveness_factor, Qt.rgba(1,1,1,1), Qt.rgba(1,0,0,1))
            }
        },
        State
        {
            name: "Active"
            when: viewMode == "Active"

            PropertyChanges
            {
                target: base
                nodeColor: controller.active ? "#00D1FF" : defaultNodeColor
            }
        },
        State
        {
            name: "Modifiers"
            when: viewMode == "Modifiers"

            PropertyChanges
            {
                target: base
                nodeColor: controller.modifiers.length > 0 ? "#00D1FF" : defaultNodeColor
            }
        }
    ]

    property color nodeColor: defaultNodeColor
    readonly property color defaultNodeColor: "white"

    Behavior on nodeColor { ColorAnimation {duration: 1000} }

    function interpolateColor(ratio, low_color, high_color)
    {
        return Qt.rgba(
             high_color.r * (1 - ratio) + low_color.r * ratio,
             high_color.g * (1 - ratio) + low_color.g * ratio,
             high_color.b * (1 - ratio) + low_color.b * ratio
        )
    }

    implicitWidth: 140
    implicitHeight: 180

    // Since we've placed the title bar in the background, the content item needs to leave that open
    topPadding: titleBarHeight + padding
    padding: borderSize + defaultMargin

    contentItem: Item
    {
        StatusIcon
        {
            id: statusIcon
            anchors.right: parent.right
            visible: false
        }
        Item
        {
            id: contentHolder
            anchors.fill: parent
        }
        Loader
        {
            id: contentLoader
            anchors.fill: parent
            sourceComponent:
            {
                if(controller.hasSettablePerformance)
                {
                    return performanceNode
                }
                if("amount_stored" in controller.additionalProperties)
                {
                    return storageNode
                }
                if(controller.node_type == "Lights")
                    return lightsNode
            }
        }
    }

    background: Rectangle
    {
        radius: base.cornerRadius
        color: base.backgroundColor
        border.width: base.borderSize
        border.color: base.nodeColor
        MouseArea
        {
            anchors.fill: parent
            onClicked: base.clicked()
        }

        Rectangle
        {
            id: titleBarBackground
            anchors
            {
                left: parent.left
                right: parent.right
            }
            height: base.titleBarHeight + base.borderSize
            radius: base.cornerRadius
            color: base.nodeColor

            Rectangle
            {
                // This is the rectangle that ensures that the border doesn't have a radius.
                id: bottomCornerCover
                anchors
                {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: base.cornerRadius
                color: parent.color
            }

            Item
            {
                anchors
                {
                    fill: parent
                    margins: base.defaultMargin
                }

                RecolorImage
                {
                    id: icon
                    width: base.iconSize
                    height: base.iconSize
                    color: base.iconColor
                    sourceSize.width: 4 * width
                    sourceSize.height: 4 * width
                    source:
                    {
                        // I knowwwwwww. It's horrible code.
                        // But I really can't be arsed to fix this now.
                        if(controller.id == "fuel_storage")
                        {
                            return "../svg/jerrycan.svg"
                        }
                        if(controller.id.includes("battery"))
                        {
                            return "../svg/battery.svg"
                        }
                        if(controller.id.includes("valve"))
                        {
                            return "../svg/valve.svg"
                        }
                        return "../svg/node.svg"
                    }
                }
                OurLabel
                {
                    id: titleTextLabel
                    text: "Not Set"
                    font.pixelSize: 12
                    height: 12
                    color: base.textColor
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    anchors
                    {
                        left: icon.right
                        leftMargin: base.defaultMargin
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                }
            }
        }
    }

    Component
    {
        id: storageNode
        Item
        {
            property double amountStored: controller.additionalProperties["amount_stored"]["value"]
            property double maxAmountStored: controller.additionalProperties["amount_stored"]["max_value"]

            Behavior on amountStored
            {
                NumberAnimation
                {
                    duration: 1250
                    easing.type: Easing.InOutCubic
                }
            }
            RecolorImage
            {
                id: warningIcon
                source: "../svg/warning.svg"

                states: [
                    State
                    {
                        name: "critical"
                        when: maxAmountStored != -1 && amountStored < maxAmountStored * 0.1
                        PropertyChanges
                        {
                            target: warningIcon
                            visible: true
                        }
                        PropertyChanges { target: warningAnimation; running: true; }
                    },
                    State
                    {
                        name: "warning"
                        when: maxAmountStored != -1 && amountStored < maxAmountStored * 0.2
                        PropertyChanges
                        {
                            target: warningIcon
                            color: "yellow"
                            visible: true
                        }
                    }
                ]
                SequentialAnimation {
                    id: warningAnimation
                    running: false
                    PropertyAnimation { to: "red"; duration: 750; target: warningIcon; property: "color"; easing.type: Easing.InOutCubic}
                    PropertyAnimation { to: "#505050"; duration: 750; target: warningIcon; property: "color"; easing.type: Easing.InOutCubic}
                    loops: Animation.Infinite
                }

                visible: false

                width: 32
                height: 32
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: storageItem.top
                anchors.bottomMargin: base.defaultMargin
                sourceSize.width: 4 * width
                sourceSize.height: 4 * width
            }
            Item
            {
                id: storageItem
                anchors.left: parent.left
                anchors.right: parent.right
                height: childrenRect.height
                anchors.verticalCenter: parent.verticalCenter
                OurText
                {
                    id: storageText
                    text: "Storage"
                    font.pixelSize: 12
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                }
                OurText
                {
                    id: amountStoredText
                    text: Math.round(amountStored)
                    font.pixelSize: 22
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: storageText.bottom
                    width: contentWidth
                    height: contentHeight
                    anchors.topMargin: 4
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            OurText
            {
                visible: maxAmountStored > -1
                text: "/" + maxAmountStored
                opacity: 0.5
                horizontalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: storageItem.bottom
                anchors.topMargin: 8
            }
        }
    }

    Component
    {
        id: lightsNode
        Item
        {
            Item
            {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                height: childrenRect.height
                OurText
                {
                    id: statusText
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: "status"
                    font.pixelSize: 12
                }
                OurText
                {
                    id: amountStoredText
                    text: controller.active ? "ON" : "OFF"
                    font.pixelSize: 22
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: statusText.bottom
                    width: contentWidth
                    height: contentHeight
                    anchors.topMargin: 4
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

    }

    Component
    {
        id: performanceNode
        CustomDial
        {
            id: performanceDial
            anchors
            {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            height: width

            from: controller.min_performance
            to: controller.max_performance

            Behavior on currentValue
            {
                NumberAnimation
                {
                    duration: 1000
                    easing.type: Easing.InOutCubic
                }
            }

            Behavior on targetValue
            {
                NumberAnimation
                {
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

            onPressedChanged: pressed ? base.clicked(): controller.setPerformance(value)
        }
    }
}