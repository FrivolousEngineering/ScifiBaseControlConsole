import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Shapes 1.0


Item
{
    id: base
    implicitWidth: 20
    implicitHeight: 20

    state: "neutral"

    property color upColor: redColor
    property color downColor: greenColor
    property color neutralColor: "#D9D9D9"

    readonly property color redColor: "#FF3F3F"
    readonly property color greenColor: "#5FC996"

    states: [
        State {
            name: "up"
            PropertyChanges { target: triangle; rotationAngle: 180; color: base.upColor; visible: true }
            PropertyChanges { target: circle; visible: false }
        },
        State
        {
            name: "down"
            PropertyChanges { target: triangle; rotationAngle: 0; color: base.downColor; visible: true }
            PropertyChanges { target: circle; visible: false }
        },
        State
        {
            name: "neutral"
            PropertyChanges { target: circle; visible: true }
            PropertyChanges { target: triangle; visible: false }
        }
    ]


    Triangle
    {
        property int rotationAngle: 0
        id: triangle
        anchors.centerIn: parent.center
        width: 20
        height: 17
        transform: Rotation { origin.x: triangle.width / 2; origin.y: triangle.height / 2; angle: triangle.rotationAngle}
    }

    Rectangle
    {
        id: circle
        anchors.fill: parent
        radius: width / 2
        color: base.neutralColor
    }
}