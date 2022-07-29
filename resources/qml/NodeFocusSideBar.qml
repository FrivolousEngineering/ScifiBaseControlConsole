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
    property bool showModifierButton: false

    signal addModifierClicked()
    signal showGraphs()
    signal showDetailedInfoClicked()

    Item
    {
        id: titleBar
        height: childrenRect.height
        anchors
        {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: base.defaultMargin
        }
        OurLabel
        {
            id: titleLabel
            font.pixelSize: 32
            text: activeNode ? activeNode.label: ""
            anchors.left: parent.left
            anchors.leftMargin: base.defaultMargin
        }
        Button
        {
            onClicked: base.collapsed = !collapsed
            anchors.right: parent.right
            anchors.rightMargin: base.defaultMargin
            width: 32
            height: 32
            anchors.verticalCenter: titleLabel.verticalCenter
            background: Item {}
            contentItem: OurLabel {
                text: "X"
                font.pixelSize: 32
                opacity: enabled ? 1.0 : 0.3
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
            OurLabel
            {
                font.pixelSize: base.largeFontSize
                text: "Health"
                color: "#56CCF2"
            }
            OurLabel
            {
                font.pixelSize: base.largeFontSize
                text: activeNode ? Math.round(activeNode.health * 100) / 100: 100
                anchors.right: parent.right
            }
        }
        Item
        {
            width: parent.width
            height: base.largeFontSize
            OurLabel
            {
                font.pixelSize: base.largeFontSize
                text: "Temperature"
                color: "#56CCF2"
            }
            OurLabel
            {
                font.pixelSize: base.largeFontSize
                text: activeNode ? Math.round(activeNode.temperature * 100) / 100: 20
                anchors.right: parent.right
            }
        }
        Item
        {
            width: 1
            height: base.defaultMargin
        }

        OurLabel
        {
            font.pixelSize: 18
            text: "Resources received"
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
            model: activeNode ? activeNode.resourcesReceived: null
            delegate: resourceComponent
        }
        Item
        {
            width: 1
            height: base.defaultMargin
            visible: resourcesRequiredRepeater.count
        }

        OurLabel
        {
            font.pixelSize: 18
            text: "Resources required"
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
            model: activeNode ? activeNode.resourcesRequired: null
            delegate: resourceComponent
        }
        Item
        {
            width: 1
            height: base.defaultMargin
            visible: resourcesProducedRepeater.count
        }
        OurLabel
        {
            font.pixelSize: 18
            text: "Resources produced"
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
            model: activeNode ? activeNode.resourcesProduced: null
            delegate: resourceComponent
        }
        Item
        {
            width: 1
            height: base.defaultMargin
        }

        OurLabel
        {
            font.pixelSize: 18
            text: "Resources provided"
            color: "white"
            visible: resourcesProvidedRepeater.count
        }
        Rectangle
        {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width / 4 * 3
            height: 1
            color: "#00D1FF"
            opacity: 0.5
            visible: resourcesProvidedRepeater.count
        }
        Repeater
        {
            id: resourcesProvidedRepeater
            model: activeNode ? activeNode.resourcesProvided: null
            delegate: resourceComponent
        }
        Item
        {
            width: 1
            height: base.defaultMargin
            visible: resourcesProvidedRepeater.count
        }

        OurLabel
        {
            font.pixelSize: 18
            text: "Modifiers"
            visible: modifiersRepeater.count
        }
        Rectangle
        {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width / 4 * 3
            height: 1
            color: "#00D1FF"
            opacity: 0.5
            visible: modifiersRepeater.count
        }

        Repeater
        {
            id: modifiersRepeater
            model: activeNode ? activeNode.modifiers: null
            delegate: modifierComponent
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
            visible: base.showModifierButton
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
                OurLabel
                {
                    font.pixelSize: 32
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
                RecolorImage
                {
                    source: "../svg/history.svg"
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: base.defaultMargin
                }
                OurLabel
                {
                    font.pixelSize: 32
                    text: "History"
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
                RecolorImage
                {
                    source: "../svg/info.svg"
                    width: 38
                    height: 38
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: base.defaultMargin
                }
                OurLabel
                {
                    font.pixelSize: 32
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
            OurLabel
            {
                text: modelData.type
                color: "#56CCF2"
            }
            OurLabel
            {
                text: Math.round(modelData.value * 100) / 100
                anchors.right: parent.right
            }
        }
    }
    Component
    {
        id: modifierComponent
        Item
        {
            width: parent.width
            height: base.defaultFontSize
            OurLabel
            {
                text: modelData.name
                color: "#56CCF2"
            }
            OurLabel
            {
                text: modelData.duration
                anchors.right: parent.right
            }
        }
    }
}
