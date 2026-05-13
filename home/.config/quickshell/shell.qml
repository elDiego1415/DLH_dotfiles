import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window

import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import Quickshell.Io

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 40
    color: "transparent"

    // ── Colores ────────────────────────────────────────────────────────────────
    readonly property color glass:       Qt.rgba(30/255,  30/255,  46/255,  0.60)
    readonly property color glassHover:  Qt.rgba(46/255,  46/255,  70/255,  0.76)
    readonly property color popupBg:     "#181825"
    readonly property color popupBorder: Qt.rgba(205/255, 214/255, 244/255, 0.11)
    readonly property color borderCol:   Qt.rgba(205/255, 214/255, 244/255, 0.13)

    readonly property color textCol:     "#cdd6f4"
    readonly property color subText:     "#a6adc8"
    readonly property color accent:      "#cba6f7"
    readonly property color yellow:      "#f9e2af"
    readonly property color teal:        "#94e2d5"
    readonly property color green:       "#a6e3a1"
    readonly property color rose:        "#eba0ac"
    readonly property color peach:       "#fab387"
    readonly property color blue:        "#89b4fa"
    readonly property color sliderTrack: Qt.rgba(205/255, 214/255, 244/255, 0.17)

    // ── Estado de menús ────────────────────────────────────────────────────────
    property bool audioMenuOpen:   false
    property bool calMenuOpen:     false
    property bool batteryMenuOpen: false
    property bool mediaMenuOpen:   false
    property bool netMenuOpen:     false

    property bool netHoveringButton:       false
    property bool netHoveringPopup:        false
    property bool audioHoveringButton:     false
    property bool audioHoveringPopup:      false
    property bool calHoveringButton:       false
    property bool calHoveringPopup:        false
    property bool batteryHoveringButton:   false
    property bool batteryHoveringPopup:    false
    property bool mediaHoveringButton:     false
    property bool mediaHoveringPopup:      false
    property bool mediaAutoCloseArmed:     false

    // ── Red ───────────────────────────────────────────────────────────────────
    property string netKind:       "none"
    property string netLabelValue: "Disconnected"
    property string netIconValue:  "󰖪"
    property string netDownValue:  "--"
    property string netUpValue:    "--"

    // ── Sistema ───────────────────────────────────────────────────────────────
    property string memValue:   "--"
    property string uptimeText: "--"
    property var    trayItemsValue: (SystemTray.items && SystemTray.items.values) ? SystemTray.items.values : []

    // ── Batería ───────────────────────────────────────────────────────────────
    property bool   batteryPresent:          false
    property int    batteryPercent:          0
    property string batteryState:            ""
    property bool   batteryChargingValue:    false
    property bool   batteryDischargingValue: false

    // ── Workspaces ────────────────────────────────────────────────────────────
    property int    currentWorkspaceId: 1
    property string usedWorkspaceList:  "|1|"

    // ── Media (MPRIS, sin polling) ────────────────────────────────────────────
    property bool   mediaAvailable:  false
    property string mediaTitle:      ""
    property string mediaPlayerName: ""
    property string mediaStatus:     "Stopped"
    property real   mediaPosition:   0
    property real   mediaLength:     0

    // ── Cava ──────────────────────────────────────────────────────────────────
    property string cavaFrame:   "0;0;0;0;0;0;0;0;0;0"
    property var    cavaValues:  [0,0,0,0,0,0,0,0,0,0]
    property bool   cavaEnabled: false

    // ── PipeWire ──────────────────────────────────────────────────────────────
    readonly property var sink:   Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    property bool audioBluetooth: false

    // ── Funciones helper ──────────────────────────────────────────────────────
    function closeAllMenus() {
        focusCloseTimer.stop()
        calCloseTimer.stop()
        audioCloseTimer.stop()
        netCloseTimer.stop()
        batteryCloseTimer.stop()
        mediaCloseTimer.stop()

        audioHoveringPopup = false
        calHoveringPopup = false
        batteryHoveringPopup = false
        mediaHoveringPopup = false
        netHoveringPopup = false

        audioMenuOpen   = false
        calMenuOpen     = false
        batteryMenuOpen = false
        mediaMenuOpen   = false
        netMenuOpen     = false
    }

    function closeMenusWithoutHover() {
        if (!audioHoveringButton && !audioHoveringPopup)
            audioMenuOpen = false
        if (!calHoveringButton && !calHoveringPopup)
            calMenuOpen = false
        if (!batteryHoveringButton && !batteryHoveringPopup)
            batteryMenuOpen = false
        if (!mediaHoveringButton && !mediaHoveringPopup)
            mediaMenuOpen = false
        if (!netHoveringButton && !netHoveringPopup)
            netMenuOpen = false
    }

    function clamp(v, minv, maxv) {
        return Math.max(minv, Math.min(maxv, v))
    }

    function popupXFor(moduleItem, popupWidth) {
        var x = rightRow.x + moduleItem.x + Math.round((moduleItem.width - popupWidth) / 2)
        return Math.max(6, Math.min(bar.width - popupWidth - 6, x))
    }

    function volIcon(v, muted) {
        if (muted)    return "󰝟"
        if (v < 0.33) return "󰕿"
        if (v < 0.66) return "󰖀"
        return "󰕾"
    }

    function audioIcon() {
        if (!bar.sink || !bar.sink.audio) return "󰖁"
        if (bar.sink.audio.muted) return "󰝟"
        if (bar.audioBluetooth) return "󰂰"
        return bar.volIcon(bar.sink.audio.volume, false)
    }

    function micIcon() {
        if (!bar.source || !bar.source.audio) return "󰍭"
        return bar.source.audio.muted ? "󰍭" : "󰍬"
    }

    function sinkVolumeText() {
        if (!bar.sink || !bar.sink.audio) return "--%"
        return String(Math.round(bar.sink.audio.volume * 100)) + "%"
    }

    function sourceVolumeText() {
        if (!bar.source || !bar.source.audio) return "--%"
        return String(Math.round(bar.source.audio.volume * 100)) + "%"
    }

    function batteryPercentText() {
        if (!bar.batteryPresent) return "--%"
        return String(bar.batteryPercent) + "%"
    }

    function batteryStateText() {
        if (!bar.batteryState || bar.batteryState.length === 0) return "Unknown"
        return bar.batteryState
    }

    function batteryColor() {
        if (!bar.batteryPresent)         return Qt.rgba(235/255, 160/255, 172/255, 0.22)
        if (bar.batteryChargingValue)    return Qt.rgba(166/255, 227/255, 161/255, 0.28)
        if (bar.batteryDischargingValue) return Qt.rgba(235/255, 160/255, 172/255, 0.28)
        return Qt.rgba(243/255, 139/255, 168/255, 0.20)
    }

    function batteryIcon() {
        var level = bar.batteryPercent
        var idx   = Math.max(0, Math.min(9, Math.floor(level / 10)))
        var chargingIcons = ["󰢜","󰂆","󰂇","󰂈","󰢝","󰂉","󰢞","󰂊","󰂋","󰂅"]
        var normalIcons   = ["󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂂","󰁹"]
        return bar.batteryChargingValue ? chargingIcons[idx] : normalIcons[idx]
    }

    function workspaceUsed(id) {
        return bar.usedWorkspaceList.indexOf("|" + String(id) + "|") !== -1
    }
    
    function workspaceIcon(id) {
        var icons = {
            "1": "󰈹",
            "2": "󰨞",
            "3": "󱁤",
            "4": ""
        }

        return icons[String(id)] || String(id)
    }


    function workspaceModel() {
        var out   = [1, 2, 3, 4]
        var extra = []
        var parts = usedWorkspaceList.split("|")
        for (var i = 0; i < parts.length; ++i) {
            var p = parts[i]
            if (!p || p.length === 0) continue
            var n = parseInt(p)
            if (isNaN(n)) continue
            if (n > 4 && extra.indexOf(n) === -1) extra.push(n)
        }
        extra.sort(function(a, b) { return a - b })
        return out.concat(extra)
    }

    function rebuildUsedWorkspaces() {
        var used = []
        var ws   = (Hyprland.workspaces && Hyprland.workspaces.values)
                   ? Hyprland.workspaces.values : []
        for (var i = 0; i < ws.length; ++i) {
            var w = ws[i]
            var count = (w.toplevels && w.toplevels.values) ? w.toplevels.values.length : 0
            if (count > 0 || w.id === bar.currentWorkspaceId)
                used.push(w.id)
        }
        if (used.indexOf(bar.currentWorkspaceId) === -1)
            used.push(bar.currentWorkspaceId)
        used.sort(function(a, b) { return a - b })
        bar.usedWorkspaceList = "|" + used.join("|") + "|"
    }

    function syncHyprlandWorkspaces() {
        Hyprland.refreshWorkspaces()
        bar.updateFocusedWorkspace()
    }

    function updateFocusedWorkspace() {
        var active = Hyprland.focusedWorkspace
        if (active) bar.currentWorkspaceId = active.id
        bar.rebuildUsedWorkspaces()
    }

    function mediaStatusIcon() {
        if (!bar.mediaAvailable) return ""
        if (bar.mediaStatus === "Playing") return "▶"
        if (bar.mediaStatus === "Paused")  return "⏸"
        return ""
    }

    function mediaIsVisible() {
        if (!bar.mediaAvailable) return false
        if (!bar.mediaTitle || bar.mediaTitle.length === 0) return false
        if (bar.mediaStatus !== "Playing" && bar.mediaStatus !== "Paused") return false
        return true
    }

    function shortMediaTitle() {
        var s      = bar.mediaTitle || ""
        var maxLen = 14
        if (s.length <= maxLen) return s
        return s.slice(0, maxLen - 3) + "..."
    }

    function formatClockText(dateObj) {
        return Qt.formatDateTime(dateObj, "HH:mm")
    }

    function trayItems() {
        return bar.trayItemsValue || []
    }

    function backgroundCount() {
        return bar.trayItems().length
    }

    function trayIconSource(trayItem) {
        var spotifyIcon = "file:///usr/share/icons/hicolor/32x32/apps/spotify.png"
        var bluemanIcon = "file:///usr/share/icons/hicolor/scalable/status/blueman-tray.svg"
        if (!trayItem) return ""

        var id = String(trayItem.id || "").toLowerCase()
        var title = String(trayItem.title || "").toLowerCase()
        var icon = String(trayItem.icon)

        if (id.indexOf("blueman") !== -1 || title.indexOf("bluetooth") !== -1 || icon.indexOf("blueman") !== -1)
            return bluemanIcon

        if (!trayItem.icon) return ""

        if (icon.indexOf("spotify-linux") !== -1 || icon.indexOf("spotify") !== -1)
            return spotifyIcon

        return trayItem.icon
    }

    function activeMprisPlayer() {
        if (!Mpris.players || Mpris.players.count <= 0) return null
        if (!Mpris.players.values || Mpris.players.values.length <= 0) return null

        var playingFallback = null
        var pausedFallback = null
        for (var i = 0; i < Mpris.players.values.length; ++i) {
            var p = Mpris.players.values[i]
            if (!p) continue

            var isUsable = p.playbackState !== MprisPlaybackState.Stopped && p.trackTitle
            if (!isUsable) continue

            if (p.playbackState === MprisPlaybackState.Playing && !playingFallback)
                playingFallback = p
            if (!pausedFallback)
                pausedFallback = p
        }

        return playingFallback || pausedFallback || Mpris.players.values[0]
    }

    function syncMpris() {
        var p = bar.activeMprisPlayer()
        if (!p || p.playbackState === MprisPlaybackState.Stopped || !p.trackTitle) {
            bar.mediaAvailable  = false
            bar.mediaTitle      = ""
            bar.mediaPlayerName = ""
            bar.mediaStatus     = "Stopped"
            bar.mediaPosition   = 0
            bar.mediaLength     = 0
            if (bar.mediaMenuOpen) {
                bar.mediaMenuOpen       = false
                bar.mediaAutoCloseArmed = false
                mediaArmTimer.stop()
                mediaCloseTimer.stop()
            }
            return
        }
        bar.mediaAvailable  = true
        bar.mediaTitle      = p.trackTitle  || ""
        bar.mediaPlayerName = p.identity    || ""
        bar.mediaLength     = p.length || 0
        switch (p.playbackState) {
            case MprisPlaybackState.Playing: bar.mediaStatus = "Playing"; break
            case MprisPlaybackState.Paused:  bar.mediaStatus = "Paused";  break
            default:                          bar.mediaStatus = "Stopped"; break
        }
    }

    // ── Componentes reutilizables ─────────────────────────────────────────────
    component GlassModule: Rectangle {
        radius: 999
        color: bar.glass
        border.width: 1
        border.color: bar.borderCol
        implicitHeight: 24
    }

    component PopupButton: Rectangle {
        radius: 999
        implicitHeight: 28
        color: Qt.rgba(203/255, 166/255, 247/255, 0.10)
        border.width: 1
        border.color: Qt.rgba(203/255, 166/255, 247/255, 0.22)
    }

    component YellowSlider: Slider {
        id: s
        implicitHeight: 20
        background: Rectangle {
            x: s.leftPadding
            y: s.topPadding + s.availableHeight / 2 - height / 2
            width: s.availableWidth
            height: 4
            radius: 999
            color: bar.sliderTrack
            Rectangle {
                width: s.visualPosition * parent.width
                height: parent.height
                radius: 999
                color: bar.yellow
            }
        }
        handle: Rectangle {
            x: s.leftPadding + s.visualPosition * (s.availableWidth - width)
            y: s.topPadding + s.availableHeight / 2 - height / 2
            implicitWidth: 10
            implicitHeight: 10
            radius: 999
            color: bar.textCol
            border.width: 1
            border.color: Qt.rgba(24/255, 24/255, 37/255, 0.35)
        }
    }

    // ── Servicios ─────────────────────────────────────────────────────────────
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    PwObjectTracker {
        objects: [bar.sink, bar.source]
    }

    Connections {
        target: Mpris.players
        function onValuesChanged() { bar.syncMpris() }
        function onObjectInsertedPost(object, index) { bar.syncMpris() }
        function onObjectRemovedPost(object, index)  { bar.syncMpris() }
    }

    Connections {
        target: SystemTray.items
        function onValuesChanged() {
            bar.trayItemsValue = (SystemTray.items && SystemTray.items.values)
                                 ? SystemTray.items.values : []
        }
        function onObjectInsertedPost(object, index) {
            bar.trayItemsValue = (SystemTray.items && SystemTray.items.values)
                                 ? SystemTray.items.values : []
        }
        function onObjectRemovedPost(object, index) {
            bar.trayItemsValue = (SystemTray.items && SystemTray.items.values)
                                 ? SystemTray.items.values : []
        }
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            bar.updateFocusedWorkspace()
        }
        function onRawEvent(event) {
            if (!event) return
            switch (event.name) {
                case "workspace":
                case "workspacev2":
                case "createworkspace":
                case "createworkspacev2":
                case "destroyworkspace":
                case "destroyworkspacev2":
                case "openwindow":
                case "closewindow":
                case "movewindow":
                case "movewindowv2":
                    bar.syncHyprlandWorkspaces()
                    break
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: bar.syncMpris()
    }

    // Posición de la barra de progreso — solo corre cuando el popup está abierto
    Timer {
        id: mediaPositionTimer
        interval: 1000
        running: bar.mediaMenuOpen && bar.mediaStatus === "Playing"
        repeat: true
        onTriggered: {
            var p = bar.activeMprisPlayer()
            if (p) bar.mediaPosition = p.position || 0
        }
    }

    Component.onCompleted: {
        bar.syncHyprlandWorkspaces()
        bar.trayItemsValue = (SystemTray.items && SystemTray.items.values)
                             ? SystemTray.items.values : []
        bar.syncMpris()
    }

    HyprlandFocusGrab {
        id: menuGrab
        windows: [calPopup, audioPopup, batteryPopup, mediaPopup]
        active: bar.calMenuOpen || bar.audioMenuOpen || bar.batteryMenuOpen || bar.mediaMenuOpen
        onCleared: focusCloseTimer.restart()
    }

    // ── Timers de cierre por hover ────────────────────────────────────────────
    Timer {
        id: focusCloseTimer
        interval: 180
        repeat: false
        onTriggered: bar.closeMenusWithoutHover()
    }

    Timer {
        id: calCloseTimer
        interval: 420
        repeat: false
        onTriggered: {
            if (!bar.calHoveringButton && !bar.calHoveringPopup)
                bar.calMenuOpen = false
        }
    }

    Timer {
        id: audioCloseTimer
        interval: 420
        repeat: false
        onTriggered: {
            if (!bar.audioHoveringButton && !bar.audioHoveringPopup)
                bar.audioMenuOpen = false
        }
    }

    Timer {
        id: netCloseTimer
        interval: 420
        repeat: false
        onTriggered: {
            if (!bar.netHoveringButton && !bar.netHoveringPopup)
                bar.netMenuOpen = false
        }
    }

    Timer {
        id: netOpenTimer
        interval: 70
        repeat: false
        onTriggered: {
            if (bar.netHoveringButton)
                bar.netMenuOpen = true
        }
    }

    Timer {
        id: batteryCloseTimer
        interval: 420
        repeat: false
        onTriggered: {
            if (!bar.batteryHoveringButton && !bar.batteryHoveringPopup)
                bar.batteryMenuOpen = false
        }
    }

    Timer {
        id: mediaCloseTimer
        interval: 420
        repeat: false
        onTriggered: {
            if (!bar.mediaHoveringButton && !bar.mediaHoveringPopup)
                bar.mediaMenuOpen = false
        }
    }

    Timer {
        id: mediaArmTimer
        interval: 450
        repeat: false
        onTriggered: {
            bar.mediaAutoCloseArmed = true
            if (!bar.mediaHoveringButton && !bar.mediaHoveringPopup)
                bar.mediaMenuOpen = false
        }
    }

    // ── Procesos externos ─────────────────────────────────────────────────────

    // RAM — cada 30s
    Process {
        id: memProc
        command: [
            "awk",
            "/MemTotal:/ { total = $2 } /MemAvailable:/ { available = $2 } END { if (total > 0) printf \"%d\", ((total - available) / total) * 100; else printf \"--\" }",
            "/proc/meminfo"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: bar.memValue = text.trim()
        }
    }
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: { if (!memProc.running) memProc.running = true }
    }

    // Uptime — cada 60s
    Process {
        id: uptimeProc
        command: [
            "awk",
            "{ d = int($1 / 86400); h = int(($1 % 86400) / 3600); m = int(($1 % 3600) / 60); if (d > 0) printf \"%dd %dh %dm\", d, h, m; else if (h > 0) printf \"%dh %dm\", h, m; else printf \"%dm\", m }",
            "/proc/uptime"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: bar.uptimeText = text.trim()
        }
    }
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: { if (!uptimeProc.running) uptimeProc.running = true }
    }

    // Cava bridge: se activa solo si el usuario enciende el visualizador.
    Process {
        id: cavaBridgeProc
        command: ["bash", "-lc", Quickshell.shellDir + "/scripts/cava_bridge.sh"]
        running: bar.cavaEnabled
    }

    // Cava poll: suficiente para una animación suave sin despertar la CPU 20 veces/s.
    Process {
        id: cavaReadProc
        command: ["bash", "-lc", "cat /tmp/quickshell-cava-${USER}.txt 2>/dev/null || echo '0;0;0;0;0;0;0;0;0;0'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var line  = text.trim()
                if (!line || line.length === 0) line = "0;0;0;0;0;0;0;0;0;0"
                bar.cavaFrame = line
                var parts = line.split(";")
                var vals  = []
                for (var i = 0; i < 10; ++i) {
                    var v = (i < parts.length) ? parseInt(parts[i]) : 0
                    if (isNaN(v)) v = 0
                    vals.push(Math.max(0, Math.min(100, v)))
                }
                bar.cavaValues = vals
            }
        }
    }
    Timer {
        id: cavaPollTimer
        interval: 160
        running: bar.cavaEnabled
        repeat: true
        onTriggered: { if (!cavaReadProc.running) cavaReadProc.running = true }
    }

    // Red — cada 15s
    Process {
        id: netProc
        command: ["python3", Quickshell.shellDir + "/scripts/net.py"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split("|")
                if (parts.length >= 6) {
                    bar.netKind       = parts[0]
                    bar.netIconValue  = parts[1]
                    bar.netLabelValue = parts[2]
                    bar.netDownValue  = parts[4]
                    bar.netUpValue    = parts[5]
                }
            }
        }
    }
    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: { if (!netProc.running) netProc.running = true }
    }

    // Batería — cada 30s
    Process {
        id: batteryProc
        command: ["python3", Quickshell.shellDir + "/scripts/battery.py"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split("|")
                if (parts.length >= 5) {
                    bar.batteryPresent          = parts[0] === "1"
                    bar.batteryPercent          = parseInt(parts[1])
                    if (isNaN(bar.batteryPercent)) bar.batteryPercent = 0
                    bar.batteryState            = parts[2]
                    bar.batteryChargingValue    = parts[3] === "1"
                    bar.batteryDischargingValue = parts[4] === "1"
                }
            }
        }
    }
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: { if (!batteryProc.running) batteryProc.running = true }
    }

    Process {
        id: audioDeviceProc
        command: ["bash", "-lc", "wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -Eiq 'bluez|bluetooth|api\\.bluez5|device\\.bus = \"bluetooth\"' && echo 1 || echo 0"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: bar.audioBluetooth = text.trim() === "1"
        }
    }
    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { if (!audioDeviceProc.running) audioDeviceProc.running = true }
    }

    // Procesos de acción única
    Process { id: logoProc }
    Process { id: wifiProc }

    // ── UI ────────────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: 14
            color: bar.glass
            border.width: 1
            border.color: bar.borderCol
        }

        // ── Izquierda: logo + workspaces ──────────────────────────────────────
        RowLayout {
            id: leftRow
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            // Logo — usa bash -lc para heredar el PATH completo del usuario
            GlassModule {
                implicitWidth: 30
                color: logoMouse.containsMouse ? bar.glassHover : bar.glass
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: bar.blue
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: logoMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        logoProc.command = ["bash", "-lc", "notify-send 'Quickshell' 'Has pulsado el logo' >/dev/null 2>&1 &"]
                        logoProc.running = true
                    }
                }
            }

            // Workspaces
            Repeater {
                model: bar.workspaceModel()

                delegate: GlassModule {
                    property int wsId: modelData

                    implicitWidth: 26

                    readonly property bool isCurrent: bar.currentWorkspaceId === wsId
                    readonly property bool isUsed:    bar.workspaceUsed(wsId)
                    property bool hovered: wsMouse.containsMouse

                    color: {
                        if (isCurrent) return Qt.rgba(203/255, 166/255, 247/255, 0.34)
                        if (hovered)   return Qt.rgba(205/255, 214/255, 244/255, 0.12)
                        if (isUsed)    return Qt.rgba(205/255, 214/255, 244/255, 0.08)
                        return bar.glass
                    }
                    border.color: isCurrent
                        ? Qt.rgba(203/255, 166/255, 247/255, 0.35)
                        : (isUsed ? Qt.rgba(205/255, 214/255, 244/255, 0.24) : Qt.rgba(205/255, 214/255, 244/255, 0.07))

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: bar.workspaceIcon(parent.wsId)
                        color: parent.isCurrent ? bar.textCol : (parent.isUsed ? bar.textCol : bar.subText)
                        opacity: parent.isCurrent || parent.isUsed ? 1.0 : 0.46
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 3
                        width: parent.isCurrent ? 12 : 8
                        height: 2
                        radius: 999
                        visible: parent.isUsed
                        color: parent.isCurrent ? bar.accent : bar.blue
                        opacity: parent.isCurrent ? 0.95 : 0.72
                    }

                    MouseArea {
                        id: wsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            bar.currentWorkspaceId = parent.wsId
                            if (!bar.workspaceUsed(parent.wsId))
                                bar.usedWorkspaceList = bar.usedWorkspaceList + String(parent.wsId) + "|"
                            Hyprland.dispatch("workspace " + parent.wsId)
                        }
                    }
                }
            }
        }

        // ── Centro: reloj ─────────────────────────────────────────────────────
        GlassModule {
            id: centerClock
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: 98
            color: clockMouse.containsMouse ? bar.glassHover : bar.glass
            Behavior on color { ColorAnimation { duration: 120 } }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: ""
                    color: bar.textCol
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }

                Text {
                    id: timeText
                    property bool alt: false
                    text: alt
                        ? Qt.formatDateTime(clock.date, "ddd, dd MMM yyyy")
                        : bar.formatClockText(clock.date)
                    color: bar.textCol
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }
            }

            MouseArea {
                id: clockMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onEntered: {
                    bar.calHoveringButton = true
                    calCloseTimer.stop()
                }
                onExited: {
                    bar.calHoveringButton = false
                    calCloseTimer.restart()
                }
                onClicked: function(mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        if (bar.calMenuOpen) { bar.calMenuOpen = false }
                        else {
                            bar.closeAllMenus()
                            bar.calHoveringButton = true
                            bar.calMenuOpen = true
                            calCloseTimer.stop()
                        }
                    } else if (mouse.button === Qt.RightButton) {
                        timeText.alt = !timeText.alt
                    }
                }
            }
        }

        // ── Derecha ───────────────────────────────────────────────────────────
        RowLayout {
            id: rightRow
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            // Media
            GlassModule {
                id: mediaModule
                implicitWidth: bar.cavaEnabled ? 182 : 150
                visible: bar.mediaIsVisible()
                color: mediaMouse.containsMouse ? bar.glassHover : bar.glass
                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on implicitWidth { NumberAnimation { duration: 140 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6
                    spacing: 5

                    Text {
                        text: bar.mediaStatusIcon()
                        color: bar.textCol
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                    }

                    Row {
                        spacing: 2
                        Layout.alignment: Qt.AlignVCenter
                        visible: bar.cavaEnabled

                        Repeater {
                            model: 10
                            delegate: Rectangle {
                                property int barIndex: index
                                width: 3; height: 12; radius: 999
                                color: Qt.rgba(205/255, 214/255, 244/255, 0.10)

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: Math.max(2, Math.round((bar.cavaValues[parent.barIndex] / 100) * parent.height))
                                    radius: 999
                                    color: bar.accent
                                }
                            }
                        }
                    }

                    Text {
                        width: bar.cavaEnabled ? 84 : 108
                        text: bar.shortMediaTitle()
                        color: bar.textCol
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        wrapMode: Text.NoWrap
                        elide: Text.ElideRight
                        clip: true
                    }
                }

                MouseArea {
                    id: mediaMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onEntered: {
                        bar.mediaHoveringButton = true
                        mediaArmTimer.stop()
                        mediaCloseTimer.stop()
                    }
                    onExited: {
                        bar.mediaHoveringButton = false
                        if (bar.mediaMenuOpen && bar.mediaAutoCloseArmed)
                            mediaCloseTimer.restart()
                    }
                    onClicked: function(mouse) {
                        if (!bar.mediaAvailable) return
                        if (mouse.button === Qt.LeftButton) {
                            if (bar.mediaMenuOpen) {
                                bar.mediaMenuOpen       = false
                                bar.mediaAutoCloseArmed = false
                                mediaArmTimer.stop()
                                mediaCloseTimer.stop()
                            } else {
                                bar.closeAllMenus()
                                bar.mediaHoveringButton = true
                                bar.mediaHoveringPopup  = false
                                bar.mediaAutoCloseArmed = false
                                bar.mediaMenuOpen       = true
                                mediaArmTimer.restart()
                                mediaCloseTimer.stop()
                            }
                        } else {
                            var p = bar.activeMprisPlayer()
                            if (p) p.togglePlaying()
                        }
                    }
                    onWheel: function(wheel) {
                        if (!bar.mediaAvailable) return
                        var p = bar.activeMprisPlayer()
                        if (!p) return
                        if (wheel.angleDelta.y > 0) p.next()
                        else                        p.previous()
                    }
                }
            }

            // Apps en segundo plano
            GlassModule {
                id: backgroundModule
                implicitWidth: trayInlineRow.implicitWidth + 10
                visible: bar.backgroundCount() > 0
                color: bar.glass
                Behavior on color { ColorAnimation { duration: 120 } }

                RowLayout {
                    id: trayInlineRow
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5
                    spacing: 5

                    Repeater {
                        model: bar.trayItemsValue

                        delegate: Item {
                            implicitWidth: 16
                            implicitHeight: 16
                            property var trayItem: modelData
                            property bool hovered: trayIconMouse.containsMouse

                            IconImage {
                                anchors.centerIn: parent
                                width: 16
                                height: 16
                                source: bar.trayIconSource(parent.trayItem)
                                opacity: parent.hovered ? 1.0 : 0.86
                            }

                            MouseArea {
                                id: trayIconMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: function(mouse) {
                                    if (mouse.button === Qt.RightButton && parent.trayItem.hasMenu) {
                                        parent.trayItem.display(bar, backgroundModule.x + parent.x, bar.height)
                                    } else if (mouse.button === Qt.RightButton && parent.trayItem.secondaryActivate) {
                                        parent.trayItem.secondaryActivate()
                                    } else {
                                        parent.trayItem.activate()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // RAM
            GlassModule {
                implicitWidth: 52

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "󰍛"; color: bar.peach; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
                    Text { text: bar.memValue + "%"; color: bar.textCol; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
                }
            }

            // Red
            GlassModule {
                id: wifiModule
                implicitWidth: 28
                color: wifiMouse.containsMouse ? bar.glassHover : bar.glass
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: bar.netIconValue
                    color: bar.teal
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }

                MouseArea {
                    id: wifiMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onEntered: {
                        bar.netHoveringButton = true
                        netCloseTimer.stop()
                        netOpenTimer.restart()
                    }
                    onExited: {
                        bar.netHoveringButton = false
                        netOpenTimer.stop()
                        netCloseTimer.restart()
                    }
                    onClicked: function(mouse) {
                        if (mouse.button === Qt.LeftButton) {
                            wifiProc.command = ["bash", "-lc", "~/.config/rofi/wifi/wifi.sh >/dev/null 2>&1 &"]
                            wifiProc.running = true
                        } else {
                            wifiProc.command = ["bash", "-lc", "~/.config/rofi/wifi/wifinew.sh >/dev/null 2>&1 &"]
                            wifiProc.running = true
                        }
                    }
                }
            }

            // Audio
            GlassModule {
                id: audioModule
                implicitWidth: 70
                color: audioMouse.containsMouse ? bar.glassHover : bar.glass
                Behavior on color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: bar.audioIcon()
                        color: bar.yellow
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                    }
                    Text {
                        text: bar.sinkVolumeText()
                        color: bar.textCol
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                    }
                    Text {
                        text: bar.micIcon()
                        color: (bar.source && bar.source.audio && !bar.source.audio.muted)
                               ? bar.yellow : bar.subText
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                    }
                }

                MouseArea {
                    id: audioMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onEntered: {
                        bar.audioHoveringButton = true
                        audioCloseTimer.stop()
                    }
                    onExited: {
                        bar.audioHoveringButton = false
                        audioCloseTimer.restart()
                    }
                    onClicked: function(mouse) {
                        if (mouse.button === Qt.LeftButton) {
                            if (bar.audioMenuOpen) { bar.audioMenuOpen = false }
                            else {
                                bar.closeAllMenus()
                                bar.audioHoveringButton = true
                                bar.audioMenuOpen = true
                                audioCloseTimer.stop()
                            }
                        } else {
                            if (bar.sink && bar.sink.audio)
                                bar.sink.audio.muted = !bar.sink.audio.muted
                        }
                    }
                    onWheel: function(wheel) {
                        if (!bar.sink || !bar.sink.audio) return
                        var step  = 0.02
                        var delta = wheel.angleDelta.y > 0 ? step : -step
                        bar.sink.audio.muted  = false
                        bar.sink.audio.volume = bar.clamp(bar.sink.audio.volume + delta, 0, 1.5)
                    }
                }
            }

            // Batería
            GlassModule {
                id: batteryModule
                implicitWidth: 58
                color: batteryMouse.containsMouse
                       ? Qt.rgba(255, 255, 255, 0.10) : bar.batteryColor()
                visible: bar.batteryPresent
                Behavior on color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: bar.batteryPercentText(); color: bar.textCol; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
                    Text { text: bar.batteryIcon();        color: bar.textCol; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
                }

                MouseArea {
                    id: batteryMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: { bar.batteryHoveringButton = true;  batteryCloseTimer.stop() }
                    onExited:  { bar.batteryHoveringButton = false; batteryCloseTimer.restart() }
                    onClicked: {
                        if (bar.batteryMenuOpen) { bar.batteryMenuOpen = false }
                        else { bar.closeAllMenus(); bar.batteryMenuOpen = true; batteryCloseTimer.stop() }
                    }
                }
            }
        }
    }

    // ── Popups ────────────────────────────────────────────────────────────────

    // Calendario
    PopupWindow {
        id: calPopup
        anchor.window: bar
        anchor.rect.x: Math.round((bar.width - width) / 2)
        anchor.rect.y: bar.height + 10
        anchor.rect.width: 1
        anchor.rect.height: 1
        anchor.adjustment: PopupAdjustment.All
        visible: bar.calMenuOpen
        color: "transparent"
        implicitWidth: 344
        implicitHeight: 368

        Rectangle {
            anchors.fill: parent
            radius: 18
            color: bar.popupBg
            border.width: 1
            border.color: bar.popupBorder
            opacity: calPopup.visible ? 1 : 0
            scale:   calPopup.visible ? 1 : 0.97
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale   { NumberAnimation { duration: 170 } }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onEntered: { bar.calHoveringPopup = true;  calCloseTimer.stop() }
                onExited:  { bar.calHoveringPopup = false; calCloseTimer.restart() }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Text {
                    text: Qt.formatDateTime(clock.date, "dddd, dd MMMM yyyy")
                    color: bar.textCol
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6

                    DayOfWeekRow {
                        Layout.fillWidth: true
                        delegate: Text {
                            text: model.shortName
                            horizontalAlignment: Text.AlignHCenter
                            color: bar.subText
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }
                    }

                    MonthGrid {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        month: clock.date.getMonth()
                        year:  clock.date.getFullYear()

                        delegate: Rectangle {
                            readonly property bool isToday: model.date.toDateString() === new Date().toDateString()
                            radius: 8
                            color: isToday ? Qt.rgba(203/255, 166/255, 247/255, 0.40) : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: model.day
                                color: bar.textCol
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                            }
                        }
                    }
                }

                Text {
                    text: Qt.formatDateTime(clock.date, "HH:mm:ss")
                    color: bar.subText
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }
            }
        }
    }

    // Audio
    PopupWindow {
        id: audioPopup
        property int popupW: 308
        anchor.window: bar
        anchor.rect.x: bar.popupXFor(audioModule, popupW)
        anchor.rect.y: bar.height + 10
        anchor.rect.width: 1
        anchor.rect.height: 1
        anchor.adjustment: PopupAdjustment.All
        visible: bar.audioMenuOpen
        color: "transparent"
        implicitWidth: popupW
        implicitHeight: 226

        Rectangle {
            anchors.fill: parent
            radius: 18
            color: bar.popupBg
            border.width: 1
            border.color: bar.popupBorder
            opacity: audioPopup.visible ? 1 : 0
            scale:   audioPopup.visible ? 1 : 0.97
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale   { NumberAnimation { duration: 170 } }

            HoverHandler {
                onHoveredChanged: {
                    bar.audioHoveringPopup = hovered
                    if (hovered) audioCloseTimer.stop()
                    else         audioCloseTimer.restart()
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 7

                Text { text: "Audio"; color: bar.textCol; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14 }
                Text { text: bar.sinkVolumeText(); color: bar.subText; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }

                YellowSlider {
                    Layout.fillWidth: true
                    from: 0; to: 1.5
                    value: (bar.sink && bar.sink.audio) ? bar.sink.audio.volume : 0
                    onMoved: {
                        if (bar.sink && bar.sink.audio) {
                            bar.sink.audio.muted  = false
                            bar.sink.audio.volume = value
                        }
                    }
                }

                PopupButton {
                    Layout.fillWidth: true
                    Text {
                        anchors.centerIn: parent
                        text: (bar.sink && bar.sink.audio && bar.sink.audio.muted)
                              ? "Activar salida" : "Silenciar salida"
                        color: bar.textCol; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: { if (bar.sink && bar.sink.audio) bar.sink.audio.muted = !bar.sink.audio.muted }
                    }
                }

                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: bar.popupBorder }

                Text { text: bar.sourceVolumeText(); color: bar.subText; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }

                YellowSlider {
                    Layout.fillWidth: true
                    from: 0; to: 1.5
                    value: (bar.source && bar.source.audio) ? bar.source.audio.volume : 0
                    onMoved: {
                        if (bar.source && bar.source.audio) {
                            bar.source.audio.muted  = false
                            bar.source.audio.volume = value
                        }
                    }
                }

                PopupButton {
                    Layout.fillWidth: true
                    Text {
                        anchors.centerIn: parent
                        text: (bar.source && bar.source.audio && bar.source.audio.muted)
                              ? "Activar micro" : "Silenciar micro"
                        color: bar.textCol; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: { if (bar.source && bar.source.audio) bar.source.audio.muted = !bar.source.audio.muted }
                    }
                }

                Item { Layout.fillHeight: true; implicitHeight: 2 }
            }
        }
    }

    // Batería
    PopupWindow {
        id: batteryPopup
        property int popupW: 268
        anchor.window: bar
        anchor.rect.x: bar.popupXFor(batteryModule, popupW)
        anchor.rect.y: bar.height + 10
        anchor.rect.width: 1
        anchor.rect.height: 1
        anchor.adjustment: PopupAdjustment.All
        visible: bar.batteryMenuOpen
        color: "transparent"
        implicitWidth: popupW
        implicitHeight: 158

        Rectangle {
            anchors.fill: parent
            radius: 18
            color: bar.popupBg
            border.width: 1
            border.color: bar.popupBorder
            opacity: batteryPopup.visible ? 1 : 0
            scale:   batteryPopup.visible ? 1 : 0.97
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale   { NumberAnimation { duration: 170 } }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onEntered: { bar.batteryHoveringPopup = true;  batteryCloseTimer.stop() }
                onExited:  { bar.batteryHoveringPopup = false; batteryCloseTimer.restart() }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                Text { text: "Battery"; color: bar.textCol; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13 }

                RowLayout {
                    Layout.fillWidth: true; spacing: 7
                    Text { text: "󰁹"; color: bar.rose;  font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
                    Text { text: bar.batteryPercentText(); color: bar.textCol; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
                }
                RowLayout {
                    Layout.fillWidth: true; spacing: 7
                    Text { text: "󰚥"; color: bar.green; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
                    Text { text: bar.batteryStateText(); color: bar.subText; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
                }
                RowLayout {
                    Layout.fillWidth: true; spacing: 7
                    Text { text: "󰔟"; color: bar.accent; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
                    Text { text: "Uptime: " + bar.uptimeText; color: bar.subText; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
                }
            }
        }
    }

    // Media
    PopupWindow {
        id: mediaPopup
        property int popupW: 338
        anchor.window: bar
        anchor.rect.x: bar.popupXFor(mediaModule, popupW)
        anchor.rect.y: bar.height + 10
        anchor.rect.width: 1
        anchor.rect.height: 1
        anchor.adjustment: PopupAdjustment.All
        visible: bar.mediaMenuOpen
        color: "transparent"
        implicitWidth: popupW
        implicitHeight: 254

        Rectangle {
            anchors.fill: parent
            radius: 18
            color: bar.popupBg
            border.width: 1
            border.color: bar.popupBorder
            opacity: mediaPopup.visible ? 1 : 0
            scale:   mediaPopup.visible ? 1 : 0.97
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale   { NumberAnimation { duration: 170 } }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onEntered: {
                    bar.mediaHoveringPopup  = true
                    bar.mediaAutoCloseArmed = true
                    mediaArmTimer.stop()
                    mediaCloseTimer.stop()
                }
                onExited: {
                    bar.mediaHoveringPopup = false
                    mediaCloseTimer.restart()
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: bar.mediaAvailable ? (bar.mediaTitle || "Sin título") : "No hay reproducción"
                    color: bar.textCol
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: bar.mediaPlayerName || ""
                    color: bar.subText
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: bar.mediaPlayerName.length > 0
                }

                // Visualizador cava
                Row {
                    spacing: 3
                    Layout.alignment: Qt.AlignLeft
                    visible: bar.mediaAvailable && bar.cavaEnabled

                    Repeater {
                        model: 10
                        delegate: Rectangle {
                            property int barIndex: index
                            width: 5; height: 20; radius: 999
                            color: Qt.rgba(205/255, 214/255, 244/255, 0.10)

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: Math.max(3, Math.round((bar.cavaValues[parent.barIndex] / 100) * parent.height))
                                radius: 999
                                color: bar.accent
                            }
                        }
                    }
                }

                // Toggle visualizador
                PopupButton {
                    Layout.fillWidth: true
                    implicitHeight: 28

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Text { text: "󰺵"; color: bar.accent; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
                        Text {
                            text: bar.cavaEnabled ? "Visualizador activado" : "Visualizador desactivado"
                            color: bar.textCol; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                        }
                        Item { Layout.fillWidth: true }
                        Text { text: bar.cavaEnabled ? "On" : "Off"; color: bar.subText; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11 }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: bar.cavaEnabled = !bar.cavaEnabled
                    }
                }

                // Barra de progreso
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 5
                    radius: 999
                    color: bar.sliderTrack
                    visible: bar.mediaLength > 0

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        radius: 999
                        width: bar.mediaLength <= 0 ? 0
                               : parent.width * Math.max(0, Math.min(1, bar.mediaPosition / bar.mediaLength))
                        color: bar.accent
                    }
                }

                // Tiempo
                Text {
                    text: {
                        function fmt(sec) {
                            sec = Math.floor(sec)
                            var m = Math.floor(sec / 60)
                            var s = sec % 60
                            return String(m) + ":" + (s < 10 ? "0" + String(s) : String(s))
                        }
                        if (bar.mediaLength <= 0) return ""
                        return fmt(bar.mediaPosition) + " / " + fmt(bar.mediaLength)
                    }
                    color: bar.subText
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    visible: bar.mediaLength > 0
                }

                // Controles — MPRIS directo, sin proceso externo
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: [
                            { label: "⏮", action: "previous" },
                            { label: bar.mediaStatus === "Playing" ? "⏸" : "▶", action: "playPause" },
                            { label: "⏭", action: "next" }
                        ]

                        delegate: PopupButton {
                            property var buttonData: modelData
                            Layout.fillWidth: true

                            Text {
                                anchors.centerIn: parent
                                text: parent.buttonData.label
                                color: bar.textCol
                                font.pixelSize: 12
                            }
                            MouseArea {
                                anchors.fill: parent
                                enabled: bar.mediaAvailable
                                onClicked: {
                                    var p = bar.activeMprisPlayer()
                                    if (!p) return
                                    var a = parent.buttonData.action
                                    if      (a === "previous")  p.previous()
                                    else if (a === "playPause") p.togglePlaying()
                                    else if (a === "next")      p.next()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Red
    PopupWindow {
        id: netPopup
        property int popupW: 220
        anchor.window: bar
        anchor.rect.x: bar.popupXFor(wifiModule, popupW)
        anchor.rect.y: bar.height + 10
        anchor.rect.width: 1
        anchor.rect.height: 1
        anchor.adjustment: PopupAdjustment.All
        visible: bar.netMenuOpen
        color: "transparent"
        implicitWidth: popupW
        implicitHeight: 82

        Rectangle {
            anchors.fill: parent
            radius: 18
            color: bar.popupBg
            border.width: 1
            border.color: bar.popupBorder
            opacity: netPopup.visible ? 1 : 0
            scale:   netPopup.visible ? 1 : 0.97
            Behavior on opacity { NumberAnimation { duration: 130 } }
            Behavior on scale   { NumberAnimation { duration: 150 } }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onEntered: { bar.netHoveringPopup = true;  netCloseTimer.stop() }
                onExited:  { bar.netHoveringPopup = false; netCloseTimer.restart() }
            }

            Column {
                anchors.centerIn: parent
                spacing: 5
                width: parent.width - 20

                Text {
                    width: parent.width
                    text: bar.netKind === "wifi"     ? bar.netLabelValue
                        : bar.netKind === "ethernet" ? "Ethernet"
                        : "Offline"
                    color: bar.textCol
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    width: parent.width
                    text: "⇣ " + bar.netDownValue + "   ⇡ " + bar.netUpValue
                    color: bar.subText
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
