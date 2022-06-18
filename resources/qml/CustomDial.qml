import QtQuick 2.11
import QtQuick.Controls 2.3
import QtQuick.Shapes 1.0
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
            text: Math.round(currentDial.value * 100) / 100
            color: "white"
            font: Qt.font({
                family: "Futura Md BT",
                pixelSize: 20,
                bold: true,
                capitalization: Font.AllUppercase
            });
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        Text
        {
            text: "Target<br>" + Math.round(control.value * 100) / 100
            color: "white"
            font: Qt.font({
                family: "Futura Md BT",
                pixelSize: 9,
                bold: true,
                capitalization: Font.AllUppercase
            });
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Canvas
        {
            id: canvas
            width: control.width
            height: control.height

            property real currentValue: control.currentValue
            property real centerWidth: width / 2
            property real centerHeight: height / 2
            property real radius: Math.min(canvas.width, canvas.height) / 2 - 2
            property color penColor: dialBackground.border.color
            property color backgroundPenColor: "#505050"

            onPenColorChanged: canvas.requestPaint()
            onCurrentValueChanged:
            {
                canvas.requestPaint()
            }

            property real angle: currentDial.angle / 360 * 2 * Math.PI
            onPaint: {
                var ctx = canvas.getContext('2d')
                ctx.reset()

                // Draw inner circle
                ctx.beginPath()
                ctx.lineWidth = 1.1
                ctx.strokeStyle = penColor
                ctx.fillStyle = penColor
                ctx.arc(canvas.centerWidth, canvas.centerHeight, canvas.radius - 22 ,
                        Math.PI / 2 + Math.PI / 4.49, Math.PI / 2 - Math.PI / 4.49)
                ctx.stroke()

                ctx.setLineDash([0.3, 0.12]);
                // Draw background caps
                ctx.lineWidth = 20
                ctx.beginPath()
                ctx.strokeStyle = backgroundPenColor
                ctx.fillStyle = backgroundPenColor
                ctx.arc(canvas.centerWidth, canvas.centerHeight, canvas.radius - 10 ,
                        Math.PI / 2 + Math.PI / 4.49, Math.PI / 2 - Math.PI / 4.49)
                ctx.stroke()

                // Draw current value lines
                ctx.beginPath()
                ctx.strokeStyle = penColor
                ctx.fillStyle = penColor

                ctx.arc(canvas.centerWidth, canvas.centerHeight, canvas.radius - 10 ,
                        Math.PI / 2 + Math.PI / 4.49, Math.PI / 2 + canvas.angle - Math.PI)
                ctx.stroke()

            }
        }
    }
    handle: Shape
    {
        id: handleItem
        x: control.background.x + control.background.width / 2 - width / 2
        y: control.background.y + control.background.height / 2 - height / 2
        width: 12
        height: 12
        antialiasing: true
        property alias color: shapePath.fillColor
        ShapePath {
            id: shapePath
            strokeColor: "transparent"
            PathLine { x: 0.5 * handleItem.width; y: -0.5 * handleItem.height}
            PathLine { x: 0; y: 0.5 * handleItem.height}
            PathLine { x: handleItem.width; y: 0.5 * handleItem.height }
            PathLine { x: 0.5 * handleItem.width; y: -0.5 * handleItem.height}
        }
        states: [
            State {
                name: "PRESSED"
                PropertyChanges { target: handleItem; color: "white"}
                when: control.pressed
            },
            State {
                name: "RELEASED"
                PropertyChanges { target: handleItem; color: "#d3d3d3"}
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
                y: -Math.min(control.background.width, control.background.height) * 0.27 + handleItem.height / 2
            },
            Rotation {
                angle: control.angle
                origin.x: handleItem.width / 2
                origin.y: handleItem.height / 2
            }
        ]
    }
}