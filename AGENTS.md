# AGENTS.md — Mixxx Project Instructions

See [README.md](README.md) for a project overview, and
[CONTRIBUTING.md](CONTRIBUTING.md) for build instructions, code style,
pre-commit setup, Git workflow, and pull request guidelines.

## Key Architecture

- **ControlObject/ControlProxy**: `[Group], key_name` inter-component communication.
- **Engine thread**: Real-time audio — no allocations, no locks, may emit Qt signals but cannot receive them.
- **parented_ptr/make_parented**: Qt object-tree ownership. Object must get a parent before `parented_ptr` destructs.

## Project Layout

```text
src/          C++ source (engine/, controllers/, library/, mixer/, effects/, qml/, preferences/, util/, test/)
res/          Resources (controllers/ JS/XML, skins/, qml/)
cmake/        CMake modules
tools/        Python helper scripts
```

## E2E UI Tests (behave)

Gherkin-driven BDD tests in `src/test/behave/`. See the dedicated
[src/test/behave/AGENTS.md](src/test/behave/AGENTS.md) for:

- spix RPC API reference
- QML objectName path map
- Step DSL reference and how to add steps/features
- Known limitations (TapHandler, Menu overlay, drag-and-drop, layout)```
