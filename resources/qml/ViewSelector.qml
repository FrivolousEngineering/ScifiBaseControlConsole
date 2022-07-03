import QtQuick 2.0
import QtQuick.Controls 2.2


Control
{
    id: base

    implicitWidth: 1024
    implicitHeight: 95
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
            source: "../svg/curved_corner.svg"
            anchors.horizontalCenter: mainBackground.left
        }
        Image
        {
            source: "../svg/curved_corner.svg"
            anchors.horizontalCenter: mainBackground.right
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
        Row
        {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 18
            spacing: 18
            ButtonGroup
            {
                id: modeGroup
                onClicked: activeMode = button.text
            }
            ViewSelectorButton
            {
                text: "Overview"
                ButtonGroup.group: modeGroup
                iconSource: "../svg/overview.svg"
                checkable: true
                checked: true
            }
            ViewSelectorButton
            {
                text: "Overheat"
                ButtonGroup.group: modeGroup
                iconSource: "../svg/warning.svg"
                checkable: true
            }
            ViewSelectorButton
            {
                text: "Health"
                ButtonGroup.group: modeGroup
                iconSource: "../svg/wrench.svg"
                checkable: true
            }
            ViewSelectorButton
            {
                text: "Efficiency"
                ButtonGroup.group: modeGroup
                iconSource: "../svg/gear.svg"
                checkable: true
            }
            ViewSelectorButton
            {
                text: "Active"
                ButtonGroup.group: modeGroup
                iconSource: "../svg/power.svg"
                checkable: true
            }
        }
    }
}