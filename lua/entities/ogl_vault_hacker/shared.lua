
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "OGL Security Hacking Device"
ENT.Category = "OGL Vault"
ENT.Author = "Tom.bat"
ENT.Spawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Opened")

    if SERVER then
        self:SetOpened(false)
    end
end

function ENT:GetHacker()
    local owner = self:CPPIGetOwner()
    if owner then return owner end

    return self.Getowning_ent and self:Getowning_ent()
end