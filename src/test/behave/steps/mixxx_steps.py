import os
import time
import xmlrpc.client
from behave import given, when, then
import profile

RPC_TIMEOUT = 30


def _rpc():
    return xmlrpc.client.ServerProxy("http://localhost:9000/", allow_none=True)


def _wait_for_visible(rpc, path, timeout=30):
    """Poll until the item at path exists and is visible, or raise."""
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
        f"Timed out waiting for '{path}' to be visible"
        + (f" (last error: {last_err})" if last_err else "")
    )


def _wait_for_nonzero_size(rpc, path, timeout=30):
    """Poll until the item at path has a non-zero bounding box, or raise."""
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
    """Poll until the item at path is no longer visible, or raise."""
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            if not rpc.existsAndVisible(path):
                return
        except Exception:
            pass
        time.sleep(0.5)
    raise RuntimeError(f"Timed out waiting for '{path}' to be hidden")


def _mixxx_running(context):
    mixxx = getattr(context, "mixxx", None)
    return (
        mixxx is not None
        and mixxx.process is not None
        and mixxx.process.poll() is None
    )


def _ensure_profile(context, profile_type):
    """Ensure the requested profile type is active, restarting mixxx if needed."""
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


@given("a new empty profile")
def step_new_empty_profile(context):
    _ensure_profile(context, "empty")


@given("a basic profile ready to go")
def step_basic_profile(context):
    _ensure_profile(context, "basic")


@given("Mixxx is open and ready to operate")
def step_open_and_ready(context):
    if _mixxx_running(context):
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
    _wait_for_nonzero_size(context.mixxx_rpc, "mainWindow")
    _wait_for_hidden(context.mixxx_rpc, "mainWindow/splashScreen")
    _wait_for_visible(context.mixxx_rpc, "mainWindow/library")
    _wait_for_nonzero_size(context.mixxx_rpc, "mainWindow/library")
    _wait_for_visible(context.mixxx_rpc, "mainWindow/libraryContent")
    _wait_for_nonzero_size(context.mixxx_rpc, "mainWindow/libraryContent")


@given("I reset the workspace to default")
def step_reset_workspace(context):
    s = context.mixxx_rpc
    try:
        bb = s.getBoundingBox("mainWindow/libraryContent")
        h = bb[3] if isinstance(bb, (list, tuple)) else bb["height"]
    except Exception:
        h = 0
    if h > 0:
        s.mouseClick("mainWindow/library")
        time.sleep(0.5)


@given("the library directory is configured with test tracks")
def step_configure_library_directory(context):
    tracks = os.environ.get("MIXXX_TEST_TRACKS_DIR")
    if not tracks:
        raise RuntimeError("MIXXX_TEST_TRACKS_DIR not set")
    profile.add_directory_to_db(tracks, context.profile_dir)
    time.sleep(5)


BUTTON_PATHS = {
    "LIBRARY": "mainWindow/library",
}


@when('I check on the button "{button}" in the main toolbar')
def step_check_button(context, button):
    s = context.mixxx_rpc
    path = BUTTON_PATHS.get(button, f"mainWindow/{button.lower()}")
    result = s.existsAndVisible(path)
    assert result, f"Button {button} (path: {path}) not found or not visible"


@when('I click the "{button}" button')
def step_click_button(context, button):
    s = context.mixxx_rpc
    path = BUTTON_PATHS.get(button, f"mainWindow/{button.lower()}")
    s.mouseClick(path)
    time.sleep(0.5)


@then("the library is shown for {operator} than {percent:d}% of the Window's height")
def step_library_height(context, operator, percent):
    s = context.mixxx_rpc
    mw = s.getBoundingBox("mainWindow")
    lb = s.getBoundingBox("mainWindow/libraryContent")
    mw_h = mw[3] if isinstance(mw, (list, tuple)) else mw["height"]
    lb_h = lb[3] if isinstance(lb, (list, tuple)) else lb["height"]
    ratio = float(lb_h) / float(mw_h)
    comparator = lambda a, b: a < b if operator == "less" else lambda a, b: a > b
    assert comparator(ratio, percent / 100.0), f"Library covers only {ratio*100:.1f}% of window height"
