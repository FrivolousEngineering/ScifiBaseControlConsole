import QtQuick 2.0
import QtQuick.Controls 2.0
CutoffRectangle
{
    id: addModifierWindow
    property string nodeId: ""
    property var nodeObject
    visible: false

    signal modifierAdded(string nodeId, string type)

    Column
    {
        spacing: 2
        anchors
        {
            top: parent.top
            bottom: closeButton.top
            left: parent.left
            right: parent.right
            margins: addModifierWindow.angleSize
            bottomMargin: 3
        }
        Repeater
        {
            model: nodeObject ? nodeObject.supported_modifiers: null
            Button
            {
                text: backend.getModifierByType(modelData).name
                onClicked:
                {
                    addModifierWindow.modifierAdded(addModifierWindow.nodeObject.id, modelData)
                    addModifierWindow.visible = false
                }
            }
        }
    }

    Button
    {
        id: closeButton
        text: "close"
        onClicked: addModifierWindow.visible = false
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 3
        anchors.horizontalCenter: parent.horizontalCenter
    }
}