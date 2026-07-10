# AGENTS.md — Mixxx Behave E2E UI Tests

## Architecture Overview

```text
mixxx_test_runner.py   ← CTest entry point (CMake add_test target "mixxx-behave-*")
  │
  ├─ profile.py        ← Profile creation, track download, MixxxProcess lifecycle
  ├─ environment.py    ← behave before_all/after_all/scenario hooks
  ├─ steps/
  │   └─ mixxx_steps.py  ← Gherkin step definitions (Given/When/Then)
  ├─ features/
  │   └─ library.feature
  └─ test_tracks.json   ← Static track metadata (url, filename, hash, etc.)
```

## How to Run Tests (Iterating)

### Single feature, headed (local dev — uses your display)

```bash
/usr/bin/python3 \
  "/workspaces/mixxx/src/test/behave/mixxx_test_runner.py" \
  "--binary" "/workspaces/mixxx/build/mixxx-test" \
  "/workspaces/mixxx/src/test/behave/features/library.feature"
```

### Single feature, offscreen (no display needed)

```bash
# Using --headless flag (preferred — also enables screenshot artifacts)
/usr/bin/python3 \
  "/workspaces/mixxx/src/test/behave/mixxx_test_runner.py" \
  "--binary" "/workspaces/mixxx/build/mixxx-test" \
  "--headless" \
  "/workspaces/mixxx/src/test/behave/features/library.feature"

# Or via QPA env var (equivalent, but no screenshot artifacts)
QT_QPA_PLATFORM=offscreen /usr/bin/python3 \
  "/workspaces/mixxx/src/test/behave/mixxx_test_runner.py" \
  "--binary" "/workspaces/mixxx/build/mixxx-test" \
  "/workspaces/mixxx/src/test/behave/features/library.feature"
```

### Single feature, named scenario only (fastest iteration)

behave forwards extra args after the feature file. Use `-n` (a.k.a. `--name`) to
run just one scenario:

```bash
/usr/bin/python3 \
  "/workspaces/mixxx/src/test/behave/mixxx_test_runner.py" \
  "--binary" "/workspaces/mixxx/build/mixxx-test" \
  "--headless" \
  "/workspaces/mixxx/src/test/behave/features/library.feature" \
  -n "Maximize library with toggle"
```

### All features via CTest

```bash
# Headed (local dev, uses existing display)
ctest -R mixxx-behave- --output-on-failure

# Headless (CI — sets MIXXX_TEST_HEADLESS=1 for Xvfb+ffmpeg)
MIXXX_TEST_HEADLESS=1 ctest -R mixxx-behave- --output-on-failure
```

### Tips for iterating

- **Real-time logs**: `MixxxProcess` streams mixxx-test stdout/stderr to the
  terminal in real-time via a daemon thread. All `qDebug()` output from the
  custom command handlers (e.g. `getControlValue`) appears inline.
- **Screenshots on failure**: `after_scenario` writes
  `artifacts/<ScenarioName>.png` on failure.
- **Session reuse**: scenarios sharing the same `Background` profile type reuse
  the same `mixxx-test` process — only the first scenario pays startup cost.
- After editing QML or `main.cpp`, rebuild:
  `cmake --build build --target mixxx-test -j$(nproc)`
- After editing Python (`steps/`, `environment.py`, `profile.py`, runner), no
  rebuild needed — just re-run the command.
- If spix patches fail to apply during build, delete
  `build/libspix-prefix` and `build/lib/libspix-install`, then reconfigure.

## How Tests Run

1. **CMake** finds `python3` + `behave`, globs `features/*.feature`, registers
   each as `mixxx-behave-<name>`.
2. `mixxx_test_runner.py` sets `MIXXX_TEST_BINARY`, sets up a global tracks
   cache at `/tmp/mixxx-test-tracks/` (downloading if needed), optionally
   starts Xvfb+ffmpeg for headless CI, then invokes `behave` with the feature
   file.
3. behave invokes `environment.py` hooks, then matches step definitions in
   `steps/mixxx_steps.py`.

## mixxx-test --serve Mode

The `mixxx-test` binary built with `USE_TEST_UI=ON` supports `--serve` flag:

