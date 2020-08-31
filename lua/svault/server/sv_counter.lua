
svault.countermanager = {}
svault.countermanager.counters = {}

local function isPolice(ply)
    return svault.config.policeteams[team.GetName(ply:Team())]
end

function svault.countermanager:GetPlayerOngoingCounterID(ply)
    local steamid = ply:SteamID64()

    for l,w in ipairs(svault.countermanager.counters) do
        for k,v in pairs(w) do
            if k == steamid then return l end
        end
    end

    return false
end

function svault.countermanager:SetupCounter(raidID)
    self.counters[raidID] = {}
end

function svault.countermanager:AlertPoliceman(ply, vault)
    net.Start("sVaultCounterAlert")
     net.WriteEntity(vault)
    net.Send(ply)
end

function svault.countermanager:Join(ply, vault, counterID)
    if not self.counters[counterID] then return end

    net.Start("sVaultCounterOpenProgress")
     net.WriteUInt(counterID, 4)
     net.WriteVector(vault:GetPos())
     net.WriteEntity(vault)
    net.Send(ply)

    self.counters[counterID][ply:SteamID64()] = true
end

function svault.countermanager:Leave(ply, counterID)
    if not self.counters[counterID] then return end

    net.Start("sVaultCounterOpenProgress")
     net.WriteUInt(0, 4)
     net.WriteVector(Vector(0, 0, 0))
    net.Send(ply)

    self.counters[counterID][ply:SteamID64()] = nil
end

net.Receive("sVaultCounterJoin", function(len, ply)
    local vault = net.ReadEntity()
    if not IsValid(vault) then return end
    if vault:GetClass() != "svault" then return end

    if not isPolice(ply) then return end

    local raidID = svault.raidmanager:GetVaultRaidID(vault)
    if not raidID then return end

    svault.countermanager:Join(ply, vault, raidID)
end)

net.Receive("sVaultCounterLeave", function(len, ply)
    svault.countermanager:Leave(ply, net.ReadUInt(4))
end)

hook.Add("PlayerDisconnected", "sVaultCounterManager", function(ply)
    local counterID = svault.countermanager:GetPlayerOngoingCounterID(ply)
    if not counterID then return end

    svault.countermanager:Leave(ply, counterID)
end)

hook.Add("playerCanChangeTeam", "sVaultCounterManager", function(ply, newTeam, force)
    local counterID = svault.countermanager:GetPlayerOngoingCounterID(ply)
    if not counterID then return end

    if force then svault.countermanager:Leave(ply, counterID) return end

    return false, svault.lang.cantchangeteam
end)

util.AddNetworkString("sVaultCounterAlert")
util.AddNetworkString("sVaultCounterJoin")
util.AddNetworkString("sVaultCounterOpenProgress")
util.AddNetworkString("sVaultCounterLeave")
util.AddNetworkString("sVaultCounterFinish")