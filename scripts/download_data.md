# Dataset download — scope decision (pending)

Not yet executed. Options considered for the Week 1 initial pull, from smallest/fastest to largest/most-representative:

| Option | Size | Tracks | Labels | Notes |
|---|---|---|---|---|
| GTZAN only | ~1.2GB | 1,000 | single-label genre (10 classes) | Fastest way to prove the Week 2 pipeline shape; defer MTG-Jamendo scale until the shape is proven. |
| MTG-Jamendo metadata + small manual slice | metadata <100MB, audio ~1-2GB | few hundred (hand-picked across genres) | native multi-label (genre/instrument/mood/theme) | Real dataset structure without committing to full download yet. |
| MTG-Jamendo `top50tags` full audio | tens of GB (32kbps) | ~54,380 | native multi-label, top-50 tags | The actual benchmark-standard subset used in CLAP-vs-baseline research. Best done once the pipeline is validated on a smaller slice. |

MTG-Jamendo download tooling lives in [MTG/mtg-jamendo-dataset](https://github.com/MTG/mtg-jamendo-dataset) (`scripts/download/download.py`), which supports pulling metadata-only or filtered audio subsets by split/tag.

**Decision:** not yet made — see `CURRENT_STATUS.md` open decisions.
