import QtQuick 2.0

Item
{
    id: base
    Canvas
    {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        property real controlWidth: width / 3.75
        property real nameWidth: width - iconWidth - controlWidth
        property real iconWidth: width / 3.75

        property real cornerWidth: 15

        property real controlAngleWidth: 10
        property real controlAngleHeight: 15

        property real nameAngleWidth: 10
        property real nameAngleHeight: 10

        property real iconAngleWidth: 15
        property real iconAngleHeight: 10
        property real lineWidth: 2
        property int _lineWidthOffset: lineWidth / 2
        onPaint:
        {
            var ctx = canvas.getContext('2d')
            ctx.reset()
            ctx.lineJoin = "round"
            ctx.lineCap = "round"

            ctx.lineWidth = lineWidth

            ctx.strokeStyle = "blue"
            ctx.fillStyle = "gray"

            ctx.beginPath()
            ctx.moveTo(_lineWidthOffset, cornerWidth)
            ctx.lineTo(cornerWidth, _lineWidthOffset)
            ctx.lineTo(controlWidth - controlAngleWidth, _lineWidthOffset)
            ctx.lineTo(controlWidth, controlAngleHeight)

            ctx.lineTo(controlWidth + nameWidth - nameAngleWidth, controlAngleHeight)
            ctx.lineTo(controlWidth + nameWidth, controlAngleHeight + nameAngleHeight)

            ctx.lineTo(controlWidth + nameWidth + iconWidth - iconAngleWidth, controlAngleHeight + nameAngleHeight)
            ctx.lineTo(controlWidth + nameWidth + iconWidth - _lineWidthOffset, controlAngleHeight + nameAngleHeight + iconAngleHeight)
            ctx.lineTo(controlWidth + nameWidth + iconWidth - _lineWidthOffset, height - controlAngleHeight - nameAngleHeight - iconAngleHeight)
            ctx.lineTo(controlWidth + nameWidth + iconWidth - iconAngleWidth, height - controlAngleHeight - nameAngleHeight)
            ctx.lineTo(controlWidth + nameWidth + 0.5 * iconWidth, height - controlAngleHeight - nameAngleHeight)
            ctx.lineTo(controlWidth + nameWidth  + 0.5 * iconWidth - nameAngleWidth, height - controlAngleHeight)

            ctx.lineTo(controlWidth, height - controlAngleHeight)
            ctx.lineTo(controlWidth - controlAngleWidth, height - _lineWidthOffset)
            ctx.lineTo(_lineWidthOffset, height - _lineWidthOffset)
            ctx.lineTo(_lineWidthOffset, cornerWidth)
            ctx.fill()
            ctx.stroke()
        }
    }
}
