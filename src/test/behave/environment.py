import os
import shutil
import time


def _artifacts_dir():
    d = os.environ.get("MIXXX_TEST_ARTIFACTS", "artifacts")
    os.makedirs(d, exist_ok=True)
    return d


def _reset_workspace(context):
    """Reset the UI to default state (unmaximize library, close popups, etc.)."""
    rpc = getattr(context, "mixxx_rpc", None)
    if rpc is None:
        return
    try:
        mw = rpc.getBoundingBox("mainWindow")
        lb = rpc.getBoundingBox("mainWindow/libraryContent")
        mw_h = mw[3] if isinstance(mw, (list, tuple)) else mw["height"]
        lb_h = lb[3] if isinstance(lb, (list, tuple)) else lb["height"]
        if mw_h > 0 and lb_h > 0:
            ratio = float(lb_h) / float(mw_h)
            if ratio > 0.75:
                rpc.mouseClick("mainWindow/library")
                time.sleep(0.5)
    except Exception:
        pass


def before_all(context):
    context._session = {
        "profile_dirs": [],
        "active_profile_type": None,
        "profile_dir": None,
        "mixxx": None,
        "rpc": None,
    }


def before_scenario(context, scenario):
    session = context._session
    if "spix/unsupported" in scenario.effective_tags:
        scenario.skip("Marked with @skip tag in Scenario")
    if session.get("mixxx") is not None:
        context.mixxx = session["mixxx"]
        context.mixxx_rpc = session["rpc"]
        context.profile_dir = session["profile_dir"]
        context.active_profile_type = session["active_profile_type"]


def after_scenario(context, scenario):
    if scenario.status == "failed" and getattr(context, "mixxx_rpc", None) is not None:
        safe_name = scenario.name.replace("/", "_").replace(" ", "_")
        path = os.path.join(_artifacts_dir(), f"{safe_name}.png")
        try:
            context.mixxx_rpc.takeScreenshot("mainWindow", path)
        except Exception:
            pass

    _reset_workspace(context)


def after_all(context):
    session = getattr(context, "_session", {})
    mixxx = session.get("mixxx")
    if mixxx is not None:
        try:
            rpc = session.get("rpc")
            if rpc is not None:
                rpc.quit()
                time.sleep(1)
        except Exception:
            pass
        mixxx.stop()

    for d in session.get("profile_dirs", []):
        shutil.rmtree(d, ignore_errors=True)
