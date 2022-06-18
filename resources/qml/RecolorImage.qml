// This is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtGraphicalEffects 1.0

Item
{
    id: base

    property alias source: img.source
    property alias color: overlay.color
    property alias sourceSize: img.sourceSize

    Image
    {
        id: img
        anchors.fill: parent
        visible: false
        sourceSize.width: base.width
        sourceSize.height: base.height
    }

    ColorOverlay
    {
        id: overlay
        anchors.fill: parent
        source: img
        color: "#ffffff"
    }
}