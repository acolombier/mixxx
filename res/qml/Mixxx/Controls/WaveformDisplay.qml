import Mixxx 1.0 as Mixxx

Mixxx.WaveformDisplay {
    id: root

    required property string group

    player: Mixxx.PlayerManager.getPlayer(root.group)

    Mixxx.ControlProxy {
        id: trackLoadedControl

        group: root.group
        key: "track_loaded"
        onValueChanged: value => {
            markers.visible = value;
        }
    }

    Mixxx.ControlProxy {
        id: playPositionControl

        group: root.group
        key: "playposition"
    }
}
