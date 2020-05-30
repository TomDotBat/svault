
include("shared.lua")

local imgui = include("ogl_vault/client/cl_imgui.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
    self.LocalPlayer = LocalPlayer()
end

local scrw, scrh = 630, 497
function ENT:DrawTranslucent()
    self:DrawModel()

    if not ogl_vault.lang then return end

    local pos, ang = self:GetBonePosition(1)

    ang = self:WorldToLocalAngles(ang)

    pos = self:WorldToLocal(pos) + ang:Up() * -22.42
    pos = pos + ang:Forward() * 1.18
    pos = pos + ang:Right() * 5.74

    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), 90)

    if imgui.Entity3D2D(self, pos, ang, 0.04, ogl_vault.config.draw3d2ddist, ogl_vault.config.draw3d2ddist - 40) then
        surface.SetDrawColor(color_white)
        surface.DrawRect(0, 0, scrw, scrh)

        draw.SimpleText("poop", "DermaDefault", scrw / 2, scrh / 2, color_black)

        imgui.End3D2D()
    end
end