
ogl_vault.raidmanager = {}
ogl_vault.raidmanager.raids = {}

local function getPolice(players)
    local police = {}
    for k,v in ipairs(players or player.GetHumans()) do
        if ogl_vault.config.policeteams[team.GetName(v:Team())] then
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

function ogl_vault.raidmanager:GetPlayerOngoingRaid(ply)
    for k,v in ipairs(ogl_vault.raidmanager.raids) do
        for l,w in ipairs(v.participants) do
            if w == ply then return v end
        end
    end
    return false
end

function ogl_vault.raidmanager:GetVaultRaidID(vault)
    for k,v in ipairs(ogl_vault.raidmanager.raids) do
        if v.vault == vault then return k end
    end

    return false
end

function ogl_vault.raidmanager:StartRaid(ply, vault)
    if vault:GetState() != VAULT_IDLE then return ogl_vault.lang.cantstartcooldown end

    local teamName = team.GetName(ply:Team())
    if ogl_vault.config.canraidteams and !ogl_vault.config.canraidteams[teamName] then return ogl_vault.lang.wrongteam end

    if ogl_vault.config.policeteams[teamName] then return ogl_vault.lang.wrongteam end

    if #self.raids > ogl_vault.config.maxraidsongoing then return ogl_vault.lang.toomanyraids end

    local players = player.GetHumans()
    if #players < ogl_vault.config.minplayers then return ogl_vault.lang.notenoughplayers end

    local police = getPolice(players)
    if #police < ogl_vault.config.minpolice then return ogl_vault.lang.notenoughpolice end

    if self:GetPlayerOngoingRaid(ply) then return ogl_vault.lang.alreadytakingpart end

    local raidID = self:GetVaultRaidID(vault)
    if raidID then return ogl_vault.lang.alreadybeingraided end

    local newRaid = {}
    newRaid.stage = RAID_WARMUP
    newRaid.vault = vault
    newRaid.participants = {ply}
    newRaid.memberCount = 0
    newRaid.leftparticipants = {}

    self.raids[#self.raids + 1] = newRaid

    vault:SetState(VAULT_WARMUP)
    vault:SetTimerLength(ogl_vault.config.warmuptime)
    vault:SetTimerEnd(CurTime() + ogl_vault.config.warmuptime)
    vault:SetRobberNames(concatenateRobbers(newRaid.participants))

    timer.Create("OGLVaultTimer" .. vault:EntIndex(), ogl_vault.config.warmuptime, 1, function()
        self:StartRaidTimer(vault)
    end)

    return "successful"
end

function ogl_vault.raidmanager:JoinRaid(ply, vault)
    local raidID = self:GetVaultRaidID(vault)
    if !raidID then return false end

    local raid = self.raids[raidID]

    if raid.stage != RAID_WARMUP then
        if raid.stage == RAID_INPROGRESS then
            if 1-((vault:GetTimerEnd() - CurTime()) / vault:GetTimerLength()) < ogl_vault.config.maxprogresstojoin / 100 then
                return ogl_vault.lang.toolate
            end
        else
            return ogl_vault.lang.toolate
        end
    end

    for k,v in ipairs(self.raids[raidID].leftparticipants) do
        if v == ply then
            return ogl_vault.lang.cantrejoin
        end
    end

    if #raid.participants >= ogl_vault.config.maxparticipants then return ogl_vault.lang.toomanyraiders end

    self.raids[raidID].participants[#raid.participants + 1] = ply

    return "successful"
end

function ogl_vault.raidmanager:LeaveRaid(ply, vault)
    local raidID = self:GetVaultRaidID(vault)
    if !raidID then return false end

    table.RemoveByValue(self.raids[raidID].participants, ply)

    if #self.raids[raidID].participants < 1 then
        if self.raids[raidID].stage == RAID_INPROGRESS then
            vault:StartCooldown()

            local police = getPolice()
            local policeReward = self.raids[raidID].memberCount * ogl_vault.config.rewardmembermultiplier
            for k,v in ipairs(police) do
                v:addMoney(math.Round(policeReward / police))
            end
        else
            vault:SetState(VAULT_IDLE)
            vault:SetRobberNames("")
        end

        self.raids[raidID] = nil
        timer.Remove("OGLVaultTimer" .. vault:EntIndex())
        return ogl_vault.lang.cancelledraid
    end

    vault:SetRobberNames(concatenateRobbers(self.raids[raidID].participants))

    return "successful"
end

function ogl_vault.raidmanager:StartRaidTimer(vault)
    local raidID = self:GetVaultRaidID(vault)
    if !raidID then return false end
    local raid = self.raids[raidID]

    vault:SetState(VAULT_RAIDING)
    self.raids[raidID].stage = RAID_INPROGRESS
    self.raids[raidID].memberCount = #raid.participants

    for k,v in ipairs(raid.participants) do
        v:OGLVaultNotify(ogl_vault.lang.warmupover)
    end

    local timerLength = ogl_vault.config.raidbasetime + ((#raid.participants - 1) * ogl_vault.config.raidmembertimemultiplier)

    vault:SetTimerLength(timerLength)
    vault:SetTimerEnd(CurTime() + timerLength)

    timer.Create("OGLVaultTimer" .. vault:EntIndex(), timerLength, 1, function()
        self:EndRaidTimer(vault)
    end)

    if vault:GetSecurityEnabled() then
        self:TriggerSecurity(vault)
    else
        vault:SetSecurityTimerEnd(CurTime() + ogl_vault.config.securitytimer)
        timer.Create("OGLVaultSecurityTimer" .. vault:EntIndex(), timerLength, 1, function()
            self:TriggerSecurity(vault)
        end)
    end
end

function ogl_vault.raidmanager:TriggerSecurity(vault)
    vault:SetSecurityEnabled(true)
    vault:SetSecurityTimerEnd(CurTime() + ogl_vault.config.securitytimer)

    for k,v in ipairs(getPolice()) do
        v:OGLVaultNotify(ogl_vault.lang.vaultbreached)
    end
end

function ogl_vault.raidmanager:EndRaidTimer(vault)
    vault:OpenVault()
end

hook.Add("PlayerDisconnected", "OGLVaultRaidManager", function(ply)
    local raid = ogl_vault.raidmanager:GetPlayerOngoingRaid(ply)
    if !raid then return end

    ogl_vault.raidmanager:LeaveRaid(ply, raid.vault)
end)

hook.Add("playerCanChangeTeam", "OGLVaultRaidManager", function(ply, newTeam, force)
    local raid = ogl_vault.raidmanager:GetPlayerOngoingRaid(ply)
    if !raid then return end

    if force then ogl_vault.raidmanager:LeaveRaid(ply, raid.vault) return end

    return false, ogl_vault.lang.cantchangeteam
end)

hook.Add("canStartVote", "OGLVaultRaidManager", function(vote)
    local ply = vote.target
    local raid = ogl_vault.raidmanager:GetPlayerOngoingRaid(ply)
    if raid then return false, nil, ogl_vault.lang.cantstartvote end
end)

hook.Add("canGoAFK", "OGLVaultRaidManager", function(ply, state)
    if !state then return end

    local raid = ogl_vault.raidmanager:GetPlayerOngoingRaid(ply)
    if raid then return false end
end)

hook.Add("canSleep", "OGLVaultRaidManager", function(ply, force)
    local raid = ogl_vault.raidmanager:GetPlayerOngoingRaid(ply)
    if !raid then return end

    if force then ogl_vault.raidmanager:LeaveRaid(ply, raid.vault) return end

    return false, ogl_vault.lang.cantsleep
end)

hook.Add("PlayerDeath", "OGLVaultRaidManager", function(victim, inflictor, attacker)
    local raid = ogl_vault.raidmanager:GetPlayerOngoingRaid(victim)
    if !raid then return end

    ogl_vault.raidmanager:LeaveRaid(victim, raid.vault)

    if !ogl_vault.config.rejoindeath then
        ogl_vault.raidmanager.raids[raidID].leftparticipants[#raid.leftparticipants + 1] = victim
    end

    if raid.stage != RAID_INPROGRESS then return end
    if ogl_vault.config.raiderkilledpenalty then
        raid.vault:SetTimerLength(raid.vault:GetTimerLength() + ogl_vault.config.raiderkilledpenalty)
        raid.vault:SetTimerEnd(raid.vault:GetTimerEnd() + ogl_vault.config.raiderkilledpenalty)

        for k,v in ipairs(raid.participants) do
            v:OGLVaultNotify(ogl_vault.lang.lang.raiderkilledpenalty)
        end
    end

    if ogl_vault.raidmanager:GetPlayerOngoingRaid(attacker) and ogl_vault.config.friendlykilledpenalty then
        raid.vault:SetTimerLength(raid.vault:GetTimerLength() + ogl_vault.config.friendlykilledpenalty)
        raid.vault:SetTimerEnd(raid.vault:GetTimerEnd() + ogl_vault.config.friendlykilledpenalty)

        for k,v in ipairs(raid.participants) do
            v:OGLVaultNotify(ogl_vault.lang.friendlyfirepenalty)
        end
    end

    if ogl_vault.config.policeteams[team.GetName(attacker:Team())] and ogl_vault.config.policekillreward then
        attacker:addMoney(ogl_vault.config.policekillreward)
        attacker:OGLVaultNotify(string.Replace(ogl_vault.lang.killedraiderreward, "%m", DarkRP.formatMoney(ogl_vault.config.policekillreward)))
    end
end)

hook.Add("PostCleanupMap", "OGLVaultRaidManager", function()
    table.Empty(ogl_vault.raidmanager.raids)
end)