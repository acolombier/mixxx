import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import "Theme"

Item {
    id: root
    required property list<string> options
    property string selected: options.length ? options[0] : null
    property real spacing: 9
    property bool normalizedWidth: true

    FontMetrics {
        id: fontMetrics
        font.pixelSize: 14
        font.capitalization: Font.AllUppercase
    }

    height: content.height + dropRatio.radius * 2
    width: content.width + dropRatio.radius * 2
    readonly property real cellSize: {
        Math.max.apply(null, options.map((option) => fontMetrics.advanceWidth(option))) + root.spacing*2
    }

    Rectangle {
        id: content
        anchors.centerIn: parent
        height: 24
        width: {
            if (root.normalizedWidth) {
                root.cellSize * root.options.length + root.spacing
            } else {
                options.reduce((acc, option) => acc + fontMetrics.advanceWidth(option) + root.spacing*2, 0) + root.spacing
            }
        }
        color: '#2B2B2B'
        radius: height / 2
        RowLayout {
            anchors.fill: parent
            Repeater {
                model: options
                Rectangle {
                    color: root.selected == modelData ? '#2D4EA1' : 'transparent'
                    width: root.normalizedWidth ? root.cellSize : fontMetrics.advanceWidth(modelData) + root.spacing*2
                    height: content.height
                    radius: height / 2
                    Text {
                        text: modelData
                        color: '#D9D9D9'
                        anchors.centerIn: parent
                        font.pixelSize: 14
                        font.capitalization: Font.AllUppercase
                    }
                    TapHandler {
                        onTapped: {
                            root.selected = modelData
                        }
                    }
                }
            }
        }
    }
    DropShadow {
        id: dropRatio
        anchors.fill: content
        horizontalOffset: 0
        verticalOffset: 0
        radius: 4.0
        color: "#80000000"
        source: content
    }
}
