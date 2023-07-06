

---------
function ghost:HandleSlashCommand(cmd)
---------
	local characterName = string.lower(cmd)
	if characterName ~= nil and characterName ~= "" then		
		ghost:CheckSpecificCharacter(characterName);	
		--ghost:PrintMessageWithGhostPrefix(ORANGE_FONT_COLOR_CODE.."This feature is not yet implemented.")
	else
		ghost:CheckCurrentCharacter();
	end
end

---------
function ghost:CheckSpecificCharacter(characterName)
---------
	if GhostCharacterProgress ~= nil then
		if GhostCharacterProgress[ghost.CurrentRealm] ~= nill then
			local progress = GhostCharacterProgress[ghost.CurrentRealm][characterName]
			if progress ~= nil then
				ghost:PrintMessageWithGhostPrefix("Entry for "..characterName..GREEN_FONT_COLOR_CODE.." found!")
				return;				
			end
		end
	end		
	ghost:PrintMessageWithGhostPrefix("Entry for "..characterName..RED_FONT_COLOR_CODE.." not found!")
	return;
end

---------
function ghost:CheckCurrentCharacter()
---------
	local playerName = UnitName("player")	
	ghost:PrintHeader(playerName)
	local progress = GhostCharacterProgress[ghost.CurrentRealm][playerName]	
	if progress == nil then
		progress = {}	
	end
	if ghost:IsMainQuestComplete(playerName) ~= true then				
		progress["IsMainQuestCompleted"] = false;
		for index, quest in pairs(ghost.ChapterQuests) do		
			ghost:PrintQuestProgress(quest)
		end	
	else		
		progress["IsMainQuestCompleted"] = true;
	end
	GhostCharacterProgress[ghost.CurrentRealm][playerName] = progress
	--print(GhostCharacterProgress[ghost.CurrentRealm][playerName])	
	return;
end

---------
function ghost:IsMainQuestComplete(characterName)
---------	
	local questID = ghost.MainQuest["id"]	
	if C_QuestLog.IsQuestFlaggedCompleted(questID) then
		ghost:PrintChainComplete(characterName);
		return true;
	elseif IsQuestComplete(questID) then
		ghost:PrintMessage(YELLOW_FONT_COLOR_CODE..ghost.MainQuest["name"]..": "..ORANGE_FONT_COLOR_CODE.." quest is complete and ready for turn in!")
	else
		return false;
	end
end

---------
function ghost:PrintHeader(characterName)
---------
	ghost:PrintMessageWithGhostPrefix("scanning for "..characterName.."...");
	ghost:PrintSeparatorLine();
end

---------
function ghost:PrintChainComplete(characterName)
---------
	ghost:PrintMessageWithGhostPrefix(GREEN_FONT_COLOR_CODE..characterName.." has already completed this quest chain.");
	ghost:PrintSeparatorLine();
end

---------
function ghost:PrintQuestProgress(quest)
---------		
	if quest ~= nil then 		
		local complete = C_QuestLog.IsQuestFlaggedCompleted(quest["id"])
		if complete then
			ghost:PrintMessage(YELLOW_FONT_COLOR_CODE..quest["name"]..": "..GREEN_FONT_COLOR_CODE.." complete.");			
		else
			local hasAllPages = true;
			local pageMessages = {}			
			for index, itemID in pairs(quest["items"]) do				
				local count = GetItemCount(itemID)
				if count < 1 then
					hasAllPages = false;
					local _, link = GetItemInfo(itemID)			
					if link == nil then
						print("Could not find link for item: "..itemID)
						_, link = GetItemInfo(itemID)	
					end
					if link ~= nil then
						table.insert(pageMessages,(YELLOW_FONT_COLOR_CODE.."    "..link));
					end
				end
			end			
			if hasAllPages then				
				ghost:PrintMessage(YELLOW_FONT_COLOR_CODE..quest["name"]..": "..ORANGE_FONT_COLOR_CODE.." Ready for turn in! All pages acquired.");
			else
				ghost:PrintMessage(YELLOW_FONT_COLOR_CODE..quest["name"]..": "..RED_FONT_COLOR_CODE.." incomplete. Still need:");
				ghost:PrintMessages(pageMessages)
			end
		end
	end	
end

---------
function ghost:PrintMessageWithGhostPrefix(message)
---------
	ghost:PrintMessage(YELLOW_FONT_COLOR_CODE.."GHOST |r"..message)
end
---------
function ghost:PrintMessage(message)
---------
	DEFAULT_CHAT_FRAME:AddMessage(message)
end

---------
function ghost:PrintMessages(messages)
---------
	if messages ~= nil then
		for index, message in pairs(messages) do
			ghost:PrintMessage(message)
		end
	end
end

---------
function ghost:PrintFooter(completed)
---------
	ghost:PrintSeparatorLine();
end

---------
function ghost:PrintSeparatorLine()
---------
	DEFAULT_CHAT_FRAME:AddMessage("---------------------------|r");
end