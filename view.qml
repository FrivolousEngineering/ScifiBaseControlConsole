import QtQuick 2.0
import QtQuick.Controls 2.2

Rectangle
{
    width: 1000
    height: 1500
    color: "black"


    property var highlightedNode: null
    property var activeNode: null
    property int object_width: 450
    property int object_height: 350
    onHighlightedNodeChanged: mycanvas.requestPaint()
    ScrollView
    {
        anchors.fill: parent
        Canvas {
            id: mycanvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = Qt.rgba(0, 0, 0, 1);
                ctx.fillRect(0, 0, width, height);
                if(activeNode == null)
                {
                    return
                }
                var ctx = getContext("2d");
                ctx.strokeStyle = "red"
                ctx.lineWidth = 3
                ctx.fillStyle = Qt.rgba(0, 0, 0, 1);
                ctx.fillRect(0, 0, width, height);
                ctx.beginPath();

                var origin_x = activeNode.x
                var origin_y = activeNode.y;

                var spacing = 25

                var target_x = highlightedNode.x
                var target_y = highlightedNode.y;
                ctx.moveTo(origin_x, origin_y)

                var y_difference = origin_y - target_y
                var x_difference = origin_x - target_x
                if(y_difference < 0 && y_difference >= -object_height - spacing)
                {
                    print("case 1")
                    ctx.moveTo(origin_x + 0.5 * object_width, origin_y + object_height)
                    ctx.lineTo(origin_x + 0.5 * object_width, origin_y + 0.5 * spacing + object_height)
                    ctx.lineTo(target_x + 0.5 * object_width, target_y - 0.5 * spacing)
                    ctx.lineTo(target_x+ 0.5 * object_width, target_y)
                }
                else if(y_difference < 0)
                {

                    if(x_difference >= 0)
                    {
                        print("case 2")
                        ctx.moveTo(origin_x + 0.5 * object_width, origin_y + object_height)
                        ctx.lineTo(origin_x + 0.5 * object_width, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(origin_x - 0.5 * spacing, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(target_x + object_width + 0.5 * spacing, target_y - 0.5 * spacing)
                        ctx.lineTo(target_x + 0.5 * object_width, target_y - 0.5 * spacing)
                        ctx.lineTo(target_x+ 0.5 * object_width, target_y)
                    }else
                    {
                        print("case3")
                        ctx.moveTo(origin_x + 0.5 * object_width, origin_y + object_height)
                        ctx.lineTo(origin_x + 0.5 * object_width, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(origin_x + object_width + 0.5 * spacing, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(target_x - 0.5 * spacing, target_y - 0.5 * spacing)
                        ctx.lineTo(target_x + 0.5 * object_width, target_y - 0.5 * spacing)
                        ctx.lineTo(target_x+ 0.5 * object_width, target_y)
                    }

                }
                else if(y_difference > 0 && y_difference <= object_height + spacing)
                {
                    print("case 4")
                    ctx.moveTo(origin_x + 0.5 * object_width, origin_y)
                    ctx.lineTo(origin_x + 0.5 * object_width, origin_y - 0.5 * spacing)
                    ctx.lineTo(target_x + 0.5 * object_width, target_y + 0.5 * spacing + object_height)
                    ctx.lineTo(target_x+ 0.5 * object_width, target_y + object_height)
                }
                else
                {
                    if(x_difference >= 0)
                    {
                        print("case 5")
                        ctx.moveTo(origin_x + 0.5 * object_width, origin_y + object_height)
                        ctx.lineTo(origin_x + 0.5 * object_width, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(origin_x - 0.5 * spacing, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(target_x + object_width + 0.5 * spacing, target_y + object_height + 0.5 * spacing)
                        ctx.lineTo(target_x + 0.5 * object_width, target_y + object_height + 0.5 * spacing)
                        ctx.lineTo(target_x+ 0.5 * object_width, target_y + object_height)
                    }else
                    {
                        print("case6")
                        ctx.moveTo(origin_x + 0.5 * object_width, origin_y + object_height)
                        ctx.lineTo(origin_x + 0.5 * object_width, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(origin_x + object_width + 0.5 * spacing, origin_y + 0.5 * spacing + object_height)
                        ctx.lineTo(target_x - 0.5 * spacing, target_y + object_height + 0.5 * spacing)
                        ctx.lineTo(target_x + 0.5 * object_width, target_y + object_height+ 0.5 * spacing)
                        ctx.lineTo(target_x+ 0.5 * object_width, target_y + object_height)
                    }
                }




                //ctx.lineTo(target_x, target_y)
                ctx.stroke();
            }
        }


        Grid
        {
            id: grid
            spacing: 25
            columns: 2
            anchors.fill:parent
            Repeater
            {
                model: backend.nodeData
                NodeWidget
                {
                    id: node
                    controller: modelData
                    nodeName: modelData.id
                    opacity: 0.5
                    onConnectionHovered:
                    {
                        for(var n in grid.children)
                        {
                            if(grid.children[n].nodeName == node_id)
                            {
                                highlightedNode = grid.children[n]
                                break
                            }
                            highlightedNode = null
                        }
                        activeNode = node
                        mycanvas.requestPaint()
                    }

                    highlighted: node == highlightedNode
                    width: object_width
                    height: object_height

                }
            }
        }
    }
}
