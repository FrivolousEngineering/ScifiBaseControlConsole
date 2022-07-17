import QtCharts 2.15
import QtQuick 2.0
import QtQuick.Controls 2.2

Rectangle
{
    id: window
    width: 925 + 30
    height: 750
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
    Text
    {
        color: "white"
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 50
        font.family: "Futura Md BT"
        text: Math.round(historyGraph.yMax * 100) / 100
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 16
    }
    Text
    {
        color: "white"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 50
        font.family: "Futura Md BT"
        text: Math.round(historyGraph.yMin * 100) / 100

        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 16
    }
    Text
    {
        id: selectedPointText
        anchors.bottom: parent.bottom
        font.family: "Futura Md BT"
        width: parent.width / 3
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
        text: ""
        horizontalAlignment: Text.AlignHCenter
    }
    Button
    {
        id: closeButton
        text: "X"
        onClicked: window.visible = false
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.rightMargin: 10
        width: 32
        height: 32
        background: Item {}
        contentItem: Label {
            text: "X"
            font.pointSize: 20
            opacity: enabled ? 1.0 : 0.3
            color: "white"
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