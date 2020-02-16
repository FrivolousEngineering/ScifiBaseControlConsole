import QtQuick 2.0
import QtQuick.Controls 2.2

Item
{
    id: base
    implicitWidth: 250
    implicitHeight: width * 0.866025404
    property var contents: []
    property string title: ""
    onContentsChanged:
    {
        for(var i in contents)
        {
            contents.width = 0.5 * base.width
        }
    }
    Hexagon
    {
        width: parent.width
        border.width: 5
    }

    Text
    {
        text: base.title
        color: "white"
        font.weight: Font.Bold
        font.pointSize: 15
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
        contentWidth: 0.5 * base.width
        anchors
        {
            left: base.left
            right: base.right
            leftMargin: 0.25 * base.width
            rightMargin: 0.25 * base.width
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