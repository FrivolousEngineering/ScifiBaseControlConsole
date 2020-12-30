import QtQuick 2.0
import QtQuick.Controls 2.3
Dial
{
    id: control
    implicitWidth: 200
    implicitHeight: 200
    value: 1

    // Due to the currentDial not accepting values outside of the to/from (and not being able to control the order)
    // We have to be a bit hackish about it
    onFromChanged:
    {
        currentDial.from = control.from
        currentDial.value = currentValue
        canvas.requestPaint()
    }

    // Due to the currentDial not accepting values outside of the to/from (and not being able to control the order)
    // We have to be a bit hackish about it
    onToChanged:
    {
        currentDial.to = control.to
        currentDial.value = currentValue
        canvas.requestPaint()
    }

    hoverEnabled: true

    property alias targetValue: control.value
    property double currentValue

    onCurrentValueChanged:
    {
        currentDial.value = currentValue
    }

    Dial
    {
        id: currentDial
        visible: false
        value: currentValue
        to: control.to
        from: control.from
    }

    background: Rectangle {
        id: dialBackground
        x: control.width / 2 - width / 2
        y: control.height / 2 - height / 2
        width: Math.max(64, Math.min(control.width, control.height))
        height: width
        color: "transparent"

        radius: width / 2
        states: [
            State
            {
                name: "HOVERED"
                PropertyChanges { target: dialBackground; border.color: "white"}
                when: control.hovered
            },
            State {
                name: "PRESSED"
                PropertyChanges { target: dialBackground; border.color: "white"}
                when: control.pressed
            },
            State {
                name: "RELEASED"
                PropertyChanges { target: dialBackground; border.color: "#d3d3d3"}
                when: !control.pressed
            }
        ]
        transitions: [
            Transition {
                from: "PRESSED"
                to: "RELEASED"
                ColorAnimation { target: dialBackground; duration: 100}
            },
            Transition {
                from: "RELEASED"
                to: "PRESSED"
                ColorAnimation { target: dialBackground; duration: 100}
            },
            Transition {
                from: "HOVERED"
                to: "RELEASED"
                ColorAnimation { target: dialBackground; duration: 100}
            },
            Transition {
                from: "RELEASED"
                to: "HOVERED"
                ColorAnimation { target: dialBackground; duration: 100}
            }
        ]
        opacity: control.enabled ? 1 : 0.3
        Text
        {
            text: Math.round(currentDial.value * 100) / 100 + " / " + Math.round(control.value * 100) / 100
            color: "white"
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        Canvas {
            id: canvas
            width: control.width
            height: control.height

            property real currentValue: control.currentValue
            property real centerWidth: width / 2
            property real centerHeight: height / 2
            property real radius: Math.min(canvas.width, canvas.height) / 2 - 2
            property color penColor: dialBackground.border.color

            onPenColorChanged: canvas.requestPaint()
            onCurrentValueChanged:
            {
                canvas.requestPaint()
            }

            property real angle: currentDial.angle / 360 * 2 * Math.PI
            onPaint: {
                var ctx = canvas.getContext('2d')
                ctx.reset()

                ctx.lineJoin = "round"
                ctx.lineCap= "round"

                ctx.lineWidth = 3

                ctx.strokeStyle = penColor
                ctx.fillStyle = penColor
                ctx.beginPath()

                ctx.arc(canvas.centerWidth, canvas.centerHeight, canvas.radius,
                        Math.PI / 2 + Math.PI / 4.49, Math.PI / 2 + canvas.angle - Math.PI)
                ctx.stroke()
            }
        }
    }
    handle: Rectangle {
        id: handleItem
        x: control.background.x + control.background.width / 2 - width / 2
        y: control.background.y + control.background.height / 2 - height / 2
        width: 12
        height: 12
        color: control.pressed ? "white": "#d3d3d3"
        radius: 6
        antialiasing: true
        opacity: control.enabled ? 1 : 0.3

        states: [
            State {
                name: "PRESSED"
                PropertyChanges { target: handleItem; border.color: "white"}
                when: control.pressed
            },
            State {
                name: "RELEASED"
                PropertyChanges { target: handleItem; border.color: "#d3d3d3"}
                when: !control.pressed
            }
        ]
        transitions: [
            Transition {
                from: "PRESSED"
                to: "RELEASED"
                ColorAnimation { target: handleItem; duration: 100}
            },
            Transition {
                from: "RELEASED"
                to: "PRESSED"
                ColorAnimation { target: handleItem; duration: 100}
            }
        ]
        transform: [
            Translate {
                y: -Math.min(control.background.width, control.background.height) * 0.4 + handleItem.height / 2
            },
            Rotation {
                angle: control.angle
                origin.x: handleItem.width / 2
                origin.y: handleItem.height / 2
            }
        ]
    }
}