
local PANEL = {}

function PANEL:Init()
    self.Title = svault.lang.securityalert
    self:CreateCloseButton()
end



vgui.Register("sVault.SecurityAlert", PANEL, "sVault.Frame")