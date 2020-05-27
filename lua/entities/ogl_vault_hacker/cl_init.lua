
include("shared.lua")

function ENT:Initialize()
    self.LocalPlayer = LocalPlayer()
end

function ENT:Think()
    self.ShouldDraw3D2D = self.LocalPlayer:GetPos():DistToSqr(self:GetPos()) < ogl_vault.config.draw3d2ddist
end

function ENT:Draw()
    self:DrawModel()

    if not ogl_vault.lang then return end
    if not self.ShouldDraw3D2D then return end
end