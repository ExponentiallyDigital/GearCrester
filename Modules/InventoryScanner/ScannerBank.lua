local addonName, GC = ...

local ScannerBank = {}
GC.modules.InventoryScanner = GC.modules.InventoryScanner or {}
GC.modules.InventoryScanner.ScannerBank = ScannerBank

function ScannerBank:Scan()
    local Utils = GC.modules.InventoryScanner.Utils
    GC.DataModel.bank = Utils:ScanContainerRange(5, 11, "bank_bag")

    if GC.db and GC.db.debug then
        print("|cff00ff98[DEBUG] Bank scanned|r")
    end
end

return ScannerBank
