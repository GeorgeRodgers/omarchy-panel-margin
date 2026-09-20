# omarchy-panel-margin

An [Omarchy](https://omarchy.org) shell plugin that gives bar panels, popups and
notifications a larger, fixed margin from the screen and bar edges, so they stop
visually merging with the window behind them.

## The problem

On Omarchy the status bar, its flyout panels (clock, network, power, audio, …),
the launcher/menu, and notifications are all drawn by the Quickshell
`omarchy-shell` process. Every one of these surfaces positions itself away from
the screen edge and the bar by a single shared value: the shell's
`Style.gapsOut` token.

That token is **not configurable**. The shell hardcodes it to *half of Hyprland's
`general:gaps_out`*, re-derived via `hyprctl getoption` at startup and again
after every theme change. `Style.gapsOut` is also what sets the panel/popup
corner rounding mirror and the edge gap, and it is refreshed out from under any
manual edit.

The result: if you run tight window gaps (e.g. `gaps_out = 2`, a common
minimalist setup), the shell computes a ~1px margin. Panels and notifications
appear to sit flush against the bar and bleed into the active window, which
looks broken rather than intentional.

There is no key in `~/.config/omarchy/shell.toml` (the file that themes and user
overrides use) for this margin — it is only ever read back from Hyprland.

## How this plugin fixes it

`panel-margin` is a tiny always-loaded shell plugin. It imports the same
`qs.Commons` `Style` singleton the rest of the shell uses and:

1. Sets `Style.gapsOut` to a fixed pixel value on load.
2. Watches `Style.gapsOutChanged` and re-applies the value every time the shell
   tries to overwrite it (startup refresh, theme switches, etc.).

Because every panel, popup and notification reads that one token, a single
override spaces all of them consistently — no per-plugin cloning required. It
has been verified to survive a full `omarchy theme set` re-apply.

## Companion change: matching borders

The plugin only controls **margin**. To make panel/notification borders match
your Hyprland window border, add this to `~/.config/omarchy/shell.toml`:

```toml
[popups]
border-width = 1

[notifications]
border-width = 1
```

`1` should equal your Hyprland `general:border_size` (in
`~/.config/hypr/looknfeel.lua`). Border **color** and **corner rounding** already
track Hyprland by default (panels use the active-window border gradient and
`decoration:rounding`), so width is the only mismatch worth pinning. This file
hot-reloads; save it, no shell restart needed.

## Install

1. Copy the plugin into your user plugin directory. The **folder name must match
   the manifest `id`** (`panel-margin`), or hot-reload won't find it:

   ```bash
   cp -r . ~/.config/omarchy/plugins/panel-margin
   ```

2. Enable it by adding an entry to the `plugins` array in
   `~/.config/omarchy/shell.json`:

   ```json
   { "id": "panel-margin" }
   ```

3. Restart the shell:

   ```bash
   omarchy restart shell
   ```

Saving files under `~/.config/omarchy/plugins/panel-margin/` hot-reloads them
while the shell is running; use step 3 only the first time or after editing
`shell.json`.

### Configure the margin

Edit the fallback value in `Panel.qml`, or set the environment variable (pixels)
without touching code:

```bash
export OMARCHY_PANEL_MARGIN_PX=14
```

A sensible value is roughly your desired panel-to-screen gap; `10`–`16` reads
well with a thin bar.

## Remove

1. Delete the plugin folder:

   ```bash
   rm -rf ~/.config/omarchy/plugins/panel-margin
   ```

2. Remove the `{ "id": "panel-margin" }` entry from `plugins` in
   `~/.config/omarchy/shell.json`.

3. `omarchy restart shell`.

The shell falls back to deriving the margin from `gaps_out` again.

## Notes

- This is a user-space shim, not a fork of Omarchy. It lives entirely in
  `~/.config/omarchy/plugins/` and survives `omarchy update`.
- The right long-term fix is an upstream `[popups] margin` key in `shell.toml`;
  until then this plugin covers panels, popups, the menu and notifications in
  one place.

## License

MIT
