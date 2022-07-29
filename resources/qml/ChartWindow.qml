import QtCharts 2.15
import QtQuick 2.0
import QtQuick.Controls 2.2

Rectangle
{
    id: window
    width: 650 + 30
    height: 650
    anchors.centerIn: parent
    property string activeProperty: "temperature"
    property variant activeData: selectedNodeData.historyData[activeProperty]
    color: "#06071E"
    border.width: 2
    border.color: "white"
    radius: 10

    onActiveDataChanged:
    {
        historyGraph.clear()
        historyGraph.resetMinMax()
        for(var i in activeData)
        {
            historyGraph.append(i, activeData[i])
        }
    }
    ChartView
    {
        id: chartView
        animationOptions: ChartView.SeriesAnimations
        antialiasing: true
        anchors
        {
            margins: 10
            top: parent.top
            right: attributeList.left
            left: parent.left
            bottom: parent.bottom
        }
        backgroundColor: "transparent"
        legend.visible: false

        AutoUpdatingLineSeries
        {
            id: historyGraph
            color: "#00D1FF"
            width: 3
            onHovered: selectedPointText.text =  Math.round(point.y * 100) / 100
        }
    }
    OurLabel
    {
        anchors
        {
            top: parent.top
            topMargin: 10
            left: parent.left
            leftMargin: 50
        }
        text: Math.round(historyGraph.yMax * 100) / 100
        horizontalAlignment: Text.AlignHCenter
    }
    OurLabel
    {
        anchors
        {
            bottom: parent.bottom
            bottomMargin: 10
            left: parent.left
            leftMargin: 50
        }

        text: Math.round(historyGraph.yMin * 100) / 100

        horizontalAlignment: Text.AlignHCenter
    }
    OurLabel
    {
        id: selectedPointText
        anchors.bottom: parent.bottom
        width: parent.width / 3
        anchors.horizontalCenter: parent.horizontalCenter
        text: ""
        horizontalAlignment: Text.AlignHCenter
    }
    Button
    {
        id: closeButton
        onClicked: window.visible = false
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.rightMargin: 10
        width: 32
        height: 32
        background: Item {}
        contentItem: OurLabel {
            text: "X"
            font.pixelSize: 32
            opacity: enabled ? 1.0 : 0.3
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    Column
    {
        id: attributeList
        anchors.right: parent.right
        anchors.top: closeButton.bottom
        anchors.bottom: parent.bottom
        anchors.margins: 10
        width: 175
        Repeater
        {
            model: selectedNodeData.allHistoryProperties
            OurButton
            {
                text: modelData
                width: 175
                onClicked: window.activeProperty = modelData
                highlighted: window.activeProperty == modelData
            }
        }
    }
}