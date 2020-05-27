
include("shared.lua")

surface.CreateFont("OGLBankTitle", {
    font = "Montserrat",
    size = 230,
    weight = 500
})

surface.CreateFont("OGLBankSmallTitle", {
    font = "Montserrat",
    size = 130,
    weight = 500
})

surface.CreateFont("OGLBankSecurityMessage", {
    font = "Montserrat",
    size = 100,
    weight = 500
})

surface.CreateFont("OGLBankSecurityTime", {
    font = "Montserrat",
    size = 170,
    weight = 600
})

surface.CreateFont("OGLBankStatus", {
    font = "Montserrat",
    size = 140,
    weight = 500
})

surface.CreateFont("OGLBankPercent", {
    font = "Montserrat",
    size = 230,
    weight = 500
})

surface.CreateFont("OGLBankInfoTitle", {
    font = "Montserrat",
    size = 110,
    weight = 500
})

surface.CreateFont("OGLBankInfo", {
    font = "Montserrat",
    size = 90,
    weight = 600
})

surface.CreateFont("OGLBankRobbersTitle", {
    font = "Montserrat",
    size = 130,
    weight = 500
})

surface.CreateFont("OGLBankRobber", {
    font = "Montserrat",
    size = 100,
    weight = 500
})

local securityMat = Material("ogl_bank/caution.png", "noclamp smooth")
local timerMat = Material("ogl_bank/notification.png", "noclamp smooth")
local statusMat = Material("ogl_bank/warning.png", "noclamp smooth")
local shadowMat = Material("ogl_bank/shadow.png", "noclamp smooth")
local infoMat = Material("ogl_bank/info.png", "noclamp smooth")
local cooldownMat = Material("ogl_bank/cooldown.png", "noclamp smooth")
local playerMat = Material("ogl_bank/player.png", "noclamp smooth")
local valueMat = Material("ogl_bank/money.png", "noclamp smooth")
local lawMat = Material("ogl_bank/gun.png", "noclamp smooth")
local circleMat = Material("ogl_bank/circle.png", "noclamp smooth")

local playerCount = 0
local policeCount = 0

timer.Create("OGLBankVaultData", 5, 0, function()
    local players = player.GetHumans()
    playerCount = #players
    policeCount = 0

    for k, v in ipairs(players) do
        if ogl_vault.config.policeteams[team.GetName(v:Team())] then
            policeCount = policeCount + 1
        end
    end
end)

function ENT:Initialize()
    self.LocalPlayer = LocalPlayer()
    self.Robbers = {}
end

function ENT:Think()
    self.ShouldDraw3D2D = self.LocalPlayer:GetPos():DistToSqr(self:GetPos()) < ogl_vault.config.draw3d2ddist
    local robbers = string.Explode("\n", self:GetRobberNames())
    table.Empty(self.Robbers)

    if #robbers[1] > 1 then
        for k, v in ipairs(robbers) do
            if #v > 18 then
                v = string.Left(v, 17) .. "..."
            end

            self.Robbers[k] = string.upper(v)
        end
    end
end

local w, h = 2425, 4025
local spacing = 50

