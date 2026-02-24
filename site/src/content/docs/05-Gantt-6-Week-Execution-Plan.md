# NAuTILUS — 6-Week Execution Plan  
**Gantt Timeline (Pilot → Deliverables)**

---

## Mermaid Gantt (Copy-Paste Ready)

```mermaid
gantt
    title NAuTILUS 6-Week Execution Plan
    dateFormat  YYYY-MM-DD
    section Prep
    Terpene & pocketome curation     :prep1, 2025-03-01, 5d
    Environment & S3 setup           :prep2, 2025-03-01, 3d
    Neptune / kb.terpedia.com port   :prep3, 2025-03-02, 7d
    section Stage 1
    Ligand standardization (RDKit)  :s1a, after prep1, 4d
    Protein/pocket preparation      :s1b, after prep1, 5d
    section Stage 2
    Protein embedding batch         :s2a, after s1b, 3d
    Ligand embedding + pairwise     :s2b, after s1a s2a, 4d
    Ranked lists → S3               :s2c, after s2b, 1d
    section Stage 3
    Top-% selection + job queue     :s3a, after s2c, 2d
    DiffDock (pilot targets)        :s3b, after s3a, 12d
    Pose/score aggregation          :s3c, after s3b, 2d
    section Stage 4
    Family enrichment               :s4a, after s3c, 2d
    Polypharmacology & clustering   :s4b, after s4a, 2d
    section Integration
    Terpedia graph build            :int1, after s4b, 3d
    NAuTILUS capture → Neptune      :int1b, after int1, 1d
    Validation & QC                :int2, after int1b, 2d
    Whitepaper figures              :int3, after int2, 3d
```

---

## Week-by-Week Summary

| Week | Focus | Key Outputs |
|------|--------|-------------|
| **1** | Curation, env, Stage 1 | Terpene list (100); pocketome (1k–2k); S3 layout; standardized ligands & pockets |
| **2** | Stage 2 (ML ranking) | Protein/ligand embeddings; 200k pairwise scores; ranked lists per terpene on S3 |
| **3** | Stage 3 start | Top-% selection; DiffDock job queue; start docking runs |
| **4** | Stage 3 continue | Bulk DiffDock completion; pose/score tables; contact residues |
| **5** | Stage 4 + integration | Enrichment; polypharmacology maps; cross-terpene clustering; Terpedia graph build; NAuTILUS capture to Neptune |
| **6** | Validation & deliver | Neptune/kb.terpedia.com verification; QC vs ChEMBL/BindingDB; negative controls; whitepaper figures; final deliverable package |

---

## Dependencies (Critical Path)

1. **Prep** → Stage 1 (standardization) must finish before embeddings.  
2. **Stage 1** → Stage 2 (both ligand and protein prep done before full pairwise ranking).  
3. **Stage 2** → Stage 3 (ranked lists required for top-% and docking queue).  
4. **Stage 3** → Stage 4 (docked set required for enrichment and polypharmacology).  
5. **Stage 4** → Integration (graph + figures depend on all analysis outputs).

Docking (Stage 3) is the longest block; parallelize across multiple GPU instances to keep to ~2 weeks.

---

## Milestones

| Milestone | Target End |
|-----------|------------|
| M1: Standardized library + pocketome in S3 | End of Week 1 |
| M2: Full ML ranking complete; ranked lists in S3 | End of Week 2 |
| M3: Docking complete for pilot set | End of Week 4 |
| M4: Graph + enrichment + clustering complete; NAuTILUS data in Neptune | End of Week 5 |
| M5: Neptune/kb.terpedia.com verified; validation done; figures and deliverable package | End of Week 6 |

---

## Scaling to $500 Tier

- Extend **Stage 1** by ~1 week (larger pocketome).  
- **Stage 2:** +1–2 days (5k proteins).  
- **Stage 3:** +2–3 weeks (more targets per terpene) or more parallel GPUs.  
- **Stage 4 / Integration:** +3–5 days (larger enrichment and clustering).  

Total expanded timeline: **~10–12 weeks** if docking is not further parallelized.

---

*Adjust start date in the Mermaid `dateFormat` and task dates as needed for your kickoff.*
