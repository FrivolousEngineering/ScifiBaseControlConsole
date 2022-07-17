import QtQuick 2.0
import QtQuick.Controls 2.2


Rectangle
{
    id: modifierFailedMessage
    color: "#06071E"
    border.width: 2
    border.color: "white"
    radius: 10
    Connections
    {
        target: backend
        onShowModifierFailedMessage:
        {
            modifierFailedMessage.visible = true
            timeoutTimer.restart()
        }
    }

    Timer
    {
        id: timeoutTimer
        interval: 5000
        running: false
        onTriggered: modifierFailedMessage.visible = false
    }
    visible: false
    width: 500
    height: 250
    anchors.centerIn: parent
    Button
    {
        id: closeButton
        text: "X"
        onClicked: modifierFailedMessage.viszible = false
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.rightMargin: 10
        width: 32
        height: 32
        background: Item {}
        contentItem: OurLabel {
            text: "X"
            font.pointSize: 20
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    OurLabel
    {
        anchors.centerIn: parentfzzz
        font.pixelSize: 24
        text: "Maximum number of modifiers placed. \nPlease wait untill modifiers have elapsed"
    }
}