
--[[-------------------------------------------------------------------------
OGL Vault Configuration
---------------------------------------------------------------------------]]
ogl_vault.config = {} //Don't touch this line

--[[-------------------------------------------------------------------------
Language
---------------------------------------------------------------------------]]
//Use the file name from the lang folder, make sure to remove the .lua extension
//Currently available languages: english
ogl_vault.config.language = "english"

--[[-------------------------------------------------------------------------
General Settings
---------------------------------------------------------------------------]]
ogl_vault.config.vaultname = "OGL Bank Vault" --The name of the vault on the 3D2D
ogl_vault.config.chatprefix = "[OGL Vault]" --The chat prefix to use for notifications if you're using the chat notification method
ogl_vault.config.notifymethod = 1 --The method used to notify the player 1 = Chat, 2 = Notifications

ogl_vault.config.policeteams = { --The teams that are classified as law enforcement
	["Policeman"] = true
}
ogl_vault.config.canraidteams = false --The teams that can start a raid, set to false for anyone

ogl_vault.config.maxparticipants = 8 --The maximum amount of people taking part in one raid

ogl_vault.config.minplayers = 0 --The minimum amount of players online needed to start a raid
ogl_vault.config.minpolice = 0 --The minimum amount of active police needed to start a raid

ogl_vault.config.maxraidsongoing = 2 --The maximum amount of raids happening at one time
ogl_vault.config.maxprogresstojoin = 30 --The furthest percentage into the raid until joining is no longer allowed

ogl_vault.config.warmuptime = 30 --How long should the warmup period last in seconds?
ogl_vault.config.securitytimer = 10 --How long should the vault wait before alerting police if the security is disabled?
ogl_vault.config.raidbasetime = 30 --What is the minimum time it should take to raid the vault?
ogl_vault.config.raidmembertimemultiplier = 10 --How many extra seconds should be added to the timer per extra raid party member?
ogl_vault.config.cooldowntime = 30 --How long should the cooldown last for after an unsuccessful raid?

ogl_vault.config.maxraiderdist = 300000 --How far should away can you be from the vault before being removed from the party? False to disable

ogl_vault.config.rejoinoutofrange = false --Should a player be allowed to rejoin the raid party (if possible) after going out of range?
ogl_vault.config.rejoindeath = false --Should a player be allowed to rejoin the raid party (if possible) after dying?

ogl_vault.config.policekillreward = 5000 --How much money should a law enforcement member get for killing a raider? False to disable
ogl_vault.config.raiderkilledpenalty = 20 --How much time should be added to the raid timer if a raider is killed? False to disable
ogl_vault.config.friendlykilledpenalty = 10 --How much time should be added on top of the raider kill penalty if their death was friendly fire? False to disable

ogl_vault.config.rewardmembermultiplier = 2000 --How much extra should the police get as a reward per party member when countering the raid successfully?

ogl_vault.config.dropmoney = false --Should we drop the money in front of the bank instead of giving the split to players directly?

ogl_vault.config.draw3d2ddist = 480000 --What should be the maximum distance from the vault that you can see the 3D2D at?

ogl_vault.config.preventphysgun = true --Should we prevent permanent vaults from being physgunned?
ogl_vault.config.preventtoolgun = true --Should we prevent permanent vaults from being toolgunned?

--[[-------------------------------------------------------------------------
Resource Settings
---------------------------------------------------------------------------]]
ogl_vault.config.usefastdl = false //Should the content be added to fast dl?
ogl_vault.config.useworkshopdl = false //Should the content be added to force download?

--[[-------------------------------------------------------------------------
Colour Settings
---------------------------------------------------------------------------]]
ogl_vault.config.chatPrefixCol = Color(215, 80, 80) //Chat prefix colour
ogl_vault.config.chatMessageCol = Color(255, 255, 255) //Chat message colour

ogl_vault.config.primaryCol = Color(194, 51, 51) //3D2D primary color
ogl_vault.config.bgCol = Color(64, 64, 64) //3D2D background color
ogl_vault.config.secondBgCol = Color(88, 88, 88) //3D2D secondary background color
ogl_vault.config.boxBgCol = Color(58, 58, 58) //3D2D box background color
ogl_vault.config.textCol = Color(255, 255, 255) //3D2D text color
ogl_vault.config.onCol = Color(63, 199, 53) //3D2D on text color
ogl_vault.config.offCol = Color(172, 50, 55) //3D2D off text color
ogl_vault.config.iconCol = Color(255, 255, 255) //3D2D icon color
ogl_vault.config.lineCol = Color(255, 255, 255) //3D2D line color
ogl_vault.config.warningCol = Color(220, 62, 62) //3D2D security system text and icon warning color
ogl_vault.config.progBgCol = Color(68, 68, 68) //3D2D progress bar background color
ogl_vault.config.progCol = Color(236, 59, 59) //3D2D progress bar main color

--[[-------------------------------------------------------------------------
End of OGL Vault Configuration
---------------------------------------------------------------------------]]