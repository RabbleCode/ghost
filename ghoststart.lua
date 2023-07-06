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
		ghost:PrimeItemCache();
		ghost:Announce();		
	elseif event == "PLAYER_ENTERING_WORLD" then
		ghostFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end
end

-- Calls GetItemInfo on all related quest items to prime the local cache
---------
function ghost:PrimeItemCache()
---------
	-- Get main quest items
	for index, itemID in pairs(ghost.MainQuest["items"]) do	
		local _, link = GetItemInfo(itemID)
	end

	-- Get chapter quest items
	for index, quest in pairs(ghost.ChapterQuests) do		
		for index, itemID in pairs(quest["items"]) do	
			local _, link = GetItemInfo(itemID)		
		end	
	end	
end

---------
function ghost:Announce()
---------
	DEFAULT_CHAT_FRAME:AddMessage(YELLOW_FONT_COLOR_CODE.."GHOST |ractivated. ");
end