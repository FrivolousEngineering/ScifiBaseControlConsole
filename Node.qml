import QtQuick 2.0

Item
{
    id: base
    property double angleSize: 20
    property double sideBarWidth: 25
    property double sideBarAngle: angleSize / 3
    property int borderSize: 2
    property int barSpacing: 2

    property alias titleText: title_text.text

    property font titleFont: Qt.font({
            family: "Roboto",
            pixelSize: 14,
            bold: true,
            capitalization: Font.AllUppercase
        });

    implicitWidth: 200
    implicitHeight: 150

    CutoffRectangle
    {
        id: input
        anchors
        {
            top: parent.top
            bottom: parent.bottom
            bottomMargin: parent.angleSize
            topMargin: parent.angleSize
        }
        angleSize: sideBarAngle
        cornerSide: CutoffRectangle.Direction.Left
        width: sideBarWidth
        border.width: borderSize
    }

    CutoffRectangle
    {
        id: main
        anchors
        {
            left: input.right
            right: output.left
            top: parent.top
            bottom: parent.bottom
        }
        angleSize: parent.angleSize
        border.width: borderSize

        CutoffRectangle
        {
            id: healthBar
            color: "white"
            cornerSide: CutoffRectangle.Direction.Down
            anchors
            {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                leftMargin: barSpacing + 2 * borderSize + 1
                rightMargin: barSpacing + 2 * borderSize
                bottomMargin: barSpacing + borderSize
            }
            border.width: 0
            border.color: "transparent"

            angleSize: height
            height: base.angleSize - 2 * borderSize - 0.5 * barSpacing
        }

        CutoffRectangle
        {
            id: titleBar
            color: "white"
            cornerSide: CutoffRectangle.Direction.Up
            anchors
            {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: barSpacing + 2 * borderSize + 1
                rightMargin: barSpacing + 2 * borderSize
                topMargin: barSpacing + borderSize
            }
            border.width: 0
            border.color: "transparent"

            angleSize: height
            height: base.angleSize - 2 * borderSize - 0.5 * barSpacing

            Text
            {
                id: title_text
                text: "undefined"
                color: "black"
                font: titleFont
                horizontalAlignment: Text.AlignHCenter
                anchors
                {
                    left: parent.left
                    right: parent.right
                    leftMargin: angleSize
                    rightMargin: angleSize
                }
            }

        }
    }

    CutoffRectangle
    {
        id: output
        anchors
        {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            bottomMargin: parent.angleSize
            topMargin: parent.angleSize
        }

        angleSize: sideBarAngle
        cornerSide: CutoffRectangle.Direction.Right
        width: sideBarWidth
        border.width: borderSize
    }
}
