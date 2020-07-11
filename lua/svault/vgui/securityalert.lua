
local PANEL = {}

function PANEL:Init()
    self.Title = svault.lang.securityalert
    self:CreateCloseButton()
    self:CreateActionButton(svault.lang.counterraid, svault.config.counterButtonCol, svault.config.counterButtonHoverCol, function()
        chat.AddText("poop")
    end)
end

local scrh = ScrH()
local function screenScale(value)
    return scrh / 1080 * value
end

surface.CreateFont("sVault.RaidCounterTitle", {
    font = "Montserrat SemiBold",
    size = screenScale(40),
    weight = 500,
    antialias = true
})

surface.CreateFont("sVault.RaidCounterMessage", {
    font = "Montserrat Medium",
    size = screenScale(22),
    weight = 500,
    antialias = true
})

function PANEL:DrawContents(x, y, w, h)
    local yOff = screenScale(4)
    local centerX = x + w / 2
    local titleH = select(2, draw.SimpleText(svault.lang.raidcountertitle, "sVault.RaidCounterTitle", centerX, y + yOff, color_white, TEXT_ALIGN_CENTER))
    draw.DrawText(svault.lang.raidcountermessage, "sVault.RaidCounterMessage", centerX, y + yOff + titleH, color_white, TEXT_ALIGN_CENTER)
end

vgui.Register("sVault.SecurityAlert", PANEL, "sVault.Frame")