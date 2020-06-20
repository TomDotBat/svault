
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

surface.CreateFont("sVaultHackingFinishSmall", {
    font = "Consolas",
    size = 38,
    weight = 500,
    antialias = true
})

surface.CreateFont("sVaultHackingFinishLarge", {
    font = "Consolas",
    size = 64,
    weight = 700,
    antialias = true
})

surface.CreateFont("sVaultHackingInstructions", {
    font = "Calibri",
    size = 20,
    weight = 400,
    antialias = true
})

surface.CreateFont("sVaultHackingStopButton", {
    font = "Arial",
    size = 54,
    weight = 700,
    antialias = true
})

function ENT:Initialize()
    self.LocalPlayer = LocalPlayer()

    self.TargetWord = ""
    self.SelectorX = 0
    self.Letters = {}
    self.ColumnOffsets = {}
    self.SelectedColumn = 1
end

local columnHeight = 11
local letterSpacing = 52
function ENT:GenerateWordGrid(word)
    self.TargetWord = word
    self.Letters = {}

    for i = 1, #self.TargetWord do
        local letterpos = math.random(1, columnHeight)
        self.Letters[i] = {}

        for j = 1, columnHeight do
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

net.Receive("sVaultHackerSendTargetWord", function()
    print("asdasd")
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    ent:GenerateWordGrid(net.ReadString())
end)

function ENT:DrawTranslucent()
    self:DrawModel()

    if not svault.lang then return end
    if not self:GetOpened() then return end

    self:DrawScreen()
    self:DrawControls()
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


local menuStartButton = [[╔═══════╗
║  START  ║
╚═══════╝]]

local menuCloseButton = [[╔═══════╗
║  CLOSE  ║
╚═══════╝]]

