import QtQuick 2.6
import QtQuick.Controls 2.3

Item
{
    id: base
    implicitWidth: 240
    implicitHeight: 95
    property alias title: titleText.text
    property bool highlighted: false
    property double angleSize: 15
    property var controller

    property color borderColor: "#BA6300"
    property bool hovered: false

    states: [
            State {
                name: "HOVERED"
                PropertyChanges { target: base; borderColor: "white"}
                when: base.hovered
            },
            State {
                name: "NOTHOVERED"
                PropertyChanges { target: base; borderColor: "#BA6300"}
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
            angleSize: base.angleSize
            CutoffRectangle
            {
                anchors.fill: parent
                anchors.margins: 3
                angleSize: base.angleSize - 2
                cornerSide: CutoffRectangle.Direction.UpLeft
                border.color: base.borderColor
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
            anchors.leftMargin: 8
            horizontalAlignment: Text.AlignHCenter
            transform: Rotation { origin.x: 50; origin.y: 50; angle: 270}
            font.pointSize : 9
            font.weight: Font.Bold
        }
    }
    Item
    {
        id: content
        height: parent.height
        anchors.right: parent.right
        anchors.left: title.right
        anchors.leftMargin: -3
        CutoffRectangle
        {
            id: background
            anchors.fill: parent
            cornerSide: CutoffRectangle.Direction.Right
            color: base.highlighted ? background.border.color : "#333333"
            angleSize: base.angleSize
            border.color: base.borderColor
            CutoffRectangle
            {
                anchors.fill: parent
                anchors.margins: 3
                cornerSide: CutoffRectangle.Direction.Right
                angleSize: base.angleSize - 2
                border.color: base.borderColor

                CustomDial
                {
                    id: dial
                    anchors.top: parent.top
                    anchors.topMargin: 3
                    anchors.bottomMargin: 3
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 3
                    width: height

                    from: controller.min_performance
                    to: controller.max_performance
                    enabled: from != to

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
                Switch {
                    id: control
                    anchors.left: dial.right

                    Binding
                    {
                        target: control
                        property: "checked"
                        value: controller.enabled
                    }
                    onClicked: controller.toggleEnabled()

                    indicator: Rectangle {
                        implicitWidth: 48
                        implicitHeight: 26
                        x: control.leftPadding
                        y: parent.height / 2 - height / 2
                        radius: 13
                        color: control.checked ? "#BA6300" : "#ffffff"
                        Behavior on color {
                            ColorAnimation { duration: 150}
                        }
                        border.color: "#BA6300"

                        Rectangle {
                            x: control.checked ? parent.width - width : 0
                            Behavior on x {
                                NumberAnimation {
                                    duration: 500
                                    easing.type: Easing.InOutCubic
                                }
                            }
                            width: 26
                            height: 26
                            radius: 13
                            border.color: "#BA6300"
                        }
                    }

                    contentItem: Text {
                        text: control.text
                        font: control.font
                        opacity: enabled ? 1.0 : 0.3
                        color: "#BA6300"
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: control.indicator.width + control.spacing
                    }
                }
            }
        }
    }
}