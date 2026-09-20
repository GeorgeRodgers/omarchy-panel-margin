import QtQuick
import Quickshell
import qs.Commons

// The shell derives the margin around every panel, popup and notification from
// half of Hyprland's `general:gaps_out` (the `Style.gapsOut` singleton),
// refreshed at startup and after every theme change. There is no shell.toml
// key for it, so with tight window gaps the panels sit ~1px off the bar and
// appear to merge with the window behind them.
//
// This plugin keeps re-asserting a fixed margin, so it survives the shell's
// periodic overwrites. Set the value here, or via the OMARCHY_PANEL_MARGIN_PX
// environment variable (in pixels).
Item {
  id: root

  readonly property int margin: {
    var fromEnv = parseInt(Quickshell.env("OMARCHY_PANEL_MARGIN_PX"), 10)
    return isFinite(fromEnv) && fromEnv >= 0 ? fromEnv : 10
  }

  function apply() {
    if (Style.gapsOut !== root.margin)
      Style.gapsOut = root.margin
  }

  Component.onCompleted: apply()

  Connections {
    target: Style
    function onGapsOutChanged() {
      root.apply()
    }
  }
}
