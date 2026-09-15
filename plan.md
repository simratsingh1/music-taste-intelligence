# Music Taste Intelligence — project plan (v4)

**Core thesis:** How effective are frozen CLAP embeddings versus classical audio features for music retrieval, and can they support useful cold-start taste profiles from a small set of pairwise user preferences?

This version keeps v3's honest, symmetric retrieval design and replaces direct seed-track selection with pairwise preference elicitation (A/B picks) as the personalization signal — a richer, more naturally-collected input that also opens up a negative-signal extension in Week 9.

**Dataset:** MTG-Jamendo (primary) — chosen over FMA/GTZAN because it has native multi-label genre/instrument/mood/theme tags across 55,000+ full tracks, and it's the current standard benchmark for CLAP-vs-baseline-encoder comparisons in recent autotagging research. GTZAN can be used as a small, fast sanity-check subset early on if you want a quicker iteration loop before running on the full dataset.

**Assumption:** ~6–8 hours/week. Weeks 1–8 are the core, portfolio-ready system. Weeks 9–10 are explicitly optional.

---

## Week 1 — Scope, data, environment

**Goal:** Lock the thesis and get data flowing.

- Write the thesis statement (above) at the top of the README
- Define the MVP: symmetric retrieval comparison (classical vs. CLAP) + pairwise preference ablation + API. Everything else is stretch.
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

## Week 5 — Pairwise preference elicitation → taste profile

**Goal:** Quantify cold-start personalization from pairwise choices instead of a directly-picked seed list.

- **Pair selection:** sample pairs from tracks spanning different genre/mood tag clusters (stratify by top-level tag, not fully random) so each pair carries a meaningful signal
- **Elicitation:** show 5–10 A/B pairs, record only the **chosen** track per round (rejected track is not used yet — see Week 9)
- **Profile construction:** taste vector = mean of chosen tracks' embeddings (positive-only) — structurally the same math as a plain seed-mean, just sourced via pairwise picks instead of a direct list
- **Ablation:** number of pairwise rounds (5 vs 10), measuring Recall@K/NDCG@K at each against a held-out relevant set — this answers "how many A/B rounds does a useful cold-start profile actually need?"
- No fabricated interaction data — the pairwise choices are the only signal, and that's stated plainly in the README

**Deliverable:** Pairwise elicitation logic (pair sampling + choice recording), positive-only taste-profile function, rounds ablation (5 vs 10 → retrieval quality).

---

## Week 6 — Serving layer (MVP cutoff point)

**Goal:** Wrap the winning pipeline in a live API.

- FastAPI service:
  - `/tag` — zero-shot tagging
  - `/pairs` — serves the next A/B pair to show (sampled from diverse clusters)
  - `/profile` — builds a taste profile from a submitted list of chosen tracks (from pairwise rounds)
  - `/recommend` — retrieval from profile
- Explicit Dockerfile
- Deploy to Cloud Run free tier or Hugging Face Spaces
- Confirm live URL works end-to-end

**Deliverable:** Live, public API. **If the project stops here, it's still demoable — protect this checkpoint.**

---

## Week 7 — CI/CD + ML-aware tests

**Goal:** Automate deployment, test things that actually matter for an ML system.

- GitHub Actions: test → build → deploy on merge to `main`
- Tests should check ML invariants: embedding shape/dtype, API response schema, a known set of pairwise choices returns expected genre tags within tolerance
- Structured logging for requests/responses — this covers most of what you'd want from monitoring without needing Grafana as a hard requirement

**Deliverable:** `.github/workflows/deploy.yml`, passing CI, test suite covering real invariants.

---

## Week 8 — Frontend, UMAP visualization, polish

**Goal:** Make it demoable and visually memorable.

- Simple Streamlit/HTML frontend: **answer 5–10 A/B picks → see taste profile → see recommendations**
- UMAP taste-map as a visualization layer only — kept explicitly separate from the retrieval algorithm itself, in both code and README
- Record a 2–3 minute demo video
- Finalize README: thesis statement, architecture diagram, retrieval-vs-classification results table, pairwise-rounds ablation chart, setup instructions, an honest "what we found" section (including anywhere the result was mixed or surprising)

**Deliverable:** Public demo + video + polished README. **Portfolio-ready stopping point.**

---

## Week 9 (stretch) — Deeper evaluation, contrastive profile, basic monitoring

**Goal:** Only if Weeks 1–8 are solid.

- If skipped in Week 4: run the human relevance-judgment eval now
- **Contrastive taste profile:** extend Week 5's pairwise signal to use the rejected track too — profile = mean(chosen) − λ·mean(rejected), tested at 1–2 λ values, compared against the Week 5 positive-only baseline on the same ablation grid
- Basic metrics dashboard (Grafana optional, not mandatory — structured logs plus a simple latency/error metrics endpoint is enough for the core story)
- Simple reranking/diversification on top of raw similarity retrieval, if time allows

**Deliverable:** Optional — deeper eval results, contrastive-vs-positive-only comparison, lightweight monitoring.

---

## Future work (not part of the core plan)

- **Spotify OAuth personalization add-on** — pulling a user's real listening history as an alternative seed-track source, matched to the catalog by artist/title. Moved fully to future work since it doesn't strengthen the core ML story and adds real time cost.

---

## What changed from v3 to v4

| Area | v3 | v4 |
|---|---|---|
| Personalization input | User directly selects N seed tracks from a list | User answers 5–10 pairwise A/B preference rounds; chosen tracks become the effective seed set |
| Profile construction | Mean/weighted mean of picked seed tracks | Mean of chosen tracks from pairwise rounds (positive-only) — same math, different source |
| Ablation variable | Seed count (1/3/5/10/20) → Recall@K/NDCG@K | Number of pairwise rounds (5 vs 10) → Recall@K/NDCG@K |
| Negative signal | Not present | Deferred to Week 9: contrastive profile using rejected tracks (mean(chosen) − λ·mean(rejected)) |
| API | `/profile` takes a seed-track list | `/pairs` serves next A/B comparison; `/profile` takes chosen-track list from pairwise rounds |
| Frontend flow | Pick seed tracks → see profile → see recs | Answer A/B picks → see profile → see recs |
| Week 9 scope | Human eval, monitoring, reranking | Same, plus contrastive profile variant added |

## Weekly checkpoint question

*"If I had to demo this today, what would I show, and does it still support the thesis statement?"*

## Hard cut line

Portfolio-ready after **Week 8**. Week 9 is bonus. Spotify is future work, not on the critical path.