import os
import re
import time
import socket
import xmlrpc.client
from behave import given, when, then
import profile
from pathlib import Path

RPC_TIMEOUT = 30
QT_LEFT_BUTTON = 1
QT_RIGHT_BUTTON = 2

QT_CONTROL_MODIFIER = 2

QT_KEY_ENTER = 0x01000005
QT_KEY_DOWN = 0x01000015



# --- RPC helpers ---

def _rpc():
    socket.setdefaulttimeout(10)
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


def _long_press(rpc, path, button=QT_LEFT_BUTTON, hold_ms=1000):
    rpc.mouseClickAndHold(path, button, 0, hold_ms)


def _drag(rpc, source_path, target_path):
    rpc.mouseBeginDrag(source_path)
    time.sleep(0.3)
    rpc.mouseEndDrag(target_path)


def _is_visible(rpc, path):
    # try:
    x, y, width, height = rpc.getBoundingBox(path)
    print(f'getBoundingBox for {path}: {width} {height}')
    return rpc.existsAndVisible(path) and width * height > 0
    # except Exception as e:
    #     print(e)
    #     return False


def _is_column_visible(rpc, col, stabilize_duration=1):
    # Letting time for UI to stabilize
    time.sleep(stabilize_duration)
    columnPath = _column_header_path(col)
    index = rpc.getStringProperty(columnPath, "index")
    if not index and index != 0:
        return False
    columnWidth = float(rpc.invokeMethod(TRACK_TABLE_PATH, "columnWidth", [index]) or 0)
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


def _get_control_value(rpc, group, key):
    rpc.command("getControlValue", f"{group},{key}")
    return rpc.getStringProperty("mainWindow", "lastControlValue")


def _set_control_value(rpc, group, key, value):
    rpc.command("setControlValue", f"{group},{key},0")
    rpc.command("setControlValue", f"{group},{key},{value}")


def _load_track(rpc, deck, filepath):
    rpc.command("loadTrack", f"{deck},{filepath}")


# --- Path resolution ---

