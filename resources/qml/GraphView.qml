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

    function showModifierWindow(nodeId)
    {
        addModifierWindow.nodeObject = backend.getNodeById(nodeId)
        addModifierWindow.visible = true
    }

    Flickable
    {
        id: flickable
        anchors.fill: parent
        contentWidth: itemContainer.width
        contentHeight: itemContainer.height
        enabled: !addModifierWindow.visible
        onHeightChanged: content.calculateSize()

        Item
        {
            id: itemContainer

            width: Math.max(content.width * content.scale, flickable.width)
            height: Math.max(content.height * content.scale, flickable.height)
            MouseArea
            {
                id: mousearea
                anchors.fill : parent
                propagateComposedEvents: true
                onClicked:
                {
                    mouse.accepted = false
                }
                onWheel:
                {
                    var new_scale = content.scale + wheel.angleDelta.y / 600
                    if(new_scale < 0.2) new_scale = 0.2
                    if(new_scale > 5) new_scale = 5

                    content.scale = new_scale
                    flickable.returnToBounds()
                }
            }
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
                    antialiasing: true
                    function drawArrowRightAdvanced(ctx, x, y, lineWidth, arrowWidth = 5)
                    {
                        ctx.beginPath()
                        ctx.lineWidth = 1

                        ctx.moveTo(x + 0.5 * arrowWidth, y)
                        ctx.lineTo(x + 0.5 * arrowWidth - 0.5 * lineWidth, y + 0.5 * lineWidth)
                        ctx.lineTo(x - 0.5 * arrowWidth - 0.5 * lineWidth, y + 0.5 * lineWidth)
                        ctx.lineTo(x - 0.5 * arrowWidth, y)

                        ctx.lineTo(x - 0.5 * arrowWidth - 0.5 * lineWidth, y - 0.5 * lineWidth)
                        ctx.lineTo(x + 0.5 * arrowWidth - 0.5 * lineWidth, y - 0.5 * lineWidth)

                        ctx.strokeStyle = Qt.rgba(1, 0, 0, 1);
                        ctx.fillStyle = Qt.rgba(0.764, 0.937, 0.98, 1);

                        ctx.fill()
                    }

                    function drawArrowLeftAdvanced(ctx, x, y, lineWidth, arrowWidth = 5)
                    {
                        ctx.beginPath()
                        ctx.lineWidth = 1

                        ctx.moveTo(x - 0.5 * arrowWidth, y)
                        ctx.lineTo(x - 0.5 * arrowWidth + 0.5 * lineWidth, y + 0.5 * lineWidth)
                        ctx.lineTo(x + 0.5 * arrowWidth + 0.5 * lineWidth, y + 0.5 * lineWidth)
                        ctx.lineTo(x + 0.5 * arrowWidth, y)

                        ctx.lineTo(x + 0.5 * arrowWidth + 0.5 * lineWidth, y - 0.5 * lineWidth)
                        ctx.lineTo(x - 0.5 * arrowWidth + 0.5 * lineWidth, y - 0.5 * lineWidth)

                        ctx.strokeStyle = Qt.rgba(1, 0, 0, 1);
                        ctx.fillStyle = Qt.rgba(0.764, 0.937, 0.98, 1);

                        ctx.fill()
                    }

                    function drawArrowRight(ctx, x, y, lineWidth) {
                        ctx.beginPath()
                        ctx.lineWidth = 3
                        ctx.strokeStyle = Qt.rgba(0.764, 0.937, 0.98, 1);
                        ctx.moveTo(x, y - lineWidth / 2 + 2)
                        ctx.lineTo(x - lineWidth / 2, y)
                        ctx.lineTo(x, y + lineWidth / 2 - 2)
                        ctx.stroke()
                    }

                    function drawArrowLeft(ctx, x, y, lineWidth) {
                        ctx.beginPath()
                        ctx.lineWidth = 3
                        ctx.strokeStyle = Qt.rgba(0.764, 0.937, 0.98, 1);
                        ctx.moveTo(x, y - lineWidth / 2 + 2)
                        ctx.lineTo(x + lineWidth / 2, y )
                        ctx.lineTo(x, y + lineWidth / 2 - 2)
                        ctx.stroke()
                    }

                    function drawArrowDown(ctx, x, y, lineWidth) {
                        ctx.beginPath()
                        ctx.lineWidth = 3
                        ctx.strokeStyle = Qt.rgba(0.764, 0.937, 0.98, 1);
                        ctx.moveTo(x - lineWidth / 2 + 2, y )
                        ctx.lineTo(x, y + lineWidth / 2)
                        ctx.lineTo(x+ lineWidth / 2 - 2, y)
                        ctx.stroke()
                    }

                    function drawArrowUp(ctx, x, y, lineWidth) {
                        ctx.beginPath()
                        ctx.lineWidth = 3
                        ctx.strokeStyle = Qt.rgba(0.764, 0.937, 0.98, 1);
                        ctx.moveTo(x - lineWidth / 2 + 2, y )
                        ctx.lineTo(x, y - lineWidth / 2)
                        ctx.lineTo(x + lineWidth / 2 - 2, y)
                        ctx.stroke()
                    }

                    onPaint:
                    {
                        var ctx = getContext("2d")

                        var horizontalDifference = 0
                        var verticalDifference = 0
                        var connectionLineWidth = 10
                        var arrowSpacing = 15
                        for(var connection_index in graph_data.connections)
                        {
                            ctx.lineWidth = connectionLineWidth
                            var connection = graph_data.connections[connection_index]
                            //var gradient = ctx.createLinearGradient(connection.points[0].x, connection.points[0].y, connection.points[connection.points.length-1].x, connection.points[connection.points.length-1].y)
                            //gradient.addColorStop(0, connection.color)
                            //gradient.addColorStop(1, "lightsteelblue")
                            //ctx.strokeStyle = gradient
                            ctx.strokeStyle = Qt.rgba(0, 0.819, 1, 1);

                            ctx.beginPath()

                            ctx.moveTo(connection.points[0].x, connection.points[1].y)

                            for(var point_index in connection.points)
                            {
                                ctx.lineTo(connection.points[point_index].x, connection.points[point_index].y)
                            }
                            ctx.stroke()

                            var prev_x = 0
                            var prev_y = 0

                            for(var point_index in connection.points)
                            {
                                if(point_index == 0)
                                    continue
                                prev_x = connection.points[point_index - 1].x
                                prev_y = connection.points[point_index - 1].y
                                // Draw the arrows
                                ctx.moveTo(prev_x, prev_y)
                                // Figure out the distance
                                horizontalDifference = prev_x - connection.points[point_index].x
                                verticalDifference = prev_y - connection.points[point_index].y
                                if(horizontalDifference < arrowSpacing && horizontalDifference > -arrowSpacing && verticalDifference < arrowSpacing && verticalDifference > -arrowSpacing)
                                {
                                    continue
                                }

                                if(horizontalDifference > 0)
                                {
                                    // Draw right facing arrows
                                    for(var i = 0; i < horizontalDifference; i+= arrowSpacing)
                                    {
                                        drawArrowRightAdvanced(ctx, prev_x - i, prev_y, 10)
                                    }
                                } else if (horizontalDifference < 0 )
                                {
                                    // Draw left facint arrow
                                    // Draw right facing arrows
                                    for(var i = horizontalDifference + arrowSpacing; i < arrowSpacing; i += arrowSpacing)
                                    {
                                        drawArrowLeftAdvanced(ctx, prev_x - i, prev_y, 10)
                                    }
                                } else if (verticalDifference < 0)
                                {
                                    // Draw down arrow
                                    for(var i = verticalDifference + arrowSpacing; i < arrowSpacing; i += arrowSpacing)
                                    {
                                        drawArrowDown(ctx, prev_x, prev_y - i, 10)
                                    }

                                } else
                                {
                                    // Draw up arrow
                                    for(var i = 0; i < verticalDifference; i+= arrowSpacing)
                                    {
                                        drawArrowUp(ctx, prev_x, prev_y - i, 10)
                                    }
                                }
                            }

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

                        NodeItem
                        {
                            property var modelPosition: graph_data.getNodeById(modelData.id)
                            x: modelPosition.x
                            y: modelPosition.y
                            width: modelPosition.width
                            height: modelPosition.height
                            titleText: modelData.id
                        }

                        /*Node
                        {
                            property var modelPosition: graph_data.getNodeById(modelData.id)
                            x: modelPosition.x
                            y: modelPosition.y
                            width: modelPosition.width
                            height: modelPosition.height

                            titleText: modelData.id
                            currentTemperature: modelData.temperature
                            previousTemperature: modelData.historyData["temperature"][Math.max(modelData.historyData["temperature"].length -5, 0)] - 273.15
                            historyTemperature: modelData.historyData["temperature"][Math.max(modelData.historyData["temperature"].length -20, 0)] - 273.15
                            maxSafeTemperature: modelData.max_safe_temperature
                            maxTemperature: modelData.max_safe_temperature + 25
                            optimalTemperature: modelData.optimalTemperature
                            isTemperatureDependant: modelData.isTemperatureDependant
                            minTemperature: 15
                            controller: modelData
                            onAddModifierClicked: showModifierWindow(nodeId)
                        }*/
                    }
                }
            }
        }

    }

    AddModifierWindow
    {
        id: addModifierWindow
        anchors.centerIn: parent
        width: 350
        height: 350
        onModifierAdded: backend.getNodeById(nodeId).addModifier(type)
        Connections
        {
            target: backend
            onInactivityTimeout:
            {
                // Ensure that this window his hidden again when inactivity was triggered
                addModifierWindow.visible = false
            }
        }
    }
}