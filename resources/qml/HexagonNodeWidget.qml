import QtQuick 2.6
import QtQuick.Controls 2.3

import SDK 1.0

Item
{
    id: base
    implicitWidth: 240
    implicitHeight: 95
    property alias title: titleText.text
    property bool highlighted: false
    property double angleSize: 15
    property var controller

    property color borderColor: "#d3d3d3"
    property bool hovered: false

    property font myFont:Qt.font({family: "Roboto"})
    property font titleFont: Qt.font({
        family: "Roboto",
        pixelSize: 9,
        bold: true,
        capitalization: Font.AllUppercase
    });

    states: [
            State {
                name: "HOVERED"
                PropertyChanges { target: base; borderColor: "white"}
                when: base.hovered
            },
            State {
                name: "NOTHOVERED"
                PropertyChanges { target: base; borderColor: "#d3d3d3"}
                when: !base.hovered
            }
        ]
        transitions: [
            Transition {
                from: "HOVERED"
                to: "NOTHOVERED"
                ColorAnimation { target: base; duration: 100}
            },
            Transition {
                from: "NOTHOVERED"
                to: "HOVERED"
                ColorAnimation { target: base; duration: 100}
            }
        ]

    signal clicked()

    MouseArea
    {
        anchors.fill: base
        hoverEnabled: true
        onEntered: hovered = true
        onExited: hovered = false
        onClicked: base.clicked()
    }

    Item
    {
        id: title
        height: parent.height
        width: 35
        CutoffRectangle
        {
            anchors.fill: parent
            cornerSide: CutoffRectangle.Direction.UpLeft
            color: base.highlighted ? background.border.color : "#333333"
            border.color: base.borderColor
            border.width: 2
            angleSize: base.angleSize
            CutoffRectangle
            {
                anchors.fill: parent
                anchors.margins: 3
                angleSize: base.angleSize - 2
                cornerSide: CutoffRectangle.Direction.UpLeft
                border.color: "transparent"
                border.width: 2
            }
        }
        Text
        {
            id: titleText
            color: "white"
            text: ""
            width: parent.height
            height: 50
            anchors.left: parent.left
            anchors.leftMargin: 18
            horizontalAlignment: Text.AlignHCenter
            transform: Rotation { origin.x: 50; origin.y: 50; angle: 270}
            font: titleFont

        }
    }
    Item
    {
        id: content
        height: parent.height
        anchors.right: parent.right
        anchors.left: title.right
        anchors.leftMargin: -1
        CutoffRectangle
        {
            id: background
            anchors.fill: parent
            cornerSide: CutoffRectangle.Direction.Right
            color: base.highlighted ? background.border.color : "#333333"
            angleSize: base.angleSize
            border.color: base.borderColor
            border.width: 2
            CutoffRectangle
            {
                id: backgroundFill
                anchors.fill: parent
                anchors.margins: 2
                cornerSide: CutoffRectangle.Direction.Right
                angleSize: base.angleSize - 1
                border.color: "transparent"
                border.width: 1
                layer.enabled: true
                CutoffRectangle
                {
                    color: "#666666"
                    border.color: "transparent"
                    border.width: -1
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    width: parent.angleSize
                    angleSize: width
                    cornerSide: CutoffRectangle.Direction.Right
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    CutoffRectangle
                    {
                        color: backgroundFill.color
                        border.width: -1
                        height: background.height / 2
                        width: parent.width / 3 * 2
                        anchors.left: parent.left
                        cornerSide: CutoffRectangle.Direction.Right
                        anchors.verticalCenter: parent.verticalCenter
                        angleSize: width
                    }
                }

                HealthAndStorageRadialBar
                {
                    id:healthAndStorage
                    anchors.top: parent.top
                    anchors.topMargin: 3
                    anchors.bottomMargin: 3
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 3
                    width: height
                    model: controller.additionalProperties
                }
                CustomDial
                {
                    id: dial
                    anchors.top: parent.top
                    anchors.topMargin: 3
                    anchors.bottomMargin: 3
                    anchors.bottom: parent.bottom
                    anchors.left: healthAndStorage.right
                    anchors.leftMargin: 3
                    width: height

                    from: controller.min_performance
                    to: controller.max_performance
                    visible: from != to
                    enabled: visible

                    onHoveredChanged: base.hovered = hovered
                    Behavior on value {
                        NumberAnimation {
                            duration: 1000
                            easing.type: Easing.InOutCubic
                        }
                    }
                    Binding
                    {
                        target: dial
                        property: "value"
                        value: controller.performance
                        when: !dial.pressed
                    }
                    onPressedChanged:
                    {
                        if(!pressed) // Released
                        {
                            controller.setPerformance(value)
                        }
                    }
                }
            }
        }
    }
}