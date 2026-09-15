# Current Status

> Living doc — key decisions and progress, updated as the project moves. For the full week-by-week roadmap see `plan.md`; for scope/setup see `README.md`.

## Where we are

**Week 1 (Scope, data, environment) — nearly done.** Repo and environment scaffolded, dataset downloaded and verified. Remaining: Colab/Kaggle GPU setup.

## Key decisions

- **2026-09-15 — Dataset download: MTG-Jamendo metadata + a 1,143-track real audio slice (2 of 100 `audio-low` tar archives, ~3GB), GTZAN skipped.** MTG-Jamendo's own `download.py` turned out to be all-or-nothing (no filter flag — full `raw_30s` low-quality is 156GB, full-quality 508GB; the only smaller built-in option is the 46GB moodtheme subset), so `scripts/download_mtg_subset.sh` pulls 2 tar archives directly instead (idempotent, checksum-verified against MTG's manifests). Verified: 194/195 corpus tags represented, genuinely multi-label (median ~3-4 tags/track). GTZAN (1,000 tracks, single-label, ~1.2GB) was evaluated as a faster sanity-check option but skipped once a real, small, verified MTG-Jamendo slice was in hand — it would only have served as throwaway dev scaffolding, never appearing in final results. Full writeup: `scripts/download_data.md`.
- **2026-09-15 — Personalization signal: pairwise A/B preference, not direct seed selection (plan v3 → v4).** Users answer 5–10 A/B track picks instead of directly choosing N seed tracks. Chosen tracks become the effective seed set; the profile is still their mean (positive-only) — same math, richer/more natural input source. Rejected tracks are logged but unused until the Week 9 contrastive-profile stretch (`profile = mean(chosen) − λ·mean(rejected)`). Cascades through: Week 5 (elicitation + rounds ablation replaces seed-count ablation), Week 6 API (new `/pairs` endpoint), Week 7 tests, Week 8 frontend flow, Week 9 stretch scope. See `plan.md`'s "What changed from v3 to v4" table for the full diff.
- **Retrieval, not classification, is the primary comparison** (carried over from v3). Classical-feature retrieval and CLAP retrieval are evaluated with the *same* harness (Precision/Recall/NDCG@K vs. MTG-Jamendo tag agreement, artist/album excluded). Zero-shot CLAP tagging vs. a classical classifier is kept as a separate, secondary result — the two comparisons are reported independently, not collapsed into one "CLAP wins" narrative.
- **Dataset: MTG-Jamendo as primary, GTZAN as optional fast-iteration sanity set.** Chosen over FMA/GTZAN-only because it has native multi-label genre/instrument/mood/theme tags across 55k+ tracks and is the current standard benchmark for CLAP-vs-baseline-encoder comparisons.
- **Python tooling: `uv`, src-layout package (`src/music_taste/`), dependency groups instead of one flat requirements file.** Base group (numpy/pandas/sklearn/librosa/etc.) installs light and fast; `clap` group (torch + laion-clap) and `api` group (fastapi/uvicorn) are opt-in via `uv sync --group <name>` so Week 1–2 work doesn't pay for Week 3/6 weight. CLAP embedding generation is expected to run on Colab/Kaggle GPU rather than locally either way.
- **Large/generated artifacts are gitignored, not committed:** `data/raw/`, `data/processed/`, model checkpoints (`*.pt`, `*.ckpt`), embeddings (`*.npy`, `*.npz`). `uv.lock` **is** committed for reproducibility.

## Done

- Repo scaffolded: `src/music_taste/`, `data/{raw,processed}/`, `notebooks/`, `scripts/`, `tests/`.
- `pyproject.toml` set up with `uv` (Python 3.11, hatchling build, src-layout), base deps installed (`uv sync`); `clap` and `api` dependency groups defined but not yet installed.
- `README.md` written: thesis statement, MVP scope (3 items), project layout, setup instructions — kept in sync with plan v4 (pairwise wording).
- `.gitignore` extended for data/checkpoints/notebook-checkpoints on top of the original Python/`.env` stub.
- `scripts/download_data.md` — records the decision (MTG-Jamendo real slice, GTZAN skipped) and the tradeoffs considered.
- `scripts/download_mtg_subset.sh` — idempotent, checksum-verified download script; reproduces the dataset slice from scratch.
- `plan.md` updated to v4 by the user (pairwise preference elicitation replaces seed-track selection as the personalization signal).
- **Dataset downloaded and verified**: 1,143 MTG-Jamendo tracks (`data/raw/audio-low/`), 194/195 corpus tags represented, genuinely multi-label. Metadata repo cloned to `data/raw/mtg-jamendo-dataset/`. Both gitignored (reproducible via the script above, not committed).
- Week 1 scaffolding committed to `week1_changes` (`38d457a`).

## Open decisions

- **Colab/Kaggle GPU setup** — not started. Needed for Week 3 (CLAP embedding generation).

## Next up

1. Set up Colab/Kaggle for free GPU access — last remaining Week 1 item.
2. Commit the dataset-download step (script + doc updates; `data/` itself stays gitignored).
3. Start Week 2 (classical features + retrieval baseline) against the 1,143-track slice.