BUTTON_PATHS = {
    "LIBRARY": "mainWindow/library",
    "4DECKS": "mainWindow/show4DecksButton",
    "EDIT": "mainWindow/editDeckButton",
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


DECK_PATHS = {
    1: "mainWindow/deck1",
    2: "mainWindow/deck2",
    3: "mainWindow/deck3",
    4: "mainWindow/deck4",
}

DECK_GROUPS = {
    1: "[Channel1]",
    2: "[Channel2]",
    3: "[Channel3]",
    4: "[Channel4]",
}

DECK_BUTTON_PATHS = {
    "play": "playButton",
    "cue": "cueButton",
    "beatjump_forward": "beatjumpForwardButton",
    "beatjump_backward": "beatjumpBackwardButton",
    "loop_in": "loopIn",
    "loop_out": "loopOut",
    "rate": "rateSlider",
    "reloop_toggle": "reloopToggle",
    "sync": "syncButton",
    "range": "rangeButton",
    "loop_halve": "loopHalve",
    "loop_double": "loopDouble",
}


def _deck_hotcue_path(deck, hotcue_number):
    return f"{_deck_path(deck)}/hotcue_{hotcue_number}"


def _deck_path(deck):
    return DECK_PATHS.get(deck, f"mainWindow/deck{deck}")


def _deck_group(deck):
    return DECK_GROUPS.get(deck, f"[Channel{deck}]")


def _deck_button_path(deck, button):
    suffix = DECK_BUTTON_PATHS.get(button, button)
    return f"{_deck_path(deck)}/{suffix}"


KNOWN_COLUMNS = [
    "", "Preview", "Title", "Artist", "Album", "AlbumArtist", "Year",
    "Genre", "Composer", "Grouping", "Track Number", "File Type",
    "Comment", "Duration", "Bitrate", "BPM", "ReplayGain", "Key",
    "Color", "Cover", "Rating", "Date Added", "Times Played",
]


# --- Session helpers ---
PROPERTY_RESET_MAP = {
    "mainWindow": ["width", "height", "x", "y"],
}

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


@given("the 4 decks view is enabled")
def step_4decks_enabled(context):
    s = context.mixxx_rpc
    _set_property(s, "mainWindow/show4DecksButton", "checked", "true")
    time.sleep(1)


@given("Mixxx is open and ready to operate")
def step_open_and_ready(context):
    if not _mixxx_running(context):
        binary = os.environ.get("MIXXX_TEST_BINARY", "mixxx-test")
        if not hasattr(context, "profile_dir"):
            _ensure_profile(context, "basic")
        context.mixxx = profile.MixxxProcess(binary, context.profile_dir)
        context.mixxx.start()
        context.mixxx_rpc = _rpc()
        context._session["mixxx"] = context.mixxx
        context._session["rpc"] = context.mixxx_rpc
    else:
        Path('/workspaces/mixxx/res/qml/main.qml').touch()
        time.sleep(1)
        # for path, props in PROPERTY_RESET_MAP.items():
        #     for prop in props:
        #         if prop not in context._default_props.get(path, {}):
        #             continue
        #         print("setStringProperty", path, prop, context._default_props.get(path, {}).get(prop))
        #         context.mixxx_rpc.setStringProperty(path, prop, context._default_props.get(path, {}).get(prop))
        # context._column_idx = {
        #     col: context.mixxx_rpc.getStringProperty(_column_header_path(col), "index")
        #     for col in KNOWN_COLUMNS
        # }
        # # Discard any popup
        # context.mixxx_rpc.mouseClickWithProportion("mainWindow", 0.01, 0.5)

    _wait_for_visible(context.mixxx_rpc, "mainWindow")
    _wait_for_hidden(context.mixxx_rpc, "mainWindow/splashScreen")
    _wait_for_visible(context.mixxx_rpc, "mainWindow/library")

    if not hasattr(context, "_column_idx"):
        context._column_idx = {
            col: context.mixxx_rpc.getStringProperty(_column_header_path(col), "index")
            for col in KNOWN_COLUMNS
        }
        print("_column_idx", context._column_idx)
    if not hasattr(context, "_default_props"):
        context._default_props = {
            path: {prop: context.mixxx_rpc.getStringProperty(path, prop) for prop in props}
            for path, props in PROPERTY_RESET_MAP.items()
        }
        context._default_props.update({
            "show4DecksButton": {"checked": "false"},
            "editDeckButton": {"checked": "false"},
        })
        print("_default_props", context._default_props)

@given("the library directory is configured with test tracks")
def step_configure_library_directory(context):
    tracks = os.environ.get("MIXXX_TEST_TRACKS_DIR")
    if not tracks:
        raise RuntimeError("MIXXX_TEST_TRACKS_DIR not set")
    profile.add_directory_to_db(tracks, context.profile_dir)
    time.sleep(0.5)


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


@when('I turn off "4 decks" mode')
def step_turn_off_4decks(context):
    s = context.mixxx_rpc
    _click(context.mixxx_rpc, "mainWindow/show4DecksButton")
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
    for i in range(int(index) + 1):
        s.wait(200)
        s.enterKey("mainWindow", QT_KEY_DOWN, 0)
    s.wait(200)
    s.enterKey("mainWindow", QT_KEY_ENTER, 0)
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
        assert _is_column_visible(s, col, 0), (
            f"Column '{col}' should be visible but is not"
        )
    for col in KNOWN_COLUMNS:
        if col and col not in expected:
            assert not _is_column_visible(s, col, 0), (
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


# --- Deck visibility ---

@then('the deck "{group}" should be visible')
def step_deck_visible(context, group):
    DECK_PATH_MAP = {
        "[Channel1]": "mainWindow/deck1",
        "[Channel2]": "mainWindow/deck2",
        "[Channel3]": "mainWindow/deck3",
        "[Channel4]": "mainWindow/deck4",
    }
    _wait_for_visible(context.mixxx_rpc, DECK_PATH_MAP[group])


@then('the deck "{group}" should not be visible')
def step_deck_not_visible(context, group):
    DECK_PATH_MAP = {
        "[Channel1]": "mainWindow/deck1",
        "[Channel2]": "mainWindow/deck2",
        "[Channel3]": "mainWindow/deck3",
        "[Channel4]": "mainWindow/deck4",
    }
    _wait_for_hidden(context.mixxx_rpc, DECK_PATH_MAP[group])


# --- Deck transport ---

@when("I click the play button on deck {deck:d}")
def step_click_deck_play(context, deck):
    _click(context.mixxx_rpc, _deck_button_path(deck, "play"))
    time.sleep(0.3)


@when("I click the cue button on deck {deck:d}")
def step_click_deck_cue(context, deck):
    _click(context.mixxx_rpc, _deck_button_path(deck, "cue"))
    time.sleep(0.3)


@when("I seek to {position:f} in deck {deck:d}")
def step_seek_in_deck(context, position, deck):
    group = _deck_group(deck)
    context.mixxx_rpc.mouseClickWithProportion(_deck_button_path(deck, "overview"), position, 0.5)
    time.sleep(0.5)


@when("I click the beatjump forward button on deck {deck:d}")
def step_click_deck_beatjump_forward(context, deck):
    _click(context.mixxx_rpc, _deck_button_path(deck, "beatjump_forward"))
    time.sleep(0.3)


@then("the play button on deck {deck:d} should be pressed")
def step_play_pressed(context, deck):
    group = _deck_group(deck)
    value = _get_control_value(context.mixxx_rpc, group, "play")
    assert float(value) > 0


@then("the play button on deck {deck:d} should be stopped")
def step_play_stopped(context, deck):
    group = _deck_group(deck)
    value = _get_control_value(context.mixxx_rpc, group, "play")
    assert float(value) == 0, (
        f"Play button on deck {deck} ({group}) is still pressed (value={value})"
    )


@then("the cue point should be set on deck {deck:d}")
def step_cue_set(context, deck):
    group = _deck_group(deck)
    value = _get_control_value(context.mixxx_rpc, group, "cue_point")
    assert float(value) > 0, f"cue_point not set (value={value})"


@when("I set hotcue {hotcue:d} on deck {deck:d}")
def step_set_hotcue(context, hotcue, deck):
    _click(context.mixxx_rpc, _deck_hotcue_path(deck, hotcue))
    time.sleep(0.3)


@then("hotcue {hotcue:d} should be set on deck {deck:d}")
def step_hotcue_set(context, hotcue, deck):
    group = _deck_group(deck)
    value = _get_control_value(context.mixxx_rpc, group, f"hotcue_{hotcue}_status")
    assert float(value) > 0, f"hotcue_{hotcue} not set (value={value})"


@when("I clear hotcue {num:d} on deck {deck:d}")
def step_clear_hotcue(context, num, deck):
    _click(context.mixxx_rpc, _deck_hotcue_path(deck, num))
    time.sleep(0.3)


@then("hotcue {num:d} should not be set on deck {deck:d}")
def step_hotcue_not_set(context, num, deck):
    group = _deck_group(deck)
    value = _get_control_value(context.mixxx_rpc, group, f"hotcue_{num}_status")
    assert float(value) == 0, f"hotcue_{num} is still set (value={value})"


@when("I click the loop in button on deck {deck:d}")
def step_click_loop_in(context, deck):
    _click(context.mixxx_rpc, _deck_button_path(deck, "loop_in"))
    time.sleep(0.3)


@when("I click the loop out button on deck {deck:d}")
def step_click_loop_out(context, deck):
    _click(context.mixxx_rpc, _deck_button_path(deck, "loop_out"))
    time.sleep(0.3)


@when("I click the reloop toggle button on deck {deck:d}")
def step_click_reloop_toggle(context, deck):
    _click(context.mixxx_rpc, _deck_button_path(deck, "reloop_toggle"))
    time.sleep(0.3)


@when("I halve the beatloop size on deck {deck:d}")
def step_halve_beatloop(context, deck):
    _click(context.mixxx_rpc, _deck_button_path(deck, "loop_halve"))
    time.sleep(0.3)


@when("I double the beatloop size on deck {deck:d}")
def step_double_beatloop(context, deck):
    _click(context.mixxx_rpc, _deck_button_path(deck, "loop_double"))
    time.sleep(0.3)


@then("the loop should be enabled on deck {deck:d}")
def step_loop_enabled(context, deck):
    group = _deck_group(deck)
    value = _get_control_value(context.mixxx_rpc, group, "loop_enabled")
    assert float(value) > 0, (
        f"Loop on deck {deck} ({group}) is not enabled (loop_enabled={value})"
    )


@then("the loop should not be enabled on deck {deck:d}")
def step_loop_not_enabled(context, deck):
    group = _deck_group(deck)
    value = _get_control_value(context.mixxx_rpc, group, "loop_enabled")
    assert float(value) == 0, (
        f"Loop on deck {deck} ({group}) is still enabled (loop_enabled={value})"
    )


@when("I remember the beatloop size of deck {deck:d}")
def step_remember_beatloop_size(context, deck):
    group = _deck_group(deck)
    context._saved_beatloop_size = float(
        _get_control_value(context.mixxx_rpc, group, "beatloop_size")
    )


@then("the beatloop size of deck {deck:d} should have changed")
def step_beatloop_size_changed(context, deck):
    group = _deck_group(deck)
    current = float(_get_control_value(context.mixxx_rpc, group, "beatloop_size"))
    saved = getattr(context, "_saved_beatloop_size", None)
    assert saved is not None, "No saved beatloop size (forgot 'I remember' step?)"
    assert current != saved, (
        f"Beatloop size did not change on deck {deck} ({group}): "
        f"was {saved}, is {current}"
    )
    context._saved_beatloop_size = current


# --- Sync ---

@when("I click the sync button on deck {deck:d}")
def step_click_sync(context, deck):
    _click(context.mixxx_rpc, _deck_button_path(deck, "sync"))
    time.sleep(0.3)


@when("I long-press the sync button on deck {deck:d}")
def step_long_press_sync(context, deck):
    rpc = context.mixxx_rpc
    path = _deck_button_path(deck, "sync")
    rpc.invokeMethod(path, "toggleLeader", [])
    time.sleep(0.5)


@then("sync should be enabled on deck {deck:d}")
def step_sync_enabled(context, deck):
    group = _deck_group(deck)
    value = _get_control_value(context.mixxx_rpc, group, "sync_enabled")
    assert float(value) > 0, (
        f"Sync on deck {deck} ({group}) is not enabled (value={value})"
    )


@then("sync should be disabled on deck {deck:d}")
def step_sync_disabled(context, deck):
    group = _deck_group(deck)
    value = _get_control_value(context.mixxx_rpc, group, "sync_enabled")
    assert float(value) == 0, (
        f"Sync on deck {deck} ({group}) is still enabled (value={value})"
    )


@then("deck {deck:d} should be the sync leader")
def step_sync_leader(context, deck):
    group = _deck_group(deck)
    leader = _get_control_value(context.mixxx_rpc, group, "sync_leader")
    assert float(leader) > 0, (
        f"Deck {deck} ({group}) is not the sync leader (sync_leader={leader})"
    )


# --- Range ---

@when("I click the range button on deck {deck:d}")
def step_click_range(context, deck):
    _click(context.mixxx_rpc, _deck_button_path(deck, "range"))
    time.sleep(0.3)


@when("I remember the rate range of deck {deck:d}")
def step_remember_rate_range(context, deck):
    group = _deck_group(deck)
    context._saved_rate_range = float(
        _get_control_value(context.mixxx_rpc, group, "rateRange")
    )


@then("the rate range of deck {deck:d} should have changed")
def step_rate_range_changed(context, deck):
    group = _deck_group(deck)
    current = float(_get_control_value(context.mixxx_rpc, group, "rateRange"))
    saved = getattr(context, "_saved_rate_range", None)
    assert saved is not None, "No saved rate range (forgot 'I remember' step?)"
    assert current != saved, (
        f"Rate range did not change on deck {deck} ({group}): "
        f"was {saved}, is {current}"
    )


# --- Tempo fader ---

@when("I set the rate of deck {deck:d} to {value:f}")
def step_set_rate(context, deck, value):
    path = f'{_deck_button_path(deck, "rate")}/handle'
    bb = context.mixxx_rpc.getBoundingBox(_deck_button_path(deck, "rate"))
    context.mixxx_rpc.mouseDrag(path, 0, 0, 0, bb[3] / 4 * -value, 1000)


@then("the rate of deck {deck:d} should be near {target}")
def step_rate_near(context, deck, target):
    group = _deck_group(deck)
    actual = float(_get_control_value(context.mixxx_rpc, group, "rate"))
    tol = 0.01
    assert abs(actual - float(target)) < tol, (
        f"Rate on deck {deck} ({group}) is {actual}, expected ~{target}"
    )


@then("the rate ratio of deck {deck:d} should be near {target}")
def step_rate_ratio_near(context, deck, target):
    group = _deck_group(deck)
    actual = float(_get_control_value(context.mixxx_rpc, group, "rate_ratio"))
    tol = 0.01
    assert abs(actual - float(target)) < tol, (
        f"Rate ratio on deck {deck} ({group}) is {actual}, expected ~{target}"
    )


# --- Edit mode ---

@then("edit mode should be enabled")
def step_edit_mode_enabled(context):
    checked = _get_property(context.mixxx_rpc, "mainWindow/editDeckButton", "checked")
    assert checked == "true", f"Edit mode not enabled (checked={checked})"


@then("edit mode should not be enabled")
def step_edit_mode_disabled(context):
    checked = _get_property(context.mixxx_rpc, "mainWindow/editDeckButton", "checked")
    assert checked == "false", f"Edit mode still enabled (checked={checked})"


@then('the edit overlay should {action} visible on the "{component}" component in deck {deck:d}')
def step_edit_overlay_visible(context, action, component, deck):
    path = f"{_deck_button_path(deck, component)}/overlayItem"
    if action == "be":
        assert _is_visible(context.mixxx_rpc, path), f"Component '{component}' is not visible"
    else:
        assert not _is_visible(context.mixxx_rpc, path), f"Component '{component}' is visible"


@when('I move the "{component}" component in deck {deck:d} after the "{target}" component')
def step_move_component_after(context, component, deck, target):
    component_path = _deck_button_path(deck, component)
    target_path = _deck_button_path(deck, target)

    component_bb = context.mixxx_rpc.getBoundingBox(component_path)
    target_bb = context.mixxx_rpc.getBoundingBox(target_path)
    delta = target_bb[0] - component_bb[0], target_bb[1] - component_bb[1]

    context.mixxx_rpc.mouseDrag(component_path, 0, 0, *delta, 1000)
    time.sleep(2)


@when('I move the selected group in deck {deck:d} after the "{target}" component')
def step_move_component_after(context, deck, target):
    component_path = _deck_button_path(deck, "selectedGroupOverlay")
    target_path = _deck_button_path(deck, target)

    component_bb = context.mixxx_rpc.getBoundingBox(component_path)
    target_bb = context.mixxx_rpc.getBoundingBox(target_path)
    delta = target_bb[0] - component_bb[0], target_bb[1] - component_bb[1]

    context.mixxx_rpc.mouseDrag(component_path, 0, 0, *delta, 1000)
    time.sleep(2)


@then('the "{component}" component should appear after the "{target}" component in deck {deck:d}')
def step_component_order_after(context, component, target, deck):
    component_bb = context.mixxx_rpc.getBoundingBox(_deck_button_path(deck, component))
    target_bb = context.mixxx_rpc.getBoundingBox(_deck_button_path(deck, target))
    assert component_bb[0] > target_bb[0], (
        f"Component {component} (x={component_bb[0]}) is not after {target} (x={target_bb[0]})"
    )


@when('I select the group containing "{component}" in deck {deck:d} with a {action}')
def step_select_component_group(context, component, deck, action):
    path = _deck_button_path(deck, component)
    if action == "long press":
        context.mixxx_rpc.mouseClickAndHold(path, QT_LEFT_BUTTON, 0, 1000)
    elif action == "ctrl+click":
        context.mixxx_rpc.mouseClickWithButton(path, QT_LEFT_BUTTON, QT_CONTROL_MODIFIER)
    else:
        raise NotImplementedError(f"Unsupported action '{action}'")
    time.sleep(0.3)


@then('the "{group_name}" group should appear after the "{target}" component in deck {deck:d}')
def step_group_order_after(context, group_name, target, deck):
    raise NotImplementedError(
        "Same approach as component_order_after but operates on groups "
        f"(LayoutContainer) in {_deck_group(deck)}'s model tree. "
        "Parse the serialized JSON to verify order."
    )


# --- Hotcues ---

# --- Track loading ---

@when("I load the track at row {row:d} into deck {deck:d}")
def step_load_track_to_deck(context, row, deck):
    s = context.mixxx_rpc
    tracks_dir = os.environ.get("MIXXX_TEST_TRACKS_DIR", "")
    if not tracks_dir:
        raise RuntimeError("MIXXX_TEST_TRACKS_DIR not set")
    track_files = sorted(os.listdir(tracks_dir))
    if not track_files:
        raise RuntimeError(f"No track files found in {tracks_dir}")
    idx = min(row - 1, len(track_files) - 1)
    filepath = os.path.join(tracks_dir, track_files[idx])
    _load_track(s, deck, filepath)
    time.sleep(1)


@when("I remember the playback position of deck {deck:d}")
def step_remember_playposition(context, deck):
    group = _deck_group(deck)
    context._saved_playposition = float(
        _get_control_value(context.mixxx_rpc, group, "playposition")
    )


@then("the playback position of deck {deck:d} should have changed")
def step_playposition_changed(context, deck):
    group = _deck_group(deck)
    current = float(_get_control_value(context.mixxx_rpc, group, "playposition"))
    saved = getattr(context, "_saved_playposition", None)
    assert saved is not None, "No saved playback position (forgot 'I remember' step?)"
    assert current != saved, (
        f"Playback position did not change on deck {deck} ({group}): "
        f"was {saved}, is {current}"
    )
    context._saved_playposition = current
