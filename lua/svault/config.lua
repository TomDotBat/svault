
--[[-------------------------------------------------------------------------
sVault Configuration
---------------------------------------------------------------------------]]
svault.config = {} --Don't touch this line

--[[-------------------------------------------------------------------------
Language
---------------------------------------------------------------------------]]
--/Use the file name from the lang folder, make sure to remove the .lua extension
--/Currently available languages: english
svault.config.language = "english"

--[[-------------------------------------------------------------------------
General Settings
---------------------------------------------------------------------------]]
svault.config.vaultname = "Bank Vault" --The name of the vault on the 3D2D
svault.config.chatprefix = "[sVault]" --The chat prefix to use for notifications if you're using the chat notification method
svault.config.notifymethod = 1 --The method used to notify the player 1 = Chat, 2 = Notifications

svault.config.policeteams = { --The teams that are classified as law enforcement
	["Policeman"] = true
}
svault.config.canraidteams = false --The teams that can start a raid, set to false for anyone

svault.config.maxparticipants = 8 --The maximum amount of people taking part in one raid

svault.config.minplayers = 0 --The minimum amount of players online needed to start a raid
svault.config.minpolice = 0 --The minimum amount of active police needed to start a raid

svault.config.maxraidsongoing = 2 --The maximum amount of raids happening at one time
svault.config.maxprogresstojoin = 30 --The furthest percentage into the raid until joining is no longer allowed

svault.config.warmuptime = 30 --How long should the warmup period last in seconds?
svault.config.securitytimer = 10 --How long should the vault wait before alerting police if the security is disabled?
svault.config.raidbasetime = 30 --What is the minimum time it should take to raid the vault?
svault.config.raidmembertimemultiplier = 10 --How many extra seconds should be added to the timer per extra raid party member?
svault.config.cooldowntime = 30 --How long should the cooldown last for after an unsuccessful raid?

svault.config.maxraiderdist = 300000 --How far should away can you be from the vault before being removed from the party? False to disable

svault.config.rejoinoutofrange = false --Should a player be allowed to rejoin the raid party (if possible) after going out of range?
svault.config.rejoindeath = false --Should a player be allowed to rejoin the raid party (if possible) after dying?

svault.config.policekillreward = 5000 --How much money should a law enforcement member get for killing a raider? False to disable
svault.config.raiderkilledpenalty = 20 --How much time should be added to the raid timer if a raider is killed? False to disable
svault.config.friendlykilledpenalty = 10 --How much time should be added on top of the raider kill penalty if their death was friendly fire? False to disable

svault.config.rewardmembermultiplier = 2000 --How much extra should the police get as a reward per party member when countering the raid successfully?

svault.config.dropmoney = false --Should we drop the money in front of the bank instead of giving the split to players directly?

svault.config.draw3d2ddist = 690 --What should be the maximum distance from the vault that you can see the 3D2D at?

svault.config.preventphysgun = true --Should we prevent permanent vaults from being physgunned?
svault.config.preventtoolgun = true --Should we prevent permanent vaults from being toolgunned?

--[[-------------------------------------------------------------------------
Resource Settings
---------------------------------------------------------------------------]]
svault.config.usefastdl = false --Should the content be added to fast dl?
svault.config.useworkshopdl = false --Should the content be added to force download?

--[[-------------------------------------------------------------------------
Colour Settings
---------------------------------------------------------------------------]]
svault.config.chatPrefixCol = Color(215, 80, 80) --Chat prefix colour
svault.config.chatMessageCol = Color(255, 255, 255) --Chat message colour

svault.config.primaryCol = Color(194, 51, 51) --3D2D primary color
svault.config.bgCol = Color(64, 64, 64) --3D2D background color
svault.config.secondBgCol = Color(88, 88, 88) --3D2D secondary background color
svault.config.boxBgCol = Color(58, 58, 58) --3D2D box background color
svault.config.textCol = Color(255, 255, 255) --3D2D text color
svault.config.onCol = Color(63, 199, 53) --3D2D on text color
svault.config.offCol = Color(172, 50, 55) --3D2D off text color
svault.config.iconCol = Color(255, 255, 255) --3D2D icon color
svault.config.lineCol = Color(255, 255, 255) --3D2D line color
svault.config.warningCol = Color(220, 62, 62) --3D2D security system text and icon warning color
svault.config.progBgCol = Color(68, 68, 68) --3D2D progress bar background color
svault.config.progCol = Color(236, 59, 59) --3D2D progress bar main color

--[[-------------------------------------------------------------------------
End of sVault Configuration
---------------------------------------------------------------------------]]