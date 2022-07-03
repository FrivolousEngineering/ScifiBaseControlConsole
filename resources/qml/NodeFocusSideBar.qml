import QtQuick 2.0
import QtQuick.Controls 2.2

Rectangle
{
    id: base
    property bool collapsed: true
    property int defaultMargin: 16
    property var activeNode: null
    color: "#06071E"
    width: 350

    property real collapseMove: collapsed ? -width : 0
    anchors.rightMargin: collapseMove
    Behavior on collapseMove { NumberAnimation {duration: 200}}
    height: parent.height
    visible: collapseMove > -width
    property int defaultFontSize: 16
    property int largeFontSize: 24

    signal addModifierClicked()
    signal showGraphs()
    signal showDetailedInfoClicked()

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
            text: activeNode.label
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
            right: parent.right
            rightMargin: base.defaultMargin
        }

        Item
        {
            width: parent.width
            height: base.largeFontSize
            Label
            {
                font.family: "Futura Md BT"
                font.pixelSize: base.largeFontSize
                text: "Health"
                color: "#56CCF2"
            }
            Label
            {
                font.family: "Futura Md BT"
                font.pixelSize: base.largeFontSize
                text: Math.round(activeNode.health * 100) / 100
                anchors.right: parent.right
                color: "white"
            }
        }
        Item
        {
            width: parent.width
            height: base.largeFontSize
            Label
            {
                font.family: "Futura Md BT"
                font.pixelSize: base.largeFontSize
                text: "Temperature"
                color: "#56CCF2"
            }
            Label
            {
                font.family: "Futura Md BT"
                font.pixelSize: base.largeFontSize
                text: Math.round(activeNode.temperature * 100) / 100
                anchors.right: parent.right
                color: "white"
            }
        }
        Item
        {
            width: 1
            height: base.defaultMargin
        }

        Label
        {
            font.family: "Futura Md BT"
            font.pixelSize: 18
            text: "Resources received"
            color: "white"
            visible: resourcesReceivedRepeater.count
        }
        Rectangle
        {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width / 4 * 3
            height: 1
            color: "#00D1FF"
            opacity: 0.5
            visible: resourcesReceivedRepeater.count
        }

        Repeater
        {
            id: resourcesReceivedRepeater
            model: activeNode.resourcesReceived
            delegate: resourceComponent
        }
        Item
        {
            width: 1
            height: base.defaultMargin
            visible: resourcesRequiredRepeater.count
        }

        Label
        {
            font.family: "Futura Md BT"
            font.pixelSize: 18
            text: "Resources required"
            color: "white"
            visible: resourcesRequiredRepeater.count
        }
        Rectangle
        {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width / 4 * 3
            height: 1
            color: "#00D1FF"
            opacity: 0.5
            visible: resourcesRequiredRepeater.count
        }
        Repeater
        {
            id: resourcesRequiredRepeater
            model: activeNode.resourcesRequired
            delegate: resourceComponent
        }
        Item
        {
            width: 1
            height: base.defaultMargin
            visible: resourcesProducedRepeater.count
        }
        Label
        {
            font.family: "Futura Md BT"
            font.pixelSize: 18
            text: "Resources produced"
            color: "white"
            visible: resourcesProducedRepeater.count
        }
        Rectangle
        {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width / 4 * 3
            height: 1
            color: "#00D1FF"
            opacity: 0.5
            visible: resourcesProducedRepeater.count
        }
        Repeater
        {
            id: resourcesProducedRepeater
            model: activeNode.resourcesProduced
            delegate: resourceComponent
        }
        Item
        {
            width: 1
            height: base.defaultMargin
        }
        Button
        {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 62
            background: Rectangle
            {
                border.width: 2
                border.color: "white"
                color: "transparent"
            }
            onClicked: base.addModifierClicked()
            contentItem: Item
            {
                Image
                {
                    source: "../svg/plus.svg"
                    width: sourceSize.width
                    height: sourceSize.height
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: base.defaultMargin
                }
                Label
                {
                    font.family: "Futura Md BT"
                    font.pixelSize: 32
                    color: "white"
                    text: "Modifier"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        Button
        {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 62
            background: Rectangle
            {
                border.width: 2
                border.color: "white"
                color: "transparent"
            }
            onClicked: base.showGraphs()
            contentItem: Item
            {
                Label
                {
                    font.family: "Futura Md BT"
                    font.pixelSize: 32
                    color: "white"
                    text: "See History"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        Button
        {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 62
            background: Rectangle
            {
                border.width: 2
                border.color: "white"
                color: "transparent"
            }
            onClicked: base.showDetailedInfoClicked()
            contentItem: Item
            {
                Label
                {
                    font.family: "Futura Md BT"
                    font.pixelSize: 32
                    color: "white"
                    text: "More Info"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
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
                text: Math.round(modelData.value * 100) / 100
                anchors.right: parent.right
                color: "white"
            }
        }
    }
}
