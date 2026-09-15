# music-taste-intelligence

**Core thesis:** How effective are frozen CLAP embeddings versus classical audio features for music retrieval, and can they support useful cold-start taste profiles from a small set of pairwise user preferences?

Retrieval (not classification) is the primary comparison, personalization is quantified (not eyeballed), and the project is set up to report an honest result — including one where CLAP loses on some dimension.

## MVP scope

Everything below is in scope for the portfolio-ready system (Weeks 1–8 of `plan.md`). Everything else is stretch.

1. **Symmetric retrieval comparison** — classical audio features (librosa) vs. CLAP embeddings, both evaluated as retrieval systems (cosine similarity → top-K), scored with Precision/Recall/NDCG@K against MTG-Jamendo tag agreement.
2. **Pairwise preference ablation** — cold-start taste profiles built from 5–10 rounds of A/B track picks (positive-only: mean of chosen tracks), measuring how retrieval quality changes with round count. Contrastive use of the rejected track is a Week 9 stretch.
3. **API** — FastAPI service (`/tag`, `/pairs`, `/profile`, `/recommend`) wrapping the winning pipeline, deployed publicly.

Full week-by-week plan: [`plan.md`](plan.md).

## Dataset

[MTG-Jamendo](https://github.com/MTG/mtg-jamendo-dataset) — 55,000+ full tracks with native multi-label genre/instrument/mood/theme tags, the current standard benchmark for CLAP-vs-baseline-encoder comparisons. Starting with a manageable subset (see `scripts/download_data.md`). GTZAN available as an optional tiny sanity-check set for fast iteration.

## Project layout

```
src/music_taste/   # library code (features, retrieval, eval, profile, api)
scripts/           # one-off / data-download scripts
notebooks/         # exploration, Colab/Kaggle notebooks (CLAP embedding generation)
data/raw/          # downloaded datasets (gitignored)
data/processed/    # extracted features, embeddings, splits (gitignored)
tests/             # pytest — ML invariants (embedding shape/dtype, API schema, known-seed tag checks)
```

## Setup

```bash
uv sync                 # base deps (features, eval, tooling)
uv sync --group clap    # + torch, laion-clap (heavy — Week 3, prefer Colab/Kaggle GPU)
uv sync --group api     # + fastapi, uvicorn (Week 6)
```

## Status

Week 1 — repo scaffolded, environment set up. Dataset download scope not yet decided. See [`CURRENT_STATUS.md`](CURRENT_STATUS.md) for decisions made and progress so far, and `plan.md` for the full roadmap (including the "Weekly checkpoint question" honesty check).
