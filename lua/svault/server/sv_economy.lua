
svault.economymanager = {}

local function getAllVaults()
    return ents.FindByClass("svault")
end

function svault.economymanager.AddVaultBalance(vault, amount)
    vault:SetValue(math.Clamp(vault:GetValue() + amount, 0, svault.config.maxvaultvalue))
end

function svault.economymanager.UpdateVault(vault)
     svault.economymanager.AddVaultBalance(vault, svault.config.econonmyupdateamount)
end

function svault.economymanager.UpdateAllVaults()
    for k,v in pairs(getAllVaults()) do
        svault.economymanager.UpdateVault(v)
    end
end

function svault.economymanager.ShareAcrossAllVaults(amount)
    local vaults = getAllVaults()
    amount = math.floor(amount / table.Count(vaults))

    if amount <= 0 then return end

    for k,v in ipairs(vaults) do
        svault.economymanager.AddVaultBalance(v, amount)
    end
end

timer.Create("sVaultEconomyTick", svault.config.econonmyupdaterate, 0, svault.economymanager.UpdateAllVaults)

hook.Add("GlorifiedBanking.FeeTaken", "sVaultAddFeesToVaults", function(_, amount)
    if not svault.config.glorifiedbankingfees then return end

    svault.economymanager.ShareAcrossAllVaults(amount)
end)