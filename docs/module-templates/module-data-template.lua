local addonName, GC = ...

-- Data modules contain static tables, lookup maps, and configuration
-- They must not contain business logic or UI code.

local Data = {}
GC.modules.<ModuleName> = Data

-- Example: static lookup table
Data.TableName = {
    -- ["key"] = value,
}

-- Example: function to expose data safely
function Data:Get(key)
    return self.TableName[key]
end

return Data
