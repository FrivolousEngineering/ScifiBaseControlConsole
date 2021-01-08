import QtQuick 2.0
import QtQuick.Controls 2.0
CutoffRectangle
{
    id: addModifierWindow
    property string nodeId: ""
    visible: false

    Button
    {
        text: "close"
        onClicked: addModifierWindow.visible = false
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 3
        anchors.horizontalCenter: parent.horizontalCenter
    }
}