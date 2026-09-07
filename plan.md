# Music Taste Intelligence — project plan (v3)

**Core thesis:** How effective are frozen CLAP embeddings versus classical audio features for music retrieval, and can they support useful cold-start taste profiles from a small set of user-selected seed tracks?

This version tightens the experimental design: retrieval (not classification) is the primary comparison, personalization is quantified rather than eyeballed, and the project is set up to report an honest result — including one where CLAP loses on some dimension.

**Dataset:** MTG-Jamendo (primary) — chosen over FMA/GTZAN because it has native multi-label genre/instrument/mood/theme tags across 55,000+ full tracks, and it's the current standard benchmark for CLAP-vs-baseline-encoder comparisons in recent autotagging research. GTZAN can be used as a small, fast sanity-check subset early on if you want a quicker iteration loop before running on the full dataset.

**Assumption:** ~6–8 hours/week. Weeks 1–8 are the core, portfolio-ready system. Weeks 9–10 are explicitly optional.

---

## Week 1 — Scope, data, environment

**Goal:** Lock the thesis and get data flowing.

- Write the thesis statement (above) at the top of the README
- Define the MVP: symmetric retrieval comparison (classical vs. CLAP) + seed-count ablation + API. Everything else is stretch.
- Set up repo structure, README skeleton
- Download MTG-Jamendo (start with a manageable subset, e.g. the `top50` tag split, or a genre-only slice if the full 55k tracks is too much to iterate on quickly)
- Optionally grab GTZAN as a tiny fast-iteration sanity-check set
- Set up Colab/Kaggle for free GPU access

**Deliverable:** Repo initialized, dataset verified, thesis statement written down.

---

## Week 2 — Classical features + retrieval baseline

**Goal:** Build the "boring" system first — full retrieval pipeline, not just classification.

- Extract classical features with `librosa` (MFCCs, spectral centroid, tempo, chroma)
- Build retrieval: classical features → cosine similarity → top-K neighbors
- Treat genre/mood as multi-label throughout, using MTG-Jamendo's native tag categories
- This retrieval pipeline — not a supervised classifier — is your baseline for the primary comparison

**Deliverable:** Classical-feature retrieval pipeline, ready to be evaluated once the eval harness exists (Week 3).

---

## Week 3 — CLAP embeddings + symmetric retrieval

**Goal:** Build the CLAP side of the same pipeline, so the comparison is fair.

- Generate CLAP embeddings for the full catalog
- Build retrieval: CLAP embeddings → cosine similarity → top-K neighbors (same structure as Week 2, different representation)
- This symmetric setup — both sides doing retrieval, not one doing classification and the other doing retrieval — is what makes the comparison valid

**Deliverable:** CLAP-based retrieval pipeline, structurally identical to the classical one.

---

## Week 4 — Evaluation harness (retrieval-primary)

**Goal:** Answer the real question: does CLAP produce better musical neighborhoods?

