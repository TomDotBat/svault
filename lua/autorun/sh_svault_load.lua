
local folder = "svault"

svault = svault or {}

AddCSLuaFile(folder .. "/config.lua")
include(folder .. "/config.lua")

if !svault.config.language then return end

if file.Exists(folder .. "/lang/" .. svault.config.language .. ".lua", "LUA") then
	svault.lang = include(folder .. "/lang/" .. svault.config.language .. ".lua")
else
	return
end

if SERVER then
	for k, v in pairs(file.Find(folder .. "/lang/*.lua", "LUA")) do
		AddCSLuaFile(folder .. "/lang/" .. v)
	end

	for k, v in pairs(file.Find(folder .. "/client/*.lua", "LUA")) do
		AddCSLuaFile(folder .. "/client/" .. v)
	end

	for k, v in pairs(file.Find(folder .. "/vgui/*.lua", "LUA")) do
		AddCSLuaFile(folder .. "/vgui/" .. v)
	end

	for k, v in pairs(file.Find(folder .. "/server/*.lua", "LUA")) do
		include(folder .. "/server/" .. v)
	end

	resource.AddWorkshop("2143071959")
else
	for k, v in pairs(file.Find(folder .. "/client/*.lua", "LUA")) do
		include(folder .. "/client/" .. v)
	end

	for k, v in pairs(file.Find(folder .. "/vgui/*.lua", "LUA")) do
		include(folder .. "/vgui/" .. v)
	end
end

VAULT_IDLE, VAULT_WARMUP, VAULT_RAIDING, VAULT_OPEN, VAULT_RECOVERING, VAULT_COOLDOWN = 1, 2, 3, 4, 5, 6
RAID_WARMUP, RAID_INPROGRESS, RAID_SUCCESSFUL = 1, 2, 3