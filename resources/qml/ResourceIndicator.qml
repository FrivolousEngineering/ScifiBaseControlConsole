import QtQuick 2.0

CutoffRectangle
{
    function getResourceColor(resource_type)
    {
        switch(resource_type)
        {
            case "water":
                return "blue"
            case "fuel":
                return "red"
            case "energy":
                return "yellow"
            case "waste":
            case "animal_waste":
                return "brown"
            case "dirty_water":
                return "#533749"
            case "oxygen":
                return "white"
            case "plants":
                return "#006600"
            case "food":
                return "green"
            case "plant_oil":
                return "#405015"
            default:
                return "pink"
        }
    }

    function getResourceAbbreviation(resource_type)
    {
        switch(resource_type)
        {
            case "water":
                return "wat"
            case "fuel":
                return "fue"
            case "energy":
                return "eng"
            case "waste":
                return "was"
            case "animal_waste":
                return "awa"
            case "dirty_water":
                return "dwt"
            case "oxygen":
                return "oxy"
            case "plants":
                return "pla"
            case "food":
                return "fod"
            case "plant_oil":
                return "plo"
            default:
                return "unk"
        }
    }

    property string type

    width: parent.width
    height: width
    color: getResourceColor(type)
    angleSize: 4
    property double value

    Behavior on value { NumberAnimation { duration: 1000 } }

    Text
    {
        id: resourceTypeText
        text: getResourceAbbreviation(modelData.type)
        font.pixelSize: 10
        font.bold: true
        font.family: "Roboto"
        font.capitalization: Font.AllUppercase
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 2
        // TODO: properly fix this.
        color: getResourceColor(type) != "yellow" && getResourceColor(type) != "white" ? "white": "black"
        horizontalAlignment: Text.AlignHCenter
        height: contentHeight
    }
    Text
    {
        text: Math.round(value)
        font.pixelSize: 10
        font.bold: true
        font.family: "Roboto"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        // TODO: properly fix this.
        color: getResourceColor(type) != "yellow" && getResourceColor(type) != "white" ? "white": "black"
        horizontalAlignment: Text.AlignHCenter
    }
}