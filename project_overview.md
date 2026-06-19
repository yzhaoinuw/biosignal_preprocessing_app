# Project Overview

## What This Repository Is

This repository contains a MATLAB App Designer application for preprocessing biosignal recordings. The primary product is `app.mlapp`.

The app accepts a subject identifier and one or both of these recording sources:

- fiber-photometry data recorded with TDT
- EEG/EMG data described by a Viewpoint experiment file

It extracts and aligns the requested signals, normalizes selected fiber-photometry channels against isosbestic references, optionally extracts TDT event labels, and saves the processed result as a MATLAB structure in a `.mat` file.

MATLAB R2025a is the current development runtime.

## Active Runtime Path

### 1. App entry point

[`app.mlapp`](app.mlapp)

- Defines the App Designer layout, state, callbacks, and orchestration.
- Adds `func/`, `util/`, and `EEGtoolbox/` to the MATLAB path during `startupFcn`.
- Collects the subject ID and input paths.
- Coordinates TDT processing, Viewpoint processing, progress messages, and output saving.

### 2. TDT and fiber-photometry path

[`util/TDTbin2mat.m`](util/TDTbin2mat.m)

- Reads a TDT block and returns streams and epocs.
- Calls `SEV2mat.m` when needed.

The app then:

1. Discovers streams named like `x<digits><A-D>`.
2. Treats wavelengths at or below 420 nm as isosbestic references.
3. Lets the user name, invert, and select reference channels.
4. Finds the synchronization onset with [`func/get_fp_onset.m`](func/get_fp_onset.m).
5. Normalizes and smooths signals with [`func/correct_fp_signal.m`](func/correct_fp_signal.m).
6. Sanitizes output field names with [`func/sanitizeSignalNames.m`](func/sanitizeSignalNames.m).
7. Extracts a selected TDT epoc as event data when requested.

### 3. Viewpoint EEG/EMG path

[`func/read_viewpoint_data.m`](func/read_viewpoint_data.m)

- Calls [`EEGtoolbox/loadEXP.m`](EEGtoolbox/loadEXP.m) to read Viewpoint experiment metadata.
- Calls [`EEGtoolbox/ExtractContinuousData.m`](EEGtoolbox/ExtractContinuousData.m) to load the continuous recording.

[`func/align_viewpoint_data.m`](func/align_viewpoint_data.m)

- Assumes the first three extracted channels are EMG, EEG, and TTL.
- Finds the relevant TTL onset and trims EEG/EMG to align with the fiber-photometry recording.
- Starts at sample 1 when no TTL pulse is found.

### 4. Output

The app assembles a structure containing:

- one field per processed fiber-photometry signal
- `fp_signal_names`
- `eeg`
- `emg`
- `fp_frequency`
- `ttl_onset`
- `eeg_frequency`
- `event`

The user chooses where to save the resulting `.mat` file.

## Repository Structure

```text
biosignal_preprocessing_app/
|- app.mlapp                 # authoritative App Designer source
|- app_exported.m            # generated text snapshot for Git review
|- export_app_source.m       # generate/verify the text snapshot
|- setup_version_control.m   # enable the repo-local Git hook
|- .githooks/pre-commit      # synchronize the export before commits
|- func/                     # app-specific processing helpers
|- util/                     # TDT import utilities
|- EEGtoolbox/               # imported Viewpoint/EEG support toolbox
|- code/                     # secondary research analysis scripts
|- AGENTS.md                 # agent workflow and project rules
|- project_overview.md       # this architecture map
|- next_steps.md             # current planned work
|- work_log.md               # recent session history
|- work_log_archive/         # rotated history
|- README.md                 # user-facing installation and usage
```

Local data and generated outputs may be present in the working directory, but they are not part of the maintained product.

## Active Versus Secondary Files

### Active product code

- [`app.mlapp`](app.mlapp)
- [`func/`](func/)
- [`util/TDTbin2mat.m`](util/TDTbin2mat.m)
- [`util/SEV2mat.m`](util/SEV2mat.m)
- directly and transitively required functions under [`EEGtoolbox/`](EEGtoolbox/)

