# Biosignal Preprocessing Pipeline Merge Guide

This guide compares the active data-extraction pipelines in this repository and in `C:\Users\yzhao\matlab_projects\preprocess_sleep_data`. It is meant to support the long-term goal of making the MATLAB App Designer app in this repository replace, or at least serve as a user-friendly alternative to, the script-based `preprocess_sleep_data` workflow.

The comparison focuses on the shared EEG/EMG, fiber-photometry, and synchronization paths first, then summarizes the script-only and app-only behavior that should be preserved during merging.

## Current Products

### Biosignal Preprocessing App

Active product:

- `app.mlapp`
- generated review snapshot `app_exported.m`
- helper functions under `func/`
- TDT utilities under `util/`
- Viewpoint helpers under `EEGtoolbox/`

The app is a GUI workflow. It currently accepts a subject ID, optional TDT fiber-photometry input, and optional Viewpoint EEG/EMG input. It lets the user inspect detected TDT streams, name selected FP signals, choose reference channels, optionally invert signals, optionally choose a TDT event epoc, process the selected signals, and save one `.mat` file.

### preprocess_sleep_data

Active products:

- `preprocess_sleep_data.m`
- `preprocess_sirenia.m`
- shared-style Viewpoint helpers under `EEGtoolbox/`
- TDT import helpers at repo root

This is a script/function workflow for preparing Sleep Scoring App-ready `.mat` files. It supports Viewpoint EEG/EMG, TDT EEG/EMG, optional TDT photometry, optional sleep scores, segmentation, video metadata, and Sirenia EDF through a separate function.

## Shared Low-Level Readers

The shared low-level readers should be treated as equivalent unless future inspection finds otherwise. The following files had matching SHA-256 hashes across the two projects during the comparison:

- `TDTbin2mat.m`
- `SEV2mat.m`
- `binary_to_OnOff.m`
- `EEGtoolbox/loadEXP.m`
- `EEGtoolbox/ExtractContinuousData.m`

This means the main pipeline drift is not in raw TDT or Viewpoint parsing. It is in orchestration: channel selection, extraction windows, TTL trimming, FP normalization details, segmentation, metadata assembly, and output contracts.

## Pipeline They Have In Common

Both projects share this conceptual flow when Viewpoint EEG/EMG and TDT FP are used together:

1. Load Viewpoint metadata with `loadEXP`.
2. Extract continuous Viewpoint data with `ExtractContinuousData`.
3. Treat the first extracted Viewpoint channels as EMG, EEG, and TTL.
4. Load TDT streams and epocs with `TDTbin2mat`.
5. Use a TDT TTL epoc to find the start of the FP recording.
6. Trim FP streams before that TDT TTL onset.
7. Use the Viewpoint TTL trace to find the corresponding EEG/EMG onset when EEG/EMG and FP come from separate sources.
8. Trim EEG/EMG before that Viewpoint TTL onset.
9. Fit the isosbestic/reference signal to the biological FP signal with `polyfit`.
10. Compute percent dF/F and smooth with `filtfilt`.
11. Save EEG, EMG, FP signal data, sampling rates, and alignment metadata.

The app implements the FP correction as `func/correct_fp_signal.m`, the TDT onset helper as `func/get_fp_onset.m`, and the Viewpoint trim as `func/align_viewpoint_data.m`. `preprocess_sleep_data.m` currently keeps the equivalent logic inline.

## Important Drift In Shared Behavior

### Viewpoint extraction end time

`preprocess_sleep_data` has a newer behavior for single-bin Viewpoint extraction: it passes an explicit end time based on the actual bin duration instead of always using `Inf`. This avoids an `ExtractContinuousData(..., Inf, ...)` behavior that can truncate extraction to the last full minute.

The app currently uses `TimeRelEndSec = Inf` in `func/read_viewpoint_data.m`. Porting the explicit single-bin duration behavior should be a high-priority app update.

Suggested app behavior:

- For a single Viewpoint bin, pass `Info.BinFiles(1).Duration`.
- For multi-bin Viewpoint exports, keep the current broader extraction behavior until the app also implements bin-aware segmentation.
- Record the extraction duration logic in a helper so it can be tested without launching the GUI.

### Conditional Viewpoint TTL trimming

`preprocess_sleep_data` only trims Viewpoint EEG/EMG by the Viewpoint TTL trace when Viewpoint EEG/EMG is being synchronized to separate TDT photometry.