- Parses `--settingsPath <dir>` via `CmdlineArgs::Instance()` (singleton — see
  `src/test/mixxxtest.cpp:29`). **Important**: `ApplicationScope` must call
  `CmdlineArgs::Instance().parse()` rather than constructing a local
  `CmdlineArgs`, otherwise `--settingsPath` is lost.
- Creates `CoreServices` + `QmlApplication` to load the full Mixxx QML UI.
- Reads `MIXXX_TEST_TRACKS_DIR` env var and adds it as a library directory via
  `TrackCollectionManager::addDirectory()`.
- Registers a **generic command handler** (see below) and starts an
  **AnyRpcServer** (spix) on **port 9000**.

## Custom spix Command: `getControlValue`

The `--serve` mode registers a custom handler via
`server.setGenericCommandHandler(...)` in `src/test/main.cpp`.

| Command           | Payload         | Result                                                                 | How to read result                                        |
|-------------------|-----------------|------------------------------------------------------------------------|-----------------------------------------------------------|
| `getControlValue` | `"[Group],key"` | `double` value stored in `mainWindow.lastControlValue` window property | `rpc.getStringProperty("mainWindow", "lastControlValue")` |

### Why two-step?

spix's `command()` RPC method returns `void`. The handler runs on the main
thread, sets the result as a Qt property on the window. A subsequent
`getStringProperty()` call (also processed on the main thread, in order)
reads it back. Since spix processes commands sequentially, this is race-free.

### Python helper

```python
def _get_control_value(rpc, group, key):
    rpc.command("getControlValue", f"{group},{key}")
    return rpc.getStringProperty("mainWindow", "lastControlValue")
```

### Adding new custom commands

To add a new C++ command, extend the lambda in `src/test/main.cpp`:

```cpp
if (command == "myCommand") {
    // parse payload, do work
    // store result: window->setProperty("myResult", value);
}
```

Then read from Python:

```python
rpc.command("myCommand", payload)
result = rpc.getStringProperty("mainWindow", "myResult")
```

## Profile Setup (`profile.py`)

### `create_empty_profile(settings_dir)`

- Creates `mixxxdb.sqlite` by running all SQL statements from `res/schema.xml`
- Inserts `mixxx.schema.version`, `.last_used_version`, `.min_compatible_version`
  into the `settings` table — **critical**: `SchemaManager::upgradeToSchemaVersion()`
  reads these to avoid re-applying migrations (which would segfault on
  "table already exists").
- Creates `mixxx.cfg` with minimal `[Config] Version = 2.6.0` and
  `[Library] Show = 1`

### Profile types

- `empty`: schema-only database, no tracks
- `basic`: schema + directory entry pointing to `MIXXX_TEST_TRACKS_DIR`

### `MixxxProcess` class

- `start()`: spawns `mixxx-test --settingsPath <dir> --serve --developer
  --logLevel warn`
