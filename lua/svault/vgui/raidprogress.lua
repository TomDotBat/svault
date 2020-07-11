
local PANEL = {}

function PANEL:Init()
    self.Title = svault.lang.securityalert
    self:CreateActionButton(svault.lang.leaveraid, svault.config.leaveButtonCol, svault.config.leaveButtonHoverCol, function()
        chat.AddText("poop")
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

    msg = string.Replace(msg, "#l", 8)
    msg = string.Replace(msg, "#j", 5)
    msg = string.Replace(msg, "#t", formatTime(10000))

    draw.DrawText(msg, "sVault.RaidProgress", x + w / 2, y + h / 2 - msgH / 2, color_white, TEXT_ALIGN_CENTER)
end

vgui.Register("sVault.RaidProgress", PANEL, "sVault.Frame")

if not IsValid(LocalPlayer()) then return end

if IsValid(testPanel) then
    testPanel:Remove()
end

testPanel = vgui.Create("sVault.RaidProgress")