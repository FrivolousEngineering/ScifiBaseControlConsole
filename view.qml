import QtQuick 2.0
import QtQuick.Controls 2.2
import QtCharts 2.3
import QtGraphicalEffects 1.12

Rectangle
{
    width: 1024
    height: 768
    color: "black"


    property var highlightedNode: null
    property var activeNode: backend.nodeData[0]
    property int object_width: 240
    property int object_height: 95
    property int activeNodeIndex: 0

    property string activeProperty: "temperature"

    property variant activeNodeGraphData: activeNode.historyData[activeProperty]
    onHighlightedNodeChanged: mycanvas.requestPaint()

    onActiveNodeChanged: mycanvas.requestPaint()
    onActiveNodeGraphDataChanged:
    {
        historyGraph.clear()
        maxTemperatureGraph.clear()
        historyGraph.resetMinMax()
        for(var i in activeNodeGraphData)
        {
            historyGraph.append(i, activeNodeGraphData[i])
            maxTemperatureGraph.append(i, activeNode.max_safe_temperature)
        }
    }
    ScrollView
    {
        anchors.fill: parent
        Canvas {
            id: mycanvas
            anchors.fill: parent
            property var spacing: 12
            function drawOutgoingConnection(origin_x, origin_y, target_x, target_y)
            {
                var ctx = getContext("2d");
                ctx.moveTo(origin_x + 0.5 * object_width, origin_y + object_height)

                var inbetween_x = origin_x + 0.5 * object_width
                var inbetween_y = origin_y + 0.5 * spacing + object_height
                ctx.lineTo(inbetween_x, inbetween_y)

                // We either move to the left or we move to the right
                if(target_x < origin_x)
                {
                    inbetween_x = origin_x - 0.5 * spacing
                }
                else
                {
                    inbetween_x = origin_x + object_width + 0.5 * spacing
                }
                ctx.lineTo(inbetween_x, inbetween_y)

                // Move up / down (if needed)
                inbetween_y = target_y + object_height + 0.5 * spacing
                ctx.lineTo(inbetween_x, inbetween_y)

                // Move to below center of the target.
                inbetween_x = target_x + 0.5 * object_width
                ctx.lineTo(inbetween_x, inbetween_y)

                // Move to target
                inbetween_y = target_y + object_height
                ctx.lineTo(inbetween_x, inbetween_y)
            }

            function drawIncommingConnection(origin_x, origin_y, target_x, target_y)
            {
                var ctx = getContext("2d");
                ctx.moveTo(origin_x + object_width, origin_y + 0.5 * object_height)

                var inbetween_x = origin_x + object_width + 0.5 * spacing
                var inbetween_y = origin_y + 0.5 * object_height
                ctx.lineTo(inbetween_x, inbetween_y)

                // We either move to the left or we move to the right

                if(target_y < origin_y)
                {
                    inbetween_y = origin_y - 0.5 * spacing
                }
                else
                {
                    inbetween_y = origin_y + 0.5 * spacing + object_height
                }
                ctx.lineTo(inbetween_x, inbetween_y)

                inbetween_x = target_x + 0.5 * spacing + object_width
                ctx.lineTo(inbetween_x, inbetween_y)

                inbetween_y = target_y + 0.5 * object_height
                ctx.lineTo(inbetween_x, inbetween_y)

                inbetween_x = target_x + object_width
                ctx.lineTo(inbetween_x, inbetween_y)
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                if(activeNode == null)
                {
                    return
                }
                var ctx = getContext("2d");
                ctx.strokeStyle = "red"
                ctx.lineWidth = 2
                ctx.fillStyle = Qt.rgba(0, 0, 0, 1);
                ctx.beginPath();


                var origin_x = 0
                var origin_y = 0

                for(var idx in grid.children)
                {
                    if(grid.children[idx].title == activeNode.id)
                    {
                        origin_x = grid.children[idx].x + spacing
                        origin_y =  grid.children[idx].y + spacing
                    }
                }

                var outgoing = []
                for(var idx in grid.children)
                {
                    for(var connected_node in activeNode.outgoingConnections)
                    {
                        if(activeNode.outgoingConnections[connected_node]["target"] == grid.children[idx].title)
                        {
                            outgoing.push(idx)
                        }
                    }
                }
                var incomming = []
                for(var idx in grid.children)
                {
                    for(var connected_node in activeNode.incomingConnections)
                    {
                        if(activeNode.incomingConnections[connected_node]["origin"] == grid.children[idx].title)
                        {
                            incomming.push(idx)
                        }
                    }
                }

                for(var entry in outgoing)
                {
                    // Start position!
                    var target_x = grid.children[outgoing[entry]].x + spacing
                    var target_y = grid.children[outgoing[entry]].y + spacing
                    drawOutgoingConnection(origin_x, origin_y, target_x, target_y)
                }
                ctx.stroke()
                ctx.beginPath()
                ctx.strokeStyle = "blue"
                for(var entry in incomming)
                {
                    // Start position!
                    var target_x = grid.children[incomming[entry]].x + spacing
                    var target_y = grid.children[incomming[entry]].y + spacing
                    drawIncommingConnection(target_x, target_y, origin_x, origin_y)
                }

                ctx.stroke()
                // Draw all outgoing connections.
                /*var origin_x = activeNode.x
                var origin_y = activeNode.y;

                var spacing = 25

                var target_x = highlightedNode.x
                var target_y = highlightedNode.y;
                ctx.moveTo(origin_x, origin_y)

                var y_difference = origin_y - target_y
                var x_difference = origin_x - target_x
                if(y_difference < 0 && y_difference >= -object_height - spacing)
                {
                    print("case 1")
                    ctx.moveTo(origin_x + 0.5 * object_width, origin_y + object_height)
                    ctx.lineTo(origin_x + 0.5 * object_width, origin_y + 0.5 * spacing + object_height)
                    ctx.lineTo(target_x + 0.5 * object_width, target_y - 0.5 * spacing)
                    ctx.lineTo(target_x+ 0.5 * object_width, target_y)
                }
                else if(y_difference < 0)
                {

                    if(x_difference >= 0)
                    {
                        print("case 2")
                        ctx.moveTo(origin_x + 0.5 * object_width, origin_y + object_height)
                        ctx.lineTo(origin_x + 0.5 * object_width, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(origin_x - 0.5 * spacing, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(target_x + object_width + 0.5 * spacing, target_y - 0.5 * spacing)
                        ctx.lineTo(target_x + 0.5 * object_width, target_y - 0.5 * spacing)
                        ctx.lineTo(target_x+ 0.5 * object_width, target_y)
                    }else
                    {
                        print("case3")
                        ctx.moveTo(origin_x + 0.5 * object_width, origin_y + object_height)
                        ctx.lineTo(origin_x + 0.5 * object_width, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(origin_x + object_width + 0.5 * spacing, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(target_x - 0.5 * spacing, target_y - 0.5 * spacing)
                        ctx.lineTo(target_x + 0.5 * object_width, target_y - 0.5 * spacing)
                        ctx.lineTo(target_x+ 0.5 * object_width, target_y)
                    }

                }
                else if(y_difference > 0 && y_difference <= object_height + spacing)
                {
                    print("case 4")
                    ctx.moveTo(origin_x + 0.5 * object_width, origin_y)
                    ctx.lineTo(origin_x + 0.5 * object_width, origin_y - 0.5 * spacing)
                    ctx.lineTo(target_x + 0.5 * object_width, target_y + 0.5 * spacing + object_height)
                    ctx.lineTo(target_x+ 0.5 * object_width, target_y + object_height)
                }
                else
                {
                    if(x_difference >= 0)
                    {
                        print("case 5")
                        ctx.moveTo(origin_x + 0.5 * object_width, origin_y + object_height)
                        ctx.lineTo(origin_x + 0.5 * object_width, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(origin_x - 0.5 * spacing, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(target_x + object_width + 0.5 * spacing, target_y + object_height + 0.5 * spacing)
                        ctx.lineTo(target_x + 0.5 * object_width, target_y + object_height + 0.5 * spacing)
                        ctx.lineTo(target_x+ 0.5 * object_width, target_y + object_height)
                    }else
                    {
                        print("case6")
                        ctx.moveTo(origin_x + 0.5 * object_width, origin_y + object_height)
                        ctx.lineTo(origin_x + 0.5 * object_width, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(origin_x + object_width + 0.5 * spacing, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(target_x - 0.5 * spacing, target_y + object_height + 0.5 * spacing)
                        ctx.lineTo(target_x + 0.5 * object_width, target_y + object_height+ 0.5 * spacing)
                        ctx.lineTo(target_x+ 0.5 * object_width, target_y + object_height)
                    }
                }

                ctx.stroke()*/
            }
        }


        /*Grid
        {
            id: grid
            spacing: 25
            columns: 2
            anchors.fill:parent
            visible: false
            Repeater
            {
                model: backend.nodeData
                NodeWidget
                {
                    id: node
                    controller: modelData
                    nodeName: modelData.id
                    opacity:
                    {
                        if(highlightedNode == node || activeNode == node || activeNode == null || highlightedNode == null)
                        {
                            return 1
                        }
                        return 0.1
                    }

                    Behavior on opacity
                    {
                        NumberAnimation { duration: 1000}
                    }
                    onConnectionHovered:
                    {
                        for(var n in grid.children)
                        {
                            if(grid.children[n].nodeName == node_id)
                            {
                                highlightedNode = grid.children[n]
                                break
                            }
                            highlightedNode = null
                        }
                        activeNode = node
                        mycanvas.requestPaint()
                    }

                    highlighted: node == highlightedNode
                    width: object_width
                    height: object_height
                }
            }
        }*/
        Grid
        {
            id: grid
            spacing: 12
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 12
            columns: 3
            opacity: 0.5
            Repeater {
                model: backend.nodeData
                HexagonNodeWidget
                {
                    title: modelData.id
                    onClicked: activeNode = modelData
                    highlighted: activeNode == modelData
                }
            }
        }

        Button
        {
            id: chartButton
            anchors.verticalCenter: infoSidebarItem.bottom
            anchors.right: infoSidebarItem.left
            anchors.rightMargin: -50

            property bool collapsed: true

            width: collapsed ? 50: 450
            height: width * 0.866025404

            Behavior on width
            {
                NumberAnimation { duration: 200}
            }

            contentItem: Item
            {
                id: content
                ChartView
                {
                    id: chartView

                    antialiasing: true
                    //theme: ChartView.ChartThemeDark
                    anchors.fill: parent
                    backgroundColor: "#B2B2B2"

                    opacity: 0

                    AutoUpdatingLineSeries
                    {
                        id: historyGraph
                        color: "red"
                        width: 3
                        onHovered: selectedPointText.text = point.y
                    }

                    LineSeries
                    {
                        id: maxTemperatureGraph
                        color: "blue"
                        width: 3
                    }
                }
                Hexagon
                {
                    id: hexagon
                    width: parent.width
                    visible: false

                }
                OpacityMask
                {
                    anchors.fill: parent
                    source: chartView
                    maskSource: hexagon
                }
                Text
                {
                    id: selectedPointText
                    anchors.bottom: parent.bottom
                    width: parent.width / 3
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
                    text: ""
                    horizontalAlignment: Text.AlignHCenter
                    visible: !chartButton.collapsed
                }
            }

            onClicked:
            {
                collapsed = !collapsed
            }

            background:Hexagon {
                border.width: 0
                color: "#666666"
            }
        }

        SidebarItem
        {
            id: infoSidebarItem
            anchors.right: parent.right
            contents: Text
            {
                color: "white"
                text: activeNode.description
                wrapMode: Text.Wrap
            }
            title: "INFO"
        }

        SidebarItem
        {
            id: statsSideBarItem
            title: "STATS"
            anchors.top: infoSidebarItem.bottom
            anchors.right: parent.right
            contents:
            Column
            {
                Text
                {
                    color: "white"
                    text: "Temp: " + activeNode.temperature
                }
                Text
                {
                   color: "white"
                   text: "Enabled: " + activeNode.enabled
                }
                Text
                {
                   color: "white"
                   text: "Surf area: " + activeNode.surface_area + " m²"
                }
                Text
                {
                   color: "white"
                   text: "Max tmp: " + activeNode.max_safe_temperature + " K"
                }
                Text
                {
                   color: "white"
                   text: "Con coef: " + activeNode.heat_convection + " W/m K"
                }
                Text
                {
                   color: "white"
                   text: "H Emissivity: " + activeNode.heat_emissivity
                }
            }

        }
        SidebarItem
        {
            id: connectSideBarItem
            title: "CONNECT"
            anchors.top: statsSideBarItem.bottom
            anchors.right: parent.right
                /*Popup
                {
                    id: chartPopup
                    width: 400
                    height: 400
                    y: -height
                    x: -width
                    background: Item{}
                    ChartView
                    {
                        id: chartView
                        anchors.fill:parent

                        antialiasing: true
                        theme: ChartView.ChartThemeDark

                        visible: false

                        AutoUpdatingLineSeries
                        {
                            id: historyGraph
                            name: "temperature"
                            color: "red"
                            width: 3
                        }
                    }
                    Hexagon
                    {
                        id: hexagon
                        width: parent.width
                        visible: false

                    }
                    OpacityMask
                    {
                        anchors.fill: parent
                        source: chartView
                        maskSource: hexagon
                    }
                }*/

        }
    }
}
