
include("shared.lua")

surface.CreateFont("sVaultTitle", {
    font = "Montserrat SemiBold",
    size = 230,
    weight = 500
})

surface.CreateFont("sVaultSmallTitle", {
    font = "Montserrat Medium",
    size = 130,
    weight = 500
})

surface.CreateFont("sVaultSecurityMessage", {
    font = "Montserrat Medium",
    size = 100,
    weight = 500
})

surface.CreateFont("sVaultSecurityTime", {
    font = "Montserrat Medium",
    size = 170,
    weight = 600
})

surface.CreateFont("sVaultStatus", {
    font = "Montserrat Medium",
    size = 140,
    weight = 500
})

surface.CreateFont("sVaultPercent", {
    font = "Montserrat Medium",
    size = 230,
    weight = 500
})

surface.CreateFont("sVaultInfoTitle", {
    font = "Montserrat Medium",
    size = 110,
    weight = 500
})

surface.CreateFont("sVaultInfo", {
    font = "Montserrat Medium",
    size = 90,
    weight = 600
})

surface.CreateFont("sVaultRobbersTitle", {
    font = "Montserrat Medium",
    size = 130,
    weight = 500
})

surface.CreateFont("sVaultRobber", {
    font = "Montserrat Medium",
    size = 100,
    weight = 500
})

local securityMat = Material("svault/caution.png", "noclamp smooth")
local timerMat = Material("svault/notification.png", "noclamp smooth")
local statusMat = Material("svault/warning.png", "noclamp smooth")
local shadowMat = Material("svault/shadow.png", "noclamp smooth")
local infoMat = Material("svault/info.png", "noclamp smooth")
local cooldownMat = Material("svault/cooldown.png", "noclamp smooth")
local playerMat = Material("svault/player.png", "noclamp smooth")
local valueMat = Material("svault/money.png", "noclamp smooth")
local lawMat = Material("svault/gun.png", "noclamp smooth")
local circleMat = Material("svault/circle.png", "noclamp smooth")

local playerCount = 0
local policeCount = 0

timer.Create("sVaultVaultData", 5, 0, function()
    local players = player.GetHumans()
    playerCount = #players
    policeCount = 0

    for k, v in ipairs(players) do
        if svault.config.policeteams[team.GetName(v:Team())] then
            policeCount = policeCount + 1
        end
    end
end)

function ENT:Initialize()
    self.LocalPlayer = LocalPlayer()
    self.Robbers = {}
end

