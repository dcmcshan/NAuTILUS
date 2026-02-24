# Neptune & SPARQL Port: kb.terpedia.com → AWS  
**Terpedia Knowledge Base Migration & NAuTILUS Result Capture**

---

## 1. Objective

- **Port** the existing Terpedia SPARQL knowledge base (**kb.terpedia.com**) to **Amazon Neptune** (RDF/SPARQL), providing a single AWS-native graph backend.
- **Capture** all NAuTILUS pipeline results (ranked interactions, docking validation, enrichment, polypharmacology) into the same Neptune graph so the Terpedia KB and the NAuTILUS atlas are queryable together via SPARQL.

---

## 2. Scope

| Item | Description |
|------|-------------|
| **Source** | kb.terpedia.com (current SPARQL endpoint and dataset) |
| **Target** | Amazon Neptune cluster (SPARQL 1.1) in the same AWS account/region as NAuTILUS (S3, GPU) |
| **Data** | (1) Existing Terpedia RDF data; (2) NAuTILUS-derived nodes and edges per Research Methods Design Document §5 |

---

## 3. Neptune Configuration (Recommendations)

- **Engine:** Neptune with SPARQL (RDF) — not Gremlin-only.
- **Instance:** Start with db.r5.large (or equivalent) for pilot; scale for full KB + NAuTILUS volume.
- **Storage:** Grows automatically; ensure VPC/security groups allow access from NAuTILUS pipeline (Lambda, EC2, or ECS) and from any app that today queries kb.terpedia.com.
- **Backup:** Enable automated backups; consider cross-region copy for disaster recovery.

---

## 4. Migration: kb.terpedia.com → Neptune

1. **Export** existing RDF from current kb.terpedia.com (e.g., RDF dump or SPARQL CONSTRUCT/DESCRIBE).
2. **Normalize** to a format Neptune bulk load accepts (e.g., N-Quads, Turtle). Document namespace and named graph usage if applicable.
3. **Bulk load** into Neptune via S3: place RDF files in an S3 bucket, trigger Neptune bulk load API; monitor until complete.
4. **Validate** sample SPARQL queries from production (kb.terpedia.com) against Neptune; compare result sets and fix any namespace or inference differences.
5. **Cutover:** Point applications and documentation from kb.terpedia.com to the Neptune SPARQL endpoint (with optional DNS/alias so “kb.terpedia.com” can resolve to an API gateway or load balancer in front of Neptune if desired).

---

## 5. NAuTILUS Result Capture (Schema Alignment)

NAuTILUS outputs conform to the graph schema in the Research Methods Design Document (§5):

**Nodes:** Terpene, Protein, Protein family, Pathway  

**Edges:** predicted_binding, docked_binding, high_confidence_binding, family_enrichment  

**Edge attributes:** score, method, model_version, timestamp  

**Ingestion options:**

- **Bulk load:** After Stage 4, generate RDF (e.g., Turtle/N-Quads) from the interaction matrix, docking table, and enrichment/clustering outputs; load into Neptune via S3 bulk load (same as migration).
- **Application writes:** From the Graph Builder (or a small ingestion service), issue SPARQL UPDATE (INSERT) or use Neptune’s REST API to add triples as NAuTILUS runs complete (e.g., per-terpene or batched).

Use a consistent vocabulary/namespace for NAuTILUS (e.g., `nautilus:` or `terpedia:nautilus/`) so that queries can distinguish NAuTILUS-derived data from legacy KB content if needed.

---

## 6. Queryability

Once ported and captured:

- **Legacy Terpedia queries** run against the Neptune SPARQL endpoint (same or equivalent results as kb.terpedia.com).
- **NAuTILUS-specific queries** (e.g., “all proteins predicted to bind terpene X”, “all terpenes with docked binding to protein Y”) use the same endpoint with the NAuTILUS schema (Terpene, Protein, predicted_binding, docked_binding, etc.).
- **Unified queries** (e.g., Terpedia literature + NAuTILUS predictions for a given terpene) are possible in one SPARQL query.

---

## 7. Timeline (Alignment with 6-Week Plan)

- **Prep (parallel):** Neptune cluster creation and bulk load of existing kb.terpedia.com data (see Gantt: “Neptune / kb.terpedia.com port”).
- **Week 5:** Graph build produces NAuTILUS graph; ingest into Neptune (bulk or app writes).
- **Week 6:** Verify Neptune endpoint; confirm NAuTILUS capture and legacy KB parity; update docs and client config to Neptune.

---

## 8. Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| SPARQL dialect or inference differences | Run a query test suite before cutover; document Neptune-specific behavior. |
| Bulk load size/time | Chunk RDF dumps; use Neptune bulk load status API; allow buffer in timeline. |
| Cost | Size instance and storage to pilot first; use Neptune cost allocation tags. |

---

*This document is the single reference for the kb.terpedia.com → Neptune port and NAuTILUS capture; the main design doc (§5) and execution plan reference it.*
