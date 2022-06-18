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

    property alias content: contentHolder.children

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
        border.color: "white"

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