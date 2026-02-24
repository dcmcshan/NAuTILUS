# NAuTILUS System Diagram  
**For NVIDIA Inception & Internal Technical Planning**

---

## Diagram: High-Level Pipeline & Data Flow

```mermaid
flowchart TB
    subgraph inputs["Inputs"]
        L[100 Terpenes<br/>SMILES / 3D]
        P[Pocketome<br/>1k–5k proteins]
    end

    subgraph stage1["Stage 1: Molecular Standardization"]
        RDK[RDKit Pipeline]
        L --> RDK
        P --> RDK
        RDK --> L_std[Standardized Ligands]
        RDK --> P_std[Docking-Ready Pockets]
    end

    subgraph stage2["Stage 2: ML Affinity Ranking"]
        PE[Protein Encoder]
        LE[Ligand Encoder]
        SC[Pairwise Scorer]
        L_std --> LE
        P_std --> PE
        LE --> SC
        PE --> SC
        SC --> RANK[Ranked Pairs<br/>200k+ scores]
    end

    subgraph stage3["Stage 3: Docking Validation"]
        SEL[Top 1–5% Selection]
        DOCK[DiffDock / Vina]
        RANK --> SEL
        SEL --> DOCK
        L_std --> DOCK
        P_std --> DOCK
        DOCK --> POSES[Poses + Scores<br/>Contact Residues]
    end

    subgraph stage4["Stage 4: Graph & Analysis"]
        ENR[Family Enrichment]
        POLY[Polypharmacology Maps]
        CLUST[Cross-Terpene Clustering]
        RANK --> ENR
        POSES --> POLY
        RANK --> CLUST
    end

    subgraph outputs["Outputs → Terpedia (Neptune)"]
        G[(Neptune Graph<br/>kb.terpedia.com port + NAuTILUS)]
        ENR --> G
        POLY --> G
        CLUST --> G
        MAT[Interaction Matrix]
        RANK --> MAT
        POSES --> MAT
    end

    subgraph infra["Infrastructure"]
        AWS[AWS GPU g5.xlarge]
        S3[(S3 Storage)]
        NEP[(Neptune)]
        BNM[BioNeMo Models]
        AWS --> BNM
        BNM --> PE
        BNM --> LE
        G --> NEP
    end
```

---

## Diagram: Component Stack (NVIDIA-Friendly)

```mermaid
flowchart LR
    subgraph data["Data Layer"]
        S3[(S3)]
        NEP[(Neptune)]
        LIB[Ligand Library]
        POCK[Pocketome DB]
    end

    subgraph compute["Compute Layer"]
        GPU[GPU Instances]
        CONT[Containers]
        GPU --> CONT
    end

    subgraph models["Model Layer"]
        BNM[BioNeMo<br/>Protein–Ligand]
        RDK[RDKit]
        DD[DiffDock]
    end

    subgraph app["Application Layer"]
        RANK[Ranking Service]
        DOCK[Docking Service]
        GRAPH[Graph Builder]
    end

    S3 --> GPU
    NEP --> GRAPH
    LIB --> RDK
    POCK --> BNM
    RDK --> RANK
    BNM --> RANK
    RANK --> DOCK
    DD --> DOCK
    DOCK --> GRAPH
    GRAPH --> S3
    GRAPH --> NEP
```

---

## Narrative Description for Slides / One-Pagers

**NAuTILUS pipeline (left to right):**

1. **Inputs:** Curated 100 terpenes (SMILES/3D) and human pocketome (1k–5k pockets from PDB/AlphaFold).
2. **Standardization:** RDKit canonicalization, protonation, 3D conformers; pocket cleaning and definition. Outputs feed both ML and docking.
3. **ML ranking:** Protein and ligand encoders (BioNeMo-compatible) produce embeddings; batched pairwise scoring yields 200k+ interaction scores and per-terpene ranked protein lists.
4. **Docking:** Top 1–5% of ranked pairs per terpene are passed to DiffDock (and optionally Vina); outputs are poses, scores, and contact residues.
5. **Analysis:** Family enrichment, polypharmacology mapping, and cross-terpene clustering run on ranked and docked results.
6. **Outputs:** Ranked matrix, docking subset, and graph (nodes: Terpene, Protein, Family, Pathway; edges: predicted_binding, docked_binding, family_enrichment) written to **Amazon Neptune**. The Terpedia SPARQL KB (kb.terpedia.com) is ported to Neptune; NAuTILUS results are captured there.

**Infrastructure:** AWS GPU instances (e.g., g5.xlarge), S3 for storage, **Neptune** for the Terpedia graph (SPARQL), containerized BioNeMo and RDKit, DiffDock for pose prediction.

---

*Use the Mermaid blocks in Markdown viewers (GitHub, Notion, etc.) or export to PNG/SVG for NVIDIA briefings and internal docs.*
