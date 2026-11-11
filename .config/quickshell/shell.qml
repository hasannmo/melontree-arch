import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris

ShellRoot {
  id: shellRoot

  // User manual visibility override (default true)
  property bool userVisible: true

  // IPC handler so Hyprland (SUPER + M) can toggle the widget
  IpcHandler {
    target: "musicWidget"

    function toggle(): void {
      shellRoot.userVisible = !shellRoot.userVisible
    }

    function show(): void {
      shellRoot.userVisible = true
    }

    function hide(): void {
      shellRoot.userVisible = false
    }
  }

  // ==========================================
  // BACKGROUND CAVA AUDIO VISUALIZER
  // ==========================================
  PanelWindow {
    id: cavaWindow
    WlrLayershell.layer: WlrLayer.Background
    aboveWindows: false
    exclusionMode: ExclusionMode.Ignore
    anchors {
      top: true; bottom: true; left: true; right: true
    }
    color: "transparent"

    property int barCount: 128
    property int barWidth: 5
    property int barSpacing: 5
    property var bars: new Array(barCount).fill(0)

    property real maxHeightFraction: 0.15
    property real barOpacity: 0.2

    readonly property real totalWidth: barCount * barWidth + (barCount - 1) * barSpacing
    readonly property real startX: (cavaWindow.width - totalWidth) / 2

    Process {
      id: cavaProc
      command: ["cava", "-p", "/home/melontree/.config/cava/config"]
      running: true

      stdout: SplitParser {
        splitMarker: "\n"
        onRead: (line) => {
          if (line.length === 0) return
          let vals = line.split(";").filter(v => v.length > 0).map(v => parseInt(v))
          if (vals.length === 0) return

          let next = cavaWindow.bars.slice()
          for (let i = 0; i < cavaWindow.barCount; i++) {
            next[i] = i < vals.length ? vals[i] : next[i]
          }
          cavaWindow.bars = next
        }
      }
    }

    Item {
      anchors.fill: parent

      Repeater {
        model: cavaWindow.barCount
        Rectangle {
          width: cavaWindow.barWidth
          height: (((index < cavaWindow.bars.length) ? cavaWindow.bars[index] : 0) / 100) * cavaWindow.height * cavaWindow.maxHeightFraction
          x: cavaWindow.startX + index * (cavaWindow.barWidth + cavaWindow.barSpacing)
          y: cavaWindow.height - height
          color: "#F4EEE5" // Ivory 400
          opacity: cavaWindow.barOpacity

          Behavior on height {
            NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
          }
        }
      }
    }
  }

  // ==========================================
  // FLOATING MUSIC PLAYER WIDGET (ASHEN REVERIE)
  // ==========================================
  PanelWindow {
    id: musicWindow
    // Anchored directly to bottom-left with margins
    anchors {
      bottom: true
      left: true
    }
    margins {
      bottom: 24
      left: 24
    }

    implicitWidth: 380
    implicitHeight: 96
    color: "transparent"

    // WlrLayer.Top overlays tiled windows, but renders BEHIND fullscreen windows!
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Ignore

    // Active MPRIS Player (prioritize actively playing, fallback to first available)
    readonly property var activePlayer: {
      let players = Mpris.players.values
      if (!players || players.length === 0) return null
      let playing = players.find(p => p.playbackState === MprisPlaybackState.Playing)
      return playing ? playing : players[0]
    }

    // Auto-appear when track is playing/paused AND user hasn't toggled off
    visible: shellRoot.userVisible &&
             activePlayer !== null &&
             (activePlayer.playbackState === MprisPlaybackState.Playing || activePlayer.playbackState === MprisPlaybackState.Paused) &&
             activePlayer.trackTitle.length > 0

    // Auto unhide userVisible when a new track starts playing
    Connections {
      target: musicWindow.activePlayer
      function onPlaybackStateChanged() {
        if (musicWindow.activePlayer && musicWindow.activePlayer.playbackState === MprisPlaybackState.Playing) {
          shellRoot.userVisible = true
        }
      }
    }

    // Glassmorphic Card Container
    Rectangle {
      id: card
      anchors.fill: parent
      radius: 12
      // Ashen Reverie Charcoal 200 with 65% opacity
      color: "#AA292724"
      // Subtle Ivory glass border
      border.color: "#28C8BFB5"
      border.width: 1

      RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 14

        // --- Album Art ---
        Rectangle {
          Layout.preferredWidth: 72
          Layout.preferredHeight: 72
          radius: 8
          clip: true
          color: "#1B1A18" // Charcoal 100 fallback
          border.color: "#3B3731"
          border.width: 1

          Image {
            id: coverArt
            anchors.fill: parent
            source: musicWindow.activePlayer ? (musicWindow.activePlayer.trackArtUrl || "") : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: status === Image.Ready
          }

          Text {
            anchors.centerIn: parent
            text: "♪"
            font.pixelSize: 28
            font.family: "JetBrains Mono Nerd Font"
            color: "#62878A" // Steel Blue 300
            visible: !coverArt.visible
          }
        }

        // --- Track Details & Controls ---
        ColumnLayout {
          Layout.fillWidth: true
          spacing: 6

          // Track Title
          Text {
            Layout.fillWidth: true
            text: musicWindow.activePlayer ? (musicWindow.activePlayer.trackTitle || "No Track") : ""
            color: "#F4EEE5" // Ivory 400
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 13
            font.bold: true
            elide: Text.ElideRight
          }

          // Artist / Subtitle
          Text {
            Layout.fillWidth: true
            text: musicWindow.activePlayer ? (musicWindow.activePlayer.trackArtist || "YouTube Music") : ""
            color: "#A89C91" // Ivory 100
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 11
            elide: Text.ElideRight
          }

          // Playback Controls Row
          RowLayout {
            spacing: 12

            // Previous Button
            Rectangle {
              width: 26
              height: 26
              radius: 6
              color: prevMouse.containsMouse ? "#514B43" : "#3B3731"
              border.color: "#28C8BFB5"
              border.width: 1

              Text {
                anchors.centerIn: parent
                text: "⏮"
                font.pixelSize: 11
                color: "#E0D8D0"
              }

              MouseArea {
                id: prevMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  if (musicWindow.activePlayer && musicWindow.activePlayer.canGoPrevious) {
                    musicWindow.activePlayer.previous()
                  }
                }
              }
            }

            // Play / Pause Toggle Button (Vermilion Accent)
            Rectangle {
              width: 32
              height: 26
              radius: 6
              color: playMouse.containsMouse ? "#E98570" : "#C85B4D"

              Text {
                anchors.centerIn: parent
                text: (musicWindow.activePlayer && musicWindow.activePlayer.playbackState === MprisPlaybackState.Playing) ? "⏸" : "▶"
                font.pixelSize: 12
                color: "#F4EEE5"
              }

              MouseArea {
                id: playMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  if (musicWindow.activePlayer) {
                    musicWindow.activePlayer.togglePlaying()
                  }
                }
              }
            }

            // Next Button
            Rectangle {
              width: 26
              height: 26
              radius: 6
              color: nextMouse.containsMouse ? "#514B43" : "#3B3731"
              border.color: "#28C8BFB5"
              border.width: 1

              Text {
                anchors.centerIn: parent
                text: "⏭"
                font.pixelSize: 11
                color: "#E0D8D0"
              }

              MouseArea {
                id: nextMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  if (musicWindow.activePlayer && musicWindow.activePlayer.canGoNext) {
                    musicWindow.activePlayer.next()
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
