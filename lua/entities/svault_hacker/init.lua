
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/ogl/ogl_securitysystem.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end
end

function ENT:Think()
    self:NextThink(CurTime())
    return true
end

function ENT:SetHacker(ply)
    self:Setowning_ent(ply)
    self:CPPISetOwner(ply)
end

hook.Add("playerBoughtCustomEntity", "sVaultSetHacker", function(ply, enttbl, ent, price)
    if ent:GetClass() != "svault_hacker" then return end
    ent:SetHacker(ply)
end)

function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if ply != self:GetHacker() then return end
    if self:GetOpened() then return end

    self:SetOpened(true)
    self:ResetSequence(1)
end

function ENT:SelfDestruct(skipTimer)
    if not skipTimer then
        self:SetScreenID(3)
        self:SetSelfDestructTime(CurTime() + svault.config.hackerselfdestructtime)

        timer.Create("sVault.HackerSelfDestruct:" .. self:EntIndex(), svault.config.hackerselfdestructtime, 1, function()
            if not IsValid(self) then return end
            self:SelfDestruct(true)
        end)
        return
    end

    local pos = self:GetPos()

    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    util.Effect("HelicopterMegaBomb", effectdata, false, true)

    self:EmitSound("BaseExplosionEffect.Sound")

    util.ScreenShake(pos, 2, 3, .5, 500)

    if svault.config.hackerexplosiondamage then
        util.BlastDamage(self, self, pos, 90, 10)
    end

    SafeRemoveEntity(self)
end

local function sendHackWord(ent)
    local word = svault.GetRandomHackingWord()

    net.Start("sVaultHackerSendTargetWord")
     net.WriteEntity(ent)
     net.WriteString(word)
    net.SendPVS(ent:GetPos())

    net.Start("sVaultHackerSendTargetWord")
     net.WriteEntity(ent)
     net.WriteString(word)
    net.Send(ent:GetHacker())

    return word
end

net.Receive("sVaultHackerPressStart", function(len, ply)
    local ent = net.ReadEntity()
    if ent:GetClass() != "svault_hacker" then return end
    if ent:GetHacker() != ply then return end
    if ent:GetPos():DistToSqr(ply:GetPos()) > 10000 then return end
    if ent:GetScreenID() != 1 then return end

    local targetVault = net.ReadEntity()
    if targetVault:GetClass() != "svault" then return end
    if ent:GetPos():DistToSqr(targetVault:GetPos()) > svault.config.hackernearbyvaultdist ^ 2 then return end
    if targetVault:GetState() != VAULT_IDLE then return end

    ent.TargetWord = sendHackWord(ent)
    ent.HackStart = CurTime()
    ent.TargetVault = targetVault

    ent:SetScreenID(2)
end)

net.Receive("sVaultHackerPressClose", function(len, ply)
    local ent = net.ReadEntity()
    if ent:GetClass() != "svault_hacker" then return end
    if ent:GetHacker() != ply then return end
    if ent:GetPos():DistToSqr(ply:GetPos()) > 10000 then return end
    if ent:GetScreenID() != 1 then return end

    ent:ResetSequence(0)
    timer.Simple(1, function() --Turn off the screen once fully closed
        if not IsValid(ent) then return end
        ent:SetOpened(false)
    end)
end)


net.Receive("sVaultHackerCompleteHack", function(len, ply)
    local ent = net.ReadEntity()
    if ent:GetClass() != "svault_hacker" then return end
    if ent:GetHacker() != ply then return end
    if ent:GetPos():DistToSqr(ply:GetPos()) > 10000 then return end
    if ent:GetScreenID() != 2 then return end
    if not ent.TargetWord then return end
    if not ent.HackStart then return end
    if not (ent.TargetVault and IsValid(ent.TargetVault)) then return end
    if ent.HackStart + svault.config.hackerminhacktime > CurTime() then return end
    if ent.TargetWord != net.ReadString() then return end

    ent:SelfDestruct()
    ent.TargetVault:HackVault()
end)

util.AddNetworkString("sVaultHackerPressStart")
util.AddNetworkString("sVaultHackerPressClose")
util.AddNetworkString("sVaultHackerSendTargetWord")
util.AddNetworkString("sVaultHackerCompleteHack")