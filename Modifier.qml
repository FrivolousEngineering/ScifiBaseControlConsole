import QtQuick 2.0

CutoffRectangle
{
    property string name
    property double duration
    implicitWidth: height
    implicitHeight: parent.height
    color: "transparent"
    angleSize: 4
    Behavior on duration { NumberAnimation { duration: 1000 } }


    Text
    {
        id: resourceTypeText
        text: getModifierAbbreviation(name)
        font.pixelSize: 10
        font.bold: true
        font.family: "Roboto"
        font.capitalization: Font.AllUppercase
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 2
        // TODO: properly fix this.
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        height: contentHeight
    }

    Text
    {
        text: Math.round(duration)
        font.pixelSize: 10
        font.bold: true
        font.family: "Roboto"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        // TODO: properly fix this.
        color: "white"
        horizontalAlignment: Text.AlignHCenter
    }

    function getModifierAbbreviation(name)
    {
        switch(name)
        {
            case "Override default safety":
                return "ODS"
            default:
                return "UNK"
        }
    }
}