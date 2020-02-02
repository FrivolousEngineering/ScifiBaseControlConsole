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

    property variant temperatureData: []

    onTemperatureDataChanged:
    {
        temperatureSplineSeries.clear()
        for(var i in temperatureData)
        {
            temperatureSplineSeries.append(i, temperatureData[i])
        }
    }

    implicitWidth: 700
    implicitHeight: 700
    Rectangle
    {
        id: background
        anchors.fill: parent
        color: "#16161d"
        border.width: 1
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
            right: parent.right
            bottom: parent.bottom
        }
        Button
        {
            id: button
            text: "UPDATE"
            onClicked: controller.update()
        }
        ChartView
        {
            anchors
            {
                top: button.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            antialiasing: true
            theme: ChartView.ChartThemeDark

            AutoUpdatingSplineSeries
            {
                id: temperatureSplineSeries
                name: "Temperature"
            }
        }
    }
}