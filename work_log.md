# Work Log

Prepend new session notes to the top of this file.

The live log holds at most five unique calendar dates. When a new date would push it past five, move the oldest five dates together into `work_log_archive/work_log_<earliest>_to_<latest>.md`.

If today's date is already at the top, add another `###` session subsection beneath it instead of creating a duplicate date heading.

## 2026-06-19

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
