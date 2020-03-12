import QtQuick 2.0
import QtQuick.Controls 2.2
import QtCharts 2.3
import QtGraphicalEffects 1.12

Rectangle
{
    id: window
    width: 1280
    height: 720
    color: "black"

    property var highlightedNode: null
    property var activeNode: backend.nodeData[0]
    property int object_width: 240
    property int object_height: 95
    property int activeNodeIndex: 0

    property string activeProperty: "temperature"

    property variant activeNodeGraphData: activeNode.historyData[activeProperty]

    onActiveNodeGraphDataChanged:
    {
        historyGraph.clear()
        historyGraph.resetMinMax()
        for(var i in activeNodeGraphData)
        {
            historyGraph.append(i, activeNodeGraphData[i])
        }
    }
    ScrollView
    {
        id: scrollview
        anchors.fill: parent
        function getConnectionColor(color)
        {
            switch(color)
            {
                case "energy": return "yellow"
                case "fuel": return "red"
                case "water": return "blue"
                default: return "white"
            }
        }
        Repeater
        {
            model: activeNode.outgoingConnections
            Connection
            {
                width: 1024
                height: 768
                object_width: window.object_width
                object_height: window.object_height

                color: scrollview.getConnectionColor(modelData.resource_type)
                end: {
                    for(var idx in grid.children)
                    {
                        if(grid.children[idx].title == modelData.target)
                        {
                            return grid.children[idx]
                        }
                    }
                }
                origin: {
                   for(var idx in grid.children)
                    {
                        if(grid.children[idx].title == modelData.origin)
                        {
                            return grid.children[idx]
                        }
                    }
                }
                Component.onCompleted: { start() }
            }
        }
        Repeater
        {
            model: activeNode.incomingConnections
            Connection
            {
                width: 1024
                height: 768

                color: scrollview.getConnectionColor(modelData.resource_type)
                end: {
                    for(var idx in grid.children)
                    {
                        if(grid.children[idx].title == modelData.target)
                        {
                            return grid.children[idx]
                        }
                    }
                }
                origin: {
                   for(var idx in grid.children)
                    {
                        if(grid.children[idx].title == modelData.origin)
                        {
                            return grid.children[idx]
                        }
                    }
                }
                Component.onCompleted: { start() }
            }
        }

        Grid
        {
            id: grid
            spacing: 12
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 12
            columns: 3

            Repeater {
                model: backend.nodeData
                HexagonNodeWidget
                {
                    title: modelData.id
                    controller: modelData
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
                Glow {
                    id: glow
                    anchors.fill: chartView
                    radius: 10
                    samples: 15
                    color: "red"
                    spread: 0.1
                    source: chartView
                    visible: false
                }

                ChartView
                {
                    id: chartView
                    animationOptions: ChartView.SeriesAnimations
                    antialiasing: true
                    anchors.fill: parent
                    backgroundColor: "transparent"
                    legend.visible: false
                    visible: false
                    opacity: 0

                    AutoUpdatingLineSeries
                    {
                        id: historyGraph
                        color: "red"
                        width: 3
                        onHovered: selectedPointText.text = point.y
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
                    source: glow
                    maskSource: hexagon
                }
                Text
                {
                    color: "white"
                    anchors.top: parent.top
                    text: "Highest\n" + Math.round(historyGraph.yMax * 100) / 100
                    visible: !chartButton.collapsed
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 18
                }
                Text
                {
                    color: "white"
                    anchors.bottom: parent.bottom
                    text: "Lowest\n" + Math.round(historyGraph.yMin * 100) / 100
                    visible: !chartButton.collapsed
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 18
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
                MouseArea
                {
                    anchors.fill: parent
                    onClicked: chartButton.clicked()
                }
            }

            onClicked: collapsed = !collapsed

            background: Hexagon
            {
                border
                {
                    width: chartButton.collapsed ? 2: 4
                    Behavior on width
                    {
                        NumberAnimation { duration: 200}
                    }
                }
                color: "#666666"
            }
        }

        SidebarItem
        {
            id: infoSidebarItem
            anchors.right: parent.right

            contents: Text
            {
                id: infoText
                color: "white"
                property QtObject activeNodeData: activeNode
                text: activeNodeData.description
                Behavior on activeNodeData
                {
                    FadeAnimation
                    {
                        target: infoSidebarItem
                        fadeProperty: "contentOpacity"
                    }
                }
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

            contents: Column
            {
                property QtObject activeNodeData: activeNode

                Behavior on activeNodeData
                {
                    FadeAnimation
                    {
                        target: statsSideBarItem
                        fadeProperty: "contentOpacity"
                    }
                }
                Text
                {
                    color: "white"
                    text: "Temp: " + Math.round(parent.activeNodeData.temperature * 100) / 100 + " K"
                }
                Text
                {
                   color: "white"
                   text: "Enabled: " + parent.activeNodeData.enabled
                }
                Text
                {
                   color: "white"
                   text: "Surf area: " + parent.activeNodeData.surface_area + " m²"
                }
                Text
                {
                   color: "white"
                   text: "Max tmp: " + parent.activeNodeData.max_safe_temperature + " K"
                }
                Text
                {
                   color: "white"
                   text: "Con coef: " + parent.activeNodeData.heat_convection + " W/m K"
                }
                Text
                {
                   color: "white"
                   text: "H Emissivity: " + parent.activeNodeData.heat_emissivity
                }
                Repeater
                {
                    model: parent.activeNodeData.additionalProperties
                    Text
                    {
                        color: "white"
                        text: modelData.key + ": " + modelData.value
                    }
                }
            }

        }
        SidebarItem
        {
            id: connectSideBarItem
            title: "CONNECT"
            anchors.top: statsSideBarItem.bottom
            anchors.right: parent.right

            contents: Column
            {
                Repeater
                {
                    model: activeNode.modifiers
                    Text
                    {
                        text: modelData.name
                        color: "white"
                    }
                }
            }
        }
    }
}
