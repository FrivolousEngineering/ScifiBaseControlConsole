import QtQuick 2.0
import QtCharts 2.3
import QtQuick.Controls 2.2


Item
{
    id: base
    property alias backgroundColor: background.color
    property string nodeName: ""

    property double temperature: 290
    property var controller: null
    property string activeProperty: "temperature"
    property variant temperatureData:  controller.historyData[activeProperty]
    property variant activeData: controller.historyData[activeProperty]
    property int borderWidth: 3

    property color borderColor: highlighted ?  "red":  "white"  // To ensure it jumps back to white again.

    SequentialAnimation on borderColor{
        running: highlighted
        loops: Animation.Infinite
        ColorAnimation { from: "white"; to: "red"; duration: 300 }
        ColorAnimation { from: "red"; to: "white";  duration: 300 }
    }


    property bool highlighted: false

    signal connectionHovered(string node_id)


    property int defaultMargin: 3
    onActiveDataChanged:
    {
        historyGraph.clear()
        historyGraph.resetMinMax()
        for(var i in activeData)
        {
            historyGraph.append(i, activeData[i])
        }
    }

    implicitWidth: 500
    implicitHeight: 500
    Rectangle
    {
        id: background
        anchors.fill: parent
        color: "#16161d"
        border.width: borderWidth
        border.color: borderColor
    }

    Rectangle
    {
        id: titleBar
        border.width: borderWidth
        border.color: borderColor
        width: parent.width
        height: 50
        color: "transparent"  // We only want this for the border.
        anchors
        {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        Text
        {
            text: nodeName
            anchors.centerIn: parent
            color: "white"
            font.pointSize : 20
            font.weight: Font.Bold
        }
    }

    Item
    {
        id: content
        anchors
        {
            top: titleBar.bottom
            topMargin: defaultMargin
            left: parent.left
            rightMargin: borderWidth
            right: parent.right
            leftMargin: borderWidth
            bottom: parent.bottom
        }

        property string activeMainMenu: "history"


        Column
        {
            id: menuBar
            spacing: defaultMargin
            anchors.left: parent.left
            anchors.right: parent.right
            ScrollView
            {
                id: mainMenuBar
                anchors
                {
                    margins: defaultMargin
                    left: parent.left
                    right: parent.right
                }
                clip: true
                Row
                {
                    spacing: defaultMargin
                    Button
                    {
                        text: "History"
                        highlighted: content.activeMainMenu == "history"
                        onClicked: content.activeMainMenu = "history"
                    }
                    Button
                    {
                        text: "Controls"
                        highlighted: content.activeMainMenu == "control"
                        onClicked: content.activeMainMenu = "control"
                    }
                    Button
                    {
                        text: "Connections"
                        highlighted: content.activeMainMenu == "connection"
                        onClicked: content.activeMainMenu = "connection"
                    }
                }
            }

        }


        Item
        {
            anchors
            {
                top: menuBar.bottom
                topMargin: defaultMargin
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }


            Item
            {
                visible: content.activeMainMenu == "history"
                anchors.fill: parent
                ScrollView
                {
                    id: subMenuBar
                    anchors
                    {
                        margins: defaultMargin
                        left: parent.left
                        right: parent.right
                    }


                    clip: true
                    Row
                    {
                        spacing: defaultMargin
                        Repeater
                        {
                            model: controller.allHistoryProperties

                            Button
                            {
                                text: modelData
                                onClicked:
                                {
                                    controller.update()
                                    activeProperty = modelData
                                }
                                highlighted: modelData == activeProperty
                            }
                        }
                    }
                }
                ChartView
                {
                    visible: content.activeMainMenu == "history"
                    anchors.top: subMenuBar.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    antialiasing: true
                    theme: ChartView.ChartThemeDark

                    AutoUpdatingLineSeries
                    {
                        id: historyGraph
                        name: activeProperty
                        color: "red"
                        width: 3
                    }
                }
            }


            Item
            {
                id: "controls_page"
                visible: content.activeMainMenu == "control"
                anchors.left: parent.left
                anchors.margins: defaultMargin
                Button
                {
                    text: controller.enabled ? "Disable": "Enable"
                    onClicked: controller.toggleEnabled()
                }
            }

            Item
            {
                id: "connections_page"
                visible: content.activeMainMenu == "connection"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: defaultMargin

                ScrollView
                {
                    anchors.fill: parent
                    Column
                    {
                        spacing: defaultMargin
                        Text
                        {
                            text: "Incoming Connections"
                            color: "white"
                            font.pointSize : 15
                            font.weight: Font.Bold
                        }
                        id: incomingConnections
                        width: parent.width / 2
                        Repeater
                        {
                            model: controller.incomingConnections

                            ConnectionWidget
                            {
                                text: modelData["origin"]
                                resourceType: modelData["resource_type"]
                                onHoveredChanged:
                                {
                                    if(hovered){base.connectionHovered(text)}
                                    else {base.connectionHovered("")}
                                }
                                borderColor: base.borderColor
                                borderWidth: base.borderWidth
                            }
                        }
                    }
                    Column
                    {
                        id: outgoingConnections
                        width: parent.width / 2
                        anchors.left: incomingConnections.right
                        spacing: defaultMargin
                        Text
                        {
                            text: "Outgoing Connections"
                            color: "white"
                            font.pointSize : 15
                            font.weight: Font.Bold
                        }
                        Repeater
                        {
                            model: controller.outgoingConnections

                            ConnectionWidget
                            {
                                text: modelData["target"]
                                resourceType: modelData["resource_type"]
                                onHoveredChanged:
                                {
                                    if(hovered){base.connectionHovered(text)}
                                    else {base.connectionHovered("")}
                                }
                                borderColor: base.borderColor
                                borderWidth: base.borderWidth
                            }
                        }
                    }
                }
            }
        }
    }
}