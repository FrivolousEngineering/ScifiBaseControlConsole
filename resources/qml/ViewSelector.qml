import QtQuick 2.0
import QtQuick.Controls 2.2


Control
{
    id: base

    implicitWidth: 1024
    implicitHeight: 90
    property string activeMode: "Overview"
    background: Item
    {
        Rectangle
        {
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 5
            color: "#1A1C48"
            height: parent.height
            width: 250
            anchors.bottom: parent.bottom
        }

        Rectangle
        {
            // The bottom bar that is always there. Doesn't do anything
            id: bottomBar
            color: "#1A1C48"
            height: 16
            width: parent.width
            anchors.bottom: parent.bottom
        }
    }
    contentItem: Item
    {
        anchors.bottom: parent.bottom
        Row
        {
            anchors.horizontalCenter: parent.horizontalCenter
            ButtonGroup
            {
                id: modeGroup
                onClicked: activeMode = button.text
            }
            Button
            {
                text: "Overview"
                ButtonGroup.group: modeGroup
                checkable: true
                checked: true
            }
            Button
            {
                text: "Overheat"
                ButtonGroup.group: modeGroup
                checkable: true
            }
        }
    }
}