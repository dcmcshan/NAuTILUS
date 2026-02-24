# Project NAuTILUS  
## Research Methods Design Document

**Neural Atlas for Terpene Interaction & Large-Scale Unified Screening**

---

## 1. Objective

To construct a scalable, GPU-accelerated computational framework that predicts and ranks interactions between a curated panel of 100 commercially available terpenes and the human pocketome, generating a polypharmacology atlas suitable for Terpedia integration.

---

## 2. Scope Definition

### 2.1 Ligand Set

Curated set of 100 terpenes selected using:

- Commercial availability (≥3 suppliers or GRAS/IFRA relevance)
- Structural diversity (RDKit clustering)
- Biological literature signal
- Market relevance (cannabis, aromatherapy, functional products)

All ligands will be:

- Canonicalized (SMILES standardization)
- Deduplicated
- Stereochemistry enumerated where applicable
- Protonation-state standardized (physiological pH)
- Converted to 3D conformers

---

### 2.2 Target Set: Human Pocketome

We do **NOT** use the entire proteome (~20,000 proteins). Instead:

**Pocketome Tier Definitions**

| Tier | Scope |
|------|--------|
| **Tier 1 (Pilot)** | ~1,000 druggable human proteins |
| **Tier 2 (Expanded)** | ~2,000–5,000 curated pockets |

**Target inclusion criteria:**

- Known small-molecule binding pockets (PDB)
- High-confidence AlphaFold structures with pocket prediction
- Protein families of pharmacological interest:
  - GPCRs
  - Kinases
  - TRP channels
  - Nuclear receptors
  - Oxidative enzymes
  - Inflammatory mediators

Each target includes:

- Cleaned 3D structure
- Identified binding pocket coordinates
- Family classification
- UniProt identifier
- Confidence metadata

---

## 3. System Architecture

### 3.1 Computational Stack

**Infrastructure:**

- AWS GPU instances (g5.xlarge or similar)
- S3 for storage
- Containerized BioNeMo models
- RDKit preprocessing pipeline
- Docking engine (DiffDock or classical docking)

---

### 3.2 Pipeline Overview

The NAuTILUS workflow consists of four stages:

1. **Molecular Standardization**
2. **ML-Based Affinity Ranking**
3. **Docking Validation**
4. **Graph Construction & Analysis**

---

## 4. Detailed Methodology

---

### 4.1 Molecular Preparation

**Ligand Preparation**

Steps:

1. Canonicalization (RDKit)
2. Tautomer normalization
3. Protonation adjustment (pH 7.4)
4. 3D conformer generation
5. Energy minimization
6. SDF export

**Output:** Standardized ligand library; embedding-ready format.

---

**Protein Preparation**

Steps:

1. Download PDB or AlphaFold structures
2. Remove water/ligands
3. Add hydrogens
4. Define pocket region:
   - Co-crystallized ligand coordinates **OR**
   - Automated pocket detection (FPocket-like methods)
5. Export cleaned PDB

**Output:** Docking-ready protein structures; embedding-ready sequence + structure representation.

---

### 4.2 Stage 1: ML-Based Affinity Ranking

**Objective**  
Efficiently rank terpene–protein pairs before docking.

**Model Type**  
Protein–ligand joint embedding model:

- Protein encoder (sequence or structure-based)
- Ligand graph encoder
- Learned interaction predictor

Inference mode only (no retraining initially).

**Computation**  
For 100 terpenes × 2,000 pockets:

**= 200,000 interaction scores**

Inference strategy:

- Batch protein embeddings
- Batch ligand embeddings
- Matrix-style pairwise scoring

GPU-accelerated batched inference.

**Output**  
For each terpene: ranked protein list, predicted affinity score, model confidence score, family annotation.

Stored as:

| terpene_id | protein_id | predicted_affinity | confidence | model_version |
|------------|------------|--------------------|------------|---------------|

---

### 4.3 Stage 2: Docking Validation

**Objective**  
Validate geometric plausibility of top-ranked predictions.

**Selection Criteria**  
For each terpene: select top 1–5% of predicted proteins; cap at 20–100 targets per terpene.

**Docking Engine**  
- **Primary:** DiffDock (diffusion-based pose prediction)  
- **Alternative:** AutoDock Vina for cross-checking

**Docking Procedure**