- Stdout streamed via `subprocess.PIPE` + daemon thread writing with
  `os.write(1, ...)` for real-time, unbuffered logging (using fd 1 directly
  to bypass Python's stdout buffering)
- Waits up to 60s for port 9000 to be reachable
- `stop()`: terminate with 15s grace, then kill

### Track downloads

- Manifest in `test_tracks.json` — each entry has `filename`, `url`,
  `file_hash`, `sample_rate`, `channels`, `duration_secs`, `bitrate_kbps`,
  `bpm`, `first_beat_secs`
- Downloaded on first run to `/tmp/mixxx-test-tracks/` (global cache, shared
  across all CTest invocations)

## Spix RPC API (`TestServer.h`)

Available via XML-RPC on `http://localhost:9000/`:

| Method | Signature | Purpose |
| --- | --- | --- |
| `mouseClick` | `(path)` | Left click at item center |
| `mouseClick` | `(path, proportion, offset?)` | Click at relative position |
| `mouseClickWithButton` | `(path, button, modifiers)` | button: 1=Left, 2=Right; modifiers: 0=None |
| `mouseBeginDrag` | `(path)` | Start drag at item center |
| `mouseEndDrag` | `(path)` | End drag at item center |
| `mouseDropUrls` | `(path, urls)` | Drag-drop URLs onto item |
| `command` | `(command, payload)` | Custom C++ handler (see `main.cpp`) |
| `inputText` | `(path, text)` | Type text into item |
| `getStringProperty` | `(path, propertyName)` | Read QML property as string |
| `setStringProperty` | `(path, propertyName, value)` | Write QML property |
| `invokeMethod` | `(path, method, args)` | Call Q_INVOKABLE method |
| `getBoundingBox` | `(path)` | Returns `[x, y, w, h]` |
| `existsAndVisible` | `(path)` | Check item exists and visible |
| `wait` | `(ms)` | Sleep on main thread |
| `takeScreenshot` | `(path, filePath)` | Capture screenshot |
| `quit` | `()` | Quit application |
| `getErrors` | `()` | Get collected errors |

## Path Resolution

Spix resolves items by their `objectName` in the QML object tree, using `/`
as separator. The path `mainWindow/libraryContent/trackList/columnHeader/Title`
means:

- Find the `ApplicationWindow` with `objectName: "mainWindow"`
- Find its child with `objectName: "libraryContent"` (Loader → Library.qml root)
- Find its descendant with `objectName: "trackList"` (TrackList.qml root
  Rectangle)
- Find child `HorizontalHeaderView` with `objectName: "columnHeader"`
- Find the column delegate whose `objectName == "Title"` (set to `display`
  property of the model)

### ObjectName Map

| QML File | objectName | Notes |
| --- | --- | --- |
| `main.qml` | `"mainWindow"` | Root `ApplicationWindow` |
| `main.qml` | `"splashScreen"` | Splash `Rectangle` (fades, then hides) |
| `MainWindow.qml` | `"library"` | Toolbar "Library" toggle button |
| `MainWindow.qml` | `"libraryContent"` | Loader that shows `Library.qml` |
| `Library/TrackList.qml` | `"trackList"` | Root Rectangle |
| `Library/TrackList.qml` | `"columnHeader"` | `HorizontalHeaderView` |
| `Library/TrackList.qml` | `"columnPickerMenu"` | Column visibility `Menu` |
| `Library/TrackList.qml` | `"trackTableView"` | `TableView` |
| `Library/TrackList.qml` | `<display value>` | Column header delegate: `objectName: display` |
| `Library/Track.qml` | `"trackContextMenu"` | Right-click context `Menu` |
| `Library/Cell.qml` | `"trackRow_" + row` | Row `Rectangle`, dynamic per-row |

### Path Constants (from `mixxx_steps.py`)

```python
BUTTON_PATHS = {"LIBRARY": "mainWindow/library"}
LIBRARY_CONTENT = "mainWindow/libraryContent"
TRACKLIST_PATH = "mainWindow/libraryContent/trackList"
COLUMN_HEADER_PATH = "mainWindow/libraryContent/trackList/columnHeader"
COLUMN_PICKER_MENU_PATH = "mainWindow/columnPickerMenu"
TRACK_TABLE_PATH = "mainWindow/libraryContent/trackList/trackTableView"
TRACK_ROW_PATH = "mainWindow/libraryContent/trackList/trackTableView"
TRACK_CONTEXT_MENU_PATH = "mainWindow/trackContextMenu"
```

> **Note**: `COLUMN_PICKER_MENU_PATH` and `TRACK_CONTEXT_MENU_PATH` use
> `mainWindow/` (not `trackList/`) because Qt `Menu` popups render in the
> window's `Overlay`, not as children of their parent item.

## Step DSL (`steps/mixxx_steps.py`)

### Constants

- `QT_LEFT_BUTTON = 1`, `QT_RIGHT_BUTTON = 2`
- `KNOWN_COLUMNS` — list of all possible library column display labels
- `RPC_TIMEOUT = 30`

### Helper Functions

| Helper | Purpose |
| --- | --- |
| `_wait_for_visible(rpc, path, timeout=5)` | Poll `existsAndVisible` until true |
| `_wait_for_nonzero_size(rpc, path, timeout=5)` | Poll `getBoundingBox` until `w>0 && h>0` |
| `_wait_for_hidden(rpc, path, timeout=60)` | Poll `existsAndVisible` until false |
| `_click(rpc, path)` | `rpc.mouseClick(path)` |
| `_right_click(rpc, path)` | `rpc.mouseClickWithButton(path, QT_RIGHT_BUTTON, 0)` |
| `_long_press(rpc, path, hold_ms=1000)` | `mouseBeginDrag` + `wait(hold_ms)` + `mouseEndDrag` |
| `_drag(rpc, source, target)` | `mouseBeginDrag` + sleep + `mouseEndDrag` |
| `_is_visible(rpc, path)` | `existsAndVisible` + bounding box area > 0 |
| `_is_column_visible(rpc, col)` | Checks header `index` property + `columnWidth` via `invokeMethod` |
| `_get_control_value(rpc, group, key)` | Custom command: reads ControlObject via `command("getControlValue", ...)` + `getStringProperty("mainWindow", "lastControlValue")` |
| `_get_property(rpc, path, prop)` | `rpc.getStringProperty(path, prop)` |
| `_set_property(rpc, path, prop, value)` | `rpc.setStringProperty(path, prop, str(value))` |
| `_ensure_profile(context, type)` | Manages profile lifecycle across scenarios (session reuse) |

### Given Steps

| Pattern | Implementation |
| --- | --- |
| `a new empty profile` | `_ensure_profile(context, "empty")` |
| `a basic profile ready to go` | `_ensure_profile(context, "basic")` |
| `Mixxx is open and ready to operate` | Starts Mixxx, waits for mainWindow, waits for splash to hide, caches `_column_idx` and `_mainwindow_default_props` |
| `the library directory is configured with test tracks` | Inserts directory into DB, sleeps 5s for rescan |

### When Steps

| Pattern | Implementation |
| --- | --- |
| `I resize the window's width to {width:d}px` | `setStringProperty("mainWindow", "width", value)` |
| `I check on the button "{button}" in the main toolbar` | Asserts button visible via `_is_visible` |
| `I click the "{button}" button` | Looks up in `BUTTON_PATHS`, clicks |
| `I click the column header "{column}"` | Clicks header at `COLUMN_HEADER_PATH/{column}` |
| `I drag the column "{column}" before the column "{target}"` | `invokeMethod(trackTableView, "moveColumn", [idx_column, idx_target])` |
| `I open the column picker menu` | Right-clicks on Title column header, waits for menu |
| `I toggle the column "{column}" in the column picker` | `invokeMethod(columnPickerMenu, "setObjectNameFor", [index])`, then clicks menu item |
| `I click the track at row {row:d}` | Clicks cell at `trackTableView/trackRow_{row}` |
| `I right-click the track at row {row:d}` | `mouseClickWithButton` with RightButton |
| `I long-press the track at row {row:d}` | `mouseBeginDrag` + wait 1s + `mouseEndDrag` |

### Then Steps

| Pattern | Implementation |
| --- | --- |
| `the library is shown for {operator} than {percent:d}% of the Window's height` | Compares `libraryContent` height ratio to `mainWindow` height |
| `only the column "{columns}" are shown` | Splits on `,`/`.`, checks each expected column visible, each unexpected column not visible |
| `the column "{column}" should {state} visible` | `_is_column_visible` check |
| `the column "{column}" should appear before the column "{other}"` | Compares `x` positions of headers |
| `the results should be sorted by "{column}" in "{order}" order` | Reads `sortingColumn`/`sortingOrder` from `columnHeader` |
| `the track at row {row:d} should be selected` | Reads `selected` property from Cell |
| `the track context menu should be visible` | `existsAndVisible` on `trackContextMenu` path |

## Test Fixtures (`environment.py`)

- `before_all`: initiates `context._session` dict for cross-scenario state
- `before_scenario`: restores `context.mixxx`, `context.mixxx_rpc`,
  `context.profile_dir` from session; skips scenarios tagged `@spix/unsupported`
- `after_scenario`: takes screenshot on failure
  (`artifacts/<scenario_name>.png`); calls `_reset_workspace()` (unmaximizes
  library if ratio > 75%)
- `after_all`: sends `rpc.quit()`, stops Mixxx process, cleans up temp profile
  dirs

## How to Add a New Step

1. Define Gherkin pattern in a `.feature` file
2. Add step implementation function in `steps/mixxx_steps.py` (or a new file
   in `steps/`)
3. Use `@given`, `@when`, or `@then` decorator from `behave`
4. Use helpers: `_rpc()` for spix proxy, `_wait_for_visible` for sync,
   `_get_control_value` for ControlObject reads

### Rules for `When` steps

- **`_set_control_value` is forbidden in `When` steps** — it bypasses the UI
  and does not test real user interaction. Use only in `Given` steps (context
  setup).
- **`_get_control_value` is allowed in `Then` steps** for assertions. It is a
  read-only operation that verifies state.
- **`When` steps must use real UI interactions** — spix `mouseClick`, drag,
  etc. If a step genuinely cannot use a UI interaction (e.g. seeking to an
  exact position on a slider), tag the scenario with `@test/missing-ui-interaction`
  and add a comment annotation explaining why.
- **Custom C++ commands** (e.g. `loadTrack`, `getControlValue`) that bypass
  UI are subject to the same tagging rule as `_set_control_value`.

## How to Add a New Feature

1. Create `features/<name>.feature` with `Feature:` header and
   `Background:` / `Scenario:` blocks
2. Add objectNames in QML as needed (`objectName: "myElement"`)
3. CMake auto-discovers `*.feature` files — no registration needed

## How to Read a ControlObject from a Test

Use `_get_control_value(rpc, group, key)`:

```python
from steps.mixxx_steps import _get_control_value

@then('the play button should be pressed')
def step_play_pressed(context):
    value = _get_control_value(context.mixxx_rpc, "[Channel1]", "play")
    assert float(value) > 0, f"Play is not pressed (value={value})"
```

Or use `command("getControlValue", "[Group],key")` directly:

```python
context.mixxx_rpc.command("getControlValue", "[Channel1],play")
value = context.mixxx_rpc.getStringProperty("mainWindow", "lastControlValue")
```

## Tagging

- `@spix/unsupported` — marks scenarios that spix cannot reliably execute
  (TapHandler interactions, QML Menu overlay popups). These are **skipped** at
  runtime.
- `@test/missing-ui-interaction` — marks scenarios whose `When` steps use
  non-UI workarounds (`_set_control_value`, custom C++ commands, `invokeMethod`)
  because a real spix interaction is not feasible. These scenarios still run.
  Always add a comment annotation above the scenario explaining the gap
  (e.g. `# seek uses _set_control_value because slider can't target exact
   playposition with spix`).

## Known Limitations / Blockers

1. **spix mouseClick does not trigger Qt6 TapHandler** — `TapHandler` (used in
   TrackList.qml header delegates and Track.qml) doesn't respond to synthetic
   mouse events from spix. A patch (spix.patch) is used to provide a work around and make it work but it remains sketchy.
2. **QML Menu popups (Overlay)** — `Menu` components like
   `columnPickerMenu` and `trackContextMenu` render outside the parent item in
   a window-level `Overlay`. spix cannot find them as children of the expected
   parent path. The alternative path `"mainWindow/columnPickerMenu"` works for
   visibility checks but click interaction may fail. Menu must override their `contentItem` with a custom `ListView` which explicitly set a `objectName` and allow interaction with the Menu's action (see 'columnSelectionMenu' and 'contextMenu' Menu for reference)
3. **spix drag-and-drop doesn't work with TableView column drag** —
   `mouseBeginDrag`/`mouseEndDrag` events don't trigger QML `TableView` column
   reorder mechanics. Current workaround: direct `invokeMethod("moveColumn",
   ...)` call.
4. **Window property `width` set via RPC doesn't trigger QML layout** —
   `setStringProperty("mainWindow", "width", "1200")` doesn't cause Column QML layout
   recalculation. Current workaround: direct `invokeMethod("columnWidth",...)` to detect if the column is now hidden.
5. **spix cannot seek to an exact playposition on a slider** — seeking to a
   precise position (e.g. 0.05) uses `_set_control_value` on the `playposition`
   CO. No spix API can target a fractional position on a `Slider` reliably.
   Tagged `@test/missing-ui-interaction`.
6. **spix cannot set an exact rate value on a tempo fader** — same limitation
   as seek: setting rate to a precise float uses `_set_control_value` on
   `rate_dir`/`rate`. Tagged `@test/missing-ui-interaction`.
7. **spix has no real press-and-hold for AbstractButton** — `mouseBeginDrag`/
   `mouseEndDrag` doesn't trigger `pressed` state on `AbstractButton`, so
   long-press behaviors (sync leader toggle) use `invokeMethod`.
   Tagged `@test/missing-ui-interaction`.
8. **Track loading via the library is blocked by TapHandler** — clicking a
   track row in the library doesn't reliably register, so loading uses a custom
   `loadTrack` C++ command that bypasses the library. Tagged
   `@test/missing-ui-interaction`.
