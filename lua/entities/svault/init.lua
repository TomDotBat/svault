
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

	self.NextThinkTime = 0
end

function ENT:Think()
	self:NextThink(CurTime())

	if self.NextThinkTime > CurTime() then return true end
	self.NextThinkTime = CurTime() + 1

	if self:GetState() != VAULT_RECOVERING then
		if self:GetValue() < svault.config.minvaultvalue then
			self:StartRecovering()
		end
	else
		if self:GetValue() >= svault.config.minvaultvalue then
			self:FinishRecovering()
		end
	end

	if svault.config.maxraiderdist then
		local raidID = svault.raidmanager:GetVaultRaidID(self)
		if not raidID then return true end
		local raid = svault.raidmanager.raids[raidID]

		local vaultPos = self:GetPos()
		for k,v in ipairs(raid.participants) do
			if v:GetPos():DistToSqr(vaultPos) > svault.config.maxraiderdist ^ 2 then
				svault.raidmanager:LeaveRaid(victim, raid.vault)

				if not svault.config.rejoinoutofrange then
					svault.raidmanager.raids[raidID].leftparticipants[#raid.leftparticipants + 1] = v
				end
			end
		end
	end

	return true
end

function ENT:Use(ply)
	local raidID = svault.raidmanager:GetVaultRaidID(self)
	if not raidID then
		if self:GetState() != VAULT_IDLE then ply:sVaultNotify(svault.lang.cantstartcooldown) return end

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
	self:SetPlaybackRate(1)

	timer.Simple(self:SequenceDuration(0) + 3, function()
		if not IsValid(self) then return end

		local raidID = svault.raidmanager:GetVaultRaidID(self)
		if not raidID then return end
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

		timer.Simple(3, function()
			if not IsValid(self) then return end
			self:CloseVault()
		end)
	end)
end

function ENT:CloseVault()
	self:SetPlaybackRate(-1)
	self:StartCooldown()

	svault.raidmanager:FinishRaid(self)
end

function ENT:HackVault()
	self:SetSecurityEnabled(false)

	timer.Create("sVaultHackReenableTimer" .. self:EntIndex(), svault.config.hackreenabletime, 1, function()
		if not IsValid(self) then return end
		if self:GetState() == VAULT_RAIDING then return end
		self:SetSecurityEnabled(true)
	end)
end

function ENT:StartCooldown()
	self:SetState(VAULT_COOLDOWN)
	self:SetTimerLength(svault.config.cooldowntime)
	self:SetTimerEnd(CurTime() + svault.config.cooldowntime)
	self:SetRobberNames("")
	self:SetSecurityEnabled(true)

	timer.Create("sVaultCooldownTimer" .. self:EntIndex(), svault.config.cooldowntime, 1, function()
		if not IsValid(self) then return end
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

function ENT:FinishRecovering()
	self:SetState(VAULT_IDLE)
	self:SetTimerLength(0)
	self:SetTimerEnd(0)
	self:SetRobberNames("")
	self:SetSecurityEnabled(true)
end