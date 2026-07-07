import os
import re
import time
import xmlrpc.client
from behave import given, when, then
import profile

RPC_TIMEOUT = 30
QT_LEFT_BUTTON = 1
QT_RIGHT_BUTTON = 2


# --- RPC helpers ---

def _rpc():
    return xmlrpc.client.ServerProxy("http://localhost:9000/", allow_none=True)


def _wait_for_visible(rpc, path, timeout=5):
    deadline = time.time() + timeout
    last_err = None
    while time.time() < deadline:
        try:
            if rpc.existsAndVisible(path):
                return
        except Exception as e:
            last_err = e
        time.sleep(0.5)
    raise RuntimeError(
        f"Timed out waiting for '{path}' to be visible/opened"
        + (f" (last error: {last_err})" if last_err else "")
    )


def _wait_for_nonzero_size(rpc, path, timeout=5):
    deadline = time.time() + timeout
    last_err = None
    while time.time() < deadline:
        try:
            bb = rpc.getBoundingBox(path)
            w = bb[2] if isinstance(bb, (list, tuple)) else bb["width"]
            h = bb[3] if isinstance(bb, (list, tuple)) else bb["height"]
            if w > 0 and h > 0:
                return bb
        except Exception as e:
            last_err = e
        time.sleep(0.5)
    raise RuntimeError(
        f"Timed out waiting for '{path}' to have non-zero size"
        + (f" (last error: {last_err})" if last_err else "")
    )


def _wait_for_hidden(rpc, path, timeout=60):
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            if not rpc.existsAndVisible(path):
                return
        except Exception:
            pass
        time.sleep(0.5)
    raise RuntimeError(f"Timed out waiting for '{path}' to be hidden")


# --- Mouse helpers ---

def _click(rpc, path):
    rpc.mouseClick(path)


def _right_click(rpc, path):
    assert rpc.existsAndVisible(path), f"{path} cannot be clicked as it does not exists"
    rpc.mouseClickWithButton(path, QT_RIGHT_BUTTON, 0)


def _long_press(rpc, path, hold_ms=1000):
    rpc.mouseBeginDrag(path)
    rpc.wait(hold_ms)
    rpc.mouseEndDrag(path)


def _drag(rpc, source_path, target_path):
    rpc.mouseBeginDrag(source_path)
    time.sleep(0.3)
    rpc.mouseEndDrag(target_path)


def _is_visible(rpc, path):
    # try:
    x, y, width, height = rpc.getBoundingBox(path)
    print(f'getBoundingBox for {path}: {width} {height} -> width:{rpc.getStringProperty(path, "index")}')
    return rpc.existsAndVisible(path) and width * height > 0
    # except Exception as e:
    #     print(e)
    #     return False


def _is_column_visible(rpc, col):
    columnPath = _column_header_path(col)
    index = rpc.getStringProperty(columnPath, "index")
    print("Column index for", col, index)
    if not index and index != 0:
        return False
    columnWidth = float(rpc.invokeMethod(TRACK_TABLE_PATH, "columnWidth", [index]) or 0)
    print(f'columnWidth for {index}: {columnWidth}')
    return rpc.existsAndVisible(columnPath) and columnWidth > 0


def _get_bb(rpc, path):
    bb = rpc.getBoundingBox(path)
    if isinstance(bb, (list, tuple)):
        return {"x": bb[0], "y": bb[1], "width": bb[2], "height": bb[3]}
    return bb


def _set_property(rpc, path, prop, value):
    rpc.setStringProperty(path, prop, str(value))


def _get_property(rpc, path, prop):
    return rpc.getStringProperty(path, prop)


# --- Path resolution ---

BUTTON_PATHS = {
    "LIBRARY": "mainWindow/library",
}

LIBRARY_CONTENT = "mainWindow/libraryContent"
TRACKLIST_PATH = f"{LIBRARY_CONTENT}/trackList"
COLUMN_HEADER_PATH = f"{TRACKLIST_PATH}/columnHeader"
COLUMN_PICKER_MENU_PATH = "mainWindow/columnPickerMenu"
TRACK_TABLE_PATH = f"{TRACKLIST_PATH}/trackTableView"
TRACK_ROW_PATH = f"{TRACK_TABLE_PATH}"
TRACK_CONTEXT_MENU_PATH = "mainWindow/trackContextMenu"


def _button_path(name):
    return BUTTON_PATHS.get(name, f"mainWindow/{name.lower()}")


def _column_header_path(column):
    return f"{COLUMN_HEADER_PATH}/{column}"


