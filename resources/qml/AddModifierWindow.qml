import QtQuick 2.0
import QtQuick.Controls 2.2
CutoffRectangle
{
    id: addModifierWindow
    property string nodeId: ""
    property var nodeObject
    visible: false

    signal modifierAdded(string nodeId, string type)
    property var activeModifier: backend.getModifierByType(view.model[0])
    ListView
    {
        id: view
        spacing: 2
        focus: true

        anchors
        {
            top: parent.top
            bottom: buttonBar.top
            left: parent.left
            right: descriptionText.left
            margins: addModifierWindow.angleSize
            bottomMargin: 3
        }
        clip: true

        ScrollBar.vertical: ScrollBar {
            active: true
        }

        model: nodeObject ? nodeObject.supported_modifiers: null
        currentIndex: 0
        Component.onCompleted: activeModifier = currentItem.modifier

        delegate: Button
        {
            property var modifier: backend.getModifierByType(modelData)
            text: modifier.name
            onClicked:
            {
                view.currentIndex = index
                activeModifier =  modifier
            }
            highlighted: index == view.currentIndex
        }
    }

    Text
    {
        id: descriptionText
        anchors.right: parent.right
        anchors.rightMargin: 2
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.topMargin: addModifierWindow.angleSize
        width: 125
        color: "white"
        text: activeModifier ? activeModifier.description: ""
        wrapMode: Text.WordWrap
    }

    Row
    {
        id: buttonBar
        spacing: 2
        anchors
        {
            bottom: parent.bottom
            bottomMargin: 3
            horizontalCenter: parent.horizontalCenter
        }
        Button
        {
            id: closeButton
            text: "close"
            onClicked: addModifierWindow.visible = false
        }

        Button
        {
            id: apply
            text: "Apply modifier"
            onClicked:
            {
                addModifierWindow.modifierAdded(addModifierWindow.nodeObject.id, activeModifier.type )
                addModifierWindow.visible = false
            }
        }
    }
}