- Build the eval harness: Precision@K, Recall@K, NDCG@K, using genre/tag agreement as the automatic ground truth (with artist/album exclusion so retrieval isn't just finding the same artist)
- Run retrieval eval for both classical and CLAP representations — this is the primary experiment
- **Stretch, time-permitting:** manually label a small query set (15–20 queries, ~10 results each) with 0/1/2 relevance judgments, to catch cases where genre agreement misses real semantic similarity. Keep this capped — it's enrichment, not a blocker.
- As a secondary, smaller experiment: also test zero-shot CLAP tagging vs. a simple supervised classical classifier on classification metrics. Report this separately from the retrieval result — don't collapse the two comparisons together.
- Write the results section: which representation wins on retrieval, which wins on classification, and don't force them to agree. If classical wins classification and CLAP wins retrieval, that's a genuinely interesting finding — write it up as one.

**Deliverable:** `eval.py`, retrieval quality numbers for both representations (primary result), classification numbers as a secondary result, README results section drafted honestly.

---

## Week 5 — Seed-track taste profile + seed-count ablation

**Goal:** Quantify cold-start personalization instead of eyeballing it.

- Build the taste-profile function: aggregate N user-selected seed tracks into one taste vector (mean or weighted mean)
- Run the seed-count ablation: test profiles built from 1, 3, 5, 10, and 20 seed tracks, measuring Recall@K/NDCG@K at each size against a held-out relevant set
- This answers a real question: how much explicit input does a useful cold-start profile actually need?
- No fabricated interaction data — seed tracks are the only signal, and that's stated plainly in the README

**Deliverable:** Seed-count ablation results (a small table or chart: N seeds → retrieval quality), taste-profile function.

---

## Week 6 — Serving layer (MVP cutoff point)

**Goal:** Wrap the winning pipeline in a live API.

- FastAPI service: `/tag` (zero-shot tagging), `/profile` (build taste profile from seed tracks), `/recommend` (retrieval from profile)
- Explicit Dockerfile
- Deploy to Cloud Run free tier or Hugging Face Spaces
- Confirm live URL works end-to-end

**Deliverable:** Live, public API. **If the project stops here, it's still demoable — protect this checkpoint.**

---

## Week 7 — CI/CD + ML-aware tests

**Goal:** Automate deployment, test things that actually matter for an ML system.

- GitHub Actions: test → build → deploy on merge to `main`
- Tests should check ML invariants: embedding shape/dtype, API response schema, a known seed-track set returns expected genre tags within tolerance
- Structured logging for requests/responses — this covers most of what you'd want from monitoring without needing Grafana as a hard requirement

**Deliverable:** `.github/workflows/deploy.yml`, passing CI, test suite covering real invariants.

---

## Week 8 — Frontend, UMAP visualization, polish

**Goal:** Make it demoable and visually memorable.

- Simple Streamlit/HTML frontend: pick seed tracks → see taste profile → see recommendations
- UMAP taste-map as a visualization layer only — kept explicitly separate from the retrieval algorithm itself, in both code and README
- Record a 2–3 minute demo video
- Finalize README: thesis statement, architecture diagram, retrieval-vs-classification results table, seed-count ablation chart, setup instructions, an honest "what we found" section (including anywhere the result was mixed or surprising)

**Deliverable:** Public demo + video + polished README. **Portfolio-ready stopping point.**

---

## Week 9 (stretch) — Deeper evaluation, basic monitoring

**Goal:** Only if Weeks 1–8 are solid.

- If skipped in Week 4: run the human relevance-judgment eval now
- Basic metrics dashboard (Grafana optional, not mandatory — structured logs plus a simple latency/error metrics endpoint is enough for the core story)
- Simple reranking/diversification on top of raw similarity retrieval, if time allows

**Deliverable:** Optional — deeper eval results, lightweight monitoring.

---

## Future work (not part of the core plan)

- **Spotify OAuth personalization add-on** — pulling a user's real listening history as an alternative seed-track source, matched to the catalog by artist/title. Moved fully to future work since it doesn't strengthen the core ML story and adds real time cost.

---

## What changed from v2 to v3

| Area | v2 | v3 |
|---|---|---|
| Thesis | Framed around cold-start personalization broadly | Explicitly names the two experiments: representation quality + cold-start profile size |
| Primary comparison | Classical (supervised classifier) vs. CLAP (zero-shot) | Symmetric: both representations evaluated on retrieval; classification kept as secondary |
| Personalization eval | Manual sanity-check on a few seed sets | Quantified seed-count ablation (1/3/5/10/20 seeds → Recall@K/NDCG@K) |
| Retrieval ground truth | Genre/tag agreement only | Genre/tag agreement (primary) + optional small human relevance-judgment set |
| Result framing | Implicitly expects CLAP to win | Explicitly designed to report a mixed result if that's what's found |
| Dataset | FMA or GTZAN | MTG-Jamendo (confirmed as current standard for this exact comparison) |
| Spotify | Week 10 stretch | Moved to Future Work, not part of the numbered plan |
| Monitoring | Grafana in Week 9 | Structured logging is sufficient; Grafana optional, not mandatory |

## Weekly checkpoint question

*"If I had to demo this today, what would I show, and does it still support the thesis statement?"*

## Hard cut line

Portfolio-ready after **Week 8**. Week 9 is bonus. Spotify is future work, not on the critical path.