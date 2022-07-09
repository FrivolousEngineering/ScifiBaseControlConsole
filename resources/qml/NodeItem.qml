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

    property color nodeColor:
    {
        if(viewMode == "Overheat")
        {
            if(controller.temperature < controller.max_safe_temperature * 0.8)
            {
                return "white"
            }
            return interpolateColor((controller.temperature - (controller.max_safe_temperature * 0.8)) / (controller.max_safe_temperature * 0.2), Qt.rgba(1,0,0,1), Qt.rgba(1,1,1,1))
        }

        if(viewMode == "Health")
        {
            return interpolateColor(controller.health / 100., Qt.rgba(0,1,0,1), Qt.rgba(1,0,0,1))
        }
        if(viewMode == "Efficiency")
        {
            return interpolateColor(controller.effectiveness_factor, Qt.rgba(1,1,1,1), Qt.rgba(1,0,0,1))
        }

        if(viewMode == "Active")
        {
            if(controller.active)
            {
                return "#00D1FF"
            }
        }
        if(viewMode == "Modifiers")
        {
            if(controller.modifiers.length > 0)
            {
                return "#00D1FF"
            }
        }

        // Default color!
        return "white"
    }

    Behavior on nodeColor { ColorAnimation {duration: 1000} }

    function interpolateColor(ratio, low_color, high_color)
    {
        return Qt.rgba(
             high_color.r * (1 - ratio) + low_color.r * ratio,
             high_color.g * (1 - ratio) + low_color.g * ratio,
             high_color.b * (1 - ratio) + low_color.b * ratio
        );
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
                Label
                {
                    id: titleTextLabel
                    text: "Not Set"
                    font.family: "Futura Md BT"
                    font.pixelSize: 12
                    height: 12
                    color: base.textColor
                    verticalAlignment: Text.AlignVCenter
                    anchors
                    {
                        left: icon.right
                        leftMargin: base.defaultMargin
                        top: parent.top
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

            Behavior on amountStored {
                NumberAnimation {
                    duration: 1250
                    easing.type: Easing.InOutCubic
                }
            }
            Item
            {
                id: storageItem
                anchors.left: parent.left
                anchors.right: parent.right
                height: childrenRect.height
                anchors.verticalCenter: parent.verticalCenter
                Text
                {
                    id: storageText
                    text:"Storage"
                    font.family: "Futura Md BT"
                    font.pixelSize: 12
                    color: "white"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                }
                Text
                {
                    id: amountStoredText
                    text: Math.round(amountStored)
                    font.family: "Futura Md BT"
                    font.pixelSize: 24
                    font.bold: true
                    color: "white"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: storageText.bottom
                    anchors.topMargin: 4
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Text
            {
                visible: maxAmountStored > -1
                text: "/" + maxAmountStored
                font.family: "Futura Md BT"
                font.pixelSize: 16
                color: "white"
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
                } else
                {
                    base.clicked()
                }
            }
        }
    }
}