The direct Viewpoint entry points used by the app are `loadEXP.m` and `ExtractContinuousData.m`. The full `EEGtoolbox/` tree is older imported code, so changes there should be narrow and justified by the active app path.

### Secondary MATLAB scripts

- [`code/`](code/) contains experiment-specific post-analysis scripts.
- [`Footshock_fromZB.m`](Footshock_fromZB.m) is a separate foot-shock analysis script with workstation-specific paths.
- [`sketch.m`](sketch.m) is scratch/development code.

These scripts are MATLAB source and can be maintained when explicitly requested, but they are not part of the app runtime.

### Out of product scope

- `*.mat` files
- `results/`
- `user_test_data/`
- `event_analysis_sleep_transitions/`
- spreadsheets, figures, presentations, videos, and raw TDT/Viewpoint recordings

Do not use these as commit content. Local data may be used for manual validation only when the user authorizes it.

## App Designer and Git

`app.mlapp` is a packaged App Designer file. Git can store it, but GitHub cannot provide a useful text diff and ordinary text merging is unsafe.

The agreed workflow is:

- keep `app.mlapp` as the only editable source of truth
- generate and track `app_exported.m` after every app change
- use `app_exported.m` for readable GitHub diffs and review
- never edit `app_exported.m` independently
- commit the `.mlapp` and generated `.m` snapshot together
- use MATLAB `visdiff` for authoritative `.mlapp` comparison
- avoid simultaneous UI-layout edits on multiple branches
- gradually move non-UI logic from the app into normal functions under `func/`

`export_app_source.m` generates and verifies the snapshot using MATLAB's App Designer code reader/exporter. The repository pre-commit hook regenerates and stages the snapshot whenever `app.mlapp` is staged, then verifies synchronization before allowing the commit.

After a fresh clone, run:

```powershell
matlab -batch "setup_version_control"
```

The current checkout is configured with `core.hooksPath=.githooks`.

## Tests and Validation

There is currently no automated test suite and no committed lightweight fixture set.

Current validation options are:

- MATLAB `checkcode` on changed `.m` functions
- manual launch and focused app smoke testing
- MATLAB Comparison Tool review for `.mlapp` changes
- authorized local-data runs for the affected input path

Raw recordings and generated `.mat` outputs must remain local and untracked.

## Input Expectations

### TDT

- The selected folder must be a readable TDT block.
- Stream names are expected to match `x<digits><A-D>`.
- Channels with wavelengths at or below 420 nm are treated as reference channels.
- Signal channels can be assigned user-facing output names and optionally inverted.
- A selected TTL epoc is used to determine the fiber-photometry onset.
- A selected event/period epoc can be included in the output.

### Viewpoint

- The selected `.exp` file must resolve its associated binary recording files.
- The app currently expects extracted channels in EMG, EEG, TTL order.
- TTL gaps greater than six seconds are used when choosing the synchronization onset.

### Sirenia/EDF status

The README currently describes Sirenia EDF input, and an EDF reader exists in `EEGtoolbox/`. However, the active app processing callback currently routes EEG/EMG input through `read_viewpoint_data.m`, which calls `loadEXP`. Treat Sirenia support as unverified until its runtime path is confirmed or implemented.

## Practical Reading Order

For product work, read:

1. [`AGENTS.md`](AGENTS.md)
2. [`README.md`](README.md)
3. [`app_exported.m`](app_exported.m), once generated
4. the relevant helper under [`func/`](func/)
5. [`util/TDTbin2mat.m`](util/TDTbin2mat.m) for TDT import work
6. `EEGtoolbox/loadEXP.m` and `EEGtoolbox/ExtractContinuousData.m` for Viewpoint work

Use MATLAB's Comparison Tool when the actual layout or packaged app contents matter.

## Questions Worth Clarifying Later

- Should Sirenia EDF support be completed, or should the README stop advertising it?
- Which transitive `EEGtoolbox/` files are truly required by the active Viewpoint path?
- Should secondary research scripts remain in this repository or move to a separate analysis repository?
- What small, non-sensitive fixture can support repeatable automated tests without committing experimental data?
