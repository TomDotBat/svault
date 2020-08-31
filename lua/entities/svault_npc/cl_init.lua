
include("shared.lua")

surface.CreateFont("sVault.NPCOverhead", {
    font = "Montserrat Medium",
    size = 100,
    weight = 1000,
    antialias = true
})

function ENT:Initialize()
    self.LocalPlayer = LocalPlayer()
end
local function drawOverhead(pos)
    local ang = LocalPlayer():EyeAngles()

    ang:SetUnpacked(0, ang[2] - 90, 90)

    surface.SetFont("sVault.NPCOverhead")
    local w, h = surface.GetTextSize(text)
    w = w + 80
    h = h + 10

    local x, y = -(w / 2), -h

    local oldClipping = DisableClipping(true)

    cam.Start3D2D(eyes.Pos, ang, 0.05)
        draw.RoundedBoxEx(16, x, y, w, h, color_black, true, true)
        draw.RoundedBox(4, x, -4, w, 8, color_black, true, true)
        draw.DrawText(svault.lang.npcname, "sVault.NPCOverhead", 0, y + 1, color_white, TEXT_ALIGN_CENTER)
    cam.End3D2D()

    DisableClipping(oldClipping)
end

local eyeOffset = Vector(0, 0, 7)
local fallbackOffset = Vector(0, 0, 73)
function ENT:Draw()
    if self.LocalPlayer:GetPos():DistToSqr(self:GetPos()) > 200000 then return end

    local eyeId = self:LookupAttachment("eyes")
    if eyeId then
        local eyes = self:GetAttachment(eyeId)
        if eyes then
            eyes.Pos:Add(eyeOffset)
            drawOverhead(eyes.Pos)
            return
        end
    end

    drawOverhead(self:GetPos() + fallbackOffset)
end