The app currently routes Viewpoint EEG/EMG through `align_viewpoint_data`, which trims by TTL whenever Viewpoint data is processed. That is probably correct for mixed Viewpoint + TDT FP, but too aggressive for Viewpoint-only EEG/EMG if the TTL trace is present for another reason.

Suggested app behavior:

- If TDT FP input is present and a TTL synchronization channel is selected, trim both FP and EEG/EMG to the synchronized start.
- If Viewpoint EEG/EMG is processed without TDT FP, extract EEG/EMG without TTL trimming.
- If no TTL pulse is found in a mixed-source workflow, keep the current fallback of starting at sample 1 but surface a clear warning in the GUI.

### FP output frequency and downsampling

`preprocess_sleep_data` saves NE after downsampling by `ds_factor_FP`, defaulting to 100, and updates `ne_frequency`.

The app saves processed FP signals at the original TDT stream rate and records `fp_frequency`.

This is not necessarily wrong, but it is a downstream contract difference. The Sleep Scoring App has historically expected NE-like FP input under `ne` with `ne_frequency`, while the app currently supports arbitrary named FP signals under `fp_signal_names`.

Suggested app behavior:

- Preserve the app's generic multi-signal FP output.
- Add an optional Sleep Scoring compatible output mode that can map one selected FP signal to `ne`.
- In that mode, support `ds_factor_FP` and save `ne_frequency`.
- Keep `fp_frequency` / `fp_signal_names` for generic app outputs so existing app behavior is not lost.

### FP fit interval

`preprocess_sleep_data` supports `fit_interval`, allowing the regression fit to use only a selected time range.

`correct_fp_signal` already has a `rangeInd` option, but the GUI path does not expose it.

Suggested app behavior:

- Keep full-trace fitting as the GUI default.
- Add an optional advanced setting for fit interval later.
- First refactor FP processing into a pure function so this can be tested with synthetic arrays.

### Signal naming and collision handling

The app now has a useful behavior that `preprocess_sleep_data` does not need in the same way: user-entered TDT signal names are normalized and checked for saved-field collisions before processing. This should be preserved when adding Sleep Scoring compatible output.

Suggested app behavior:

- Continue validating generic FP field names.
- When a selected FP signal is also exported as `ne`, ensure the app does not create confusing duplicate names such as both `ne` and a generic `ne` field unless that is intentionally documented.

## Differences To Preserve Or Port

### Behaviors in preprocess_sleep_data that the app should eventually gain

#### TDT EEG/EMG input

`preprocess_sleep_data` can use a TDT folder as the EEG/EMG source by taking `EEG_stream`, `EEG_chan`, and `EMG_stream`.

The app currently treats TDT primarily as FP input. To replace the script workflow, it should support TDT EEG/EMG source selection in the GUI.

#### Segmentation

`preprocess_sleep_data` segments outputs:

- TDT EEG/EMG recordings longer than 12 hours are split into 12-hour chunks.
- Viewpoint EEG/EMG follows Viewpoint `.exp` bin boundaries.
- TDT FP paired with Viewpoint EEG/EMG is split using the same output windows as EEG/EMG.

The app currently saves one output file. Segmentation is a core replacement requirement.

#### Sleep scores

`preprocess_sleep_data` can import manual sleep-score spreadsheets and save `sleep_scores` plus `num_class`.

The app has no sleep-score import path yet. This should be added if the GUI output is expected to feed the Sleep Scoring App as a training or review input.

#### Video metadata

`preprocess_sleep_data` saves:

- `video_name`
- `video_path`
- `video_start_time`

The current video model uses signed seconds:

```matlab
video_time = eeg_time + video_start_time;
```

Negative values mean the video starts after EEG/EMG time zero. Positive values mean the video starts before EEG/EMG time zero.

The app does not currently save video metadata. This is a high-value port because it affects downstream video playback and clip generation.

#### Per-bin Viewpoint video offsets

`preprocess_sleep_data` computes metadata-derived per-bin Viewpoint video offsets when the Viewpoint shape is supported: one video per bin.

The app should adopt this behavior when it gains Viewpoint-bin segmentation.

#### Sirenia EDF

`preprocess_sleep_data` has a separate active path in `preprocess_sirenia.m` for Sirenia EDF plus TDT FP.

The app README mentions EDF, but the active app path still routes EEG/EMG through the Viewpoint loader. The app should either implement a true EDF path or stop advertising EDF support until it is real.

### Behaviors in the app that should be kept

#### GUI channel discovery

The app discovers TDT streams matching `x<digits><A-D>`, infers isosbestic channels by wavelength, and presents the detected channels interactively. This is friendlier than requiring stream names as function arguments.

