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
        border.color: "white"
    }

    Rectangle
    {
        id: titleBar
        border.width: borderWidth
        border.color: "white"
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
                }
            }
            ScrollView
            {
                id: subMenuBar
                anchors
                {
                    margins: defaultMargin
                    left: parent.left
                    right: parent.right
                }
                height: visible ? contentHeight: 0
                visible: content.activeMainMenu == "history"
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

            ChartView
            {
                visible: content.activeMainMenu == "history"
                anchors.fill: parent
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
        }
    }
}