function ghost:OnLoad()

	SLASH_GHOST1 = "/ghost";
	SLASH_GHOSTV1 = "/ghostv";
	SLASH_GHOSTV2 = "/gv";
	SlashCmdList["GHOST"] = function(msg) ghost:HandleSlashCommand(msg, true) end
	SlashCmdList["GHOSTV"] = function(msg) ghost:HandleSlashCommand(msg, false) end

	ghostFrame:RegisterEvent("PLAYER_LOGIN")
	ghostFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	ghostFrame:RegisterEvent("ADDON_LOADED")
end

function ghost:OnEvent(self, event, ...)

	local arg1, arg2, arg3, arg4 = ...
	if event == "ADDON_LOADED" and arg1 == "ghost" then
		ghostFrame:UnregisterEvent("ADDON_LOADED");
	elseif event == "PLAYER_LOGIN" then
		ghostFrame:UnregisterEvent("PLAYER_LOGIN");
		ghost:LoadGameVersionData();
		ghost:LoadQuestData();
		ghost:LoadPlayerData();
		ghost:LoadAccountData();
		ghost:CleanUpEmptyKeyData();
		ghost:PrimeItemCache();
		ghost:UpdatePlayerProgress();
		ghost:Announce();
	elseif event == "PLAYER_ENTERING_WORLD" then
		ghostFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end
end

function ghost:LoadGameVersionData()

	ghost.IsForever = WOW_PROJECT_ID == WOW_PROJECT_CAMELOT
	ghost.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

function ghost:LoadPlayerData()

	ghost.CurrentRealm = GetRealmName();
	ghost.PlayerName, ghost.PlayerLastName = UnitName("player");
	ghost.HideRealmName = false
	if(ghost.IsForever) then -- Accounting for Forever's dual names and "realmlessness"
		ghost.HideRealmName = true
		ghost.PlayerName = ghost.PlayerName..' '..ghost.PlayerLastName 
		ghost.CurrentRealm = 'Forever' -- API changes no longer return realm name on Forever, and names are unique across regions anyway
	end	
	ghost.PlayerNameWithRealm = ghost.CurrentRealm.." - "..ghost.PlayerName
	ghost.PlayerClass = UnitClass("player");
	ghost.PlayerFaction = UnitFactionGroup("player");
	ghost.PlayerLevel = UnitLevel("player");
	ghost.PlayerProgress = {}
end

function ghost:LoadAccountData()

	if(GhostCharacterProgress == nil) then 
		GhostCharacterProgress = {} 
	end
	
	if(GhostCharacterProgress[ghost.CurrentRealm] == nil) then
		GhostCharacterProgress[ghost.CurrentRealm] = {}
	end

end

function ghost:CleanUpEmptyKeyData()

	-- API Change with 1.60.1 Forever patch changed GetRealmName() to return empty string
	-- causing the addon to store character data in a different, empty key instead of by realm name
	-- The addon is now fixed to store character data for Forever in key "Forever", but we need to
	-- clean up the old data that was stored in "CAMWOW..." realm keys and then in the empty realm key

	-- Import then delete any data stored in that interim empty key first, as that's more recent then "CAMWOW" realm data
	if(GhostCharacterProgress[""] ~= nil) then
		GhostCharacterProgress[ghost.CurrentRealm] = GhostCharacterProgress[""]
		GhostCharacterProgress[""] = nil
	end

	-- Then import "CAMWOW" data if needed and delete "CAMWOW" data
	for realm, data in pairs(GhostCharacterProgress) do
		if(string.find(realm,"CAMWOW",1, true) and realm ~= nil) then
			if(GhostCharacterProgress[ghost.CurrentRealm] == nil) then
				GhostCharacterProgress[ghost.CurrentRealm] = GhostCharacterProgress[realm]
			end
			GhostCharacterProgress[realm] = nil
		end
	end

end

-- Calls GetItemInfo on all related quest items to prime the local cache
function ghost:PrimeItemCache()

	-- Get each chapter
	for index, chapter in pairs(ghost.MainQuest.Chapters) do			
		ghost:GetItemInfo(chapter.ItemID)	

		-- Get pages for each chapter
		for index, itemID in pairs(chapter.Pages) do	
			ghost:GetItemInfo(itemID)		
		end	
	end	
end

function ghost:Announce()

	ghost:PrintMessageWithGhostPrefix("activated");	
end