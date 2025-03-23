import QtQuick 2.12

Rectangle {
    id: root
    property bool vertical: false
    required property var entity
    required property string type

    property var connection: null

    color: 'transparent'
    width: 10
    height: 10
}
