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

    property int content_width: 4000
    property int content_height: 5000

    property var selectedNodeData: null

    property var activeViewMode: "Overview"

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

                onClicked: mouse.accepted = false
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
                Rectangle
                {
                    id: highlighted
                    visible: window.selectedNodeData !== null
                    property int borderSize: 20
                    property var modelPosition: graph_data.getNodeById(window.selectedNodeData.id)
                    x: modelPosition.x - borderSize / 2
                    y: modelPosition.y - borderSize / 2
                    width: modelPosition.width + borderSize
                    height: modelPosition.height + borderSize
                    opacity: 0.75
                    radius: 20
                }
                Canvas
                {
                    width: window.content_width
                    height: window.content_height
                    antialiasing: true
                    function drawArrowRightAdvanced(ctx, x, y, lineWidth, arrowWidth = 5, arrowColor = Qt.rgba(0.764, 0.937, 0.98, 1))
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
                        ctx.fillStyle = arrowColor;

                        ctx.fill()
                    }

                    function drawArrowLeftAdvanced(ctx, x, y, lineWidth, arrowWidth = 5, arrowColor = Qt.rgba(0.764, 0.937, 0.98, 1))
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
                        ctx.fillStyle = arrowColor

                        ctx.fill()
                    }

                    function drawArrowDownAdvanced(ctx, x, y, lineWidth, arrowWidth = 5, arrowColor = Qt.rgba(0.764, 0.937, 0.98, 1))
                    {
                        ctx.beginPath()
                        ctx.lineWidth = 1

                        ctx.moveTo(x, y + 0.5 * arrowWidth)
                        ctx.lineTo(x + 0.5 * lineWidth, y + 0.5 * arrowWidth - 0.5 * lineWidth)
                        ctx.lineTo(x + 0.5 * lineWidth, y - 0.5 * arrowWidth - 0.5 * lineWidth)
                        ctx.lineTo(x, y - 0.5 * arrowWidth)

                        ctx.lineTo(x - 0.5 * lineWidth, y - 0.5 * arrowWidth - 0.5 * lineWidth)
                        ctx.lineTo(x - 0.5 * lineWidth, y + 0.5 * arrowWidth - 0.5 * lineWidth)

                        ctx.strokeStyle = Qt.rgba(1, 0, 0, 1);
                        ctx.fillStyle = arrowColor

                        ctx.fill()
                    }

                    function drawArrowUpAdvanced(ctx, x, y, lineWidth, arrowWidth = 5, arrowColor = Qt.rgba(0.764, 0.937, 0.98, 1))
                    {
                        ctx.beginPath()
                        ctx.lineWidth = 1

                        ctx.moveTo(x, y - 0.5 * arrowWidth)
                        ctx.lineTo(x + 0.5 * lineWidth, y - 0.5 * arrowWidth + 0.5 * lineWidth)
                        ctx.lineTo(x + 0.5 * lineWidth, y + 0.5 * arrowWidth + 0.5 * lineWidth)
                        ctx.lineTo(x, y + 0.5 * arrowWidth)

                        ctx.lineTo(x - 0.5 * lineWidth, y + 0.5 * arrowWidth + 0.5 * lineWidth)
                        ctx.lineTo(x - 0.5 * lineWidth, y - 0.5 * arrowWidth + 0.5 * lineWidth)

                        ctx.strokeStyle = Qt.rgba(1, 0, 0, 1);
                        ctx.fillStyle = arrowColor;

                        ctx.fill()
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
                            ctx.strokeStyle = Qt.darker(connection.color);
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
                                    for(var i = 5; i < horizontalDifference; i+= arrowSpacing)
                                    {
                                        drawArrowRightAdvanced(ctx, prev_x - i, prev_y, 10, 5, Qt.lighter(connection.color, 1.5))
                                    }
                                } else if (horizontalDifference < 0 )
                                {
                                    // Draw left facint arrow
                                    // Draw right facing arrows
                                    for(var i = horizontalDifference; i < 5; i += arrowSpacing)
                                    {
                                        drawArrowLeftAdvanced(ctx, prev_x - i, prev_y, 10, 5, Qt.lighter(connection.color, 1.5))
                                    }
                                } else if (verticalDifference < 0)
                                {
                                    // Draw down arrow
                                    for(var i = verticalDifference + arrowSpacing; i < 5; i += arrowSpacing)
                                    {
                                        drawArrowDownAdvanced(ctx, prev_x, prev_y - i, 10, 5, Qt.lighter(connection.color, 1.5))
                                    }
                                } else
                                {
                                    // Draw up arrow
                                    for(var i = 5; i < verticalDifference + 5; i+= arrowSpacing)
                                    {
                                        drawArrowUpAdvanced(ctx, prev_x, prev_y - i, 10, 5, Qt.lighter(connection.color, 1.5))
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
                            titleText: modelData.label
                            viewMode: window.activeViewMode
                            controller: modelData

                            onClicked:
                            {
                                window.selectedNodeData = modelData
                                focusBar.collapsed = false
                            }
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

    TopBar
    {
        anchors.left: parent.left
        anchors.top: parent.top
    }

    NodeFocusSideBar
    {
        id: focusBar
        anchors.right: parent.right
        collapsed: true
        onCollapsedChanged:
        {
            if(collapsed)
            {
                window.selectedNodeData = null
            }
        }
        onAddModifierClicked: window.showModifierWindow(selectedNodeData.id)
        onShowGraphs: graphWindow.visible = true
        onShowDetailedInfoClicked: showDetailedInfoWindow.visible = true
        activeNode: window.selectedNodeData
    }

    ViewSelector
    {
        anchors
        {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        onActiveModeChanged: window.activeViewMode = activeMode
    }

    AddModifierWindow
    {
        id: addModifierWindow
        anchors.centerIn: parent
        width: 500
        height: 500
        onModifierAdded: backend.addModifier(type, nodeId)
        Connections
        {
            target: backend
            onInactivityTimeout:
            {
                // Ensure that this window his hidden again when inactivity was triggered
                addModifierWindow.visible = false
                window.selectedNodeData = null
            }
        }
    }

    ModifierFailedMessage {}

    DetailedNodeInfoWindow
    {
        id: showDetailedInfoWindow
        anchors.centerIn: parent
        description: selectedNodeData.description
    }

    ChartWindow
    {
        id: graphWindow
        visible: false
    }
}