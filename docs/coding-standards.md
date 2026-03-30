# Coding Standards

- 4-space indentation
- No tabs
- No globals except GC and SavedVariables
- One module per file
- No business logic in UI files
- No hard-coded magic numbers
- Use descriptive function names
- Prefer local functions where possible
- Avoid deep nesting
- separate data and logic, all data to go into core/constants.lua or core/datamodel.lua
- utility functions used by multiple modules to go into core/utils.lua
