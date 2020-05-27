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

	self:SetState(VAULT_IDLE)
	self:SetValue(1500000)
	self:SetTimerLength(0)
	self:SetTimerEnd(0)
	self:SetSecurityTimerEnd(0)
	self:SetSecurityEnabled(false)
	self:SetRobberNames("")
end

function ENT:Think()
	if ogl_vault.config.maxraiderdist then
		local raidID = ogl_vault.raidmanager:GetVaultRaidID(self)
		if !raidID then return end
		local raid = ogl_vault.raidmanager.raids[raidID]

		local vaultPos = self:GetPos()
		for k,v in ipairs(raid.participants) do
			if v:GetPos():DistToSqr(vaultPos) > ogl_vault.config.maxraiderdist then
				ogl_vault.raidmanager:LeaveRaid(victim, raid.vault)

				if !ogl_vault.config.rejoinoutofrange then
					ogl_vault.raidmanager.raids[raidID].leftparticipants[#raid.leftparticipants + 1] = v
				end
			end
		end
	end
end

function ENT:Use(ply)
	local raidID = ogl_vault.raidmanager:GetVaultRaidID(self)
	if !raidID then
		if !self:GetState(VAULT_IDLE) then ply:OGLVaultNotify(ogl_vault.lang.cantstartcooldown) return end

		local response = ogl_vault.raidmanager:StartRaid(ply, self)
		if response != "successful" then
			ply:OGLVaultNotify(response)
			return
		end

		ply:OGLVaultNotify(ogl_vault.lang.startingraid)
	else
		local raid = ogl_vault.raidmanager.raids[raidID]

		if raid.stage != RAID_WARMUP then ply:OGLVaultNotify(ogl_vault.lang.cantjoinleavestage) return end

		for k,v in ipairs(raid.participants) do
			if v == ply then
				local response = ogl_vault.raidmanager:LeaveRaid(ply, self)
				if response != "successful" then
					ply:OGLVaultNotify(response)
					break
				end
				ply:OGLVaultNotify(ogl_vault.lang.leftraid)
				break
			end
		end

		local response = ogl_vault.raidmanager:JoinRaid(ply, self)
		if response != "successful" then
			ply:OGLVaultNotify(response)
			return
		end

		ply:OGLVaultNotify(ogl_vault.lang.joinedraidparty)
	end
end

function ENT:OpenVault()
	self:SetState(VAULT_OPEN)
	self:SetTimerLength(0)
	self:SetTimerEnd(0)

	self:ResetSequence(0)
	self:SetSequence(0)

	timer.Simple(self:SequenceDuration(0), function()
		local raidID = ogl_vault.raidmanager:GetVaultRaidID(self)
		if !raidID then return end
		local raid = ogl_vault.raidmanager.raids[raidID]

		if ogl_vault.config.dropmoney then
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

function ENT:StartCooldown()
	self:SetState(VAULT_COOLDOWN)
	self:SetTimerLength(ogl_vault.config.cooldowntime)
	self:SetTimerEnd(CurTime() + ogl_vault.config.cooldowntime)	self:SetRobberNames("")
	self:SetRobberNames("")

	timer.Create("OGLVaultCooldownTimer" .. self:EntIndex(), ogl_vault.config.cooldowntime, 1, function()
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