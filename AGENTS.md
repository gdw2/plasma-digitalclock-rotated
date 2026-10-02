# AGENTS.md

Guidance for agents and humans working on this repository.

## What this is

A standalone Plasma 6 widget package (KPackage `Plasma/Applet`) that rotates the
Digital Clock 90° in vertical panels. It is a fork of Plasma's built-in Digital
Clock applet with one behavioral change in `contents/ui/DigitalClock.qml`.

The package is pure QML: no C++ is compiled here. It relies on QML modules
provided by `plasma-workspace` at runtime.

## Repository layout

```
metadata.json                     KPackage metadata (KPackageStructure + KPlugin.Id)
contents/ui/*.qml                 Applet QML (main.qml is the entry point)
contents/config/main.xml          KConfigXT schema for the widget settings
contents/config/*.qml             Settings pages
patches/*.patch                   Upstream patch for plasma-workspace (optional)
package.sh                        Builds the distributable archive
```

- `metadata.json` must keep `"KPackageStructure": "Plasma/Applet"` and a unique
  `KPlugin.Id`. The id must differ from `org.kde.plasma.digitalclock`, otherwise
  the compiled built-in plugin wins and this package is ignored.
- `contents/config/main.xml` defines the settings; keys are read in QML via
  `Plasmoid.configuration.<key>`.

## Build

No toolchain is required beyond `tar`:

```bash
./package.sh
```

This writes `build/org.kde.plasma.digitalclock.rotated.plasmoid` and a
`.tar.gz` with the same contents. Both are gzip-compressed tarballs containing
`metadata.json` and `contents/` at the archive root.

## Install / iterate

```bash
kpackagetool6 --type Plasma/Applet --install  build/org.kde.plasma.digitalclock.rotated.tar.gz
kpackagetool6 --type Plasma/Applet --upgrade  build/org.kde.plasma.digitalclock.rotated.tar.gz
kpackagetool6 --type Plasma/Applet --remove   org.kde.plasma.digitalclock.rotated
```

Plasma caches QML components per URL, so an upgrade is **not** picked up by a
running applet. Reload it by restarting the shell or removing and re-adding the
widget:

```bash
kquitapp6 plasmashell && kstart plasmashell
```

## Debugging

QML runtime errors (binding errors, `TypeError`, undefined properties) are
logged by `plasmashell`:

```bash
journalctl --user -f | grep -iE "digitalclock|qml|TypeError"
```

To inspect where a widget actually landed in the panel (size, position) without
touching the config files, use the Plasma scripting API:

```bash
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var p = panelById(2);
var ws = p.widgets();
var out = "";
for (var i = 0; i < ws.length; i++) {
    out += ws[i].id + " " + ws[i].type + " w=" + ws[i].geometry.width + " h=" + ws[i].geometry.height + "\n";
}
print(out);
'
```

`addWidget()` / `widget.remove()` on the same API are useful for adding a
throwaway instance for testing.

## Pitfalls learned while building this

- **`Plasmoid.configuration` is not always ready.** In a pure-QML package
  applet it can be `undefined` while a `State`'s `PropertyChanges` bindings are
  first evaluated. Referencing `Plasmoid.configuration.x` there throws and
  leaves the binding broken, which can collapse the widget's Layout size to
  zero. Prefer reading an already-bound property (e.g. `dateLabel.visible`)
  instead of touching `Plasmoid.configuration` inside state bindings.
- **Rotation does not change layout size.** A rotated `Item` still reports its
  unrotated width/height to the layout, so the rotated bounding box must be
  accounted for explicitly when sizing/centering.
- **Panels can size an applet from its content.** If a font size depends on the
  applet's own width while that width is in turn derived from the content, you
  can get a feedback loop. Size the rotated text from the panel *thickness* and
  leave headroom for font ascent/descent.
- **Same-id packages cannot override compiled system applets.**
  `Plasma::PluginLoader` prefers the C++ plugin when both exist.

## Working from NixOS

A QML widget needs no building; install it with the system `kpackagetool6` as
above. NixOS keeps system packages in an immutable store, so to change the
*built-in* Digital Clock you patch the `plasma-workspace` derivation instead:
add the patch in `patches/` via an overlay and rebuild the system. The patch is
written against the upstream file and applies to the matching Plasma release.

To get a compile/test environment for `plasma-workspace` itself (for upstream
work), use a dev shell for its package, e.g.:

```bash
nix develop nixpkgs#kdePackages.plasma-workspace
```

Notes:

- `plasmoidviewer` from `plasma-sdk` renders a widget standalone, but it is not
  a real panel: it does not constrain the applet to a panel thickness, so its
  sizing/overflow results are not representative. Verify vertical-panel behavior
  in an actual panel.
- Install packages for the current user only (`kpackagetool6` without
  `--global`); never write into the Nix store.

## Conventions

- Keep the diff against upstream minimal and localized so the widget stays easy
  to rebase and to upstream.
- Preserve the existing SPDX headers in every QML file; add new files under
  `GPL-2.0-or-later`.
- Match the surrounding QML style (4-space indent, `id:` first, bindings over
  imperative code).
- Don't add settings that can be derived automatically (e.g. panel edge).
