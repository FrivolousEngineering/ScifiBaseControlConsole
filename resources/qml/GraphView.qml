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

    property int content_width: 8000
    property int content_height: 8000
    Flickable
    {
        id: flickable
        anchors.fill: parent
        contentWidth: itemContainer.width
        contentHeight: itemContainer.height
        onHeightChanged: content.calculateSize()

        Item
        {
            id: itemContainer

            width: Math.max(content.width * content.scale, flickable.width)
            height: Math.max(content.height * content.scale, flickable.height)

            Item
            {
                id: content
                property real prevScale
                anchors.centerIn: parent
                width: window.content_width
                height: window.content_height
                function calculateSize()
                {
                    scale = Math.min(flickable.width / width, flickable.height / height) * 0.98
                    prevScale = Math.min(scale, 1)
                }

                onScaleChanged:
                {
                    if (width * scale > flickable.width)
                    {
                        var xoff = (flickable.width / 2 + flickable.contentX) * scale / prevScale
                        flickable.contentX = xoff - flickable.width / 2
                    }
                    if (height * scale > flickable.height)
                    {
                        var yoff = (flickable.height / 2 + flickable.contentY) * scale / prevScale
                        flickable.contentY = yoff - flickable.height / 2
                    }

                    prevScale = scale
                }

                Canvas
                {
                    width: window.content_width
                    height: window.content_height
                    onPaint:
                    {
                        var ctx = getContext("2d")
                        ctx.lineWidth = 4

                        for(var connection_index in graph_data.connections)
                        {

                            var connection = graph_data.connections[connection_index]
                            var gradient = ctx.createLinearGradient(connection.points[0].x, connection.points[0].y, connection.points[connection.points.length-1].x, connection.points[connection.points.length-1].y)
                            gradient.addColorStop(0, connection.color)
                            gradient.addColorStop(1, "lightsteelblue")
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
                    implicitWidth: window.content_width
                    implicitHeight: window.content_height
                    Repeater
                    {
                        model: backend.nodeData//graph_data.nodes

                        Node
                        {
                            property var modelPosition: graph_data.getNodeById(modelData.id)
                            x: modelPosition.x
                            y: modelPosition.y
                            width: modelPosition.width
                            height: modelPosition.height

                            titleText: modelData.id
                            currentTemperature: modelData.temperature
                            controller: modelData
                        }
                    }
                }
            }
        }
        MouseArea
        {
            id: mousearea
            anchors.fill : parent

            onWheel:
            {
                var new_scale = content.scale + wheel.angleDelta.y / 600
                if(new_scale < 0.2) new_scale = 0.2
                if(new_scale > 5) new_scale = 5

                content.scale = new_scale
                flickable.returnToBounds()
            }
        }
    }
}