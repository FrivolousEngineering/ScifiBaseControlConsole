import QtQuick 2.0

Item {

    id: connection

    property var origin: null
    property var end: null
    property color color: "red"
    property int object_width: 240
    property int object_height: 95
    property int spacing: 12


    function start() {
        if(origin != null && end != null)
        {
            canvas.addPoint( connection.origin.x + 0.5 * object_width, connection.origin.y + object_height)
            pathAnimation.start();
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        property var path: []

        onPaint: {
            if (path.length < 2)
            {
                return
            }

            var ctx = canvas.getContext('2d')

            ctx.reset()

            ctx.lineJoin = "round"
            ctx.lineCap="round"


            ctx.lineWidth = 2

            ctx.strokeStyle = connection.color
            ctx.fillStyle = connection.color

            var p1 = path[0]
            var p2 = path[1]
            ctx.beginPath();
            ctx.moveTo(p1.x, p1.y);

            for (var i = 1; i < path.length -1 ; i++)
            {
                p1 = path[i];
                p2 = path[i+1]
                var midPoint = midPointBtw(p1, p2);
                ctx.quadraticCurveTo(p1.x, p1.y, midPoint.x, midPoint.y);
            }
            ctx.lineTo(p2)
            ctx.stroke();


        }

        function midPointBtw(p1, p2) {
            return {
                x: p1.x + (p2.x - p1.x) / 2,
                y: p1.y + (p2.y - p1.y) / 2
            }
        }
        function addPoint(x, y) {
            path.push(Qt.point(x,y));
            canvas.requestPaint();
        }
    }

    PathInterpolator
    {
        id: pathInterpolate

        path: Path {
            startX: connection.origin.x + 0.5 * object_width
            startY: connection.origin.y + object_height + 0.5 * spacing

            PathLine
            {
                relativeX: connection.end.x < connection.origin.x ? -0.5 * object_width - 0.5 * spacing: 0.5 * object_width + 0.5 * spacing
                relativeY: 0
            }

            PathLine
            {
                y: connection.end.y + object_height + 0.5 * spacing
                relativeX: 0
            }
            PathLine
            {
                relativeY: 0
                x: connection.end.x + 0.5 * object_width
            }
        }
        NumberAnimation on progress {
            id: pathAnimation
            running:false
            from: 0
            to: 1
            duration: 1000
            onStopped:
            {
                canvas.addPoint( connection.end.x + 0.5 * object_width, connection.end.y + object_height + 0.5 * spacing)
                canvas.addPoint( connection.end.x + 0.5 * object_width, connection.end.y + object_height - 0.5 * spacing)
            }
        }

        onProgressChanged: {
            canvas.addPoint(pathInterpolate.x, pathInterpolate.y);
        }
    }
}
