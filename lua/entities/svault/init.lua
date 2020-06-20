
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/ogl/ogl_vault_v2.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Think()
	self:NextThink(CurTime())

	if svault.config.maxraiderdist then
		local raidID = svault.raidmanager:GetVaultRaidID(self)
		if !raidID then return true end
		local raid = svault.raidmanager.raids[raidID]

		local vaultPos = self:GetPos()
		for k,v in ipairs(raid.participants) do
			if v:GetPos():DistToSqr(vaultPos) > svault.config.maxraiderdist ^ 2 then
				svault.raidmanager:LeaveRaid(victim, raid.vault)

				if !svault.config.rejoinoutofrange then
					svault.raidmanager.raids[raidID].leftparticipants[#raid.leftparticipants + 1] = v
				end
			end
		end
	end

	return true
end

function ENT:Use(ply)
	local raidID = svault.raidmanager:GetVaultRaidID(self)
	if !raidID then
		if !self:GetState(VAULT_IDLE) then ply:sVaultNotify(svault.lang.cantstartcooldown) return end

		local response = svault.raidmanager:StartRaid(ply, self)
		if response != "successful" then
			ply:sVaultNotify(response)
			return
		end

		ply:sVaultNotify(svault.lang.startingraid)
	else
		local raid = svault.raidmanager.raids[raidID]

		if raid.stage != RAID_WARMUP then ply:sVaultNotify(svault.lang.cantjoinleavestage) return end

		for k,v in ipairs(raid.participants) do
			if v == ply then
				local response = svault.raidmanager:LeaveRaid(ply, self)
				if response != "successful" then
					ply:sVaultNotify(response)
					break
				end
				ply:sVaultNotify(svault.lang.leftraid)
				break
			end
		end

		local response = svault.raidmanager:JoinRaid(ply, self)
		if response != "successful" then
			ply:sVaultNotify(response)
			return
		end

		ply:sVaultNotify(svault.lang.joinedraidparty)
	end
end

function ENT:OpenVault()
	self:SetState(VAULT_OPEN)
	self:SetTimerLength(0)
	self:SetTimerEnd(0)

	self:ResetSequence(0)

	timer.Simple(self:SequenceDuration(0), function()
		local raidID = svault.raidmanager:GetVaultRaidID(self)
		if !raidID then return end
		local raid = svault.raidmanager.raids[raidID]

		if svault.config.dropmoney then
			DarkRP.createMoneyBag(self:LocalToWorld(Vector(-70, 35, 50)), self:GetValue())
		else
			local split = self:GetValue() / #raid.participants
			for k,v in ipairs(raid.participants) do
				v:addMoney(split)
			end
		end

		self:SetValue(0)
	end)
end

function ENT:CloseVault()

end

function ENT:HackVault()

end

function ENT:StartCooldown()
	self:SetState(VAULT_COOLDOWN)
	self:SetTimerLength(svault.config.cooldowntime)
	self:SetTimerEnd(CurTime() + svault.config.cooldowntime)	self:SetRobberNames("")
	self:SetRobberNames("")

	timer.Create("sVaultCooldownTimer" .. self:EntIndex(), svault.config.cooldowntime, 1, function()
		self:SetState(VAULT_IDLE)
		self:SetTimerLength(0)
		self:SetTimerEnd(0)
	end)
end

function ENT:StartRecovering()
	self:SetState(VAULT_RECOVERING)
	self:SetTimerLength(0)
	self:SetTimerEnd(0)
	self:SetRobberNames("")
end