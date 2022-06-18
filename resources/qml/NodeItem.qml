import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQml 2.2
import SDK 1.0


Control
{
    id: base

    property alias titleText: titleTextLabel.text
    implicitWidth: 140
    implicitHeight: 180
    property int titleBarHeight: 32
    property int cornerRadius: 10
    property int borderSize: 2
    property int defaultMargin: 8
    property int iconSize: 16
    property color backgroundColor: "#050732"
    property color textColor: backgroundColor
    property color iconColor: textColor
    property string viewMode: "Overview"
    property alias content: contentHolder.children

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

        // Default color!
        return "white"

    }

    function interpolateColor(ratio, low_color, high_color) {

        return Qt.rgba(
             high_color.r * (1 - ratio) + low_color.r * ratio,
             high_color.g * (1 - ratio) + low_color.g * ratio,
             high_color.b * (1 - ratio) + low_color.b * ratio
        );
    }


    // Since we've placed the title bar in the background, the content item needs to leave that open
    topPadding: titleBarHeight + padding
    padding: borderSize + defaultMargin
    signal clicked()

    contentItem: Item
    {
        StatusIcon
        {
            anchors.right: parent.right
        }
        Item
        {
            id: contentHolder
            anchors.fill: parent
        }
    }

    MouseArea
    {
        anchors.fill: parent
        onClicked: base.clicked()
    }

    background: Rectangle
    {
        radius: base.cornerRadius
        color: base.backgroundColor
        border.width: base.borderSize
        border.color: base.nodeColor

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
                    bottomMargin: base.defaultmargin
                    margins: base.defaultMargin + base.borderSize
                }

                // TODO: Ensure that this actually is an image and not a rectangle.
                Rectangle
                {
                    id: icon
                    width: base.iconSize
                    height: base.iconSize
                    color: base.iconColor
                }
                Label
                {
                    id: titleTextLabel
                    text: "Not Set"
                    font.family: "Futura Md BT"
                    font.pixelSize: 12
                    color: base.textColor
                    anchors
                    {
                        left: icon.right
                        leftMargin: base.defaultMargin
                    }
                }
            }
        }
    }
}