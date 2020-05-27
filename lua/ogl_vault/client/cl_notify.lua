
net.Receive("OGLVaultNotify", function(len)
	if ogl_vault.config.notifymethod == 1 then
		chat.AddText(ogl_vault.config.chatPrefixCol, ogl_vault.config.chatprefix, ogl_vault.config.chatMessageCol, " " .. net.ReadString())
	elseif ogl_vault.config.notifymethod == 2 then
		surface.PlaySound("buttons/button14.wav")
		notification.AddLegacy(net.ReadString(), NOTIFY_GENERIC, 5)
	end
end)