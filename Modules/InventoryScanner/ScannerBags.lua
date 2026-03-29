local addonName, GC = ...

local ScannerBags = {}
GC.modules.InventoryScanner = GC.modules.InventoryScanner or {}
GC.modules.InventoryScanner.ScannerBags = ScannerBags

function ScannerBags:Scan()
    local Utils = GC.modules.InventoryScanner.Utils
    GC.DataModel.bags = Utils:ScanContainerRange(0, 4, "bag")

    if GC.db and GC.db.debug then
        print("|cff00ff98[DEBUG] Bags scanned|r")
    end
end

return ScannerBags
