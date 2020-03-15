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