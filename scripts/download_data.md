# Dataset download

## Decision (2026-09-15)

Went with **MTG-Jamendo metadata + a small real audio slice** (2 of the 100 `audio-low` tar archives), skipped GTZAN. Reproducible via `scripts/download_mtg_subset.sh`.

Options that were considered:

| Option | Size | Tracks | Labels | Chosen? |
|---|---|---|---|---|
| GTZAN only | ~1.2GB | 1,000 | single-label genre (10 classes) | No — dev-loop scaffolding only, never appears in the final results, not needed once a real slice was cheap to get |
| **MTG-Jamendo metadata + 2 audio-low tar archives** | ~3GB | 1,143 | native multi-label (genre/instrument/mood/theme) | **Yes** |
| MTG-Jamendo full low-quality audio | 156GB | 55,701 | native multi-label | No — too large for Week 1; can extend later by adding archive numbers to `ARCHIVES` in the download script |
| MTG-Jamendo full-quality audio | 508GB | 55,701 | native multi-label | No |

Correction to the original plan: MTG-Jamendo's `download.py` script has no filter/subset flag — it's all-or-nothing per `--dataset` (`raw_30s` = 156GB low-quality / 508GB full, or `autotagging_moodtheme` = 46GB low-quality subset). There's no "top50tags-only" or "genre-only" download path in the official tooling. The audio is packed into 100 tar archives (~1.5GB each, ~550-600 tracks per archive) grouped by an internal path prefix, not by genre — so a small real slice means pulling whole archives directly, which is what the script below does.

## How to reproduce

```bash
bash scripts/download_mtg_subset.sh
```

Idempotent — clones the metadata repo if missing, downloads+verifies+extracts only the archives not already present, drops the tar after successful checksum+extract. To pull more tracks later, add archive numbers (`"02"`, `"03"`, ...) to the `ARCHIVES` array in the script.

## What's on disk

- `data/raw/mtg-jamendo-dataset/` — shallow clone of [MTG/mtg-jamendo-dataset](https://github.com/MTG/mtg-jamendo-dataset): all metadata TSVs (`autotagging.tsv`, `autotagging_top50tags.tsv`, `autotagging_genre.tsv`, etc.), splits, download tooling. Gitignored (reproduced by the script, not committed).
- `data/raw/audio-low/{00,01}/*.low.mp3` — 1,143 tracks (archives 00 + 01 of `raw_30s_audio-low`), ~3GB. SHA256-verified against MTG's official manifests (tar-level + spot-checked track-level).

## Verification

Cross-referenced the 1,143 downloaded track IDs against `autotagging.tsv` (the full 195-tag corpus):

- 1,140 / 1,143 tracks matched (3 tracks in the audio slice have no tag row — expected, a small fraction of `raw_30s` is untagged)
- 194 / 195 corpus tags represented in this slice
- Genuinely multi-label: tags-per-track ranges 1–28, median ~3-4 (e.g. 218 tracks have exactly 3 tags, 153 have 5); top tags are a real mix of genre (`electronic`, `pop`, `rock`, `ambient`) and instrument (`piano`, `synthesizer`, `drums`, `bass`)
- 1,105 / 1,143 tracks also present in `autotagging_top50tags.tsv` specifically

This is enough real, correctly-labeled multi-label data to build and sanity-check the Week 2 classical-feature retrieval pipeline against.
