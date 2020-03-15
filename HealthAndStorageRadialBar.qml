import QtQuick 2.6
import QtQuick.Controls 2.3
import SDK 1.0

Item
{
    property var model

    // Yeah, i know, I know. It's really bad to asume that health is always the first and storage is the second.
    // But right now it works, and I don't feel like over-engineering at the moment.
    RadialBar
    {
        id: healthBar
        property var health: model[0]
        anchors.fill: parent
        progressColor: "green"
        value: health != undefined ? health["value"]: 0
        maxValue: health != undefined ? health["max_value"]: 1
        dialWidth: 3
        showText: false
        states: [
            State {
                name: "HEALTHY"
                PropertyChanges { target: healthBar; progressColor: "green"}
                when: healthBar.value >= 80
            },
            State {
                name: "DAMAGED"
                PropertyChanges { target: healthBar; progressColor: "yellow"}
                when: healthBar.value >= 30 && healthBar.value < 80
            },
            State {
                name: "CRITICAL"
                PropertyChanges { target: healthBar; progressColor: "red"}
                PropertyChanges { target: warningAnimation; running: true; }
                when: healthBar.value < 30
            }
        ]
        transitions: Transition {
            to: "*"
            ColorAnimation { target: healthBar; duration: 200}
        }
        SequentialAnimation {
            id: warningAnimation
            running: false
            PropertyAnimation { to: "white"; duration: 1000; target: healthBar; property: "foregroundColor"}
            PropertyAnimation { to: "#505050"; duration: 1000; target: healthBar; property: "foregroundColor"}
            loops: Animation.Infinite
        }

    }
    RadialBar
    {
        property var storage: model[1]
        anchors.fill: parent
        anchors.margins: 5
        showText: false
        visible: storage != undefined
        value: storage != undefined ? storage["value"]: 0
        maxValue: storage != undefined ? storage["max_value"]: 1
    }
}