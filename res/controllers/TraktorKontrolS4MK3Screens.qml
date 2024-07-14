import QtQuick 2.15
import QtQuick.Window 2.3
import QtQuick.Scene3D 2.14

import QtQuick.Controls 2.15
import QtQuick.Shapes 1.11
import QtQuick.Layouts 1.3
import QtQuick.Window 2.15

import Qt5Compat.GraphicalEffects

import "." as Skin
import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls

import S4MK3 as S4MK3

Item {
    id: root

    required property string screenId
    property color fontColor: Qt.rgba(242/255,242/255,242/255, 1)
    property color smallBoxBorder: Qt.rgba(44/255,44/255,44/255, 1)

    property string group: screenId == "rightdeck" ? "[Channel2]" : "[Channel1]"
    property string theme: engine.getSetting("theme")

    readonly property bool isStockTheme: theme == "stock"

    property var _zones_needing_redraw: new Array()

    function init(controlerName, isDebug) {
        console.log(`Screen ${root.screenId} has started with theme ${root.theme}`)
        root.state = "Live"
    }

    function shutdown() {
        console.log(`Screen ${root.screenId} is stopping`)
        root.state = "Stop"
    }

    function redraw(component) {
        if (theme == "Advanced") {
            return;
        }
        const timestamp = Date.now();
        const pos = component.mapToGlobal(0, 0)
        const x = Math.min(Math.max(0, pos.x), 320), y = Math.min(Math.max(0, pos.y), 240);
        const zone = Qt.rect(
            x,
            y,
            Math.min(Math.max(0, component.width), 320 - x),
            Math.min(Math.max(0, component.height), 240 - y )
        );
        if (zone.width * zone.height) {
            _zones_needing_redraw.push([zone, timestamp])
        } else {
            console.log(`Component generated a null rectangle! pos=${pos}, component=${component}, width=${component.width}, height=${component.height}`)
        }
    }

    function contains_rect(rect1, rect2) {
        return rect1.x <= rect2.x &&
        rect1.y <= rect2.y &&
        rect1.width >= rect2.width + (rect2.x - rect1.x) &&
        rect1.height >= rect2.height + (rect2.y - rect1.y);
    }

    function transformFrame(input, timestamp) {
        // First, find all the region that are ready to be redrawn
        const areasToDraw = []
        let totalPixelToDraw = 0;
        let zone_requesting_redraw = new Array()
        let zone_not_ready = new Array()
        _zones_needing_redraw.forEach(function(element, i) {
                const [zone, zoneTimestamp] = element;
                console.debug(`zone: ${zone} ${zoneTimestamp}`)
                if (zoneTimestamp <= timestamp) {
                    for (let i in zone_requesting_redraw) {
                        const existingZone = zone_requesting_redraw[i];
                        if (!existingZone) {
                        // Already nullified
                            continue
                        }
                        console.debug(`zone_requesting_redraw: ${i} ${existingZone}`)
                        if (existingZone === zone || contains_rect(existingZone, zone)) return;
                        if (contains_rect(zone, existingZone)) {
                            totalPixelToDraw -= zone_requesting_redraw[i].width * zone_requesting_redraw[i].height;
                            zone_requesting_redraw[i] = null;
                        }
                    }
                    totalPixelToDraw += zone.width * zone.height;
                    zone_requesting_redraw.push(zone);
                    if (zoneTimestamp == timestamp) zone_not_ready.push([zone, zoneTimestamp]);
                } else {
                    console.log(`Too soon to draw ${zone} (in ${zoneTimestamp-timestamp} cs)`)
                    zone_not_ready.push([zone, zoneTimestamp])
                }
        })
        _zones_needing_redraw = zone_not_ready

        // Depending of the state, force full redraw
        if (root.state === "Stop" || theme == "Advanced") {
            zone_requesting_redraw = [Qt.rect(0, 0, 320, 240)];
            totalPixelToDraw = 320 * 240;
        }

        // No redraw needed, stop right there
        if (!zone_requesting_redraw.length) {
            return new ArrayBuffer(0);
        }

        console.log(`Redrawing ${totalPixelToDraw} the following region: ${zone_requesting_redraw}`)

        const screenIdx = screenId === "leftdeck" ? 0 : 1;

        const outputData = new ArrayBuffer(totalPixelToDraw*2 + 20*zone_requesting_redraw.length); // Number of pixel + 20 (header/footer size) x the number of region
        let offset = 0;

        for (const area of zone_requesting_redraw) {
            if (!area) {
                // This happens when the area has been nullified because overlapping with an other region
                continue;
            }
            const header = new Uint8Array(outputData, offset, 16);
            const payload = new Uint8Array(outputData, offset + 16, area.width*area.height*2);
            const footer = new Uint8Array(outputData, offset + area.width*area.height*2 + 16, 4);

            header.fill(0)
            footer.fill(0)
            header[0] = 0x84;
            header[2] = screenIdx;
            header[3] = 0x21;

            header[8] = area.x >> 8;
            header[9] = area.x & 0xff;
            header[10] = area.y >> 8;
            header[11] = area.y & 0xff;

            header[12] = area.width >> 8;
            header[13] = area.width & 0xff;
            header[14] = area.height >> 8;
            header[15] = area.height & 0xff;

            if (area.x === 0 && area.width === 320) {
                payload.set(new Uint8Array(input, area.y * 320 * 2, area.width*area.height*2));
            } else {
                for (let line = 0; line < area.height; line++) {
                    payload.set(new Uint8Array(input,
                            ((area.y + line) * 320 + area.x) * 2,
                            area.width * 2),
                        line * area.width * 2);
                }
            }
            footer[0] = 0x40;
            footer[2] = screenIdx;
            offset += area.width*area.height*2 + 20
        }
        console.log(`Generated ${offset} bytes to be sent`)
        return outputData;
    }

    Component {
        id: splashOff
        S4MK3.SplashOff {
            anchors.fill: parent
        }
    }
    Component {
        id: stockLive
        S4MK3.StockScreen {
            anchors.fill: parent
        }
    }
    Component {
        id: advancedLive
        S4MK3.AdvancedScreen {
            isLeftScreen: root.screenId == "leftdeck"
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: splashOff
        onLoaded: {
            redraw(root)
        }
    }

    states: [
        State {
            name: "Live"
            PropertyChanges {
                target: loader
                sourceComponent: isStockTheme ? stockLive : advancedLive
            }
        },
        State {
            name: "Stop"
            PropertyChanges {
                target: loader
                sourceComponent: splashOff
            }
        }
    ]
}
