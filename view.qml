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
    property var activeNode: null
    property int object_width: 450
    property int object_height: 350
    property int activeNodeIndex: 0

    property string activeProperty: "temperature"
    property variant activeNodeGraphData: backend.nodeData[activeNodeIndex].historyData[activeProperty]
    onHighlightedNodeChanged: mycanvas.requestPaint()
    onActiveNodeGraphDataChanged:
    {
        historyGraph.clear()
        maxTemperatureGraph.clear()
        historyGraph.resetMinMax()
        for(var i in activeNodeGraphData)
        {
            historyGraph.append(i, activeNodeGraphData[i])
            maxTemperatureGraph.append(i, backend.nodeData[activeNodeIndex].max_safe_temperature)
        }
    }
    ScrollView
    {
        anchors.fill: parent
        Canvas {
            id: mycanvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                if(activeNode == null)
                {
                    return
                }
                var ctx = getContext("2d");
                ctx.strokeStyle = "red"
                ctx.lineWidth = 3
                ctx.fillStyle = Qt.rgba(0, 0, 0, 1);
                ctx.beginPath();

                var origin_x = activeNode.x
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

                ctx.stroke();
            }
        }


        Grid
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
        }
        Grid
        {
            spacing: 12
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.top:parent.top
            anchors.topMargin: 12
            columns: 3
            Repeater {
                model: backend.nodeData
                HexagonNodeWidget
                {
                    title: modelData.id
                    onClicked: activeNodeIndex = index
                    highlighted: activeNodeIndex == index
                    indexx: index
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
                    theme: ChartView.ChartThemeDark
                    anchors.fill: parent

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
            }
        }

        SidebarItem
        {
            id: infoSidebarItem
            anchors.right: parent.right
            contents: Text
            {
                color: "white"
                text: backend.nodeData[activeNodeIndex].description
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
                    text: "Temp: " + backend.nodeData[activeNodeIndex].temperature
                }
                Text
                {
                   color: "white"
                   text: "Enabled: " + backend.nodeData[activeNodeIndex].enabled
                }
                Text
                {
                   color: "white"
                   text: "Surf area: " + backend.nodeData[activeNodeIndex].surface_area + " m²"
                }
                Text
                {
                   color: "white"
                   text: "Max tmp: " + backend.nodeData[activeNodeIndex].max_safe_temperature + " K"
                }
                Text
                {
                   color: "white"
                   text: "Con coef: " + backend.nodeData[activeNodeIndex].heat_convection + " W/m K"
                }
                Text
                {
                   color: "white"
                   text: "H Emissivity: " + backend.nodeData[activeNodeIndex].heat_emissivity
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
