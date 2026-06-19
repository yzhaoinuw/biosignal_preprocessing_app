# Work Log Archive

This folder contains older coordination history rotated out of [`../work_log.md`](../work_log.md). It contains documentation only; do not place experimental data or generated MATLAB outputs here.

## Rotation Policy

The live work log holds at most five unique calendar dates. When adding a sixth date:

1. Move the oldest five dates together into a new archive file.
2. Leave the newest date in `work_log.md`.
3. Keep entries newest-first within each file.

Each archive file should contain exactly five unique calendar dates.

## File Names

Use:

```text
work_log_<earliest>_to_<latest>.md
```

Example:

```text
work_log_2026-01-04_to_2026-02-12.md
```

## Search History

From the repository root:

```powershell
rg -n '^## [0-9]{4}-[0-9]{2}-[0-9]{2}' work_log.md work_log_archive
```
