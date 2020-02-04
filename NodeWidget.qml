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
    property int borderWidth: 1
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
        border.width: 1
        border.color: "white"
        width: parent.width
        height: 20
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
        }
    }

    Item
    {
        id: content
        anchors
        {
            top: titleBar.bottom
            left: parent.left
            rightMargin: borderWidth
            right: parent.right
            leftMargin: borderWidth
            bottom: parent.bottom
        }

        ScrollView
        {
            id: menuBar
            width: parent.width
            clip: true
            Row
            {
                spacing: 2
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
            anchors
            {
                top: menuBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
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
}