function ENT:Think()
    self.ShouldDraw3D2D = self.LocalPlayer:GetPos():DistToSqr(self:GetPos()) < svault.config.draw3d2ddist ^ 2
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

    if not svault.lang then return end
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
        surface.SetDrawColor(svault.config.bgCol)
        surface.DrawRect(0, 0, w, h)

        --Title Box
        local vaultname = string.upper(svault.config.vaultname)

        surface.SetFont("sVaultTitle")
        local th = select(2, surface.GetTextSize(vaultname))

        draw.RoundedBox(32, w * .04, offy, w * .92, th * 1.4, svault.config.secondBgCol)
        draw.RoundedBox(20, w * .04, offy, w * .92, 40, svault.config.primaryCol)
        draw.RoundedBox(20, w * .04, offy + th * 1.4 - 40, w * .92, 40, svault.config.primaryCol)

        draw.SimpleText(vaultname, "sVaultTitle", w / 2, offy + th * .67, svault.config.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        offy = offy + th * 1.4 + spacing

        --Container Box
        draw.RoundedBox(32, w * .04, offy, w * .92, h - offy - 100, svault.config.secondBgCol)
        offy = offy + spacing

        --Security System Box
        surface.SetFont("sVaultSmallTitle")
        local sh = select(2, surface.GetTextSize(svault.lang.securitysystem))

        surface.SetFont("sVaultSecurityMessage")
        local msgh = select(2, surface.GetTextSize(svault.lang.alertcps))

        surface.SetFont("sVaultSecurityTime")
        local timeLeft = self:GetSecurityTimerEnd() - CurTime()
        local timeLeftText = (timeLeft > 0 and string.format("%.2f", timeLeft) .. "s" or "0.00s")
        local sth = select(2, surface.GetTextSize(timeLeftText))

        draw.RoundedBox(32, w * .06, offy, w * .88, sh * 1.4 + msgh + 40 + sth + 40, svault.config.boxBgCol)
        draw.RoundedBox(20, w * .06, offy, w * .88, 40, svault.config.primaryCol)

        surface.SetDrawColor(svault.config.iconCol)
        surface.SetMaterial(securityMat)
        surface.DrawTexturedRect(w * .06 + 40, offy + sh * .55 - 10, 100, 100)

        draw.SimpleText(svault.lang.securitysystem, "sVaultSmallTitle", w * .06 + 40 + 100 + 30, offy + sh * .55 + 30, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(security and svault.lang.enabled or svault.lang.disabled, "sVaultSmallTitle", w * .06 + w * .88 - 40, offy + sh * .55 + 30, security and svault.config.onCol or svault.config.offCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.RoundedBox(20, w * .06, offy + sh * 1.4, w * .88, 40, svault.config.primaryCol)

        if state == VAULT_RAIDING then
            draw.DrawText(svault.lang.alertcps, "sVaultSecurityMessage", w * .5, offy + sh * 1.4 + 40, svault.config.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

            surface.SetFont("sVaultSecurityTime")
            local tmw, tmh = surface.GetTextSize(timeLeftText)
            tmw = tmh + 5 + tmw
            surface.SetDrawColor(svault.config.warningCol)
            surface.SetMaterial(timerMat)
            surface.DrawTexturedRect(w * .5 - tmw * .5, offy + sh * 1.4 + msgh + 40 + tmh * .1, tmh * .8, tmh * .8)
            draw.SimpleText(timeLeftText, "sVaultSecurityTime", w * .5 + tmw * .5, offy + sh * 1.4 + msgh + 40, svault.config.warningCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
        else
            if self:GetSecurityEnabled() then
                draw.DrawText(svault.lang.securityenabled, "sVaultSecurityMessage", w * .5, offy + sh * 1.4 + 110, svault.config.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            else
                draw.DrawText(svault.lang.securitydisabledmsg, "sVaultSecurityMessage", w * .5, offy + sh * 1.4 + 110, svault.config.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end
        end

        draw.RoundedBox(20, w * .06, offy + sh * 1.4 + msgh + 40 + sth, w * .88, 40, svault.config.primaryCol)
        offy = offy + sh * 1.4 + msgh + 40 + sth + 40 + spacing

        --Status Box
        surface.SetFont("sVaultStatus")
        local statusText = state == VAULT_WARMUP and svault.lang.warmupperiod or (state == VAULT_RAIDING or state == VAULT_OPEN) and svault.lang.robberystatus or state == VAULT_IDLE and svault.lang.vaultstatus or svault.lang.cooldownperiod
        local rw, rh = surface.GetTextSize(statusText)

        surface.SetFont("sVaultInfoTitle")
        local ih = select(2, surface.GetTextSize(svault.lang.info))

        draw.RoundedBox(32, w * .06, offy, w * .88, 40 + 20 + rh + 10 + 40 + 300 + 40 + ih + 740, svault.config.boxBgCol)
        draw.RoundedBox(20, w * .06, offy, w * .88, 40, svault.config.primaryCol)
        draw.RoundedBox(0, w / 2 - (rw * 1.1) / 2, offy + 40 + 20, rw * 1.1, 18, svault.config.lineCol)
        draw.SimpleText(statusText, "sVaultStatus", w * .5, offy + 40 + 20 + rh * .5, svault.config.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox(0, w / 2 - (rw * 1.1) / 2, offy + 40 + 20 + rh - 8, rw * 1.1, 18, svault.config.lineCol)

        if state == VAULT_RAIDING or state == VAULT_OPEN then
            surface.SetDrawColor(svault.config.iconCol)
            surface.SetMaterial(statusMat)
            surface.DrawTexturedRect(w / 2 - (rw * 1.1) / 2 - rh - 40, offy + 40 + 20 + rh * .05, rh, rh)
            surface.SetDrawColor(svault.config.iconCol)
            surface.SetMaterial(statusMat)
            surface.DrawTexturedRect(w / 2 + (rw * 1.1) / 2 + 40, offy + 40 + 20 + rh * .05, rh, rh)
        end

        offy = offy + 40 + 20 + rh + 10 + 40
        surface.SetDrawColor(color_white)
        surface.SetMaterial(shadowMat)
        surface.DrawTexturedRect(0, offy, w, 460)

        local progress = (state == VAULT_IDLE and 1) or (state == VAULT_RECOVERING and 1) or (1 - ((self:GetTimerEnd() - CurTime()) / self:GetTimerLength()))
        progress = math.Clamp(progress, 0, 1)

        draw.RoundedBox(32, w * .08, offy, w * .84, 300, svault.config.primaryCol)
        draw.RoundedBox(16, w * .08 + 20, offy + 20, w * .84 - 40, 260, svault.config.progBgCol)
        draw.RoundedBox(16, w * .08 + 20, offy + 20, (w * .84 - 40) * progress, 260, svault.config.progCol)
        draw.SimpleText((state == VAULT_IDLE and svault.lang.idle) or (state == VAULT_RECOVERING and svault.lang.recovering) or (math.Round(progress * 100) .. "%"), "sVaultPercent", w * .5, offy + 140, svault.config.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        offy = offy + 300 + 40

        draw.SimpleText(svault.lang.info, "sVaultInfoTitle", w * .06 + 40, offy, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetDrawColor(svault.config.iconCol)
        surface.SetMaterial(infoMat)
        surface.DrawTexturedRect(w * .08 + w * .84 - 74, offy + 17, 75, 75)

        offy = offy + ih

        draw.RoundedBox(0, w * .08, offy, w * .84, 18, svault.config.lineCol)
        draw.RoundedBox(0, w * .55, offy, 18, 740, svault.config.lineCol)

        surface.SetDrawColor(svault.config.iconCol)
        surface.SetMaterial(cooldownMat)
        surface.DrawTexturedRect(w * .06 + 40, offy + 170 - 110, 100, 100)
        draw.SimpleText(svault.lang.cooldown, "sVaultInfo", w * .06 + 40 + 100 + 20, offy + 170 - 110, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(cooldown and svault.lang.active or svault.lang.inactive, "sVaultInfo", w * .55 + 18 + 40, offy + 170 - 110, cooldown and svault.config.onCol or svault.config.offCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        surface.SetDrawColor(svault.config.iconCol)
        surface.SetMaterial(playerMat)
        surface.DrawTexturedRect(w * .06 + 40, offy + 170 * 2 - 110, 100, 100)
        draw.SimpleText(svault.lang.players, "sVaultInfo", w * .06 + 40 + 100 + 20, offy + 170 * 2 - 110, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(playerCount .. "/" .. svault.config.minplayers, "sVaultInfo", w * .55 + 18 + 40, offy + 170 * 2 - 110, playerCount >= svault.config.minplayers and svault.config.onCol or svault.config.offCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        surface.SetDrawColor(svault.config.iconCol)
        surface.SetMaterial(valueMat)
        surface.DrawTexturedRect(w * .06 + 40, offy + 170 * 3 - 110, 100, 100)
        draw.SimpleText(svault.lang.totalvalue, "sVaultInfo", w * .06 + 40 + 100 + 20, offy + 170 * 3 - 110, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(DarkRP.formatMoney(self:GetValue()), "sVaultInfo", w * .55 + 18 + 40, offy + 170 * 3 - 110, svault.config.onCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        surface.SetDrawColor(svault.config.iconCol)
        surface.SetMaterial(lawMat)
        surface.DrawTexturedRect(w * .06 + 40, offy + 170 * 4 - 110, 100, 100)
        draw.SimpleText(svault.lang.lawenforcement, "sVaultInfo", w * .06 + 40 + 100 + 20, offy + 170 * 4 - 110, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(policeCount .. "/" .. svault.config.minpolice, "sVaultInfo", w * .55 + 18 + 40, offy + 170 * 4 - 110, policeCount >= svault.config.minpolice and svault.config.onCol or svault.config.offCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.RoundedBox(20, w * .06, offy + 740 - 40, w * .88, 40, svault.config.primaryCol)

        offy = offy + 740 + spacing

        --Current Robbers Box
        surface.SetFont("sVaultRobbersTitle")
        local crh = select(2, surface.GetTextSize(svault.lang.currentrobbers))

        draw.RoundedBox(32, w * .06, offy, w * .88, (h - 100) - offy - spacing, svault.config.boxBgCol)
        draw.RoundedBox(20, w * .06, offy, w * .88, 40, svault.config.primaryCol)
        draw.SimpleText(svault.lang.currentrobbers, "sVaultRobbersTitle", w * .5, offy + crh * .55 + 35, svault.config.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox(20, w * .06, offy + crh * 1.4, w * .88, 40, svault.config.primaryCol)

        surface.SetDrawColor(self.Robbers[1] and svault.config.onCol or svault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + 80, offy + 315, 100, 100)
        draw.SimpleText(self.Robbers[1] and self.Robbers[1] or svault.lang.notapplicable, "sVaultRobber", w * .06 + 40 + 100 + 70, offy + 315 + 50, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[2] and svault.config.onCol or svault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + 80, offy + 490, 100, 100)
        draw.SimpleText(self.Robbers[2] and self.Robbers[2] or svault.lang.notapplicable, "sVaultRobber", w * .06 + 40 + 100 + 70, offy + 490 + 50, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[3] and svault.config.onCol or svault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + 80, offy + 665, 100, 100)
        draw.SimpleText(self.Robbers[3] and self.Robbers[3] or svault.lang.notapplicable, "sVaultRobber", w * .06 + 40 + 100 + 70, offy + 665 + 50, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[4] and svault.config.onCol or svault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + 80, offy + 840, 100, 100)
        draw.SimpleText(self.Robbers[4] and self.Robbers[4] or svault.lang.notapplicable, "sVaultRobber", w * .06 + 40 + 100 + 70, offy + 840 + 50, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[5] and svault.config.onCol or svault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + w * .88 - 1000, offy + 315, 100, 100)
        draw.SimpleText(self.Robbers[5] and self.Robbers[5] or svault.lang.notapplicable, "sVaultRobber", w * .06 + w * .88 - 1000 + 100 + 30, offy + 315 + 50, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[6] and svault.config.onCol or svault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + w * .88 - 1000, offy + 490, 100, 100)
        draw.SimpleText(self.Robbers[6] and self.Robbers[6] or svault.lang.notapplicable, "sVaultRobber", w * .06 + w * .88 - 1000 + 100 + 30, offy + 490 + 50, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[7] and svault.config.onCol or svault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + w * .88 - 1000, offy + 665, 100, 100)
        draw.SimpleText(self.Robbers[7] and self.Robbers[7] or svault.lang.notapplicable, "sVaultRobber", w * .06 + w * .88 - 1000 + 100 + 30, offy + 665 + 50, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(self.Robbers[8] and svault.config.onCol or svault.config.offCol)
        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(w * .06 + w * .88 - 1000, offy + 840, 100, 100)
        draw.SimpleText(self.Robbers[8] and self.Robbers[8] or svault.lang.notapplicable, "sVaultRobber", w * .06 + w * .88 - 1000 + 100 + 30, offy + 840 + 50, svault.config.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.RoundedBox(20, w * .06, offy + (h - 100) - offy - spacing - 40, w * .88, 40, svault.config.primaryCol)
    cam.End3D2D()
end