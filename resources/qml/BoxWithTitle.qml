import QtQuick 2.0
CutoffRectangle
{
    angleSize: 2
    property alias titleText: title.text
    default property alias contents: placeholder.children
    property alias font: title.font
    property alias titleColor: title.color
    Text
    {
        id: title
        height: contentHeight
        text: ""
        font: Qt.font({
            family: "Roboto",
            pixelSize: 8,
            bold: true,
            capitalization: Font.AllUppercase
        });
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Item
    {
        id: placeholder
        anchors
        {
            left: parent.left
            right: parent.right
            top: title.bottom
            bottom: parent.bottom
            bottomMargin: parent.angleSize + 1
            leftMargin: 2
            rightMargin: 2
        }
    }
}