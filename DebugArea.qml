import QtQuick 2.0

Rectangle {
    property alias text: name.text

    border.width: 1
    border.color: "red"
    color: "transparent"
//    visible: false

    Text {
        id: name
        anchors.fill: parent
        color: parent.border.color
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
    }
}
