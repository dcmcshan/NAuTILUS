# Project NAuTILUS — Executive Summary  
**Neural Atlas for Terpene Interaction & Large-Scale Unified Screening**

*2-page brief for NVIDIA Inception, grant panels, and technical partners*

---

## Vision & Objective

**NAuTILUS** is a GPU-accelerated, graph-integrated **polypharmacology inference engine** for terpenes. It is not a docking project: it is a scalable computational framework that predicts and ranks terpene–protein interactions across the human pocketome, then validates top hits with docking and integrates results into Terpedia’s knowledge graph.

**Goal:** Build a polypharmacology atlas for 100 commercially relevant terpenes × 1,000–5,000 druggable human pockets, with ML-based ranking, docking validation, and Terpedia-ready outputs. The Terpedia SPARQL knowledge base (**kb.terpedia.com**) will be ported to **Amazon Neptune**; NAuTILUS results will be captured in the same Neptune graph.

---

## Why Terpenes, Why Now

- **Market:** Cannabis, aromatherapy, and functional ingredients drive demand for evidence-based terpene profiles.  
- **Gap:** Systematic, proteome-scale interaction data for terpenes is scarce; most work is single-target or anecdotal.  
- **Opportunity:** GPU-native ML (e.g., BioNeMo) + structured pocketome design enable cost-effective, large-scale inference and atlas generation.

---

## Scope (Controlled & Scalable)

| Component | Pilot ($100 tier) | Expanded ($500 tier) |
|-----------|-------------------|------------------------|
| **Ligands** | 100 terpenes (curated, standardized) | Same |
| **Targets** | ~1,000–2,000 pockets | ~2,000–5,000 pockets |
| **ML ranking** | All pairs | All pairs |
| **Docking** | Top ~20–30 per terpene | Top ~50–150 per terpene |
| **Output** | Pilot atlas | Publishable atlas + enrichment & clustering |

**Ligand criteria:** Commercial availability, structural diversity (RDKit), literature signal, market relevance. **Target criteria:** Known/AlphaFold pockets; GPCRs, kinases, TRP channels, nuclear receptors, oxidative/inflammatory mediators.

---

## Pipeline (Four Stages)

1. **Molecular Standardization** — RDKit canonicalization, protonation (pH 7.4), 3D conformers; cleaned PDB/AlphaFold pockets.  
2. **ML-Based Affinity Ranking** — Protein–ligand joint embedding (BioNeMo-compatible); batched inference → 200k+ scores; ranked lists per terpene.  
3. **Docking Validation** — DiffDock (primary) / Vina (cross-check) on top 1–5% per terpene; poses, scores, contact residues.  
4. **Graph & Analysis** — Family enrichment, polypharmacology maps, cross-terpene clustering; Terpedia nodes/edges (predicted_binding, docked_binding, family_enrichment) ingested into Neptune (post SPARQL KB port).

---

## Infrastructure & Positioning

- **Stack:** AWS GPU (e.g., g5.xlarge), S3, containerized BioNeMo, RDKit, DiffDock.  
- **Validation:** ChEMBL/BindingDB cross-reference, family plausibility, negative controls, uncertainty scoring.  
- **Deliverables:** Ranked interaction matrix, docking subset, enrichment analysis, polypharmacology maps, Terpedia integration via Neptune (kb.terpedia.com port + NAuTILUS capture), whitepaper figures.

**Positioning:** A GPU-accelerated, graph-integrated polypharmacology engine—powered by AWS (GPU, S3, Neptune), BioNeMo-compatible models, a structured pocketome, and Terpedia knowledge graph on Neptune—designed for both pilot and publishable-scale atlases.

---

## Risk & Mitigation

**Limitations:** Static structures; no membrane/MD/covalent modeling; docking score ≠ affinity. **Mitigation:** Confidence scoring, conservative interpretation, predictions labeled as computational hypotheses.

---

## Next Steps & Extensions

- **Immediate:** Execute pilot ($100) → expanded ($500) per 6-week plan; produce system diagram and compute sizing for partners.  
- **Future:** MD refinement, free energy calculations, covalent/reactive modeling, 180k terpene expansion, experimental validation partnerships.

---

*For full methodology, tier definitions, and data schemas, see the Research Methods Design Document.*