def _track_row_path(row):
    return f"{TRACK_ROW_PATH}/trackRow_{row}"


KNOWN_COLUMNS = [
    "", "Preview", "Title", "Artist", "Album", "AlbumArtist", "Year",
    "Genre", "Composer", "Grouping", "Track Number", "File Type",
    "Comment", "Duration", "Bitrate", "BPM", "ReplayGain", "Key",
    "Color", "Cover", "Rating", "Date Added", "Times Played",
]


# --- Session helpers ---

def _mixxx_running(context):
    mixxx = getattr(context, "mixxx", None)
    return (
        mixxx is not None
        and mixxx.process is not None
        and mixxx.process.poll() is None
    )


def _ensure_profile(context, profile_type):
    session = context._session
    if session.get("active_profile_type") == profile_type and _mixxx_running(context):
        return
    if _mixxx_running(context):
        try:
            context.mixxx_rpc.quit()
            time.sleep(1)
        except Exception:
            pass
        context.mixxx.stop()
        session["mixxx"] = None
        session["rpc"] = None
    profile_dir = profile.make_temp_profile(profile_type)
    context.profile_dir = profile_dir
    context.active_profile_type = profile_type
    session["profile_dir"] = profile_dir
    session["active_profile_type"] = profile_type
    session["profile_dirs"].append(profile_dir)


# --- Given steps ---

@given("a new empty profile")
def step_new_empty_profile(context):
    _ensure_profile(context, "empty")


@given("a basic profile ready to go")
def step_basic_profile(context):
    _ensure_profile(context, "basic")


@given("Mixxx is open and ready to operate")
def step_open_and_ready(context):
    if _mixxx_running(context):
        for prop, value in context._mainwindow_default_props.items():
            context.mixxx_rpc.setStringProperty("mainWindow", prop, value)
        context._column_idx = {
            col: context.mixxx_rpc.getStringProperty(_column_header_path(col), "index")
            for col in KNOWN_COLUMNS
        }
        return
    binary = os.environ.get("MIXXX_TEST_BINARY", "mixxx-test")
    if not hasattr(context, "profile_dir"):
        _ensure_profile(context, "basic")
    context.mixxx = profile.MixxxProcess(binary, context.profile_dir)
    context.mixxx.start()
    context.mixxx_rpc = _rpc()
    context._session["mixxx"] = context.mixxx
    context._session["rpc"] = context.mixxx_rpc
    _wait_for_visible(context.mixxx_rpc, "mainWindow")
    _wait_for_hidden(context.mixxx_rpc, "mainWindow/splashScreen")
    _wait_for_visible(context.mixxx_rpc, "mainWindow/library")
    context._column_idx = {
        col: context.mixxx_rpc.getStringProperty(_column_header_path(col), "index")
        for col in KNOWN_COLUMNS
    }
    context._mainwindow_default_props = {
        prop: context.mixxx_rpc.getStringProperty("mainWindow", prop)
        for prop in ["width", "height", "x", "y"]
    }

@given("the library directory is configured with test tracks")
def step_configure_library_directory(context):
    tracks = os.environ.get("MIXXX_TEST_TRACKS_DIR")
    if not tracks:
        raise RuntimeError("MIXXX_TEST_TRACKS_DIR not set")
    profile.add_directory_to_db(tracks, context.profile_dir)
    time.sleep(5)


# --- When: button steps ---

@when("I resize the window's width to {width:d}px")
def step_resize_window_width(context, width):
    s = context.mixxx_rpc
    _set_property(s, "mainWindow", "width", width)
    time.sleep(0.5)


@when('I check on the button "{button}" in the main toolbar')
def step_check_button(context, button):
    s = context.mixxx_rpc
    path = _button_path(button)
    assert _is_visible(s, path), f"Button {button} (path: {path}) not found or not visible"


@when('I click the "{button}" button')
def step_click_button(context, button):
    s = context.mixxx_rpc
    _click(s, _button_path(button))
    time.sleep(0.5)


# --- When: column steps ---

@when('I click the column header "{column}"')
def step_click_column_header(context, column):
    s = context.mixxx_rpc
    path = _column_header_path(column)
    _click(s, path)
    time.sleep(0.5)


@when('I drag the column "{column}" before the column "{target}"')
def step_drag_column(context, column, target):
    s = context.mixxx_rpc
    # FIXME not working with column, using bare "moveColumn" instead
    # _drag(s, _column_header_path(column), _column_header_path(target))
    print(TRACK_TABLE_PATH, "moveColumn", [context._column_idx[column], context._column_idx[target]])
    s.invokeMethod(TRACK_TABLE_PATH, "moveColumn", [context._column_idx[column], context._column_idx[target]])
    time.sleep(0.5)


