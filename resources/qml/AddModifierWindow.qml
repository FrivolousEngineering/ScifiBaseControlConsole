import QtQuick 2.0
import QtQuick.Controls 2.2
Rectangle
{
    id: addModifierWindow
    property string nodeId: ""
    property var nodeObject

    // Graphical properties
    property int titleBarHeight: 32
    property int cornerRadius: 10
    property int borderSize: 2
    property int defaultMargin: 8

    visible: false

    color: "#050732"
    border.width: 2
    border.color: "White"
    radius: 10

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
            margins: addModifierWindow.cornerRadius
        }
        clip: true

        ScrollBar.vertical: ScrollBar { active: true }

        model: nodeObject ? nodeObject.supported_modifiers: null
        currentIndex: 0
        Component.onCompleted: currentItem ? activeModifier = currentItem.modifier: null

        delegate: OurButton
        {
            property var modifier: backend.getModifierByType(modelData)
            text: modifier.name
            width: view.width - 5
            height: visible ? implicitHeight: 0
            onClicked:
            {
                view.currentIndex = index
                activeModifier =  modifier
            }
            visible: backend.accessLevel >= modifier.required_engineering_level
            highlighted: index == view.currentIndex
        }
    }

    OurText
    {
        id: descriptionText
        anchors
        {
            right: parent.right
            rightMargin: cornerRadius
            bottom: parent.bottom
            top: parent.top
            topMargin: addModifierWindow.cornerRadius
        }

        width: parent.width / 2
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
            bottomMargin: addModifierWindow.cornerRadius
            horizontalCenter: parent.horizontalCenter
        }
        OurButton
        {
            id: closeButton
            text: "close"
            width: 55
            onClicked: addModifierWindow.visible = false
        }

        OurButton
        {
            id: apply
            text: "Apply modifier"
            width: 125
            onClicked:
            {
                addModifierWindow.modifierAdded(addModifierWindow.nodeObject.id, activeModifier.type )
                addModifierWindow.visible = false
            }
        }
    }
}
