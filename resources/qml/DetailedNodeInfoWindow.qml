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
    property string custom_description: ""
    Button
    {
        id: closeButton
        text: "X"
        onClicked: showDetailedInfoWindow.visible = false
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.rightMargin: 10
        width: 32
        height: 32
        background: Item {}
        contentItem: Label {
            text: "X"
            font.pointSize: 20
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Column
    {
        anchors
        {
            left: parent.left
            right: parent.right
            margins: 16
            top: closeButton.bottom
        }
        Label
        {
            id: descriptionLabel
            color: "white"
            wrapMode: Text.WordWrap
            anchors
            {
                left: parent.left
                right: parent.right
            }
        }
    }
}