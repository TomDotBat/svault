
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

surface.CreateFont("sVault.ActionButtion", {
    font = "Montserrat SemiBold",
    size = screenScale(34),
    weight = 500,
    antialias = true
})

function PANEL:Init()
    local size = screenScale(220)
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

function PANEL:CreateActionButton(text, col, hoverCol, doClick)
    self.Button = vgui.Create("DButton", self)
    self.Button:SetText("")
    function self.Button:Paint(w, h)
        draw.RoundedBox(screenScale(6), 0, 0, w, h, self:IsHovered() and hoverCol or col)
        draw.SimpleText(text, "sVault.ActionButtion", w / 2, h * .48, svault.config.actionButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.Button.DoClick = doClick
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.Close) then
        local closeSize = screenScale(20)
        local closePad = screenScale(10)
        self.Close:SetSize(closeSize, closeSize)
        self.Close:SetPos(w - closeSize - closePad, closePad)
    end

    if IsValid(self.Button) then
        local buttonH = screenScale(55)
        self.Button:SetSize(w * .9, buttonH)
        self.Button:SetPos(w * .05, h - buttonH - screenScale(14))
    end
end

function PANEL:DrawContents(x, y, w, h) end

function PANEL:Paint(w, h)
    draw.RoundedBox(screenScale(8), 0, 0, w, h, svault.config.uiBackgroundCol)

    local headerH = screenScale(40)
    draw.RoundedBoxEx(screenScale(8), 0, 0, w, headerH, svault.config.uiHeaderCol, true, true)
    draw.SimpleText(self.Title, "sVault.FrameTitle", screenScale(9), headerH * .45, svault.config.uiTitleCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    self:DrawContents(w * .05, headerH + h * .04, w * .9, h * .48)
end

vgui.Register("sVault.Frame", PANEL, "EditablePanel")