local addonName, GC = ...

local ScannerBags = {}
GC.modules.InventoryScanner = GC.modules.InventoryScanner or {}
GC.modules.InventoryScanner.ScannerBags = ScannerBags

function ScannerBags:Scan()
    -- Stub for MVP: bags scanning not implemented
end

return ScannerBags
