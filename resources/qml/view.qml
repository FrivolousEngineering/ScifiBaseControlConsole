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
    color: "#1a1a1a"

    property var highlightedNode: null
    property var activeNode: backend.nodeData[0]
    property int object_width: 240
    property int object_height: 95
    property int activeNodeIndex: 0

    property string activeProperty: "temperature"

    //property variant activeNodeGraphData: activeNode.historyData[activeProperty]

    property color border_color: "#d3d3d3"
    property color text_color: "white"

    property font myFont: Qt.font({
        family: "Roboto",
        pixelSize: 13
    });

    Image
    {
        anchors.fill: parent
        source: "background_hexes.png"
        fillMode: Image.PreserveAspectFit
    }

    function showModifierWindow(nodeId)
    {
        addModifierWindow.nodeObject = backend.getNodeById(nodeId)
        addModifierWindow.visible = true
    }

    ScrollView
    {
        anchors.fill: parent
        Grid
        {
            id: grid
            spacing: 40
            anchors.left: parent.left
            anchors.leftMargin: 40
            columns: 4
            columnSpacing: 65

            Instantiator
            {
                model: backend.nodeData
                asynchronous: true
                onObjectAdded:
                {
                    object.parent = grid
                    object.opacity = 1 // Force the animation
                }
                onObjectRemoved: object.parent = null

                Node
                {
                    titleText: modelData.id
                    currentTemperature: modelData.temperature
                    previousTemperature: modelData.historyData["temperature"][Math.max(modelData.historyData["temperature"].length -5, 0)]
                    historyTemperature: modelData.historyData["temperature"][Math.max(modelData.historyData["temperature"].length -20, 0)]
                    maxSafeTemperature: modelData.max_safe_temperature
                    maxTemperature: modelData.max_safe_temperature + 25
                    optimalTemperature: modelData.optimalTemperature
                    isTemperatureDependant: modelData.isTemperatureDependant
                    minTemperature: 288.15 // 15 degrees kelvin
                    opacity: 0
                    controller: modelData
                    onAddModifierClicked: showModifierWindow(nodeId)

                    Behavior on opacity { NumberAnimation { duration: 1000; easing.type: Easing.InOutCubic } }
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
        onModifierAdded:
        {
            backend.getNodeById(nodeId).addModifier(type)
        }
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

    Item
    {
        anchors.fill: parent
        visible: backend.authenticationRequired
        Rectangle
        {
            opacity: 0.9
            color: "black"
            anchors.fill: parent
        }
        Text
        {
            id: authRequiredText
            text: "AUTHENTICATION REQUIRED"
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 40
            font.family: "Roboto"
        }
        Text
        {

            text: "CARD READER NOT ATTACHED"
            anchors.top: authRequiredText.bottom
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !backend.authenticationScannerAttached
        }
    }



    /*onActiveNodeGraphDataChanged:
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
                    opacity: highlighted || hovered ? 1 : 0.5
                    Behavior on opacity { NumberAnimation { duration: 150} }
                }
            }
        }

        Button
        {
            id: chartButton
            anchors.verticalCenter: infoSidebarItem.bottom
            anchors.verticalCenterOffset: 5
            anchors.right: infoSidebarItem.left
            anchors.rightMargin: -10

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
                    color: window.text_color
                    anchors.top: parent.top
                    text: "Highest\n" + Math.round(historyGraph.yMax * 100) / 100
                    visible: !chartButton.collapsed
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 18
                }
                Text
                {
                    color: window.text_color
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
                    color: window.text_color
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
                border.color: "#d3d3d3"
            }
        }

        SidebarItem
        {
            id: infoSidebarItem
            anchors.right: parent.right
            anchors.rightMargin: 3
            anchors.topMargin: 20
            anchors.top: parent.top
            cornerSide: CutoffRectangle.Direction.ExcludeBottomRight

            contents: Text
            {
                id: infoText
                color: window.text_color
                property QtObject activeNodeData: activeNode
                text: activeNodeData.description
                font: myFont
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
            anchors.topMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 3
            cornerSide: CutoffRectangle.Direction.Left

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
                    color: window.text_color
                    text: "Temp: " + Math.round(parent.activeNodeData.temperature * 100) / 100 + " K"
                    font: myFont
                }
                Text
                {
                   color: window.text_color
                   text: "Enabled: " + parent.activeNodeData.enabled
                   font: myFont
                }
                Text
                {
                   color: window.text_color
                   text: "Surf area: " + parent.activeNodeData.surface_area + " m²"
                   font: myFont
                }
                Text
                {
                   color: window.text_color
                   text: "Max tmp: " + parent.activeNodeData.max_safe_temperature + " K"
                   font: myFont
                }
                Text
                {
                   color: window.text_color
                   text: "Con coef: " + parent.activeNodeData.heat_convection + " W/m K"
                   font: myFont
                }
                Text
                {
                   color: window.text_color
                   text: "H Emissivity: " + parent.activeNodeData.heat_emissivity
                   font: myFont
                }
                Repeater
                {
                    model: parent.activeNodeData.additionalProperties
                    Text
                    {
                        color: window.text_color
                        text: modelData.key + ": " + Math.round(modelData.value * 100) / 100
                        font: myFont
                    }
                }
            }

        }
        SidebarItem
        {
            id: connectSideBarItem
            title: "CONNECT"
            anchors.top: statsSideBarItem.bottom
            anchors.topMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 3
            cornerSide: CutoffRectangle.Direction.ExcludeTopRight
            contents: Column
            {
                Repeater
                {
                    model: activeNode.modifiers
                    Text
                    {
                        text: modelData.name
                        color: window.text_color
                        font: myFont
                    }
                }
            }
        }
    }

    Item
    {
        id: connectionIssuesOverlay
        anchors.fill: parent
        Rectangle
        {
            anchors.fill: parent
            opacity: 0.5
            color: "black"
        }

        // Prevent actions from being taken when the server can't be reached.
        MouseArea
        {
            hoverEnabled: true
            anchors.fill: parent
        }

        Text
        {
            text: "WAITING FOR SERVER"
            color: "white"
            anchors.centerIn: parent
            font.pixelSize: 50
        }
        visible: !backend.serverReachable
    }*/
}