Keep this workflow when adding Sleep Scoring compatible outputs.

#### Multiple FP signals

`preprocess_sleep_data` is NE-oriented: one 465 signal paired with one 405 control.

The app is more general: it can process multiple user-named FP channels and store `fp_signal_names`. This should remain. NE should become one supported FP export mode, not the only app mode.

#### Per-signal inversion

The app supports optional inversion per selected FP signal. Preserve this, especially for non-NE FP signals where the desired sign convention may vary.

#### TDT event or period epoc export

The app can export a selected TDT epoc as event data aligned to the FP TTL onset. This is not part of the classic `preprocess_sleep_data` output contract, but it is useful and should remain.

## Suggested Merge Strategy

### 1. Extract pure pipeline functions inside the app repo

Before adding many GUI controls, move reusable processing out of `app.mlapp` into functions under `func/`.

Good targets:

- Viewpoint extraction-window selection.
- Viewpoint EEG/EMG extraction.
- Conditional EEG/EMG TTL trimming.
- TDT FP onset detection.
- FP correction and optional downsampling.
- Output structure assembly.
- Segmentation windows.
- Video metadata extraction.

This reduces future App Designer churn and makes behavior easier to compare against `preprocess_sleep_data`.

### 2. Define two output contracts

The app likely needs two explicit output modes:

- Generic biosignal app output:
  - arbitrary FP signal fields
  - `fp_signal_names`
  - `fp_frequency`
  - optional `event`
  - EEG/EMG when provided

- Sleep Scoring compatible output:
  - `eeg`
  - `emg`
  - `ne`
  - `sleep_scores`
  - `start_time`
  - `video_start_time`
  - `num_class`
  - `eeg_frequency`
  - `ne_frequency`
  - `video_name`
  - `video_path`

The Sleep Scoring output can be built from the generic app workflow, but it should make the NE mapping and downsampling rules explicit.

### 3. Port behavior in small vertical slices

Avoid one large rewrite. A safer order is:

1. Port single-bin Viewpoint extraction duration handling.
2. Make Viewpoint TTL trimming conditional on mixed-source synchronization.
3. Add Sleep Scoring compatible output fields for single-output files.
4. Add NE mapping and optional downsampling.
5. Add Viewpoint video metadata for single-bin Viewpoint recordings.
6. Add Viewpoint-bin segmentation.
7. Add TDT 12-hour segmentation.
8. Add sleep-score spreadsheet import.
9. Add TDT EEG/EMG source selection.
10. Decide and implement or retract Sirenia EDF support.

### 4. Keep compatibility checks close to the behavior

For every ported behavior, add a small function-level check using synthetic data when possible. Do not commit raw recordings just to create fixtures.

Useful checks:

- TTL gap selection chooses the first pulse after a gap greater than 6 seconds.
- FP onset trimming never produces an index less than 1.
- Viewpoint-only EEG/EMG is not TTL-trimmed.
- Mixed Viewpoint + TDT FP trims both sources consistently.
- Single-bin Viewpoint extraction uses actual bin duration.
- Segmentation windows cover the expected duration without overlap.
- Sleep Scoring output contains the expected fields.
- Generic FP output still preserves multiple signal names.

## Priority Recommendation

### Highest priority

1. Port the Viewpoint single-bin extraction duration fix.
2. Make Viewpoint TTL trimming conditional.
3. Preserve app signal-name normalization and collision validation while changing output assembly.

These affect correctness of extracted EEG/EMG and synchronized timelines.

### Next priority

4. Add Sleep Scoring compatible output fields.
5. Add NE mapping, downsampling, and `ne_frequency`.
6. Add Viewpoint video metadata and signed `video_start_time`.

These make the app output usable as a direct replacement for common `preprocess_sleep_data` outputs.

### Later priority

7. Add segmentation.
8. Add sleep-score import.
9. Add TDT EEG/EMG source selection.
10. Implement or remove advertised Sirenia EDF support.

These are needed for full replacement, but they are larger workflow additions and should follow the correctness fixes.

## Open Questions

- Should the GUI default to generic app output, Sleep Scoring compatible output, or ask the user to choose?
- When multiple FP signals are selected, how should the user designate which one becomes `ne`?
- Should Sleep Scoring compatible output include both `ne` and the generic FP signal fields, or only the classic Sleep Scoring fields?
- What small synthetic fixtures can cover TTL trimming, FP correction, and segmentation without committing experimental recordings?
- Should `preprocess_sleep_data` eventually call shared functions from this app repo, or should it be retired after the GUI reaches feature parity?
