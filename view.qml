import QtQuick 2.0
import QtQuick.Controls 2.2

Rectangle
{
    width: 1024
    height: 768
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
                ctx.reset();
                if(activeNode == null)
                {
                    return
                }
                var ctx = getContext("2d");
                ctx.strokeStyle = "red"
                ctx.lineWidth = 3
                ctx.fillStyle = Qt.rgba(0, 0, 0, 1);
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

                ctx.stroke();
            }
        }


        Grid
        {
            id: grid
            spacing: 25
            columns: 2
            anchors.fill:parent
            visible: false
            Repeater
            {
                model: backend.nodeData
                NodeWidget
                {
                    id: node
                    controller: modelData
                    nodeName: modelData.id
                    opacity:
                    {
                        if(highlightedNode == node || activeNode == node || activeNode == null || highlightedNode == null)
                        {
                            return 1
                        }
                        return 0.1
                    }

                    Behavior on opacity
                    {
                        NumberAnimation { duration: 1000}
                    }
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
        Column
        {
            spacing: 5
            anchors.left: parent.left
            anchors.leftMargin: 3
            anchors.top:parent.top
            anchors.topMargin: 3
            HexagonNodeWidget
            {
                title: "Generator"
            }
            HexagonNodeWidget
            {
                title: "Water Tank"
                highlighted: true
            }
        }
        Column
        {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 50
            SidebarItem
            {
                contents: Text
                {
                    color: "white"
                    text: "<b>Lorem ipsum</b> <br>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam maximus eget velit at efficitur. <br> <br> Praesent condimentum tortor lacus, nec tincidunt justo laoreet vel. Donec velit lacus, fermentum quis lacus et, auctor tristique quam. Nam efficitur sagittis nisl. Nulla vitae sem bibendum, dignissim nunc mattis, venenatis nisl. Morbi suscipit vel ante eget pretium. Vestibulum venenatis lobortis pellentesque. Praesent non mi pellentesque, aliquet elit pellentesque, porttitor sem. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; "
                    wrapMode: Text.Wrap
                }
                title: "INFO"
            }
            SidebarItem
            {
                title: "STATS"
            }
            SidebarItem
            {
                title: "CONNECT"
            }
        }
    }
}
