import QtQuick 2.0
import QtQuick.Controls 2.2

// Custom styled button
Button
{
    id: control
    implicitHeight: 40

    background: Rectangle
    {
        color: "transparent"
        border.width: 2
        border.color: control.checked | control.highlighted ? "#56CCF2": "white"
    }
    contentItem: Item
    {
        Label
        {
            text: control.text
            color: control.checked | control.highlighted ? "#56CCF2": "white"
            font.family: "Futura Md BT"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}