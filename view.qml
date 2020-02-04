import QtQuick 2.0

Rectangle {
    width: 750
    height: 750
    color: "green"

    Repeater
    {

        model: backend.nodeData
        NodeWidget
        {
            x: 25
            y: 25
            controller: modelData
            nodeName: modelData.id
        }
    }
}
