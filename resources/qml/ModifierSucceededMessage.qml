import QtQuick 2.0
import QtQuick.Controls 2.2


Rectangle
{
    id: modifierSucceededMessage
    color: "#06071E"
    border.width: 2
    border.color: "white"
    radius: 10
    Connections
    {
        target: backend
        onShowModifierSucceededMessage:
        {
            modifierSucceededMessage.visible = true
            timeoutTimer.restart()
        }
    }

    Timer
    {
        id: timeoutTimer
        interval: 5000
        running: false
        onTriggered: modifierSucceededMessage.visible = false
    }
    visible: false
    width: 550
    height: 250
    anchors.centerIn: parent
    Button
    {
        id: closeButton
        onClicked: modifierSucceededMessage.visible = false
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.rightMargin: 10
        width: 32
        height: 32
        background: Item {}
        contentItem: OurLabel {
            text: "X"
            font.pixelSize: 32
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    OurLabel
    {
        anchors.centerIn: parent
        font.pixelSize: 24
        text: "Modifier has been placed."
    }
}