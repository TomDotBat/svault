
file.CreateDir("ogl_vault")

local function spawnVaults()
	if !file.Exists("ogl_vault/" .. game.GetMap() .. ".txt", "DATA") then return end

	local vaults = util.JSONToTable(file.Read("ogl_vault/" .. game.GetMap() .. ".txt", "DATA"))
	if !vaults then return end

	for k,v in ipairs(vaults) do
		local newVault = ents.Create("ogl_vault")
		newVault:SetPos(v.pos)
		newVault:SetAngles(v.ang)
		newVault:Spawn()
		newVault.OGLVaultPersist = true

		local phys = newVault:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
end
hook.Add("InitPostEntity", "OGLVaultPersist", spawnVaults)
hook.Add("PostCleanupMap", "OGLVaultPersist", spawnVaults)

hook.Add("PlayerSay", "OGLVaultPersist", function(ply, text, team)
	if string.Left(string.lower(text), #ogl_vault.lang.savevaultscmd) == ogl_vault.lang.savevaultscmd then
		if !ply:IsSuperAdmin() then ply:OGLVaultNotify(ogl_vault.lang.nopermission) return "" end

		local vaults = {}
		for k,v in ipairs(ents.FindByClass("ogl_vault")) do
			vaults[k] = {pos = v:GetPos(), ang = v:GetAngles()}
			v:Remove()
		end

		file.Write("ogl_vault/" .. game.GetMap() .. ".txt", util.TableToJSON(vaults))
		spawnVaults()
		ply:OGLVaultNotify(ogl_vault.lang.savedvaults)
		return ""
	elseif string.Left(string.lower(text), #ogl_vault.lang.clearvaultscmd) == ogl_vault.lang.clearvaultscmd then
		if !ply:IsSuperAdmin() then ply:OGLVaultNotify(ogl_vault.lang.nopermission) return "" end

		for k,v in ipairs(ents.FindByClass("ogl_vault")) do
			v:Remove()
		end

		file.Write("ogl_vault/" .. game.GetMap() .. ".txt", "[]")

		ply:OGLVaultNotify(ogl_vault.lang.removedvaults)
		return ""
	end
end)

hook.Add("CanTool", "OGLVaultPersist", function(ply, tr, tool)
	if !tr.Entity then return end
	if tr.Entity:GetClass() != "ogl_vault" then return end
	if ogl_vault.config.preventtoolgun and tr.Entity.OGLVaultPersist then return false end
end)

hook.Add("PhysgunPickup", "OGLVaultPersist", function(ply, ent)
	if ent:GetClass() != "ogl_vault" then return end
	if ogl_vault.config.preventphysgun and ent.OGLVaultPersist then return false end
end)