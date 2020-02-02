import QtCharts 2.3
SplineSeries
{
    id: splineSeries

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