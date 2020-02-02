import QtQuick 2.0
import QtCharts 2.3


Item
{
    id: base
    property alias backgroundColor: background.color
    property string nodeName: ""

    property double temperature: 290

    property variant temperatureData: []

    onTemperatureDataChanged:
    {
        for(var i in temperatureData)
        {
            splineSeries.append(i, temperatureData[i])
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

        ChartView
        {
            anchors.fill: parent
            antialiasing: true
            theme: ChartView.ChartThemeDark

            SplineSeries
            {
                id: splineSeries
                name: "Temperature"
                property double yMin: 10000
                property double yMax: 0
                property double xMin: 10000
                property double xMax: 0

                axisX: ValueAxis
                {
                    tickType: ValueAxis.TicksDynamic
                    tickInterval: 1
                    tickAnchor: 0
                }

                onPointAdded:
                {
                    // Calculate new min/max values
                    var y_value = splineSeries.at(index).y
                    if(y_value< yMin || y_value > yMax)
                    {
                        if(y_value < yMin)
                        {
                            yMin = y_value;
                        }
                        if(y_value > yMax)
                        {
                            yMax = y_value;
                        }
                        splineSeries.axisY.min = 0
                        splineSeries.axisY.max = yMax + 10
                    }

                    var x_value = splineSeries.at(index).x
                    if(x_value< xMin || x_value > xMax)
                    {
                        if(x_value < xMin)
                        {
                            xMin = x_value;
                        }
                        if(x_value > xMax)
                        {
                            xMax = x_value;
                        }
                        splineSeries.axisX.min = xMin
                        splineSeries.axisX.max = xMax + 1
                    }
                }

            }

            Component.onCompleted:
            {

            }
        }
    }
}