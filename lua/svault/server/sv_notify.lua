
local meta = FindMetaTable("Player")

function meta:sVaultNotify(msg)
	if !isstring(msg) then return end

	net.Start("sVaultNotify")
	 net.WriteString(msg)
	net.Send(self)
end

util.AddNetworkString("sVaultNotify")