import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
  PanelWindow {
    id: root
    WlrLayershell.layer: WlrLayer.Background
    aboveWindows: false
    exclusionMode: ExclusionMode.Ignore
    anchors {
      top: true; bottom: true; left: true; right: true
    }
    color: "transparent"

    property int barCount: 128 //86
    property int barWidth: 5
    property int barSpacing: 5
    property var bars: new Array(barCount).fill(0)

    property real maxHeightFraction: 0.15   // <-- ADJUST HERE: 1.0 = full screen height, 0.25 = quarter
    property real barOpacity: 0.2           // <-- ADJUST HERE: 0.0 = invisible, 1.0 = solid

    readonly property real totalWidth: barCount * barWidth + (barCount - 1) * barSpacing
    readonly property real startX: (root.width - totalWidth) / 2

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

          let next = root.bars.slice()
          for (let i = 0; i < root.barCount; i++) {
            next[i] = i < vals.length ? vals[i] : next[i]
          }
          root.bars = next
        }
      }
    }

    Item {
      anchors.fill: parent

      Repeater {
        model: root.barCount
        Rectangle {
          width: root.barWidth
          height: (((index < root.bars.length) ? root.bars[index] : 0) / 100) * root.height * root.maxHeightFraction
          x: root.startX + index * (root.barWidth + root.barSpacing)
          y: root.height - height
          color: "#F4EEE5"
          opacity: root.barOpacity

          Behavior on height {
            NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
          }
        }
      }
    }
  }
}