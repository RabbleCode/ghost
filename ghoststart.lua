ghost = {};

---------
function ghost:OnLoad()
---------
	SLASH_GHOST1 = "/ghost";
	SlashCmdList["GHOST"] = function(msg) ghost:HandleSlashCommand(msg) end

	ghostFrame:RegisterEvent("PLAYER_LOGIN")
	ghostFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	ghostFrame:RegisterEvent("ADDON_LOADED")
end

---------
function ghost:OnEvent(self, event, ...)
---------
	local arg1, arg2, arg3, arg4 = ...
	if event == "ADDON_LOADED" and arg1 == "ghost" then
		ghostFrame:UnregisterEvent("ADDON_LOADED");
	elseif event == "PLAYER_LOGIN" then
		ghostFrame:UnregisterEvent("PLAYER_LOGIN");
		ghost:LoadData();
		ghost:LoadCharacterData();
		ghost:PrimeItemCache();
		ghost:Announce();		
	elseif event == "PLAYER_ENTERING_WORLD" then
		ghostFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end
end

---------
function ghost:LoadCharacterData()
---------
	ghost.CurrentRealm = GetRealmName();
	ghost.PlayerName = UnitName("player");
	ghost.PlayerNameWithRealm = ghost.CurrentRealm.." - "..ghost.PlayerName

	if(GhostCharacterProgress == nil) then 
		GhostCharacterProgress = {} 
	end
	
	if(GhostCharacterProgress[ghost.CurrentRealm] == nil) then
		GhostCharacterProgress[ghost.CurrentRealm] = {}
	end

	if(GhostCharacterProgress[ghost.CurrentRealm][ghost.PlayerName] == nil) then
		GhostCharacterProgress[ghost.CurrentRealm][ghost.PlayerName] = {}
	end

	ghost.PlayerProgress = GhostCharacterProgress[ghost.CurrentRealm][ghost.PlayerName]
	ghost:UpdatePlayerProgress();
end

-- Calls GetItemInfo on all related quest items to prime the local cache
---------
function ghost:PrimeItemCache()
---------
	-- Get each chapter
	for index, chapter in pairs(ghost.Chapters) do			
		GetItemInfo(chapter["itemid"])	

		-- Get pages for each chapter
		for index, itemID in pairs(chapter["pages"]) do	
			GetItemInfo(itemID)		
		end	
	end	
end

---------
function ghost:Announce()
---------
	ghost:PrintMessageWithGhostPrefix("activated");	
end