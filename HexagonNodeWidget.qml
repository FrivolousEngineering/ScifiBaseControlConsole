import QtQuick 2.0
import QtQuick.Controls 2.3

Item
{
    id: base
    implicitWidth: 240
    implicitHeight: 95
    property alias title: titleText.text
    property bool highlighted: false
    property double angleSize: 15

    property color borderColor: hovered ? "white": "#BA6300"
    property bool hovered: false

    signal clicked()

    MouseArea
    {
        anchors.fill: base
        hoverEnabled: true
        onEntered: hovered = true
        onExited: hovered = false
        onClicked: base.clicked()
    }

    Item
    {
        id: title
        height: parent.height
        width: 35
        CutoffRectangle
        {
            anchors.fill: parent
            cornerSide: CutoffRectangle.Direction.UpLeft
            color: base.highlighted ? background.border.color : "#333333"
            border.color: base.borderColor
            angleSize: base.angleSize
            CutoffRectangle
            {
                anchors.fill: parent
                anchors.margins: 3
                angleSize: base.angleSize - 2
                cornerSide: CutoffRectangle.Direction.UpLeft
                border.color: base.borderColor
            }
        }
        Text
        {
            id: titleText
            color: "white"
            text: ""
            width: parent.height
            height: 50
            anchors.left: parent.left
            anchors.leftMargin: 8
            horizontalAlignment: Text.AlignHCenter
            transform: Rotation { origin.x: 50; origin.y: 50; angle: 270}
            font.pointSize : 9
            font.weight: Font.Bold
        }
    }
    Item
    {
        id: content
        height: parent.height
        anchors.right: parent.right
        anchors.left: title.right
        anchors.leftMargin: -3
        CutoffRectangle
        {
            id: background
            anchors.fill: parent
            cornerSide: CutoffRectangle.Direction.Right
            color: base.highlighted ? background.border.color : "#333333"
            angleSize: base.angleSize
            border.color: base.borderColor
            CutoffRectangle
            {
                anchors.fill: parent
                anchors.margins: 3
                cornerSide: CutoffRectangle.Direction.Right
                angleSize: base.angleSize - 2
                border.color: base.borderColor

                CustomDial
                {
                    anchors.top: parent.top
                    anchors.topMargin: 3
                    anchors.bottomMargin: 3
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 3
                    width: height
                }
            }
        }
    }
}