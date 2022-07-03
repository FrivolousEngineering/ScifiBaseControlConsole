import QtQuick 2.0
import QtQuick.Controls 2.2

Button
{
    id: control
    property alias iconSource: icon.source

    implicitWidth: 80
    implicitHeight: 72

    background: Item {}

    contentItem: Item
    {
        RecolorImage
        {
            id: icon
            anchors.horizontalCenter: parent.horizontalCenter
            source: iconSource
            width: 27
            height: 28
            color: control.checked ? "white": "#9499C3"
        }
        Label
        {
            anchors
            {
                top: icon.bottom
                horizontalCenter: parent.horizontalCenter
                topMargin: 6
            }
            font.family: "Futura Md BT"
            font.pixelSize: 12
            color: control.checked ? "white": "#9499C3"
            text: control.text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle
        {
            id: checkedIndicator
            visible: control.checked
            width: parent.width
            height: 4
            radius: height
            anchors.bottom: parent.bottom
        }
    }
}