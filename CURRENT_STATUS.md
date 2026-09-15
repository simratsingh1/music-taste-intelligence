# Current Status

> Living doc — key decisions and progress, updated as the project moves. For the full week-by-week roadmap see `plan.md`; for scope/setup see `README.md`.

## Where we are

**Week 1 (Scope, data, environment) — in progress.** Repo and environment scaffolded; dataset download not started yet.

## Key decisions

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
- `scripts/download_data.md` drafted — records the three dataset-scope options considered (GTZAN-only / MTG-Jamendo metadata+small slice / MTG-Jamendo `top50tags` full audio) with size/track/label tradeoffs.
- `plan.md` updated to v4 by the user (pairwise preference elicitation replaces seed-track selection as the personalization signal).

## Open decisions

- **Dataset download scope not yet chosen** — GTZAN-only (fast, ~1.2GB) vs. MTG-Jamendo metadata + small manual slice (~1-2GB) vs. MTG-Jamendo `top50tags` full audio (tens of GB). See `scripts/download_data.md` for the tradeoff table. This blocks the rest of Week 1's "dataset verified" deliverable.
- **Colab/Kaggle GPU setup** — not started. Needed for Week 3 (CLAP embedding generation).
- Nothing committed to git yet this session — `.gitignore`, `README.md`, `plan.md` (user's edit) are modified but unstaged; `pyproject.toml`, `uv.lock`, `src/`, `data/` (with `.gitkeep` placeholders) are new and untracked.

## Next up

1. Decide dataset download scope (open decision above), execute it, verify it loads.
2. Set up Colab/Kaggle for free GPU access.
3. Commit Week 1 scaffolding once the dataset step lands, closing out Week 1's deliverable ("repo initialized, dataset verified, thesis statement written down").
