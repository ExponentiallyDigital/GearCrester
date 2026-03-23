local addonName, GC = ...

function GC:SafeCall(func, ...)
    if type(func) == "function" then
        return pcall(func, ...)
    end
end

function GC:Round(num, places)
    local mult = 10^(places or 0)
    return math.floor(num * mult + 0.5) / mult
end
