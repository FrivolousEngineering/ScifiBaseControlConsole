import QtQuick 2.0
import QtQuick.Controls 2.2

Rectangle
{
    id: base
    property bool collapsed: true
    property int defaultMargin: 16
    property var activeNode: null
    color: "#06071E"
    width: collapsed ? 0: 350
    height: parent.height
    visible: width != 0
    property int defaultFontSize: 16


    Item
    {
        id: titleBar
        height: childrenRect.height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: base.defaultMargin
        Label
        {
            id: titleLabel
            color: "white"
            font.family: "Futura Md BT"
            font.pixelSize: 32
            text: activeNode.id
            anchors.left: parent.left
            anchors.leftMargin: base.defaultMargin
        }
        Button
        {
            text: "X"
            onClicked: base.collapsed = !collapsed
            anchors.right: parent.right
            anchors.rightMargin: base.defaultMargin
            width: 32
            height: 32
            anchors.verticalCenter: titleLabel.verticalCenter
            background: Item {}
            contentItem: Label {
                text: "X"
                font.pointSize: 20
                opacity: enabled ? 1.0 : 0.3
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle
        {
            anchors.top: titleLabel.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: base.defaultMargin
            width: parent.width / 4 * 3
            height: 1
            color: "#00D1FF"
            opacity: 0.5
        }
    }

    Column
    {
        spacing: 5

        height: 200
        anchors
        {
            top: titleBar.bottom
            topMargin: base.defaultMargin
            left: parent.left
            leftMargin: base.defaultMargin
        }
        Label
        {
            font.family: "Futura Md BT"
            font.pixelSize: 32
            text: "Resources received"
            color: "white"
        }
        Rectangle
        {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width / 4 * 3
            height: 1
            color: "#00D1FF"
            opacity: 0.5
        }

        Repeater
        {
            model: activeNode.resourcesReceived
            delegate: resourceComponent
        }
        Item
        {
            width: 1
            height: base.defaultMargin
        }

        Label
        {
            font.family: "Futura Md BT"
            font.pixelSize: 32
            text: "Resources required"
            color: "white"
        }
        Rectangle
        {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width / 4 * 3
            height: 1
            color: "#00D1FF"
            opacity: 0.5
        }
        Repeater
        {
            model: activeNode.resourcesRequired
            delegate: resourceComponent
        }
        Item
        {
            width: 1
            height: base.defaultMargin
        }
        Label
        {
            font.family: "Futura Md BT"
            font.pixelSize: 32
            text: "Resources produced"
            color: "white"
        }
        Rectangle
        {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width / 4 * 3
            height: 1
            color: "#00D1FF"
            opacity: 0.5
        }
        Repeater
        {
            model: activeNode.resourcesProduced
            delegate: resourceComponent
        }
    }

    Component
    {
        id: resourceComponent
        Item
        {
            width: parent.width
            height: base.defaultFontSize
            Label
            {
                font.family: "Futura Md BT"
                font.pixelSize: base.defaultFontSize
                text: modelData.type
                color: "#56CCF2"
            }
            Label
            {
                font.family: "Futura Md BT"
                font.pixelSize: base.defaultFontSize
                text: modelData.value
                anchors.right: parent.right
                color: "white"
            }
        }
    }
}