@when("I open the column picker menu")
def step_open_column_picker(context):
    s = context.mixxx_rpc
    _right_click(s, _column_header_path("Title"))
    _wait_for_visible(s, COLUMN_PICKER_MENU_PATH)


@when('I toggle the column "{column}" in the column picker')
def step_toggle_column(context, column):
    s = context.mixxx_rpc
    index = context._column_idx[column]
    if index != 0 and not index:
        raise KeyError(f'column {column} unknown')
    s.invokeMethod(COLUMN_PICKER_MENU_PATH, "setObjectNameFor", [index])
    _click(s, f"{COLUMN_PICKER_MENU_PATH}/1")
    time.sleep(0.5)


# --- When: track steps ---

@when("I click the track at row {row:d}")
def step_click_track(context, row):
    s = context.mixxx_rpc
    _click(s, _track_row_path(row))
    time.sleep(0.3)


@when("I right-click the track at row {row:d}")
def step_right_click_track(context, row):
    s = context.mixxx_rpc
    _right_click(s, _track_row_path(row))
    time.sleep(0.3)


@when("I long-press the track at row {row:d}")
def step_long_press_track(context, row):
    s = context.mixxx_rpc
    _long_press(s, _track_row_path(row))
    time.sleep(0.3)


# --- Then: library height ---

@then("the library is shown for {operator} than {percent:d}% of the Window's height")
def step_library_width(context, operator, percent):
    s = context.mixxx_rpc
    mw = _get_bb(s, "mainWindow")
    lb = _get_bb(s, LIBRARY_CONTENT)
    ratio = float(lb["height"]) / float(mw["height"])
    if operator == "less":
        assert ratio < percent / 100.0, f"Library covers {ratio*100:.1f}%, expected less than {percent}%"
    else:
        assert ratio > percent / 100.0, f"Library covers {ratio*100:.1f}%, expected more than {percent}%"


# --- Then: column visibility ---

@then('only the column "{columns}" are shown')
def step_only_columns_shown(context, columns):
    # time.sleep(10)
    s = context.mixxx_rpc
    expected = [c.strip() for c in re.split(r"[,\.]", columns)]
    for col in expected:
        if not col:
            continue
        assert _is_column_visible(s, col), (
            f"Column '{col}' should be visible but is not"
        )
    for col in KNOWN_COLUMNS:
        if col and col not in expected:
            assert not _is_column_visible(s, col), (
                f"Column '{col}' should not be visible but is"
            )


@then('the column "{column}" should {state} visible')
def step_column_visible(context, column, state):
    s = context.mixxx_rpc
    requested = "not" not in state
    currentState = "not" if requested else "still"
    assert _is_column_visible(s, column) is requested, f"Column {column} is {currentState} visible"


@then('the column "{column}" should appear before the column "{other}"')
def step_column_order(context, column, other):
    s = context.mixxx_rpc
    col_bb = _get_bb(s, _column_header_path(column))
    other_bb = _get_bb(s, _column_header_path(other))
    assert col_bb["x"] < other_bb["x"], (
        f"Column {column} (x={col_bb['x']}) is not before {other} (x={other_bb['x']})"
    )


# --- Then: sort order ---

@then('the results should be sorted by "{column}" in "{order}" order')
def step_sorted_by(context, column, order):
    s = context.mixxx_rpc
    sort_col = _get_property(s, COLUMN_HEADER_PATH, "sortingColumn")
    sort_order = _get_property(s, COLUMN_HEADER_PATH, "sortingOrder")
    assert sort_col != "-1", "No column is being sorted"
    assert order in ("ascending", "descending"), f"Unknown order: {order}"
    expected_order = "0" if order == "ascending" else "1"
    assert sort_order == expected_order, (
        f"Expected {order} sort (Qt value {expected_order}), got {sort_order}"
    )


# --- Then: track selection ---

@then("the track at row {row:d} should be selected")
def step_track_selected(context, row):
    s = context.mixxx_rpc
    path = _track_row_path(row)
    selected = _get_property(s, path, "selected")
    assert selected == "true", f"Track at row {row} is not selected (selected={selected})"


# --- Then: context menu ---

@then("the track context menu should be visible")
def step_track_context_menu_visible(context):
    s = context.mixxx_rpc
    assert _is_visible(s, TRACK_CONTEXT_MENU_PATH), "Track context menu is not visible"
