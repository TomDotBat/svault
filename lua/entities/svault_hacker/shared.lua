
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Security Hacking Device"
ENT.Category = "sVault"
ENT.Author = "Tom.bat"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
    self:NetworkVar("Int", 0, "ScreenID")
    self:NetworkVar("Bool", 0, "Opened")
    self:NetworkVar("Float", 0, "SelfDestructTime")

    if SERVER then
        self:SetScreenID(1)
        self:SetOpened(false)
        self:SetSelfDestructTime(0)
    end
end

function ENT:GetHacker()
    local owner = self:CPPIGetOwner()
    if owner then return owner end

    return self.Getowning_ent and self:Getowning_ent()
end