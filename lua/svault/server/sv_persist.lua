
file.CreateDir("svault")

local function spawnVaults()
	if !file.Exists("svault/" .. game.GetMap() .. ".txt", "DATA") then return end

	local vaults = util.JSONToTable(file.Read("svault/" .. game.GetMap() .. ".txt", "DATA"))
	if !vaults then return end

	for k,v in ipairs(vaults) do
		local newVault = ents.Create("svault")
		newVault:SetPos(v.pos)
		newVault:SetAngles(v.ang)
		newVault:Spawn()
		newVault.sVaultPersist = true

		local phys = newVault:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
end
hook.Add("InitPostEntity", "sVaultPersist", spawnVaults)
hook.Add("PostCleanupMap", "sVaultPersist", spawnVaults)

hook.Add("PlayerSay", "sVaultPersist", function(ply, text, team)
	if string.Left(string.lower(text), #svault.lang.savevaultscmd) == svault.lang.savevaultscmd then
		if !ply:IsSuperAdmin() then ply:sVaultNotify(svault.lang.nopermission) return "" end

		local vaults = {}
		for k,v in ipairs(ents.FindByClass("svault")) do
			vaults[k] = {pos = v:GetPos(), ang = v:GetAngles()}
			v:Remove()
		end

		file.Write("svault/" .. game.GetMap() .. ".txt", util.TableToJSON(vaults))
		spawnVaults()
		ply:sVaultNotify(svault.lang.savedvaults)
		return ""
	elseif string.Left(string.lower(text), #svault.lang.clearvaultscmd) == svault.lang.clearvaultscmd then
		if !ply:IsSuperAdmin() then ply:sVaultNotify(svault.lang.nopermission) return "" end

		for k,v in ipairs(ents.FindByClass("svault")) do
			v:Remove()
		end

		file.Write("svault/" .. game.GetMap() .. ".txt", "[]")

		ply:sVaultNotify(svault.lang.removedvaults)
		return ""
	end
end)

hook.Add("CanTool", "sVaultPersist", function(ply, tr, tool)
	if !tr.Entity then return end
	if tr.Entity:GetClass() != "svault" then return end
	if svault.config.preventtoolgun and tr.Entity.sVaultPersist then return false end
end)

hook.Add("PhysgunPickup", "sVaultPersist", function(ply, ent)
	if ent:GetClass() != "svault" then return end
	if svault.config.preventphysgun and ent.sVaultPersist then return false end
end)