import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris

ShellRoot {
  id: shellRoot

  // User manual visibility override (controlled only via keybind SUPER + M)
  property bool userVisible: false

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

    // Full screen overlay so card movement is completely internal and 144Hz butter-smooth!
    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }
    color: "transparent"

    // Only the card area receives mouse clicks; everything else passes through 100%
    mask: Region {
      item: cardWrapper
    }

    // WlrLayer.Top overlays tiled windows, but stays underneath fullscreen windows!
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Ignore

    // Active MPRIS Player (prioritize playing, fallback to first available)
    readonly property var activePlayer: {
      let players = Mpris.players.values
      if (!players || players.length === 0) return null
      let playing = players.find(p => p.playbackState === MprisPlaybackState.Playing)
      return playing ? playing : players[0]
    }

    // Purely toggled via keybind (SUPER + M)
    visible: shellRoot.userVisible && activePlayer !== null

    // Draggable and Resizable Card Item
    Item {
      id: cardWrapper
      x: 24
      y: musicWindow.height - height - 24
      width: 380
      height: 140

      // Main Glassmorphic Card Container
      Rectangle {
        id: card
        anchors.fill: parent
        radius: 12
        // Ashen Reverie Charcoal 200 with 75% opacity
        color: "#BF292724"
        // Subtle Ivory glass border
        border.color: "#28C8BFB5"
        border.width: 1

        // Smooth Internal Dragging Handler using Qt's native Drag subsystem
        MouseArea {
          id: dragArea
          anchors.fill: parent
          drag.target: cardWrapper
          drag.axis: Drag.XAndYAxis
          drag.minimumX: 10
          drag.maximumX: musicWindow.width - cardWrapper.width - 10
          drag.minimumY: 10
          drag.maximumY: musicWindow.height - cardWrapper.height - 10
        }

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 14
          spacing: 12

          // Top Row: Album Art + Song Info + Playback Controls
          RowLayout {
            Layout.fillWidth: true
            spacing: 14

            // --- Album Art ---
            Rectangle {
              Layout.preferredWidth: 64
              Layout.preferredHeight: 64
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
                font.pixelSize: 26
                font.family: "JetBrains Mono Nerd Font"
                color: "#62878A" // Steel Blue 300
                visible: !coverArt.visible
              }
            }

            // --- Track Details & Controls ---
            ColumnLayout {
              Layout.fillWidth: true
              spacing: 5

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
                spacing: 10

                // Previous Button
                Rectangle {
                  width: 26
                  height: 24
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
                  height: 24
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
                  height: 24
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

          // Bottom Row: Volume Slider Feature
          RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
              text: {
                let v = musicWindow.activePlayer ? musicWindow.activePlayer.volume : 1.0
                if (v <= 0.01) return "󰝟"
                if (v < 0.5) return "󰕿"
                return "󰕾"
              }
              font.family: "JetBrains Mono Nerd Font"
              font.pixelSize: 13
              color: "#62878A" // Steel Blue 300
            }

            // Volume Track Container
            Item {
              id: volumeTrack
              Layout.fillWidth: true
              Layout.preferredHeight: 18

              // Center track line
              Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 6
                radius: 3
                color: "#3B3731" // Charcoal 300 track

                // Filled Active Portion
                Rectangle {
                  anchors.left: parent.left
                  anchors.top: parent.top
                  anchors.bottom: parent.bottom
                  radius: 3
                  width: parent.width * Math.min(1.0, Math.max(0.0, musicWindow.activePlayer ? musicWindow.activePlayer.volume : 1.0))
                  color: volMouse.containsMouse ? "#C85B4D" : "#7F9478" // Sage 300 / Vermilion hover
                }
              }

              // Interactive Volume Area with comfortable hit box
              MouseArea {
                id: volMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function updateVolume(mouse) {
                  if (musicWindow.activePlayer) {
                    let ratio = Math.max(0.0, Math.min(1.0, mouse.x / volumeTrack.width))
                    musicWindow.activePlayer.volume = ratio
                  }
                }

                onPressed: (mouse) => updateVolume(mouse)
                onPositionChanged: (mouse) => {
                  if (pressed) updateVolume(mouse)
                }
              }
            }

            // Volume Percent Label
            Text {
              text: {
                let v = musicWindow.activePlayer ? Math.round(musicWindow.activePlayer.volume * 100) : 100
                return v + "%"
              }
              font.family: "JetBrains Mono Nerd Font"
              font.pixelSize: 10
              color: "#A89C91" // Ivory 100
              Layout.preferredWidth: 32
              horizontalAlignment: Text.AlignRight
            }
          }
        }

        // --- Interactive Resizer Handle (Bottom-Right Corner) ---
        Rectangle {
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          width: 16
          height: 16
          color: "transparent"

          MouseArea {
            id: resizeHandle
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor

            property int startMouseX: 0
            property int startMouseY: 0
            property int startW: 0
            property int startH: 0

            onPressed: (mouse) => {
              startMouseX = mouse.x
              startMouseY = mouse.y
              startW = cardWrapper.width
              startH = cardWrapper.height
            }

            onPositionChanged: (mouse) => {
              if (pressed) {
                cardWrapper.width = Math.max(320, startW + (mouse.x - startMouseX))
                cardWrapper.height = Math.max(130, startH + (mouse.y - startMouseY))
              }
            }
          }
        }
      }
    }
  }
}
