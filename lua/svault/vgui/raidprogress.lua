
local PANEL = {}

function PANEL:Init()
    self.Title = svault.lang.securityalert
    self:CreateActionButton(svault.lang.leaveraid, svault.config.leaveButtonCol, svault.config.leaveButtonHoverCol, function()
        net.Start("sVaultCounterLeave")
         net.WriteUInt(self.counterID, 4)
        net.SendToServer()
    end)
end

surface.CreateFont("sVault.RaidProgress", {
    font = "Montserrat SemiBold",
    size = ScrH() / 1080 * 28,
    weight = 500,
    antialias = true
})

local function formatTime(time)
    local s = time % 60
    time = math.floor(time / 60)

    return string.format("%02i:%02i", time % 60, s)
end

function PANEL:DrawContents(x, y, w, h)
    local msg = svault.lang.raidprogressmessage

    surface.SetFont("sVault.RaidProgress")
    local msgH = select(2, surface.GetTextSize(msg))

    if not IsValid(svault.countervault) then
        msg = string.Replace(msg, "#l", "???")
        msg = string.Replace(msg, "#j", "???")
        msg = string.Replace(msg, "#t", "??:??")
    else
        msg = string.Replace(msg, "#l", #svault.countervault.Robbers)
        msg = string.Replace(msg, "#j", 5)
        msg = string.Replace(msg, "#t", formatTime(self:GetTimerEnd()))
    end

    draw.DrawText(msg, "sVault.RaidProgress", x + w / 2, y + h / 2 - msgH / 2, color_white, TEXT_ALIGN_CENTER)
end

vgui.Register("sVault.RaidProgress", PANEL, "sVault.Frame")

net.Receive("sVaultCounterOpenProgress", function()
    if IsValid(svault.raidprogress) then
        svault.raidprogress:Remove()
        svault.raidprogress = nil
    end

    local counterID = net.ReadUInt(4)
    svault.targetvault = net.ReadVector()

    if counterID == 0 then
        svault.targetvault = false
        return
    end

    svault.countervault = net.ReadEntity()

    svault.raidprogress = vgui.Create("sVault.RaidProgress")
    svault.raidprogress.counterID = counterID
end)