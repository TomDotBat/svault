
include("shared.lua")

local imgui = include("ogl_vault/client/cl_imgui.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
    self.LocalPlayer = LocalPlayer()
end

function ENT:DrawTranslucent()
    self:DrawModel()

    if not ogl_vault.lang then return end

    --Use the flippy out screen bone pos/angs?
    --Or wait for anim to play then animate screen turn on

    if imgui.Entity3D2D(self, Vector(0, 0, 50), Angle(0, 90, 90), 0.06, ogl_vault.config.draw3d2ddist, ogl_vault.config.draw3d2ddist - 40) then
        surface.SetDrawColor(color_white)
        surface.DrawRect(0, 0, 100, 100)

        imgui.End3D2D()
    end
end