import QtQuick 2.0
import QtQuick.Controls 2.2

Control
{
    id: base

    implicitWidth: 350
    implicitHeight: 90
    topPadding: 30
    bottomPadding: 30
    leftPadding: 16
    background: Item
    {
        Rectangle
        {
            id: mainBackground

            radius: 5
            color: "#1A1C48"
            height: parent.height
            width: 325
            anchors.bottom: parent.bottom
        }
        Image
        {
            source: "../svg/curved_corner_flipped.svg"
            anchors.horizontalCenter: mainBackground.right

        }
    }
    contentItem: Item
    {
        RecolorImage
        {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            source: "../svg/user.svg"
            width: 18
            height: 18
            color:  "white"
        }

        Label
        {
            id: label
            text: backend.userName
            color: "white"
            font.family: "Futura Md BT"
            font.pixelSize: 18
            anchors.left: icon.right
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
        }

        Button
        {
            width: 18
            height: 18
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            background: RecolorImage
            {
                source: "../svg/logout.svg"
                color:  "white"
            }
            contentItem: Item {}
            onClicked: print("OMGZOMG")
        }
    }
}