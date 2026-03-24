# GearCrester Architecture Documentation

This folder contains all high‑level architectural documentation for GearCrester.
These documents are **living artifacts** and MUST be kept up to date by Qwen.

---

## Contents

### **1. GEARCRESTER_ARCHITECTURE.md**

A clean, portrait‑oriented Mermaid diagram showing the major subsystems of GearCrester:

- Core Layer
- Inventory Scanner
- Crest Tracker
- Upgrade Advisor
- UI Layer
- Export System
- Diagnostics
- Profiles

This diagram focuses on **structure**, not file‑level detail.
A file breakdown is included below the diagram for clarity.

### **2. GEARCRESTER_DEPENDENCY_MAP.md**

A high‑level dependency graph showing how subsystems depend on each other.

This diagram focuses on **data and control flow**, not internal logic.

---

## Maintenance Rules (Qwen MUST follow these)

Qwen MUST update both diagrams whenever:

- A new module or subsystem is added
- A module is removed
- A module changes responsibilities
- Dependencies change
- A subsystem is renamed
- A subsystem is split or merged

Qwen MUST ensure:

- Diagrams remain **portrait‑oriented**
- Mermaid syntax is **GitHub‑safe** and **VS Code‑safe**
- No horizontal sprawl
- No looping arrows
- No oversized subgraphs
- No styling blocks
- No indentation before ```mermaid fences

---

## Purpose of These Diagrams

These diagrams serve to:

- Provide a clear architectural overview
- Help new contributors understand the system
- Prevent architectural drift
- Ensure Qwen maintains a consistent mental model
- Support long‑term maintainability

These diagrams are **not** intended to show:

- Internal function‑level logic
- Temporary experimental modules
- Debug‑only code
- Implementation details

Those belong in developer notes or module‑level documentation.

---

## Human Editing

These files are **AI‑maintained**.

Humans SHOULD NOT manually edit the diagrams.
Humans MAY edit explanatory text if needed.

Qwen is responsible for keeping diagrams accurate and up to date.

---

End of document.
