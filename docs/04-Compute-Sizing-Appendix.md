# NAuTILUS Compute Sizing Appendix  
**AWS GPU & Cost Planning (BioNeMo-Compatible Workflows)**

---

## 1. Instance Assumptions

| Instance | vCPUs | GPU | GPU Mem | Use Case |
|----------|--------|-----|---------|----------|
| **g5.xlarge** | 4 | 1 × A10G | 24 GB | ML inference, docking (primary) |
| **g5.2xlarge** | 8 | 1 × A10G | 24 GB | Heavier batching, single large jobs |
| **g5.4xlarge** | 16 | 1 × A10G | 24 GB | Max single-GPU throughput |

All sizing below uses **g5.xlarge** as baseline unless noted. Prices are illustrative (us-east-1 on-demand); use AWS Calculator and Spot for actual budgets.

---

## 2. Stage-Level Sizing

### 2.1 Molecular Standardization (RDKit)

- **Compute:** CPU-bound; 4 vCPUs sufficient.
- **Runtime (estimate):** 100 ligands × ~30 s + 2,000 proteins × ~10 s ≈ 50 min on one g5.xlarge (using CPU only) or a smaller CPU instance.
- **Recommendation:** Run on same GPU instance during idle, or separate c5.xlarge/c6i to save GPU cost. Negligible GPU hours if batched with other work.

### 2.2 ML-Based Affinity Ranking

- **Workload:** Batch inference over 100 terpenes × 2,000 proteins = 200,000 pairs.
- **Assumptions:** Protein embeddings cached once (~2,000 forward passes); ligand embeddings once per terpene (100 passes); pairwise scoring in batches (e.g., 1,000–10,000 pairs per batch).
- **Rough GPU time:**  
  - Embedding 2,000 proteins: ~10–30 min  
  - Embedding 100 ligands: &lt;5 min  
  - 200k pairwise scores: ~30–90 min (batch size dependent)  
  - **Total:** ~1–2.5 GPU-hours per full run (Tier 1). Tier 2 (5k proteins): ~3–6 GPU-hours.
- **Memory:** 24 GB A10G sufficient for typical BioNeMo inference batch sizes; reduce batch size if OOM.

### 2.3 Docking Validation (DiffDock / Vina)

- **Pilot ($100):** 100 terpenes × ~25 targets × 5 poses ≈ 12,500 docking runs.  
  - DiffDock: ~2–5 min per run on GPU → ~400–1,000 GPU-hours if fully parallelized; in practice, batching and queue reduce wall-clock (e.g., 5–10 g5.xlarge for 1–2 days).
- **Expanded ($500):** 100 × ~100 × 5 = 50,000 runs → ~4× GPU time of pilot.
- **Vina (CPU):** Slower per run but cheap; use for cross-check subset (e.g., 10% of DiffDock runs) on c5/c6i.

### 2.4 Graph & Analysis

- **Compute:** Enrichment and clustering are lightweight (Python/NumPy/networkx); run on CPU on same or a small instance. &lt;1 hour typical.

---

## 3. Aggregate GPU-Hour Estimates

| Tier | ML Ranking | Docking (DiffDock) | Total GPU-h (ballpark) |
|------|------------|---------------------|-------------------------|
| **$100 (Pilot)** | ~2–3 h | ~500–1,000 h* | ~500–1,000 h |
| **$500 (Expanded)** | ~5–6 h | ~2,000–4,000 h* | ~2,000–4,000 h |

\*Docking dominates; actual total depends on parallelism and batch efficiency. Reduce via fewer poses per pair or stricter top-% cutoff.

---

## 4. Cost Balls (On-Demand, us-east-1)

- **g5.xlarge:** ~\$1.006/hr (Linux).  
- **Pilot:** 600 GPU-h × \$1 ≈ **\$600** (GPU only; upper bound). With Spot (~70% discount): ~\$180–200.  
- **Expanded:** 3,000 GPU-h × \$1 ≈ **\$3,000** (GPU only). With Spot: ~\$900–1,000.  
- **Storage (S3):** Tens of GB for structures, poses, and matrices → \$1–5/month.  
- **Data transfer:** Minimal if run and store in same region.

**Neptune:** Add Neptune instance cost for graph storage and SPARQL endpoint (e.g., db.r5.large or similar; see AWS Neptune pricing). NAuTILUS ingestion is lightweight (bulk load or application-level writes); no material change to GPU budget.

*Note:* Your $100 / $500 tiers imply heavy use of Spot, selective docking (tight top-% and caps), and/or smaller instance mix; the appendix supports tuning those levers.

---

## 5. BioNeMo-Specific Notes

- **Container:** Use NGC BioNeMo container on GPU instance; ensure driver and CUDA versions match.
- **Batch size:** Tune for 24 GB (e.g., 32–64 proteins per batch for sequence models; adjust for structure-based models).
- **Checkpointing:** Save protein (and optionally ligand) embeddings to S3 to avoid recomputation when iterating on scoring or docking subsets.

---

## 6. Recommended Run Strategy (Pilot)

1. **Week 1:** Standardization on 1× g5.xlarge (CPU phase) or c5.xlarge; upload to S3.  
2. **Week 2:** ML ranking on 1× g5.xlarge; write ranked lists and embeddings to S3.  
3. **Weeks 3–4:** DiffDock on 5–10× g5.xlarge (Spot), queue of ~25 targets × 100 terpenes; checkpoint poses to S3.  
4. **Week 5:** Enrichment and clustering on 1× small CPU instance; build graph; Neptune ingest (NAuTILUS nodes/edges).  
5. **Week 6:** Terpedia/Neptune integration (verify kb.terpedia.com port, NAuTILUS capture), validation, and figure generation.

Scaling to $500 tier: increase pocketome and top-% docking; add instances or run time for docking phase; same pipeline.

---

*For exact pricing and Spot options, use AWS Pricing Calculator and current NGC documentation for BioNeMo.*
