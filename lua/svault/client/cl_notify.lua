
net.Receive("sVaultNotify", function(len)
	if svault.config.notifymethod == 1 then
		chat.AddText(svault.config.chatPrefixCol, svault.config.chatprefix, svault.config.chatMessageCol, " " .. net.ReadString())
	elseif svault.config.notifymethod == 2 then
		surface.PlaySound("buttons/button14.wav")
		notification.AddLegacy(net.ReadString(), NOTIFY_GENERIC, 5)
	end
end)