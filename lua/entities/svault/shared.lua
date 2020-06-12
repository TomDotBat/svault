
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Vault"
ENT.Category = "sVault"
ENT.Author = "Tom.bat"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Float", 0, "Value")
	self:NetworkVar("Float", 1, "TimerLength")
	self:NetworkVar("Float", 2, "TimerEnd")
	self:NetworkVar("Float", 3, "SecurityTimerEnd")
	self:NetworkVar("Bool", 0, "SecurityEnabled")
	self:NetworkVar("String", 0, "RobberNames")

	if SERVER then
		self:SetState(VAULT_IDLE)
		self:SetValue(1500000)
		self:SetTimerLength(0)
		self:SetTimerEnd(0)
		self:SetSecurityTimerEnd(0)
		self:SetSecurityEnabled(false)
		self:SetRobberNames("")
	end
end