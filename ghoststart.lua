ghost = {};

function ghost:OnLoad()

	SLASH_GHOST1 = "/ghost";
	SLASH_GHOSTC1 = "/ghostc";
	SLASH_GHOSTC2 = "/gc";
	SlashCmdList["GHOST"] = function(msg) ghost:HandleSlashCommand(msg, false) end
	SlashCmdList["GHOSTC"] = function(msg) ghost:HandleSlashCommand(msg, true) end

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
		ghost:LoadQuestData();
		ghost:LoadPlayerData();
		ghost:LoadAccountData();
		ghost:PrimeItemCache();
		ghost:UpdatePlayerProgress();
		ghost:Announce();
	elseif event == "PLAYER_ENTERING_WORLD" then
		ghostFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end
end

function ghost:LoadPlayerData()

	ghost.CurrentRealm = GetRealmName();
	ghost.PlayerName = UnitName("player");
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

-- Calls GetItemInfo on all related quest items to prime the local cache
function ghost:PrimeItemCache()

	-- Get each chapter
	for index, chapter in pairs(ghost.MainQuest.Chapters) do			
		GetItemInfo(chapter.ItemID)	

		-- Get pages for each chapter
		for index, itemID in pairs(chapter.Pages) do	
			GetItemInfo(itemID)		
		end	
	end	
end

function ghost:Announce()

	ghost:PrintMessageWithGhostPrefix("activated");	
end