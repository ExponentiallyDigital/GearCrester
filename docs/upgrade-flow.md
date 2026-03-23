# Upgrade Evaluation Flow

1. Read equipped items from InventoryScanner
2. For each item:
    - Determine upgrade track
    - Determine current rank
    - Determine next rank
    - Determine crest type required
    - Determine crest cost
    - Determine if blocked by weekly cap
    - Determine if blocked by seasonal cap
    - Determine if crest type is available
3. Apply slot priority
4. Sort results
5. Return upgrade list
