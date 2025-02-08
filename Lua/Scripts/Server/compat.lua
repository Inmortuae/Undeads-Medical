NTCompat = {} -- Global table

local NTIn  = false
local NTCIn = false

-- Check if NT is enabled
for package in ContentPackageManager.EnabledPackages.All do
    if tostring(package.UgcId) == "3190189044" then
        NTIn = true
    end
end

-- Check if NTC is enabled
for package in ContentPackageManager.EnabledPackages.All do
    if tostring(package.UgcId) == "3324062208" then
        NTCIn = true
    end
end

-- Store functions in the global table
function NTCompat.isNTactive()
    return NTIn
end

function NTCompat.isNTCactive()
    return NTCIn
end
