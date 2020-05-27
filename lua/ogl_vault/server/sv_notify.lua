
local meta = FindMetaTable("Player")

function meta:OGLVaultNotify(msg)
	if !isstring(msg) then return end

	net.Start("OGLVaultNotify")
	 net.WriteString(msg)
	net.Send(self)
end

util.AddNetworkString("OGLVaultNotify")