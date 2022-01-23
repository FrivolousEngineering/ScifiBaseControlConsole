import QtQuick 2.0
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import QtQml 2.2

import SDK 1.0

Rectangle
{
    id: window
    width: 1280
    height: 720

    color: "black"

    Flickable
    {
        anchors.fill: parent
        clip: true
        contentWidth: 5000
        contentHeight: 5000
        Canvas
        {
            width: 5000
            height: 5000
            onPaint:
            {
                var ctx = getContext("2d")
                ctx.lineWidth = 4

                for(var connection_index in graph_data.connections)
                {

                    var connection = graph_data.connections[connection_index]
                    var gradient = ctx.createLinearGradient(connection.points[0].x,connection.points[0].y,connection.points[connection.points.length-1].x,connection.points[connection.points.length-1].y)
                    gradient.addColorStop(0, "blue")
                    gradient.addColorStop(0.5, "lightsteelblue")
                    ctx.strokeStyle = gradient

                    ctx.beginPath()

                    ctx.moveTo(connection.points[0].x, connection.points[1].y)

                    for(var point_index in connection.points)
                    {
                        ctx.lineTo(connection.points[point_index].x, connection.points[point_index].y)
                    }
                    ctx.stroke()
                }
            }
        }
        Item
        {
            implicitWidth: 5000
            implicitHeight: 5000
            Repeater
            {
                model: graph_data.nodes

                Rectangle
                {
                    x: modelData.x
                    y: modelData.y
                    width: modelData.width
                    height: modelData.height
                    color: "blue"
                    Label
                    {
                        text: modelData.id
                        color: "white"
                    }
                }
            }
        }


    }
}