1. Generate ligand conformer
2. Dock within defined pocket
3. Generate N poses (default 5)
4. Record: pose confidence, docking score, binding orientation, interacting residues

**Output**  
For each validated interaction: docking score, pose coordinates, contact residues, docking confidence metric.

Stored as:

| terpene_id | protein_id | pose_rank | docking_score | confidence | contact_residues |
|------------|------------|-----------|---------------|------------|------------------|

---

### 4.4 Stage 3: Statistical & Network Analysis

#### 4.4.1 Family Enrichment

- Overrepresentation of protein families
- Fisher exact test or permutation testing
- Family-level binding enrichment score

#### 4.4.2 Polypharmacology Mapping

For each terpene: count high-confidence targets; cluster proteins by pathway; identify multi-target hubs.

#### 4.4.3 Cross-Terpene Clustering

Cluster terpenes by: shared predicted targets; interaction fingerprint similarity; functional profile similarity.

---

## 5. Data Integration into Terpedia & Neptune

### 5.1 Terpedia Graph Architecture (Target Schema)

All outputs will be ingested into Terpedia’s graph architecture:

**Nodes:** Terpene, Protein, Protein family, Pathway  

**Edges:** predicted_binding, docked_binding, high_confidence_binding, family_enrichment  

Each edge includes: score, method, model_version, timestamp.

### 5.2 SPARQL KB Port to Neptune & NAuTILUS Capture

The existing Terpedia SPARQL knowledge base (**kb.terpedia.com**) will be ported to **Amazon Neptune**, providing a unified, scalable graph backend on AWS. NAuTILUS results will be captured in the same Neptune graph:

- **Port scope:** Migrate existing kb.terpedia.com dataset and SPARQL endpoint semantics to Neptune (RDF/SPARQL engine). Queries and applications that today target kb.terpedia.com will be pointed at the Neptune endpoint after migration.
- **NAuTILUS capture:** Ranked interaction matrix, docking validation subset, enrichment metadata, and polypharmacology annotations will be written into Neptune as graph nodes and edges conforming to the schema above (Terpene, Protein, family, pathway; predicted_binding, docked_binding, high_confidence_binding, family_enrichment), with score, method, model_version, and timestamp on edges.
- **Benefits:** Single AWS-native graph (Neptune) for both legacy Terpedia KB content and NAuTILUS-derived atlas data; SPARQL queryability; alignment with S3/GPU pipeline in the same cloud.

A dedicated technical note (Neptune & SPARQL port) is maintained in the docs for migration and ingestion details.

---

## 6. Validation Strategy

Because docking and ML predictions generate false positives, we include:

1. Cross-reference with known binding data (ChEMBL, BindingDB)
2. Family plausibility checks
3. Literature mining validation
4. Negative control terpenes
5. Model uncertainty scoring

---

## 7. Budget-Constrained Execution Plan

| Tier | Scope | Output |
|------|--------|--------|
| **$100** | 100 terpenes; 1,000–2,000 proteins; ML ranking; dock top ~20–30 per terpene | Pilot atlas |
| **$500** | 100 terpenes; 2,000–5,000 proteins; ML ranking; dock top ~50–150 per terpene; enrichment + clustering | Publishable-scale atlas |

---

## 8. Risk & Limitations

Limitations include: static protein structures; no explicit membrane modeling; no MD refinement; no covalent binding modeling; docking score ≠ true binding affinity.

**Mitigation:** Confidence scoring; conservative interpretation; flag predictions as computational hypotheses.

---

## 9. Deliverables

1. Ranked terpene–protein interaction matrix  
2. Docking validation subset  
3. Family enrichment analysis  
4. Polypharmacology maps  
5. Terpedia graph integration (Neptune: kb.terpedia.com port + NAuTILUS result capture)  
6. Whitepaper-ready figures  

---

## 10. Future Extensions

Beyond $500 tier: molecular dynamics refinement; free energy calculations; covalent docking modeling; reactive oxygen species modeling; full 180k terpene expansion; experimental validation partnerships.

---

## Closing Positioning Statement

**NAuTILUS is not a docking project.**

It is: **A GPU-accelerated, graph-integrated polypharmacology inference engine for terpenes.**

Powered by:

- AWS GPU infrastructure  
- BioNeMo-compatible models  
- Structured biological pocketome design  
- Terpedia knowledge graph integration (Neptune: SPARQL KB port + NAuTILUS capture)  
