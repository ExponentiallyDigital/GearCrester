# Contributing Guidelines

## Code Style

- 4-space indentation
- No tabs
- No globals except GC and SavedVariables
- One module per file
- No business logic in UI files

## Architecture Rules

- Core handles events and shared utilities
- Modules must not depend on each other directly
- Data tables live in AdvisorData or CrestData
- UI files must not compute logic

## Commit Message Format

<type>: <short summary>

Types:

- feat
- fix
- refactor
- docs
- chore
