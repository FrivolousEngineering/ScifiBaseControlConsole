import QtQuick.Controls 2.2
import QtQuick 2.0


MouseArea
{
    id: connectionWidget
    property var hovered: false
    onEntered: hovered = true
    onExited: hovered = false
    hoverEnabled: true
    property string text: ""
    property int borderWidth: 1
    property color borderColor: "transparent"
    property alias color: background.color
    property string resourceType: ""
    implicitWidth: 200
    implicitHeight: 50
    Rectangle
    {
        id: background
        anchors.fill: parent
        border.width: borderWidth
        border.color: borderColor
        color: "transparent"
    }
    Text
    {
        id: label
        text: connectionWidget.text + " (" + connectionWidget.resourceType + ")"
        color: "white"
        font.pointSize: 12
        anchors.centerIn: parent
    }
}