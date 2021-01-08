import QtQuick 2.0
import QtQuick.Controls 2.0
CutoffRectangle
{
    id: addModifierWindow
    property string nodeId: ""
    property var nodeObject
    visible: false

    signal modifierAdded(string nodeId, string type)

    ListModel {
        id: modifierModel

        ListElement { name: "BOC"; type: "BoostCoolingModifier" }
        ListElement { name: "ODS"; type: "OverrideDefaultSafetyControlsModifier"}
        ListElement { name: "ROT"; type: "RepairOverTimeModifier" }
        ListElement { name: "JUG"; type: "JuryRigModifier" }

    }

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
            model: nodeObject.supported_modifiers

            Button
            {
                text: modelData
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