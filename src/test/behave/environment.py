import os
import shutil
import time


def _artifacts_dir():
    d = os.environ.get("MIXXX_TEST_ARTIFACTS", "artifacts")
    os.makedirs(d, exist_ok=True)
    return d


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
