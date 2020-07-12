
local circleMat = Material("svault/circle.png", "noclamp smooth")

local scrh = ScrH()
local function screenScale(value)
    return scrh / 1080 * value
end

surface.CreateFont("sVault.VaultWaypoint", {
    font = "Montserrat SemiBold",
    size = screenScale(24),
    weight = 500,
    antialias = true
})

local localPly

hook.Add("HUDPaint", "sVaultShowVaultLocation", function()
    if not svault.targetvault then return end

    if not localPly then localPly = LocalPlayer() end
    if localPly:GetPos():DistToSqr(svault.targetvault) < 640000 then return end

    local pos = svault.targetvault:ToScreen()
    local x, y = pos.x, pos.y

    local dotSize = screenScale(10)

    surface.SetMaterial(circleMat)
    surface.SetDrawColor(svault.config.waypointDotCol)
    surface.DrawTexturedRect(x - dotSize / 2, y - dotSize / 2, dotSize, dotSize)

    surface.SetFont("sVault.VaultWaypoint")
    local textW, textH = surface.GetTextSize(svault.lang.waypoint)

    textW = textW + screenScale(10)
    textH = textH + screenScale(2)

    draw.RoundedBox(screenScale(6), x - textW / 2, y + dotSize + screenScale(4), textW, textH, svault.config.waypointBackgroundCol)
    draw.SimpleText(svault.lang.waypoint, "sVault.VaultWaypoint", x, y + dotSize + screenScale(4), svault.config.waypointTextCol, TEXT_ALIGN_CENTER)
end)