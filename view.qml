import QtQuick 2.0
import QtQuick.Controls 2.2

Rectangle
{
    width: 1000
    height: 750
    color: "green"

    ScrollView
    {
        anchors.fill: parent
        Grid
        {
            spacing: 5
            Repeater
            {

                model: backend.nodeData
                NodeWidget
                {
                    controller: modelData
                    nodeName: modelData.id
                }
            }
        }
    }
}
