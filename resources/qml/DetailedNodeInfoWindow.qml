import QtQuick 2.0
import QtQuick.Controls 2.2

Rectangle
{
    id: showDetailedInfoWindow
    color: "#06071E"
    border.width: 2
    border.color: "white"
    radius: 10

    width: 500
    height: 500
    visible: false
    property alias description: descriptionLabel.text
    property alias custom_description: customDescriptionLabel.text
    property alias titleText: titleLabel.text
    property int spacerSize: 10
    property int default_margin: 16
    Button
    {
        id: closeButton
        onClicked: showDetailedInfoWindow.visible = false
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: default_margin
        anchors.rightMargin: default_margin
        width: 32
        height: 32
        background: Item {}
        contentItem: OurLabel {
            text: "X"
            font.pixelSize: 32
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    OurLabel
    {
        id: titleLabel
        font.pixelSize: 24
        font.bold: true
        text: ""
        anchors.top: parent.top
        anchors.topMargin: default_margin
        anchors.leftMargin: default_margin
        anchors.left: parent.left
    }

    Column
    {
        anchors
        {
            left: parent.left
            right: parent.right
            margins: default_margin
            top: closeButton.bottom
        }
        OurLabel
        {
            font.bold: true
            text: "General Description"
        }
        OurLabel
        {
            id: descriptionLabel
            wrapMode: Text.WordWrap
            anchors
            {
                left: parent.left
                right: parent.right
            }
        }
        Item
        {
            width: spacerSize
            height: spacerSize
        }
        OurLabel
        {
            font.bold: true
            text: "Custom Description"
            visible: customDescriptionLabel.text != ""
        }
        OurLabel
        {
            id: customDescriptionLabel
            wrapMode: Text.WordWrap
            anchors
            {
                left: parent.left
                right: parent.right
            }
        }
    }
}