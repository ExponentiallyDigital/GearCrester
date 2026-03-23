local addonName, GC = ...

local ScannerBank = {}
GC.modules.InventoryScanner = GC.modules.InventoryScanner or {}
GC.modules.InventoryScanner.ScannerBank = ScannerBank

function ScannerBank:Scan()
    -- Stub for MVP: bank scanning not implemented
end

return ScannerBank
