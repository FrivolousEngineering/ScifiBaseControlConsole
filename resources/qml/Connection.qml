import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: connection

    property var origin: null
    property var end: null
    property color color: "red"
    property int object_width: 240
    property int object_height: 95
    property int spacing: 12
    property int offset_x: spacing
    property int offset_y: spacing

    property bool _is_valid: connection.origin != undefined

    function start() {
        if(origin != null && end != null)
        {
            canvas.addPoint(connection.origin.x + 0.5 * object_width, connection.origin.y + object_height)
            pathAnimation.start()
        }
    }

    Glow {
        id: glow
        anchors.fill: parent
        radius: 10
        samples: 15
        color: connection.color
        spread: 0.3
        source: canvas
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Cooperative

        property var path: []

        onPaint: {
            if (path.length < 2) { return }

            var ctx = canvas.getContext('2d')

            ctx.reset()

            ctx.lineJoin = "round"
            ctx.lineCap = "round"

            ctx.lineWidth = 2

            ctx.strokeStyle = connection.color
            ctx.fillStyle = connection.color

            var p1 = path[0]
            var p2 = path[1]
            ctx.beginPath()
            ctx.moveTo(p1.x, p1.y)

            for (var i = 1; i < path.length -1 ; i++)
            {
                p1 = path[i]
                p2 = path[i+1]
                var midPoint = midPointBtw(p1, p2)
                ctx.quadraticCurveTo(p1.x, p1.y, midPoint.x, midPoint.y)
            }
            ctx.lineTo(p2)
            ctx.stroke()
        }

        function midPointBtw(p1, p2) {
            return {
                x: p1.x + (p2.x - p1.x) / 2,
                y: p1.y + (p2.y - p1.y) / 2
            }
        }
        function addPoint(x, y) {
            path.push(Qt.point(x + connection.offset_x, y + connection.offset_y))
            canvas.requestPaint()
        }
    }

    Path
    {
        id: connectionPath

        startX: connection.origin.x + 0.5 * object_width
        startY: connection.origin.y + object_height + 0.5 * spacing

        PathLine
        {
            x: connection.end.x - 0.5 * spacing
            relativeY: 0
        }
        PathLine
        {
            relativeX: 0
            y: connection.end.y + 0.5 * object_height
        }
    }

    PathInterpolator
    {
        id: motionPath
        path: connectionPath

        NumberAnimation on progress {
            id: particleAnimation
            from: 0; to: 1;
            duration: 2 * animationDuration;
            running: !pathAnimation.running
            loops: Animation.Infinite
        }
    }
    Rectangle
    {
        width: 4;
        height: 4
        color: "white"
        radius: 2

        //bind our attributes to follow the path as progress changes
        x: motionPath.x + connection.offset_x - 0.5 * width
        y: motionPath.y + connection.offset_y - 0.5 * height
        rotation: motionPath.angle
        visible: connection._is_valid && particleAnimation.running
    }

    property int animationDuration:
    {
        var x_difference = Math.abs(connection.origin.x - connection.end.x)
        var y_difference = Math.abs(connection.origin.y - connection.end.y)
        // Since we only go straight lines, this is actually true ;)
        var distance = x_difference + y_difference
        return Math.max(5 * distance, 1200)
    }

    PathInterpolator
    {
        id: pathInterpolate

        path: connectionPath

        NumberAnimation on progress {
            id: pathAnimation
            running: false
            from: 0
            to: 1
            duration: animationDuration

            onStopped:
            {
                canvas.addPoint( connection.end.x - 0.5 * spacing, connection.end.y + 0.5 * object_height)
                canvas.addPoint( connection.end.x + 0.5 * spacing, connection.end.y + 0.5 * object_height)
            }
            easing.type: Easing.InOutCubic
        }

        onProgressChanged: canvas.addPoint(pathInterpolate.x, pathInterpolate.y)
    }
}
