local addonName, GC = ...

local Module = {}
GC.modules.<ModuleName> = Module

function Module:Init()
    -- initialization logic
end

function Module:DoSomething()
    -- core logic
end

return Module
