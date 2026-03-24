# Qwen Feature Implementation Template

Use this template when requesting new functionality from Qwen.

---

## 1. Feature Description

Explain the feature clearly and concisely.

Example:
Implement bag scanning using C_Container APIs.

---

## 2. Requirements

List explicit requirements.

Example:

- Must scan all bag slots
- Must populate GC.DataModel.bags
- Must not modify existing scanning logic
- Must not break InventoryOverview

---

## 3. Files Qwen Must Modify or Create

List exact file paths.

Example:

- `Modules/InventoryScanner/ScannerBags.lua`
- `docs/testplans/scanning.md`

---

## 4. Guardrails

Qwen must:

- Respect all rules in `docs\qwen\QWEN_GUARDRAILS.md`
- Not modify protected modules
- Not rename functions or variables
- Not refactor unrelated code

---

## 5. Test Plan Requirements

Qwen must:

- Update or create the relevant test plan(s)
- Include exact slash commands
- Include expected output
- Include regression checks

---

## 6. Output Requirements

Qwen must:

- Output only modified or new files
- Provide no commentary or explanation
- Not include analysis or reasoning

---

## 7. Documentation

Qwen MUST update architecture diagrams and dependency maps located at:

- docs/architecture/GEARCRESTER_ARCHITECTURE.md
- docs/architecture/GEARCRESTER_DEPENDENCY_MAP.md

whenever new modules are added or existing modules change responsibilities or dependencies.

### 7.1 Architecture Diagram Updates

Qwen MUST update the following files whenever a feature affects architecture or dependencies:

- docs/architecture/GEARCRESTER_ARCHITECTURE.md
- docs/architecture/GEARCRESTER_DEPENDENCY_MAP.md

Qwen MUST regenerate diagrams using:

- Portrait‑oriented Mermaid (`flowchart TB`)
- Minimal node sets (one node per subsystem)
- No subgraphs unless explicitly required
- No horizontal arrows
- GitHub‑safe and VS Code‑safe syntax

Qwen MUST confirm in its output summary:
“Architecture diagrams updated.”

# End of Template
