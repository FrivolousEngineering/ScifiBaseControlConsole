import QtQuick 2.0
import QtQuick.Controls 2.2

Rectangle
{
    width: 1200
    height: 750
    color: "green"
    ScrollView
    {
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
