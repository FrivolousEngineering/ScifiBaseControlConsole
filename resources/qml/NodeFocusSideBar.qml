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
    property int buttonSize: 40

    signal addModifierClicked()
    signal showGraphs()
    signal showDetailedInfoClicked()

    MouseArea
    {
        anchors.fill: parent
    }
    ScrollView
    {
        height: parent.height
        width: base.width - 2 * base.defaultMargin
        anchors.left: parent.left
        anchors.leftMargin: base.defaultMargin

        Column
        {
            spacing: 5

            width: parent.width

            Item
            {
                id: titleBar
                height: childrenRect.height
                anchors
                {
                    left: parent.left
                    right: parent.right
                }
                OurLabel
                {
                    id: titleLabel
                    font.pixelSize: 24
                    text: activeNode ? activeNode.label: ""
                    font.bold: true
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
                    anchors.topMargin: base.defaultMargin / 2
                    width: parent.width / 4 * 3
                    height: 1
                    color: "#00D1FF"
                    opacity: 0.5
                }
            }


            Item
            {
                width: parent.width
                height: base.defaultFontSize
                OurLabel
                {
                    text: "Health"
                    color: "#56CCF2"
                }
                OurLabel
                {
                    text: activeNode ? Math.round(activeNode.health * 100) / 100: 100
                    anchors.right: parent.right
                }
            }
            Item
            {
                width: parent.width
                height: base.defaultFontSize
                OurLabel
                {
                    text: "Temperature"
                    color: "#56CCF2"
                }
                OurLabel
                {
                    text: activeNode ? Math.round(activeNode.temperature * 100) / 100: 20
                    anchors.right: parent.right
                }
            }

            Item
            {
                width: 1
                height: base.defaultMargin / 2
            }

            OurLabel
            {
                font.pixelSize: 16
                text: "Resources received"
                font.bold: true
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
                height: base.defaultMargin / 2
                visible: resourcesRequiredRepeater.count
            }

            OurLabel
            {
                font.pixelSize: 16
                text: "Resources required"
                font.bold: true
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
                height: base.defaultMargin / 2
                visible: resourcesProducedRepeater.count
            }
            OurLabel
            {
                font.pixelSize: 16
                text: "Resources produced"
                font.bold: true
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
                height: base.defaultMargin / 2
            }

            OurLabel
            {
                font.pixelSize: 16
                text: "Resources provided"
                color: "white"
                font.bold: true
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

            OurLabel
            {
                font.pixelSize: 16
                text: "Modifiers"
                visible: modifiersRepeater.count
                font.bold: true
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
                height: base.defaultMargin / 2
            }
            Button
            {
                anchors.left: parent.left
                anchors.right: parent.right
                height: base.buttonSize
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
                    RecolorImage
                    {
                        source: "../svg/plus.svg"
                        width: base.buttonSize / 2
                        height: base.buttonSize / 2
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: base.defaultMargin
                    }
                    OurLabel
                    {
                        font.pixelSize: base.buttonSize / 2
                        text: "Modifier"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Item
            {
                height: base.buttonSize
                anchors.left: parent.left
                anchors.right: parent.right
                Button
                {
                    id: historyButton
                    anchors.left: parent.left
                    width: parent.width / 2 - base.defaultMargin / 2
                    height: base.buttonSize
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
                            width: base.buttonSize / 2
                            height: base.buttonSize / 2
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                        }
                        OurLabel
                        {
                            font.pixelSize: base.buttonSize / 2
                            text: "History"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                Button
                {
                    anchors.left: historyButton.right
                    anchors.right: parent.right
                    anchors.leftMargin: base.defaultMargin / 2
                    height: base.buttonSize
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
                            width: base.buttonSize / 2 + 3
                            height: base.buttonSize / 2 + 3
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                        }
                        OurLabel
                        {
                            font.pixelSize: base.buttonSize / 2
                            text: "Info"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
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