ENT.Screens = {
    [1] = function(self)
        surface.SetDrawColor(svault.config.hackerBgCol) --BG
        surface.DrawRect(0, 0, w, h)

        surface.SetFont("sVaultHackingName")
        local nameH = select(2, surface.GetTextSize(hackerName))
        local nameY = h * .5 - nameH * .5 + math.sin(CurTime() * 1) * 20 - 60 -- would be kinda hot if we made the text shake on error

        draw.DrawText(hackerName, "sVaultHackingName", w * .5, nameY, svault.config.hackerNameCol, TEXT_ALIGN_CENTER) --Draw that really lit name bro

        surface.SetFont("sVaultHackingButton")
        local startBtnW, btnH = surface.GetTextSize(menuStartButton)
        local closeBtnW = surface.GetTextSize(menuCloseButton)
        local btnsW = startBtnW + closeBtnW + 80
        local startBtnX, btnY = w * .5 - btnsW * .5, h * .5 - btnH * .5 + 165
        local closeBtnX = startBtnX + btnsW - closeBtnW

        draw.DrawText(menuStartButton, "sVaultHackingButton", startBtnX, btnY, HSVToColor((CurTime() * 20) % 360, 1, 1)) --Start Button
        draw.DrawText(menuCloseButton, "sVaultHackingButton", closeBtnX, btnY, HSVToColor((CurTime() * 20) % 360, 1, 1)) --Close Button

        if not imgui.IsPressed() then return end

        if imgui.IsHovering(startBtnX, btnY, startBtnW, btnH) then
            net.Start("sVaultHackerPressStart")
            net.WriteEntity(self)
            net.SendToServer()
        elseif imgui.IsHovering(closeBtnX, btnY, closeBtnW, btnH) then
            net.Start("sVaultHackerPressClose")
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

        local rowTall = columnHeight * letterSpacing
        for columnId, column in ipairs(self.Letters) do --This is where we draw the meaty part of the minigame
            if not self.ColumnOffsets[columnId] then self.ColumnOffsets[columnId] = 0 end

            for letterId, letter in ipairs(column) do
                local col = letter == self.TargetWord[columnId] and svault.config.hackerLetterCorrectCol or svault.config.hackerLetterCol

                local letterY = letterId * letterSpacing + self.ColumnOffsets[columnId]
                if letterY > rowTall then
                    letterY = letterY - rowTall
                end

                draw.SimpleText(letter, "sVaultHackingLetters", columnId * letterSpacing - 24, letterY - 63, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            if columnId == self.SelectedColumn then
                self.ColumnOffsets[columnId] = self.ColumnOffsets[columnId] + FrameTime() * svault.config.hackerscrollspeed

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

        self.SelectorX = Lerp(FrameTime() * 5, self.SelectorX, 3 + (self.SelectedColumn - 1) * 52)

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

        surface.SetFont("sVaultHackingFinishLarge")
        local textH = select(2, surface.GetTextSize(svault.lang.securitydisabled))

        surface.SetFont("sVaultHackingFinishSmall")
        local evidenceText = string.Replace(svault.lang.destroyingevidence, "%s", string.format("%.2f", self:GetSelfDestructTime() - CurTime()) .. "s")
        textH = textH + select(2, surface.GetTextSize(evidenceText))
        textH = textH + select(2, surface.GetTextSize(svault.lang.standback)) + 30

        local textY = h * .5 - textH * .5
        draw.SimpleText(svault.lang.securitydisabled, "sVaultHackingFinishLarge", w * .5, textY, svault.config.hackerFinishTextCol, TEXT_ALIGN_CENTER)
        draw.SimpleText(evidenceText, "sVaultHackingFinishSmall", w * .5, textY + textH / 2 + 10, svault.config.hackerFinishTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(svault.lang.standback, "sVaultHackingFinishSmall", w * .5, textY + textH, ColorAlpha(svault.config.hackerFinishStandBackCol, math.abs(math.sin(CurTime() * 2)) * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end
}

local circleMat = Material("svault/circle.png", "noclamp smooth")

local controlW, controlH = 587, 468
local controlPos = Vector(-9.35, -11.73, 5.73)
local controlAng = Angle(0, 90, 0)
function ENT:DrawControls()
    if imgui.Entity3D2D(self, controlPos, controlAng, 0.04, svault.config.draw3d2ddist, svault.config.draw3d2ddist - 40) then
        draw.RoundedBox(0, 0, 0, controlW, controlH, svault.config.hackerControlBgCol)

        draw.DrawText(svault.lang.hackerinstructions, "sVaultHackingInstructions", 10, 10, svault.config.hackerInstructionsCol)

        if self:GetScreenID() != 2 then
            imgui.End3D2D()
            return
        end

        local btnSize = controlH * .35
        local btnX, btnY = controlW * .5 - btnSize * .5, controlH * .65 - btnSize * .5

        if imgui.IsHovering(btnX, btnY, btnSize, btnSize) then
            surface.SetDrawColor(svault.config.hackerButtonHoverCol)

            if imgui.IsPressed() then
                if self.LocalPlayer != self:GetHacker() then imgui.End3D2D() return end

                local selectedOffset = self.ColumnOffsets[self.SelectedColumn]
                if not selectedOffset then imgui.End3D2D() return end

                self.ColumnOffsets[self.SelectedColumn] = math.floor(selectedOffset / letterSpacing + 0.5) * letterSpacing

                local rowTall = columnHeight * letterSpacing
                local selectedChar
                for k,v in ipairs(self.Letters[self.SelectedColumn]) do
                    local letterY = k * letterSpacing + selectedOffset
                    if letterY > rowTall then
                        letterY = letterY - rowTall
                    end

                    letterY = letterY - 63

                    if letterY < 221.65 or letterY > 273.35 then continue end --Check if we're within the bounds of the two bars
                    selectedChar = v
                    break
                end

                if not selectedChar then imgui.End3D2D() return end

                if selectedChar != self.TargetWord[self.SelectedColumn] then
                    self:GenerateWordGrid(self.TargetWord)
                    imgui.End3D2D()
                    return
                end

                self.SelectedColumn = self.SelectedColumn + 1
            end
        else
            surface.SetDrawColor(svault.config.hackerButtonCol)
        end

        surface.SetMaterial(circleMat)
        surface.DrawTexturedRect(btnX, btnY, btnSize, btnSize)

        draw.SimpleText(svault.lang.hackerstop, "sVaultHackingStopButton", btnX + btnSize * .5, btnY + btnSize * .5, svault.config.hackerButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        imgui.End3D2D()
    end
end