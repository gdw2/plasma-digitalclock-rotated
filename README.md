# Rotated Digital Clock

A [Plasma 6](https://kde.org/plasma-desktop/) widget that shows the time and
date rotated 90°, so it reads naturally along a **vertical panel** instead of
being squeezed horizontally until it is illegible.

This is a standalone Plasmoid package (KPackage `Plasma/Applet`) derived from
Plasma's built-in Digital Clock applet.

## What it does

When the widget is placed in a vertical panel it lays the clock out exactly like
the horizontal one (time on one line, date on the line below) and then rotates
the whole thing:

- **Left-edge panel** (default): rotated counter-clockwise, reading bottom-to-top.
- **Right-edge panel**: rotated clockwise, reading top-to-bottom.
- The time is slightly larger than the date, matching the built-in horizontal
  layout.
- In a horizontal panel it behaves like the normal Digital Clock.

The rotation is automatic based on the panel edge; there is no extra setting.

## Requirements

- Plasma 6 (KDE Frameworks 6 / Qt 6).
- The private QML modules `org.kde.plasma.clock` and
  `org.kde.plasma.private.digitalclock`, which ship with
  `plasma-workspace`. They must match your Plasma version.

## Install

### From the widget explorer (recommended)

1. Build the archive: `./package.sh` (produces `build/*.plasmoid` and
   `build/*.tar.gz`).
2. Right-click the panel/desktop → **Add Widgets…** → **Get New Widgets…** →
   **Install Widget From File…** and pick `build/*.plasmoid`.
3. Add **Digital Clock (rotated)** to your panel.

If your system refuses the `.plasmoid` extension, use the `.tar.gz` variant or
install from the command line:

```bash
kpackagetool6 --type Plasma/Applet --install org.kde.plasma.digitalclock.rotated.tar.gz
```

To upgrade or remove:

```bash
kpackagetool6 --type Plasma/Applet --upgrade org.kde.plasma.digitalclock.rotated.tar.gz
kpackagetool6 --type Plasma/Applet --remove  org.kde.plasma.digitalclock.rotated
```

After installing or upgrading, restart the shell (or remove and re-add the
widget) so the new QML is loaded:

```bash
kquitapp6 plasmashell && kstart plasmashell
```

## Build

Only a shell and `tar` are needed to produce the package:

```bash
./package.sh
```

## Why a separate widget?

Plasma's built-in Digital Clock is compiled into `plasma-workspace` as a C++
plugin with the QML embedded. A user-installed package with the *same* plugin id
cannot override it (`Plasma::PluginLoader` prefers the compiled plugin), so this
widget uses a distinct id and appears as its own entry in the widget list.

If you would rather fix the built-in clock system-wide, the change is small
enough to carry as a distro patch; see
[`patches/digital-clock-vertical-rotate.patch`](patches/digital-clock-vertical-rotate.patch).
Upstream tracking bug: [KDE bug 440096](https://bugs.kde.org/show_bug.cgi?id=440096).

## License

GPL-2.0-or-later. See [LICENSE](LICENSE). The QML is derived from the KDE Plasma
Digital Clock applet; original copyright belongs to the KDE contributors (see
the SPDX headers in each file).
