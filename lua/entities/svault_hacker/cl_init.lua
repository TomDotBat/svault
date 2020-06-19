
include("shared.lua")

local imgui = include("svault/client/cl_imgui.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

surface.CreateFont("sVaultHackingName", {
    font = "Consolas",
    size = 14,
    weight = 400,
    antialias = true
})

surface.CreateFont("sVaultHackingButton", {
    font = "Consolas",
    size = 24,
    weight = 400,
    antialias = true
})

surface.CreateFont("sVaultHackingLetters", {
    font = "Consolas",
    size = 46,
    weight = 500,
    antialias = true
})

local columnheight = 11

function ENT:Initialize()
    self.LocalPlayer = LocalPlayer()
end

local done = false
function ENT:Think()
    if done then return end
    done = true
    self.SelectorX = 0

    self.TargetWord = svault.HackingWords[math.random(1, #svault.HackingWords)]

    self.Letters = {}

    for i = 1, #self.TargetWord do
        local letterpos = math.random(1, columnheight)
        self.Letters[i] = {}

        for j = 1, columnheight do
            if j == letterpos then
                self.Letters[i][j] = self.TargetWord[i]
                continue
            end

            self.Letters[i][j] = string.char(math.random(65, 90))
        end
    end

    self.ColumnOffsets = {}

    self.SelectedColumn = 1
end

function ENT:DrawTranslucent()
    self:DrawModel()

    if not svault.lang then return end
    if not self:GetOpened() then return end

    self:DrawScreen()
end

function ENT:DrawScreen()
    local pos, ang = self:GetBonePosition(1)

    ang = self:WorldToLocalAngles(ang)

    pos = self:WorldToLocal(pos) + ang:Up() * -22.42
    pos = pos + ang:Forward() * 1.14
    pos = pos + ang:Right() * 5.74

    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), 90)

    if imgui.Entity3D2D(self, pos, ang, 0.04, svault.config.draw3d2ddist, svault.config.draw3d2ddist - 40) then
        local screenID = self:GetScreenID()
        if not self.Screens[screenID] then return end

        self.Screens[screenID](self)
        imgui.End3D2D()
    end
end

local gradientDownMat = Material("gui/gradient_down", "noclamp smooth")
local gradientUpMat = Material("gui/gradient_up", "noclamp smooth")

local w, h = 630, 497

local scrollspeed = 120
local spacing = 52

local function startCutOut(drawMask)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilReferenceValue(1)
    render.OverrideColorWriteEnable(true, false)

    drawMask()

    render.OverrideColorWriteEnable(false, false)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
end

local function finishCutOut()
    render.SetStencilEnable(false)
end

local hackerName = [[ $$$$$$\  $$$$$$$$\  $$$$$$\  $$\   $$\ $$$$$$$\  $$$$$$\ $$$$$$$$\ $$\     $$\ 
$$  __$$\ $$  _____|$$  __$$\ $$ |  $$ |$$  __$$\ \_$$  _|\__$$  __|\$$\   $$  |
$$ /  \__|$$ |      $$ /  \__|$$ |  $$ |$$ |  $$ |  $$ |     $$ |    \$$\ $$  / 
\$$$$$$\  $$$$$\    $$ |      $$ |  $$ |$$$$$$$  |  $$ |     $$ |     \$$$$  /  
 \____$$\ $$  __|   $$ |      $$ |  $$ |$$  __$$<   $$ |     $$ |      \$$  /   
$$\   $$ |$$ |      $$ |  $$\ $$ |  $$ |$$ |  $$ |  $$ |     $$ |       $$ |    
\$$$$$$  |$$$$$$$$\ \$$$$$$  |\$$$$$$  |$$ |  $$ |$$$$$$\    $$ |       $$ |    
 \______/ \________| \______/  \______/ \__|  \__|\______|   \__|       \__|    
                                                                                
                                                                                
                                                                                
      $$$$$$\  $$\      $$\  $$$$$$\   $$$$$$\  $$\   $$\ $$$$$$$$\ $$$$$$$\         
     $$  __$$\ $$$\    $$$ |$$  __$$\ $$  __$$\ $$ |  $$ |$$  _____|$$  __$$\        
     $$ /  \__|$$$$\  $$$$ |$$ /  $$ |$$ /  \__|$$ |  $$ |$$ |      $$ |  $$ |       
     \$$$$$$\  $$\$$\$$ $$ |$$$$$$$$ |\$$$$$$\  $$$$$$$$ |$$$$$\    $$$$$$$  |       
      \____$$\ $$ \$$$  $$ |$$  __$$ | \____$$\ $$  __$$ |$$  __|   $$  __$$<        
     $$\   $$ |$$ |\$  /$$ |$$ |  $$ |$$\   $$ |$$ |  $$ |$$ |      $$ |  $$ |       
     \$$$$$$  |$$ | \_/ $$ |$$ |  $$ |\$$$$$$  |$$ |  $$ |$$$$$$$$\ $$ |  $$ |       
      \______/ \__|     \__|\__|  \__| \______/ \__|  \__|\________|\__|  \__|       ]]


local hackerButton = [[╔═══════╗
║  START  ║
╚═══════╝]]

ENT.Screens = {
    [1] = function(self)
        surface.SetDrawColor(svault.config.hackerBgCol) --BG
        surface.DrawRect(0, 0, w, h)

        surface.SetFont("sVaultHackingName")
        local nameH = select(2, surface.GetTextSize(hackerName))
        local nameY = h * .5 - nameH * .5 + math.sin(CurTime() * 1) * 20 - 60

        draw.DrawText(hackerName, "sVaultHackingName", w * .5, nameY, svault.config.hackerNameCol, TEXT_ALIGN_CENTER) --Draw that really lit name bro

        surface.SetFont("sVaultHackingButton")
        local btnW, btnH = surface.GetTextSize(hackerButton)
        local btnX, btnY = w * .5 - btnW * .5, h * .5 - btnH * .5 + 165

        draw.DrawText(hackerButton, "sVaultHackingButton", btnX, btnY, HSVToColor((CurTime() * 20) % 360, 1, 1)) --Draw the button

        if imgui.IsPressed() and imgui.IsHovering(btnX, btnY, btnW, btnH) then
            net.Start("sVaultHackerPressStart")
             net.WriteEntity(self)
            net.SendToServer()
        end
    end,
    [2] = function(self)
        startCutOut(function()
            surface.SetDrawColor(255, 255, 255)
            surface.DrawRect(0, 0, w, h)
        end)

        surface.SetDrawColor(svault.config.hackerBgCol) --BG
        surface.DrawRect(0, 0, w, h)

        local rowTall = columnheight * spacing
        for columnId, column in ipairs(self.Letters) do --This is where we draw the meaty part of the minigame
            if not self.ColumnOffsets[columnId] then self.ColumnOffsets[columnId] = 0 end

            for letterId, letter in ipairs(column) do
                local col = letter == self.TargetWord[columnId] and svault.config.hackerLetterCorrectCol or svault.config.hackerLetterCol

                local letterY = letterId * spacing + self.ColumnOffsets[columnId]
                if letterY > rowTall then
                    letterY = letterY - rowTall
                end

                draw.SimpleText(letter, "sVaultHackingLetters", columnId * spacing - 24, letterY - 63, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            if columnId == self.SelectedColumn then
                self.ColumnOffsets[columnId] = self.ColumnOffsets[columnId] + FrameTime() * scrollspeed

                if self.ColumnOffsets[columnId] >= rowTall then
                    self.ColumnOffsets[columnId] = 0
                end
            end
        end

        local selectorW = 2
        local selectorsH = selectorW * 2 + h * .1
        local selectorY = h * .5 - selectorsH * .5
        surface.SetDrawColor(svault.config.hackerSelectorCol)
        surface.DrawRect(0, selectorY, w, selectorW) --Top Horizontal Bar
        surface.DrawRect(0, selectorY + selectorsH - selectorW, w, selectorW) --Bottom Horizontal Bar

        self.SelectorX = Lerp(FrameTime() * 5, self.SelectorX, 3)

        local selectorX = self.SelectorX
        surface.DrawRect(selectorX, 0, selectorW, h) --Left Selector Bar
        surface.DrawRect(selectorX + h * .1, 0, selectorW, h) --Right Selector Bar

        local gradientH = h * .49
        surface.SetMaterial(gradientDownMat) --Top Gradient
        surface.SetDrawColor(svault.config.hackerGradientCol)
        surface.DrawTexturedRect(0, -1, w, gradientH)

        surface.SetMaterial(gradientUpMat) --Bottom Gradient
        surface.SetDrawColor(svault.config.hackerGradientCol)
        surface.DrawTexturedRect(0, h - gradientH + 2, w, gradientH)

        finishCutOut()
    end,
    [3] = function(self)
        surface.SetDrawColor(svault.config.hackerBgCol) --BG
        surface.DrawRect(0, 0, w, h)

        --Security disabled,
        --Destroying evidence, in 10s
        --please stand back

    end
}