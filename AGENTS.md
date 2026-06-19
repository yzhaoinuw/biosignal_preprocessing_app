# Guidelines for Agents

Read this file first when starting work in this repository. It defines the product boundary, active runtime path, source-control rules, and documentation workflow.

## Project Scope

The main product is the MATLAB App Designer application in `app.mlapp`.

Source work in this repository should focus on:

- `app.mlapp`
- MATLAB source files (`*.m`)
- project documentation
- small source-control or automation files that support the MATLAB workflow

Do not inspect, edit, stage, or commit experimental recordings, generated results, or other data files unless the user explicitly asks. This includes `*.mat`, TDT recording files, Viewpoint/Sirenia recordings, spreadsheets, figures, videos, and folders such as `results/` and `user_test_data/`.

## Runtime Environment

- Primary runtime: MATLAB R2025a on Windows
- Installed executable: `C:\Program Files\MATLAB\R2025a\bin\matlab.exe`
- No Conda environment is required to run the app.
- If Python tooling is introduced later, Conda environments live under `C:\Users\yzhao\miniconda3\envs\`.

The app adds these folders to the MATLAB path at startup:

- `func/`
- `util/`
- `EEGtoolbox/`

Keep the app relocatable. Do not add workstation-specific absolute paths to active product code.

## Common Tasks

Open the app for editing and manual testing:

```powershell
matlab -r "open('app.mlapp')"
```

The user-facing equivalent is to open `app.mlapp` in MATLAB App Designer and click **Run**.

Compare two App Designer files:

```matlab
visdiff("app.mlapp", "path/to/other/app.mlapp")
```

Configure MATLAB as Git's diff and merge tool once per workstation:

```matlab
comparisons.ExternalSCMLink.setupGitConfig()
```

Review MATLAB source files statically:

```matlab
checkcode("func/correct_fp_signal.m")
```

Generate the tracked text snapshot of the App Designer app:

```powershell
matlab -batch "export_app_source"
```

Verify that the snapshot is current:

```powershell
matlab -batch "export_app_source('verify')"
```

Enable the repository's pre-commit hook after cloning:

```powershell
matlab -batch "setup_version_control"
```

There is currently no automated test suite. Verification should be proportional to the change:

- run `checkcode` on changed standalone functions
- manually launch the app after changes to `app.mlapp`
- exercise the affected input path with local data when the user authorizes it
- compare `app.mlapp` revisions with MATLAB's Comparison Tool when reviewing app changes

## App Designer Version-Control Contract

`app.mlapp` is the authoritative runnable and editable app.

The tracked text companion is `app_exported.m`. It exists for readable GitHub diffs, code review, and commit history. It is a generated snapshot, not a second source of truth.

1. Edit `app.mlapp` in App Designer.
2. Regenerate `app_exported.m`.
3. Do not hand-edit `app_exported.m`.
4. Commit `app.mlapp` and `app_exported.m` together.
5. Use GitHub's text diff for `app_exported.m`.
6. Use MATLAB `visdiff` when the actual `.mlapp` package or generated layout must be inspected.

`export_app_source.m` uses MATLAB R2025a's App Designer serializer/exporter, renames the exported class to `app_exported`, writes stable LF line endings, and can verify exact synchronization.

The repo-local `.githooks/pre-commit` hook:

- runs only when `app.mlapp` or `app_exported.m` is staged
- rejects staged/unstaged split versions of either file
- regenerates and stages `app_exported.m` when `app.mlapp` is staged
- verifies that the generated snapshot matches before the commit continues

`setup_version_control.m` generates the initial export and sets this repository's `core.hooksPath` to `.githooks`. Run it once after each new clone.

Git treats `.mlapp` as binary through `.gitattributes`:

```gitattributes
*.mlapp binary
```

Do not attempt a normal text merge of `app.mlapp`. MATLAB can merge editable callback/helper code, but concurrent changes to generated UI layout code usually require manual reconciliation in App Designer. Keep UI-layout branches short and avoid having multiple people edit the layout simultaneously.

## Coding Guidance

- Keep callbacks in `app.mlapp` small and focused on reading UI state, calling functions, and updating the UI.
- Put processing logic that does not directly manipulate UI components in ordinary `.m` files under `func/`.
- Prefer functions with explicit inputs and outputs so they can be reviewed and tested independently.
- Preserve the relative-path startup behavior for `func/`, `util/`, and `EEGtoolbox/`.
- Treat `util/` and `EEGtoolbox/` as imported/vendor-style dependencies. Make targeted changes only when the active app path requires them.
- Do not mix unrelated research analysis scripts into app changes.

## Active Runtime Reminders

- TDT data is loaded through `util/TDTbin2mat.m`.
- Fiber-photometry helpers live in `func/`.
- Viewpoint loading calls `EEGtoolbox/loadEXP.m` and `EEGtoolbox/ExtractContinuousData.m` through `func/read_viewpoint_data.m`.
- App startup adds the dependency folders to the MATLAB path.
- The current Viewpoint alignment assumes the first three extracted channels are EMG, EEG, and TTL.
- TDT stream discovery expects names matching `x<digits><A-D>` and treats wavelengths at or below 420 nm as isosbestic reference channels.
- The README mentions Sirenia EDF input, but the active processing path currently calls the Viewpoint loader. Confirm or implement EDF handling before claiming that path is validated.

## Git and Data Hygiene

Before staging:

```powershell
git status --short
git diff -- . ":(exclude)*.mat"
git diff --cached --name-only
```

Only stage intended source, app, documentation, and workflow files. Never stage local recordings or generated results merely because they are present in the workspace.

If Git reports dubious repository ownership, use:

```powershell
git config --global --add safe.directory C:/Users/yzhao/matlab_projects/biosignal_preprocessing_app
```

Do not delete or untrack existing files without explicit user approval. Adding an ignore rule does not remove files that Git already tracks.

## Pre-Commit Checklist

- `app.mlapp` opens and the affected workflow has been checked when the app changed.
- Changed standalone `.m` functions pass an appropriate `checkcode` review.
- `app_exported.m` matches `app.mlapp`.
- No raw data, generated results, cache files, or workstation-specific paths are staged.
- The diff contains only the requested scope.
- `work_log.md` has a new entry for substantive work.
- `next_steps.md` reflects any newly created or completed follow-up.

## Branch Handoff

`main` is the integration/release branch. Work may occur on `dev` or a focused feature branch.

Before switching branches or handing work off:

```powershell
git status --short --branch
git log --oneline --left-right --cherry-pick main...HEAD
git merge-base --is-ancestor main HEAD
```

Do not leave important app changes only in an uncommitted worktree while moving on to another branch.

## Documentation Map

- `README.md`: user-facing installation and app usage
- `project_overview.md`: architecture, runtime path, active versus secondary files, and data contracts
- `next_steps.md`: concrete planned work and current engineering threads
- `work_log.md`: recent substantive sessions and verification evidence
- `work_log_archive/`: older work-log entries after rotation

At the end of substantive work, update `work_log.md` unless the user explicitly asks not to. Also update `next_steps.md` whenever work creates, completes, or changes a concrete follow-up.

The live work log holds at most five unique calendar dates. When a sixth date is added, move the oldest five dates together into a dated file under `work_log_archive/`.

## Commit Messages

Use a short title. If a commit contains multiple user-requested changes, add a short body with flat bullets describing high-level behavior.

Do not mention tests, documentation, or internal implementation details in a feature commit unless those items are themselves the purpose of the commit.
