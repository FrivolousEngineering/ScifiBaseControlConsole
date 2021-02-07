import QtQuick 2.0
import QtQuick.Controls 2.2

Item
{
    id: base
    implicitWidth: 250
    implicitHeight: width * 0.866025404
    property var contents: []
    property string title: ""

    property double contentOpacity: 1.

    property alias cornerSide: background.cornerSide

    property font titleFont: Qt.font({
        family: "Roboto",
        pixelSize: 18,
        bold: true,
        capitalization: Font.AllUppercase
    });

    onContentsChanged:
    {
        for(var i in contents)
        {
            contents.width = 0.75 * base.width
            contents.opacity = Qt.binding(function() { return base.contentOpacity })
        }
    }
    CutoffRectangle
    {
        id: background
        width: parent.width
        height: parent.height
        border.width: 3
        border.color: "#d3d3d3"
        color: "#666666"
        angleSize: 25
        cornerSide: CutoffRectangle.Direction.All

        CutoffRectangle
        {
            color: "#888888"
            border.width: -1
            angleSize: width
            cornerSide: CutoffRectangle.Direction.Right
            anchors.right: parent.right
            anchors.rightMargin: background.border.width + 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: background.border.width + 2 + 3
            anchors.top: parent.top
            anchors.topMargin: background.border.width + 2 + 3
            border.color: "#d3d3d3"
            width: 25 - 2 - 3

            CutoffRectangle
            {
                color: "#666666"
                border.width: -1
                height: background.height / 2
                width: parent.width / 3 * 2
                anchors.left: parent.left
                cornerSide: CutoffRectangle.Direction.Right
                anchors.verticalCenter: parent.verticalCenter
                angleSize: width
            }
        }

        CutoffRectangle
        {
            color: "#d3d3d3"
            border.width: -1
            angleSize: width
            cornerSide: CutoffRectangle.Direction.DownLeft
            anchors.right: parent.right
            anchors.rightMargin: background.border.width + 2
            anchors.top: parent.top
            anchors.topMargin: background.border.width + 2
            visible: background.cornerSide != CutoffRectangle.Direction.ExcludeBottomRight
            border.color: "#d3d3d3"
            width: 25 - 2 - 3 - 1
            height: width
        }

        CutoffRectangle
        {
            color: "#d3d3d3"
            border.width: -1
            angleSize: width
            cornerSide: CutoffRectangle.Direction.UpLeft
            anchors.right: parent.right
            anchors.rightMargin: background.border.width + 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: background.border.width + 2
            visible: background.cornerSide != CutoffRectangle.Direction.ExcludeTopRight
            border.color: "#d3d3d3"
            width: 25 - 2 - 3 - 1
            height: width
        }

        CutoffRectangle
        {
            color: "#888888"
            border.width: -1
            angleSize: width
            cornerSide: CutoffRectangle.Direction.Left
            anchors.left: parent.left
            anchors.leftMargin: background.border.width + 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: background.border.width + 2 + 3
            anchors.top: parent.top
            anchors.topMargin: background.border.width + 2 + 3
            border.color: "#d3d3d3"
            width: 25 - 2 - 3

            CutoffRectangle
            {
                color: "#666666"
                border.width: -1
                height: background.height / 2
                width: parent.width / 3 * 2
                anchors.right: parent.right
                cornerSide: CutoffRectangle.Direction.Left
                anchors.verticalCenter: parent.verticalCenter
                angleSize: width
            }
        }
    }

    Text
    {
        text: base.title
        visible: false
        color: "white"
        font: titleFont
        width: base.width / 3
        horizontalAlignment: Text.AlignRight
        transform:[
            Rotation { origin.x: 50; origin.y: 50; angle: 300},
            Translate{x: base.width / 3 * 2 + 30; y: base.height / 2 - 5}
        ]
    }

    Button
    {
        id: leftButton
        width: 20
        anchors.right: content.left
        anchors.bottom: parent.verticalCenter
        onClicked: content.setContentPosition(content.contentItem.contentY - content.availableHeight)
        enabled: content.contentItem.contentY - content.availableHeight >= 0
        background: Item{}
        visible: content.availableHeight < content.contentHeight
        opacity: contentOpacity
        contentItem: Text
        {
            opacity: enabled ? 1.0 : 0.3
            Behavior on opacity { NumberAnimation { duration: 150} }
            transform: Rotation { origin.x: 5; origin.y: 5; angle: 90}
            text: "<"
            color: "white"
            font.weight: Font.Bold
        }
    }
    Button
    {
        id: rightButton
        width: 20
        anchors.right: content.left
        anchors.top: parent.verticalCenter
        onClicked: content.setContentPosition(content.contentItem.contentY + content.availableHeight)
        enabled: content.contentHeight > content.contentItem.contentY + content.availableHeight
        visible: content.availableHeight < content.contentHeight
        opacity: contentOpacity
        background: Item {}
        contentItem: Text
        {
            opacity: enabled ? 1.0 : 0.3
            text: ">"
            transform: Rotation { origin.x: 5; origin.y: 5; angle: 90}
            Behavior on opacity { NumberAnimation { duration: 150} }
            color: "white"
            font.weight: Font.Bold
        }
    }

    ScrollView
    {
        id: content

        // Since we have to do some manual magic to get the scroll animation working with the manual buttons
        // We need to do some bookkeeping ourselves.
        property bool animationState: false

        // Same as with the animstate, we need to manually create the animation object. We unfortunately cant use
        // "Behavior on", since the contentItem doesn't exist on init of the scrollview
        function setContentPosition(new_pos)
        {
            if(animationState)
            {
                return  // Previous animation is still running.
            }
            var anim = Qt.createQmlObject ('import QtQuick 2.3; PropertyAnimation { }', content);
            anim.target = content.contentItem
            anim.property = "contentY"
            anim.from = content.contentItem.contentY
            anim.to = new_pos
            anim.duration = 200
            animationState = Qt.binding(function() { return anim.running })
            anim.restart();
        }

        clip: true
        contentWidth: 0.75 * base.width
        anchors
        {
            left: base.left
            right: base.right
            leftMargin: 0.125 * base.width
            rightMargin: 0.125 * base.width
            bottom: parent.bottom
            top: parent.top
            topMargin: 5
            bottomMargin: 5
        }
        contentChildren: base.contents
        contentData: base.contents

        ScrollBar.vertical: ScrollBar
        {
            policy: ScrollBar.AlwaysOff
            interactive: false
        }
    }
}