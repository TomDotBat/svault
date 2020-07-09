
local PANEL = {}

local scrh = ScrH()
local function screenScale(value)
    return scrh / 1080 * value
end

surface.CreateFont("sVault.FrameTitle", {
    font = "Montserrat SemiBold",
    size = screenScale(28),
    weight = 500,
    antialias = true
})

function PANEL:Init()
    local size = screenScale(250)
    self:SetSize(size, size)
    self:SetPos(ScrW() - size - screenScale(30), ScrH() / 2 - size / 2)

    self.Title = "INVALID TITLE"
end

local closeMat = Material("svault/close.png", "noclamp smooth")

function PANEL:CreateCloseButton()
    self.Close = vgui.Create("DButton", self)
    self.Close:SetText("")
    self.Close.DoClick = function()
        self:Remove()
    end

    self.Close.Paint = function(s, w, h)
        surface.SetMaterial(closeMat)
        surface.SetDrawColor(s:IsHovered() and svault.config.closeButtonHoverCol or svault.config.closeButtonCol)
        surface.DrawTexturedRect(0, 0, w, h)
    end
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.Close) then
        local closeSize = screenScale(20)
        local closePad = screenScale(10)
        self.Close:SetSize(closeSize, closeSize)
        self.Close:SetPos(w - closeSize - closePad, closePad)
    end
end

function PANEL:DrawContents(x, y, w, h) end

function PANEL:Paint(w, h)
    draw.RoundedBox(screenScale(8), 0, 0, w, h, svault.config.uiBackgroundCol)

    local headerH = screenScale(40)
    draw.RoundedBoxEx(screenScale(8), 0, 0, w, headerH, svault.config.uiHeaderCol, true, true)
    draw.SimpleText(self.Title, "sVault.FrameTitle", screenScale(9), headerH * .45, svault.config.uiTitleCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("sVault.Frame", PANEL, "EditablePanel")

if not IsValid(LocalPlayer()) then return end

if IsValid(testPanel) then
    testPanel:Remove()
end

testPanel = vgui.Create("sVault.SecurityAlert")