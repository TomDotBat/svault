
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
    if self.Setowning_ent then
        self:Setowning_ent(ply)
    end

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

net.Receive("sVaultHackerPressStart", function(len, ply)
    local ent = net.ReadEntity()
    if ent:GetClass() != "svault_hacker" then return end
    if ent:GetPos():DistToSqr(ply:GetPos()) > 10000 then return end
    if ent:GetScreenID() != 1 then return end
    if ent:GetHacker() != ply then return end

    ent:SetScreenID(2)
end)

util.AddNetworkString("sVaultHackerPressStart")