function ENT:Draw()
    self:DrawModel()

    if not ogl_vault.lang then return end
    if not self.ShouldDraw3D2D then return end

    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 270)
    ang:RotateAroundAxis(ang:Forward(), 90)

    local state = self:GetState()
    local security = self:GetSecurityEnabled()
    local cooldown = state == VAULT_COOLDOWN or state == VAULT_RECOVERING

    cam.Start3D2D(self:LocalToWorld(Vector(-37.5, -32.1, 103.8)), ang, 0.025)
        local offy = 100

        --Background
        surface.SetDrawColor(ogl_vault.config.bgCol)
        surface.DrawRect(0, 0, w, h)

        --Title Box
        local vaultname = string.upper(ogl_vault.config.vaultname)

        surface.SetFont("OGLBankTitle")
        local th = select(2, surface.GetTextSize(vaultname))

        draw.RoundedBox(32, w * .04, offy, w * .92, th * 1.4, ogl_vault.config.secondBgCol)
        draw.RoundedBox(20, w * .04, offy, w * .92, 40, ogl_vault.config.primaryCol)
        draw.RoundedBox(20, w * .04, offy + th * 1.4 - 40, w * .92, 40, ogl_vault.config.primaryCol)

        draw.SimpleText(vaultname, "OGLBankTitle", w / 2, offy + th * .7, ogl_vault.config.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        offy = offy + th * 1.4 + spacing

        --Container Box
        draw.RoundedBox(32, w * .04, offy, w * .92, h - offy - 100, ogl_vault.config.secondBgCol)
        offy = offy + spacing

        --Security System Box
        surface.SetFont("OGLBankSmallTitle")
        local sh = select(2, surface.GetTextSize(ogl_vault.lang.securitysystem))

        surface.SetFont("OGLBankSecurityMessage")
        local msgh = select(2, surface.GetTextSize(ogl_vault.lang.alertcps))

        surface.SetFont("OGLBankSecurityTime")
        local timeLeft = self:GetSecurityTimerEnd() - CurTime()
        local timeLeftText = (timeLeft > 0 and string.format("%.2f", timeLeft) .. "s" or "0.00s")
        local sth = select(2, surface.GetTextSize(timeLeftText))

        draw.RoundedBox(32, w * .06, offy, w * .88, sh * 1.4 + msgh + 40 + sth + 40, ogl_vault.config.boxBgCol)
        draw.RoundedBox(20, w * .06, offy, w * .88, 40, ogl_vault.config.primaryCol)

        surface.SetDrawColor(ogl_vault.config.iconCol)
        surface.SetMaterial(securityMat)
        surface.DrawTexturedRect(w * .06 + 40, offy + sh * .55 - 10, 100, 100)

        draw.SimpleText(ogl_vault.lang.securitysystem, "OGLBankSmallTitle", w * .06 + 40 + 100 + 30, offy + sh * .55 + 40, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(security and ogl_vault.lang.enabled or ogl_vault.lang.disabled, "OGLBankSmallTitle", w * .06 + w * .88 - 40, offy + sh * .55 + 40, security and ogl_vault.config.onCol or ogl_vault.config.offCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.RoundedBox(20, w * .06, offy + sh * 1.4, w * .88, 40, ogl_vault.config.primaryCol)
        draw.DrawText(ogl_vault.lang.alertcps, "OGLBankSecurityMessage", w * .5, offy + sh * 1.4 + 40, ogl_vault.config.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        surface.SetFont("OGLBankSecurityTime")
        local tmw, tmh = surface.GetTextSize(timeLeftText)
        tmw = tmh + 5 + tmw
        surface.SetDrawColor(ogl_vault.config.warningCol)
        surface.SetMaterial(timerMat)
        surface.DrawTexturedRect(w * .5 - tmw * .5, offy + sh * 1.4 + msgh + 40 + tmh * .1, tmh * .8, tmh * .8)
        draw.SimpleText(timeLeftText, "OGLBankSecurityTime", w * .5 + tmw * .5, offy + sh * 1.4 + msgh + 40, ogl_vault.config.warningCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
        draw.RoundedBox(20, w * .06, offy + sh * 1.4 + msgh + 40 + sth, w * .88, 40, ogl_vault.config.primaryCol)
        offy = offy + sh * 1.4 + msgh + 40 + sth + 40 + spacing

        --Status Box
        surface.SetFont("OGLBankStatus")
        local statusText = state == VAULT_WARMUP and ogl_vault.lang.warmupperiod or (state == VAULT_RAIDING or state == VAULT_OPEN) and ogl_vault.lang.robberystatus or state == VAULT_IDLE and ogl_vault.lang.vaultstatus or ogl_vault.lang.cooldownperiod
        local rw, rh = surface.GetTextSize(statusText)

        surface.SetFont("OGLBankInfoTitle")
        local ih = select(2, surface.GetTextSize(ogl_vault.lang.info))

        draw.RoundedBox(32, w * .06, offy, w * .88, 40 + 20 + rh + 10 + 40 + 300 + 40 + ih + 740, ogl_vault.config.boxBgCol)
        draw.RoundedBox(20, w * .06, offy, w * .88, 40, ogl_vault.config.primaryCol)
        draw.RoundedBox(0, w / 2 - (rw * 1.1) / 2, offy + 40 + 20, rw * 1.1, 18, ogl_vault.config.lineCol)
        draw.SimpleText(statusText, "OGLBankStatus", w * .5, offy + 40 + 20 + 4 + rh * .5, ogl_vault.config.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox(0, w / 2 - (rw * 1.1) / 2, offy + 40 + 20 + rh - 8, rw * 1.1, 18, ogl_vault.config.lineCol)

        if state == VAULT_RAIDING or state == VAULT_OPEN then
            surface.SetDrawColor(ogl_vault.config.iconCol)
            surface.SetMaterial(statusMat)
            surface.DrawTexturedRect(w / 2 - (rw * 1.1) / 2 - rh - 40, offy + 40 + 20 + rh * .05, rh, rh)
            surface.SetDrawColor(ogl_vault.config.iconCol)
            surface.SetMaterial(statusMat)
            surface.DrawTexturedRect(w / 2 + (rw * 1.1) / 2 + 40, offy + 40 + 20 + rh * .05, rh, rh)
        end

        offy = offy + 40 + 20 + rh + 10 + 40
        surface.SetDrawColor(color_white)
        surface.SetMaterial(shadowMat)
        surface.DrawTexturedRect(0, offy, w, 460)

        local progress = state == VAULT_IDLE and 1 or 1 - ((self:GetTimerEnd() - CurTime()) / self:GetTimerLength())
        progress = math.Clamp(progress, 0, 1)

        draw.RoundedBox(32, w * .08, offy, w * .84, 300, ogl_vault.config.primaryCol)
        draw.RoundedBox(16, w * .08 + 20, offy + 20, w * .84 - 40, 260, ogl_vault.config.progBgCol)
        draw.RoundedBox(16, w * .08 + 20, offy + 20, (w * .84 - 40) * progress, 260, ogl_vault.config.progCol)
        draw.SimpleText(state == VAULT_IDLE and ogl_vault.lang.idle or (math.Round(progress * 100) .. "%"), "OGLBankPercent", w * .5, offy + 150, ogl_vault.config.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        offy = offy + 300 + 40

        draw.SimpleText(ogl_vault.lang.info, "OGLBankInfoTitle", w * .06 + 40, offy, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetDrawColor(ogl_vault.config.iconCol)
        surface.SetMaterial(infoMat)
        surface.DrawTexturedRect(w * .08 + w * .84 - 74, offy + 17, 75, 75)

        offy = offy + ih

        draw.RoundedBox(0, w * .08, offy, w * .84, 18, ogl_vault.config.lineCol)
        draw.RoundedBox(0, w * .55, offy, 18, 740, ogl_vault.config.lineCol)

        surface.SetDrawColor(ogl_vault.config.iconCol)
        surface.SetMaterial(cooldownMat)
        surface.DrawTexturedRect(w * .06 + 40, offy + 170 - 110, 100, 100)
        draw.SimpleText(ogl_vault.lang.cooldown, "OGLBankInfo", w * .06 + 40 + 100 + 20, offy + 170 - 110, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(cooldown and ogl_vault.lang.active or ogl_vault.lang.inactive, "OGLBankInfo", w * .55 + 18 + 40, offy + 170 - 110, cooldown and ogl_vault.config.onCol or ogl_vault.config.offCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        surface.SetDrawColor(ogl_vault.config.iconCol)
        surface.SetMaterial(playerMat)
        surface.DrawTexturedRect(w * .06 + 40, offy + 170 * 2 - 110, 100, 100)
        draw.SimpleText(ogl_vault.lang.players, "OGLBankInfo", w * .06 + 40 + 100 + 20, offy + 170 * 2 - 110, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(playerCount .. "/" .. ogl_vault.config.minplayers, "OGLBankInfo", w * .55 + 18 + 40, offy + 170 * 2 - 110, playerCount >= ogl_vault.config.minplayers and ogl_vault.config.onCol or ogl_vault.config.offCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        surface.SetDrawColor(ogl_vault.config.iconCol)
        surface.SetMaterial(valueMat)
        surface.DrawTexturedRect(w * .06 + 40, offy + 170 * 3 - 110, 100, 100)
        draw.SimpleText(ogl_vault.lang.totalvalue, "OGLBankInfo", w * .06 + 40 + 100 + 20, offy + 170 * 3 - 110, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(DarkRP.formatMoney(self:GetValue()), "OGLBankInfo", w * .55 + 18 + 40, offy + 170 * 3 - 110, ogl_vault.config.onCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        surface.SetDrawColor(ogl_vault.config.iconCol)
        surface.SetMaterial(lawMat)
        surface.DrawTexturedRect(w * .06 + 40, offy + 170 * 4 - 110, 100, 100)
        draw.SimpleText(ogl_vault.lang.lawenforcement, "OGLBankInfo", w * .06 + 40 + 100 + 20, offy + 170 * 4 - 110, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(policeCount .. "/" .. ogl_vault.config.minpolice, "OGLBankInfo", w * .55 + 18 + 40, offy + 170 * 4 - 110, policeCount >= ogl_vault.config.minpolice and ogl_vault.config.onCol or ogl_vault.config.offCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.RoundedBox(20, w * .06, offy + 740 - 40, w * .88, 40, ogl_vault.config.primaryCol)

        offy = offy + 740 + spacing

        --Current Robbers Box
        surface.SetFont("OGLBankRobbersTitle")
        local crh = select(2, surface.GetTextSize(ogl_vault.lang.currentrobbers))

        draw.RoundedBox(32, w * .06, offy, w * .88, (h - 100) - offy - spacing, ogl_vault.config.boxBgCol)
        draw.RoundedBox(20, w * .06, offy, w * .88, 40, ogl_vault.config.primaryCol)
        draw.SimpleText(ogl_vault.lang.currentrobbers, "OGLBankRobbersTitle", w * .5, offy + crh * .55 + 40, ogl_vault.config.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox(20, w * .06, offy + crh * 1.4, w * .88, 40, ogl_vault.config.primaryCol)

        surface.SetDrawColor(self.Robbers[1] and ogl_vault.config.onCol or ogl_vault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + 80, offy + 315, 100, 100)
        draw.SimpleText(self.Robbers[1] and self.Robbers[1] or ogl_vault.lang.notapplicable, "OGLBankRobber", w * .06 + 40 + 100 + 70, offy + 315 + 50, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[2] and ogl_vault.config.onCol or ogl_vault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + 80, offy + 490, 100, 100)
        draw.SimpleText(self.Robbers[2] and self.Robbers[2] or ogl_vault.lang.notapplicable, "OGLBankRobber", w * .06 + 40 + 100 + 70, offy + 490 + 50, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[3] and ogl_vault.config.onCol or ogl_vault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + 80, offy + 665, 100, 100)
        draw.SimpleText(self.Robbers[3] and self.Robbers[3] or ogl_vault.lang.notapplicable, "OGLBankRobber", w * .06 + 40 + 100 + 70, offy + 665 + 50, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[4] and ogl_vault.config.onCol or ogl_vault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + 80, offy + 840, 100, 100)
        draw.SimpleText(self.Robbers[4] and self.Robbers[4] or ogl_vault.lang.notapplicable, "OGLBankRobber", w * .06 + 40 + 100 + 70, offy + 840 + 50, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[5] and ogl_vault.config.onCol or ogl_vault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + w * .88 - 1000, offy + 315, 100, 100)
        draw.SimpleText(self.Robbers[5] and self.Robbers[5] or ogl_vault.lang.notapplicable, "OGLBankRobber", w * .06 + w * .88 - 1000 + 100 + 30, offy + 315 + 50, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[6] and ogl_vault.config.onCol or ogl_vault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + w * .88 - 1000, offy + 490, 100, 100)
        draw.SimpleText(self.Robbers[6] and self.Robbers[6] or ogl_vault.lang.notapplicable, "OGLBankRobber", w * .06 + w * .88 - 1000 + 100 + 30, offy + 490 + 50, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[7] and ogl_vault.config.onCol or ogl_vault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + w * .88 - 1000, offy + 665, 100, 100)
        draw.SimpleText(self.Robbers[7] and self.Robbers[7] or ogl_vault.lang.notapplicable, "OGLBankRobber", w * .06 + w * .88 - 1000 + 100 + 30, offy + 665 + 50, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[8] and ogl_vault.config.onCol or ogl_vault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + w * .88 - 1000, offy + 840, 100, 100)
        draw.SimpleText(self.Robbers[8] and self.Robbers[8] or ogl_vault.lang.notapplicable, "OGLBankRobber", w * .06 + w * .88 - 1000 + 100 + 30, offy + 840 + 50, ogl_vault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.RoundedBox(20, w * .06, offy + (h - 100) - offy - spacing - 40, w * .88, 40, ogl_vault.config.primaryCol)
    cam.End3D2D()
end