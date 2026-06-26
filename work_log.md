# Work Log

Prepend new session notes to the top of this file.

The live log holds at most five unique calendar dates. When a new date would push it past five, move the oldest five dates together into `work_log_archive/work_log_<earliest>_to_<latest>.md`.

If today's date is already at the top, add another `###` session subsection beneath it instead of creating a duplicate date heading.

## 2026-06-26

### Repair TDT signal-name normalization and verification rules (Codex, GPT-5)

- Implemented the previously missing TDT signal-name normalization in `app.mlapp`: user-entered names are now trimmed, lowercased, and written back to the visible fields when the TDT biosignals panel continues.
- Added pre-processing validation that rejects duplicate saved field names after `sanitizeSignalNames`, preventing collisions such as `GCaMP`/`gcamp` and `a-b`/`a_b` before the save path can hit MATLAB duplicate-field errors.
- Added an `AGENTS.md` guardrail requiring behavior-specific diff/source evidence before claims appear in final answers, work logs, next steps, or commit messages.
- Corrected the inaccurate 2026-06-19 work-log entry that had claimed this behavior before it actually existed in the app.
- Verification:
  - `rg -n "lower\(strtrim|signalNamesUnique|Signal names must be unique|formattedSignalNames" app_exported.m` confirmed the final exported source contains the behavior-specific markers.
  - `matlab -batch "addpath('func'); export_app_source('verify'); ..."` confirmed `app_exported.m` matches `app.mlapp`, `GCaMP`/`gcamp` and `a-b`/`a_b` collide after formatting, and `signal one`/`signal two` remain distinct.
  - MATLAB Code Analyzer still reports the same nine app-code warnings.
  - `git diff --check`
  - `treaty validate .` was attempted but the `treaty` command is not available on this shell's PATH.

## 2026-06-19

### Signal-name normalization was incorrectly recorded here (corrected 2026-06-26)

- Correction: this section originally claimed TDT signal names were lowercased and collision-checked, but later inspection showed the committed `app.mlapp` / `app_exported.m` did not contain that logic.
- The actual 2026-06-19 app behavior shipped in this area was the TDT navigation/cache change below.
- The missing signal-name normalization and collision validation were implemented and verified on 2026-06-26.

### Reuse loaded TDT data after returning to Home (Codex, GPT-5)

- Cached the loaded TDT block together with the source folder used to create it.
- Returning from the TDT biosignals panel to Home no longer leaves a suspended processing callback.
- Home Continue now reuses the cached TDT block when the folder is unchanged, preserving the current TDT-panel choices.
- Changing only the subject ID updates the displayed ID without re-reading TDT data; changing the TDT folder triggers a fresh read.
- Kept Viewpoint processing in the final processing phase because that file has not yet been read when the user returns from the TDT panel.
- Cleared the TDT cache when the app resets after saving.
- Verification:
  - `matlab -batch "export_app_source; export_app_source('verify')"`
  - `matlab -batch "issues=checkcode('app_exported.m','-id')"` returned the same nine pre-existing warnings
  - `git diff --check`
  - manual local-data smoke testing remains pending

### Switch to the tri-color treaty badge and publish to main (Codex, GPT-5)

- Replaced the single-color shields.io treaty badge with the centrally hosted tri-color SVG.
- Published the badge follow-up on `dev`, then fast-forwarded `main` to the complete App Designer version-control workflow.
- Verification:
  - `treaty validate .`
  - `git diff --check`
  - confirmed `dev` and `main` remote refs after push

### Add App Designer source export and Git synchronization (Codex, GPT-5)

- Added the Agent Collab Treaty adoption badge to the user-facing README.
- Generated the initial `app_exported.m` from `app.mlapp` using MATLAB's App Designer serializer/exporter.
- Added `export_app_source.m` with deterministic LF output and a strict verification mode.
- Added `.gitattributes` so `.mlapp` and other MATLAB packaged formats are handled as binary while the generated review source stays stable text.
- Added `setup_version_control.m` and activated the repository-local `.githooks/pre-commit` hook.
- The hook regenerates and stages `app_exported.m` only when relevant, rejects staged/unstaged split versions, and verifies synchronization before commit.
- Left the real Git index untouched.
- Code Analyzer reports no issues in the two new MATLAB workflow scripts. The generated app exposes nine pre-existing app-code warnings, primarily unused callback arguments.
- Verification:
  - `matlab -batch "changed=export_app_source; export_app_source('verify');"`
  - `matlab -batch "issues=checkcode('export_app_source.m','-id'); issues2=checkcode('setup_version_control.m','-id');"`
  - `matlab -batch "setup_version_control"`
  - `.githooks/pre-commit` no-op run through Git Bash
  - isolated temporary-repository hook test confirmed that staging `app.mlapp` generates and stages `app_exported.m`
  - `git check-attr -a -- app.mlapp app_exported.m .githooks/pre-commit`
  - `git diff --check`

### Replace treaty placeholders with project-specific guidance (Codex, GPT-5)

- Rewrote the treaty documents around the actual MATLAB App Designer product and runtime.
- Defined `app.mlapp` as the authoritative app and documented the planned generated `app_exported.m` review snapshot.
- Recorded the future export, pre-commit synchronization, MATLAB diff, and incremental helper-function workflow.
- Documented the maintained source boundary: MATLAB scripts, the app, documentation, and supporting workflow files.
- Excluded raw recordings, `.mat` outputs, result folders, local test data, and other experimental artifacts from normal repository work.
- Mapped the active TDT and Viewpoint runtime paths and separated them from secondary research scripts.
- Recorded the current lack of automated tests and the unverified Sirenia/EDF path rather than overstating support.
- Added repository ignore rules for local data and common generated artifacts.
- Verification:
  - `rg --files -g '*.md' -g '!**/.git/**'`
  - inspected `app.mlapp` package contents and extracted function definitions from `matlab/document.xml`
  - inspected direct app references to `func/`, `util/`, and `EEGtoolbox/`
  - inspected Git-tracked files and untracked data with `git status --short --branch` and `git ls-files`
  - `treaty validate .`
  - `git diff --check`

## Entry Format

Use this shape for future sessions:

```markdown
## YYYY-MM-DD

### Short session title (model/version, effort if surfaced, token budget if surfaced)

- high-level change or finding
- another durable change or decision
- Verification:
  - exact command that was run
  - what passed or was confirmed
```

Log substantive work: file edits, meaningful validation/debugging, technical decisions, reusable findings, branch/release changes, and unfinished work that belongs in `next_steps.md`.

Skip casual Q&A, trivial commands, and scratch work with no lasting coordination value.
