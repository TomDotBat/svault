
ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "OGL Vault"
ENT.Category = "OGL Vault"
ENT.Author = "Tom.bat"
ENT.Spawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Float", 0, "Value")
	self:NetworkVar("Float", 1, "TimerLength")
	self:NetworkVar("Float", 2, "TimerEnd")
	self:NetworkVar("Float", 3, "SecurityTimerEnd")
	self:NetworkVar("Bool", 0, "SecurityEnabled")
	self:NetworkVar("String", 0, "RobberNames")
end