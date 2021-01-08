import QtQuick 2.0
import QtQuick.Controls 2.0
CutoffRectangle
{
    id: addModifierWindow
    property string nodeId: ""
    visible: false

    signal modifierAdded(string nodeId, string type)

    ListModel {
        id: modifierModel

        ListElement { name: "BOC"; type: "BoostCoolingModifier" }
        ListElement { name: "ODS"; type: "OverrideDefaultSafetyControlsModifier"}
        ListElement { name: "ROT"; type: "RepairOverTimeModifier" }
        ListElement { name: "JUG"; type: "JuryRigModifier" }

    }

    Grid
    {
        anchors
        {
            top: parent.top
            bottom: closeButton.top
            left: parent.left
            right: parent.right
            margins: 3
        }
        columns: 2
        Repeater
        {
            model: modifierModel

            Button
            {
                text: model.name
                onClicked:
                {
                    addModifierWindow.modifierAdded(addModifierWindow.nodeId, model.type)
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