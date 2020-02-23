import QtQuick 2.0
import QtQuick.Controls 2.3
Dial
{
    id: control

    from: 0.5
    to: 1.5
    value: 1
    background: Rectangle {
        id: dialBackground
        x: control.width / 2 - width / 2
        y: control.height / 2 - height / 2
        width: Math.max(64, Math.min(control.width, control.height))
        height: width
        color: "transparent"

        radius: width / 2
        states: [
            State {
                name: "PRESSED"
                PropertyChanges { target: dialBackground; border.color: "white"}
                when: control.pressed
            },
            State {
                name: "RELEASED"
                PropertyChanges { target: dialBackground; border.color: "#BA6300"}
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
            }
        ]
        opacity: control.enabled ? 1 : 0.3
        Text
        {
            text: Math.round(control.value * 100) / 100
            color: "white"
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    handle: Rectangle {
        id: handleItem
        x: control.background.x + control.background.width / 2 - width / 2
        y: control.background.y + control.background.height / 2 - height / 2
        width: 12
        height: 12
        color: control.pressed ? "white": "#BA6300"
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
                PropertyChanges { target: handleItem; border.color: "#BA6300"}
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