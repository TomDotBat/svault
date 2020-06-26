
--[[-------------------------------------------------------------------------
sVault Configuration
---------------------------------------------------------------------------]]
svault.config = {} --Don't touch this line

--[[-------------------------------------------------------------------------
Language
---------------------------------------------------------------------------]]
--Use the file name from the lang folder, make sure to remove the .lua extension
--Currently available languages: english
svault.config.language = "english"

--[[-------------------------------------------------------------------------
General Settings
---------------------------------------------------------------------------]]
svault.config.vaultname = "Bank Vault" --The name of the vault on the 3D2D
svault.config.chatprefix = "[sVault]" --The chat prefix to use for notifications if you're using the chat notification method
svault.config.notifymethod = 1 --The method used to notify the player 1 = Chat, 2 = Notifications

svault.config.econonmyupdaterate = 300 --How often should vault balances increase?
svault.config.econonmyupdateamount = 50000 --How much should get added to the vault on each economy update?
svault.config.glorifiedbankingfees = true --Should we take transaction fees from Glorified Banking and put them into the vault?

svault.config.vaultstartvalue = 900000 --The value the vault should spawn in with
svault.config.minvaultvalue = 900000 --The minimum money needed in the vault to start a raid
svault.config.maxvaultvalue = 1000000 --The maximum money a vault can store at one time

svault.config.policeteams = { --The teams that are classified as law enforcement
	["CP"] = true,
	["Policeman"] = true
}
svault.config.canraidteams = false --The teams that can start a raid, set to false for anyone

svault.config.maxparticipants = 8 --The maximum amount of people taking part in one raid

svault.config.minplayers = 10 --The minimum amount of players online needed to start a raid
svault.config.minpolice = 4 --The minimum amount of active police needed to start a raid

svault.config.maxraidsongoing = 2 --The maximum amount of raids happening at one time
svault.config.maxprogresstojoin = 30 --The furthest percentage into the raid until joining is no longer allowed

svault.config.warmuptime = 30 --How long should the warmup period last in seconds?
svault.config.securitytimer = 10 --How long should the vault wait before alerting police if the security is disabled?
svault.config.securitytimerdisabled = 20 --How long should the vault wait before alerting police if the security is enabled?
svault.config.raidbasetime = 30 --What is the minimum time it should take to raid the vault?
svault.config.raidmembertimemultiplier = 10 --How many extra seconds should be added to the timer per extra raid party member?
svault.config.cooldowntime = 30 --How long should the cooldown last for after an unsuccessful raid?

svault.config.maxraiderdist = 600 --How far should away can you be from the vault before being removed from the party? False to disable

svault.config.rejoinoutofrange = false --Should a player be allowed to rejoin the raid party (if possible) after going out of range?
svault.config.rejoindeath = false --Should a player be allowed to rejoin the raid party (if possible) after dying?

svault.config.policekillreward = 5000 --How much money should a law enforcement member get for killing a raider? False to disable
svault.config.raiderkilledpenalty = 20 --How much time should be added to the raid timer if a raider is killed? False to disable
svault.config.friendlykilledpenalty = 10 --How much time should be added on top of the raider kill penalty if their death was friendly fire? False to disable

svault.config.rewardmembermultiplier = 2000 --How much extra should the police get as a reward per party member when countering the raid successfully?

svault.config.dropmoney = false --Should we drop the money in front of the bank instead of giving the split to players directly?

svault.config.hackernearbyvaultdist = 4000 --How far away can a vault be before it's out of the hacker's range?
svault.config.hackerselfdestructtime = 10 --How many seconds after a successful hack should it take for the hacker to self destruct?
svault.config.hackerexplosiondamage = true --Should the hacker cause explosion damage to nearby players on self destruct?
svault.config.hackerscrollspeed = 150 --The speed the letters scroll at in the hacking device
svault.config.hackerminhacktime = 5 --The minimum time it should take for someone to hack the security system (seconds)
svault.config.hackreenabletime = 300 --How long after the hack should we wait to re enable the security system if the vault doesn't get raided?

svault.config.draw3d2ddist = 690 --What should be the maximum distance from the vault that you can see the 3D2D at?

svault.config.preventphysgun = true --Should we prevent permanent vaults from being physgunned?
svault.config.preventtoolgun = true --Should we prevent permanent vaults from being toolgunned?

--[[-------------------------------------------------------------------------
Colour Settings
---------------------------------------------------------------------------]]
svault.config.chatPrefixCol = Color(215, 80, 80)
svault.config.chatMessageCol = Color(255, 255, 255)

svault.config.primaryCol = Color(194, 51, 51)
svault.config.bgCol = Color(64, 64, 64)
svault.config.secondBgCol = Color(88, 88, 88)
svault.config.boxBgCol = Color(58, 58, 58)
svault.config.textCol = Color(255, 255, 255)
svault.config.onCol = Color(63, 199, 53)
svault.config.offCol = Color(172, 50, 55)
svault.config.iconCol = Color(255, 255, 255)
svault.config.lineCol = Color(255, 255, 255)
svault.config.warningCol = Color(220, 62, 62)
svault.config.progBgCol = Color(68, 68, 68)
svault.config.progCol = Color(236, 59, 59)

svault.config.hackerBgCol = Color(0, 0, 0)
svault.config.hackerNameCol = Color(255, 255, 255)
svault.config.hackerGradientCol = Color(0, 0, 0)
svault.config.hackerSelectorCol = Color(255, 255, 255)
svault.config.hackerLetterCol = Color(255, 255, 255)
svault.config.hackerLetterCorrectCol = Color(255, 0, 0)
svault.config.hackerFinishTextCol = Color(255, 255, 255)
svault.config.hackerFinishStandBackCol = Color(255, 0, 0)

svault.config.hackerControlBgCol = Color(66, 61, 54, 180)
svault.config.hackerInstructionsCol = Color(255, 255, 255)
svault.config.hackerButtonCol = Color(194, 51, 51)
svault.config.hackerButtonHoverCol = Color(153, 40, 40)
svault.config.hackerButtonTextCol = Color(255, 255, 255)

--[[-------------------------------------------------------------------------
End of sVault Configuration
---------------------------------------------------------------------------]]