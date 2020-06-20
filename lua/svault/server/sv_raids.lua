
svault.raidmanager = {}
svault.raidmanager.raids = {}

local function getPolice(players)
    local police = {}
    for k,v in ipairs(players or player.GetHumans()) do
        if svault.config.policeteams[team.GetName(v:Team())] then
            police[#police + 1] = v
        end
    end
    return police
end

local function concatenateRobbers(participants)
    local robbers = ""
    for k,v in ipairs(participants) do
        robbers = robbers .. v:Name() .. "\n"
    end
    return string.Left(robbers, #robbers - 1)
end

function svault.raidmanager:GetPlayerOngoingRaid(ply)
    for k,v in ipairs(svault.raidmanager.raids) do
        for l,w in ipairs(v.participants) do
            if w == ply then return v end
        end
    end
    return false
end

function svault.raidmanager:GetVaultRaidID(vault)
    for k,v in ipairs(svault.raidmanager.raids) do
        if v.vault == vault then return k end
    end

    return false
end

function svault.raidmanager:StartRaid(ply, vault)
    if vault:GetState() != VAULT_IDLE then return svault.lang.cantstartcooldown end

    local teamName = team.GetName(ply:Team())
    if svault.config.canraidteams and !svault.config.canraidteams[teamName] then return svault.lang.wrongteam end

    if svault.config.policeteams[teamName] then return svault.lang.wrongteam end

    if #self.raids > svault.config.maxraidsongoing then return svault.lang.toomanyraids end

    local players = player.GetHumans()
    if #players < svault.config.minplayers then return svault.lang.notenoughplayers end

    local police = getPolice(players)
    if #police < svault.config.minpolice then return svault.lang.notenoughpolice end

    if self:GetPlayerOngoingRaid(ply) then return svault.lang.alreadytakingpart end

    local raidID = self:GetVaultRaidID(vault)
    if raidID then return svault.lang.alreadybeingraided end

    local newRaid = {}
    newRaid.stage = RAID_WARMUP
    newRaid.vault = vault
    newRaid.participants = {ply}
    newRaid.memberCount = 0
    newRaid.leftparticipants = {}

    self.raids[#self.raids + 1] = newRaid

    vault:SetState(VAULT_WARMUP)
    vault:SetTimerLength(svault.config.warmuptime)
    vault:SetTimerEnd(CurTime() + svault.config.warmuptime)
    vault:SetRobberNames(concatenateRobbers(newRaid.participants))

    timer.Create("sVaultTimer" .. vault:EntIndex(), svault.config.warmuptime, 1, function()
        self:StartRaidTimer(vault)
    end)

    return "successful"
end

function svault.raidmanager:JoinRaid(ply, vault)
    local raidID = self:GetVaultRaidID(vault)
    if !raidID then return false end

    local raid = self.raids[raidID]

    if raid.stage != RAID_WARMUP then
        if raid.stage == RAID_INPROGRESS then
            if 1-((vault:GetTimerEnd() - CurTime()) / vault:GetTimerLength()) < svault.config.maxprogresstojoin / 100 then
                return svault.lang.toolate
            end
        else
            return svault.lang.toolate
        end
    end

    for k,v in ipairs(self.raids[raidID].leftparticipants) do
        if v == ply then
            return svault.lang.cantrejoin
        end
    end

    if #raid.participants >= svault.config.maxparticipants then return svault.lang.toomanyraiders end

    self.raids[raidID].participants[#raid.participants + 1] = ply

    return "successful"
end

function svault.raidmanager:LeaveRaid(ply, vault)
    local raidID = self:GetVaultRaidID(vault)
    if !raidID then return false end

    table.RemoveByValue(self.raids[raidID].participants, ply)

    if #self.raids[raidID].participants < 1 then
        if self.raids[raidID].stage == RAID_INPROGRESS then
            vault:StartCooldown()

            local police = getPolice()
            local policeReward = self.raids[raidID].memberCount * svault.config.rewardmembermultiplier
            for k,v in ipairs(police) do
                v:addMoney(math.Round(policeReward / police))
            end
        else
            vault:SetState(VAULT_IDLE)
            vault:SetRobberNames("")
        end

        self.raids[raidID] = nil
        timer.Remove("sVaultTimer" .. vault:EntIndex())
        return svault.lang.cancelledraid
    end

    vault:SetRobberNames(concatenateRobbers(self.raids[raidID].participants))

    return "successful"
end

function svault.raidmanager:StartRaidTimer(vault)
    local raidID = self:GetVaultRaidID(vault)
    if !raidID then return false end
    local raid = self.raids[raidID]

    vault:SetState(VAULT_RAIDING)
    self.raids[raidID].stage = RAID_INPROGRESS
    self.raids[raidID].memberCount = #raid.participants

    for k,v in ipairs(raid.participants) do
        v:sVaultNotify(svault.lang.warmupover)
    end

    local timerLength = svault.config.raidbasetime + ((#raid.participants - 1) * svault.config.raidmembertimemultiplier)

    vault:SetTimerLength(timerLength)
    vault:SetTimerEnd(CurTime() + timerLength)

    timer.Create("sVaultTimer" .. vault:EntIndex(), timerLength, 1, function()
        self:EndRaidTimer(vault)
    end)

    timer.Create("sVaultSecurityTimer" .. vault:EntIndex(), vault:GetSecurityEnabled() and svault.config.securitytimer or svault.config.securitytimerdisabled, 1, function()
        self:TriggerSecurity(vault)
    end)
end

function svault.raidmanager:TriggerSecurity(vault)
    vault:SetSecurityEnabled(true)
    vault:SetSecurityTimerEnd(CurTime() + svault.config.securitytimer)

    for k,v in ipairs(getPolice()) do
        v:sVaultNotify(svault.lang.vaultbreached)
    end
end

function svault.raidmanager:EndRaidTimer(vault)
    vault:OpenVault()
end

hook.Add("PlayerDisconnected", "sVaultRaidManager", function(ply)
    local raid = svault.raidmanager:GetPlayerOngoingRaid(ply)
    if !raid then return end

    svault.raidmanager:LeaveRaid(ply, raid.vault)
end)

hook.Add("playerCanChangeTeam", "sVaultRaidManager", function(ply, newTeam, force)
    local raid = svault.raidmanager:GetPlayerOngoingRaid(ply)
    if !raid then return end

    if force then svault.raidmanager:LeaveRaid(ply, raid.vault) return end

    return false, svault.lang.cantchangeteam
end)

hook.Add("canStartVote", "sVaultRaidManager", function(vote)
    local ply = vote.target
    local raid = svault.raidmanager:GetPlayerOngoingRaid(ply)
    if raid then return false, nil, svault.lang.cantstartvote end
end)

hook.Add("canGoAFK", "sVaultRaidManager", function(ply, state)
    if !state then return end

    local raid = svault.raidmanager:GetPlayerOngoingRaid(ply)
    if raid then return false end
end)

hook.Add("canSleep", "sVaultRaidManager", function(ply, force)
    local raid = svault.raidmanager:GetPlayerOngoingRaid(ply)
    if !raid then return end

    if force then svault.raidmanager:LeaveRaid(ply, raid.vault) return end

    return false, svault.lang.cantsleep
end)

hook.Add("PlayerDeath", "sVaultRaidManager", function(victim, inflictor, attacker)
    local raid = svault.raidmanager:GetPlayerOngoingRaid(victim)
    if !raid then return end

    svault.raidmanager:LeaveRaid(victim, raid.vault)

    if !svault.config.rejoindeath then
        svault.raidmanager.raids[raidID].leftparticipants[#raid.leftparticipants + 1] = victim
    end

    if raid.stage != RAID_INPROGRESS then return end
    if svault.config.raiderkilledpenalty then
        raid.vault:SetTimerLength(raid.vault:GetTimerLength() + svault.config.raiderkilledpenalty)
        raid.vault:SetTimerEnd(raid.vault:GetTimerEnd() + svault.config.raiderkilledpenalty)

        for k,v in ipairs(raid.participants) do
            v:sVaultNotify(svault.lang.lang.raiderkilledpenalty)
        end
    end

    if svault.raidmanager:GetPlayerOngoingRaid(attacker) and svault.config.friendlykilledpenalty then
        raid.vault:SetTimerLength(raid.vault:GetTimerLength() + svault.config.friendlykilledpenalty)
        raid.vault:SetTimerEnd(raid.vault:GetTimerEnd() + svault.config.friendlykilledpenalty)

        for k,v in ipairs(raid.participants) do
            v:sVaultNotify(svault.lang.friendlyfirepenalty)
        end
    end

    if svault.config.policeteams[team.GetName(attacker:Team())] and svault.config.policekillreward then
        attacker:addMoney(svault.config.policekillreward)
        attacker:sVaultNotify(string.Replace(svault.lang.killedraiderreward, "%m", DarkRP.formatMoney(svault.config.policekillreward)))
    end
end)

hook.Add("PostCleanupMap", "sVaultRaidManager", function()
    table.Empty(svault.raidmanager.raids)
end)