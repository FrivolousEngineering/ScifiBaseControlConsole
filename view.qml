import QtQuick 2.0
import QtQuick.Controls 2.2

Rectangle
{
    width: 1000
    height: 750
    color: "black"


    property string highlightedNode: ""
    ScrollView
    {
        anchors.fill: parent
        Grid
        {
            spacing: 5
            columns: 2
            Repeater
            {

                model: backend.nodeData
                NodeWidget
                {
                    controller: modelData
                    nodeName: modelData.id
                    onConnectionHovered: highlightedNode = node_id
                    highlighted: modelData.id == highlightedNode
                }
            }
        }
    }
}
