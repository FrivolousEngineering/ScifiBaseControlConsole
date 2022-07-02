import QtQuick 2.0
import QtQuick.Controls 2.2

Control
{
    id: base

    implicitWidth: 350
    implicitHeight: 90
    property string activeMode: "Overview"
    background: Item
    {
        Rectangle
        {
            id: mainBackground
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 5
            color: "#1A1C48"
            height: parent.height
            width: 400
            anchors.bottom: parent.bottom
        }
        Image
        {
            source: "../svg/curved_corner_flipped.svg"
            anchors.horizontalCenter: mainBackground.right

        }
    }
}