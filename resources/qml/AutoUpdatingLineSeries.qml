import QtCharts 2.0
LineSeries
{
    id: splineSeries

    property double yMin: 10000
    property double yMax: 0
    property double xMin: 10000
    property double xMax: 0

    function resetMinMax()
    {
        yMin = 10000
        yMax = 0
        xMin = 10000
        xMax = 0
    }

    axisY: ValueAxis
    {
        gridVisible: false
        labelsVisible: false
        lineVisible: false
        visible: false
    }
    axisX: ValueAxis
    {
        tickCount: 50
        labelsVisible: false
        visible: false
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
            splineSeries.axisY.min = Math.max(yMin - 10, 0)
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