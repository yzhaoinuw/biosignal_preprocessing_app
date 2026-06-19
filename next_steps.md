# Next Steps

Use this file with `work_log.md`. Remove completed items instead of letting this become a permanent wish list.

## Currently Hot

- No active engineering thread. Add the next concrete task here when work resumes.

## Completed: App Designer Source-Control Workflow

Status: implemented and validated

Completed:

- Added the Agent Collab Treaty adoption badge to `README.md`.
- Added `.gitattributes` so Git treats `app.mlapp` and other MATLAB packaged formats as binary.
- Generated the initial tracked `app_exported.m`.
- Added `export_app_source.m` for deterministic generation and verification.
- Added `setup_version_control.m` to configure the repository hook after cloning.
- Added `.githooks/pre-commit` to regenerate, verify, and stage the exported source when the app changes.
- Activated `core.hooksPath=.githooks` in the current checkout.
- Verified the hook in an isolated temporary Git repository without touching the real index.

No remaining work for the initial workflow. Future clones need one setup command:

```powershell
matlab -batch "setup_version_control"
```

## Background / Paused

### Move processing logic out of `app.mlapp`

The app still contains substantial non-UI processing and file orchestration. Over time, move logic that does not directly access UI components into functions under `func/`.

Good first candidates include:

- TDT stream discovery and channel-table construction
- multi-channel fiber-photometry processing
- output-structure assembly
- event extraction

Keep this incremental. Do not rewrite the app solely for stylistic reasons.

### Establish repeatable tests

No automated test suite currently exists. After more processing logic is separated from the UI, add unit tests around pure functions using small synthetic inputs. Do not commit experimental recordings merely to create tests.

### Clarify Sirenia EDF support

The README advertises EDF input, but the active callback currently uses the Viewpoint `.exp` loader. Confirm the intended product contract before modifying or documenting this path further.
