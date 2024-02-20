---------
function ghost:HandleSlashCommand(cmd)
---------
	if cmd ~= nil and cmd ~= "" then
		if(cmd == "delete all") then			
			ghost:EraseAllCharacterProgress();
		elseif(cmd == "delete") then
			ghost:ErasePlayerProgress();
		else
			local cmd1, cmd2 = cmd:match("^(%S*)%s*(.-)$")
			local character = ghost:ConvertToTitleCase(cmd1)
			if(cmd1 ~= nil and cmd2 ~= nil and cmd2 ~= "") then
				local realm = ghost:ConvertToTitleCase(cmd2)
				ghost:CheckSpecificCharacter(character, realm);
			else
				ghost:CheckSpecificCharacter(character, ghost.CurrentRealm);
			end			
		end
	else
		ghost:UpdatePlayerProgress();
		ghost:PrintCharacterProgress(ghost.PlayerName, ghost.CurrentRealm);
	end
end

---------
function ghost:ConvertToTitleCase(text)
---------
	return string.gsub(text, "(%a)([%w_']*)", TitleCase)
end

---------
function TitleCase( first, rest )
---------
	return first:upper()..rest:lower()
end

---------
function ghost:CheckSpecificCharacter(character, realm)
---------
	local name = character.." - "..realm
	local progress = nil
	if(GhostCharacterProgress[realm] ~= nil and GhostCharacterProgress[realm][character] ~= nil) then
		progress = GhostCharacterProgress[realm][character]	
	end
	if progress == nil then	
		ghost:PrintMessageWithGhostPrefix("Progress for "..YELLOW_FONT_COLOR_CODE..name..RED_FONT_COLOR_CODE.." not found.")
	else		
		ghost:PrintCharacterProgress(character, realm)
	end
end

---------
function ghost:ErasePlayerProgress()
---------
	ghost:PrintMessageWithGhostPrefix(RED_FONT_COLOR_CODE.."Erasing |rdata for "..YELLOW_FONT_COLOR_CODE..ghost.PlayerNameWithRealm)
	ghost.PlayerProgress = nil
	ghost:SavePlayerProgress()
end

---------
function ghost:EraseAllCharacterProgress()
---------
	ghost:PrintMessageWithGhostPrefix(RED_FONT_COLOR_CODE.."Erasing data for all characters.")		
	GhostCharacterProgress = nil
end

function ghost:SavePlayerProgress()
	if(GhostCharacterProgress[ghost.CurrentRealm] ~= nil) then
		-- Delete character progress if it's nil
		if(ghost.PlayerProgress == nil) then
			GhostCharacterProgress[ghost.CurrentRealm][ghost.PlayerName] = nil
		-- Delete character progress if there is no main quest or chapter progress
		elseif (ghost.PlayerProgress["MainQuestProgress"] == nil and ghost.PlayerProgress["ChapterProgress"] == nil) then
			GhostCharacterProgress[ghost.CurrentRealm][ghost.PlayerName] = nil
		-- Save character progress
		else
			GhostCharacterProgress[ghost.CurrentRealm][ghost.PlayerName] = ghost.PlayerProgress	
		end

		-- After updating character progress, check if there are any characters recorded on this realm
		local realmCount = 0
		for _,_ in pairs(GhostCharacterProgress[ghost.CurrentRealm]) do	
			realmCount = realmCount + 1
		end

		-- If there are no recorded characters on this realm, delete the realm too
		if(realmCount == 0) then
			GhostCharacterProgress[ghost.CurrentRealm] = nil
		end
	end
end

---------
function ghost:UpdatePlayerProgress()
---------
	local questID = ghost.MainQuest["questid"]

	-- Quest is already completed and turned in
	if C_QuestLog.IsQuestFlaggedCompleted(questID) then
		ghost.PlayerProgress["MainQuestProgress"] = {
			["completed"] = true
		}
	-- Quest is complete and ready to be turned in
	elseif IsQuestComplete(questID) then
		ghost.PlayerProgress["MainQuestProgress"] = {
			["ready"] = true
		}	
	-- Quest is not yet complete
	else
		-- Check each individual chapter
		ghost:UpdateChapterProgress()			
	end

	ghost:SavePlayerProgress();
end

---------
function ghost:UpdateChapterProgress()
---------			
	for _, chapter in pairs(ghost.Chapters) do

		local questID = chapter["questid"]
		local isComplete = C_QuestLog.IsQuestFlaggedCompleted(questID) 
		local isReady = IsQuestComplete(questID)
		local chaptersProgress = ghost.PlayerProgress["ChapterProgress"]
		local hasPages = false
		local pages = {}

		-- If incomplete, record progress on individual pages
		if not isComplete and not isReady then		
			for _, pageID in pairs(chapter["pages"]) do			
				if GetItemCount(pageID) > 0 then	
					hasPages = true;
					pages[pageID] = pageID;
				end
			end
		end
		
		-- Only cache data if there's something to cache
		if(isComplete or isReady or hasPages) then
			if(chaptersProgress == nil) then
				chaptersProgress = {}
			end

			chaptersProgress[questID] = {
				["itemid"] = chapter["itemid"],
			}

			local chapterProgress = ghost.PlayerProgress["ChapterProgress"][questID]

			if(isComplete) then
				chapterProgress["completed"] = true
			elseif(isReady) then
				chapterProgress["ready"] = true
			elseif(hasPages) then
				chapterProgress["PageProgress"] = pages
			end
		elseif chaptersProgress ~= nil and chaptersProgress[questID] ~= nil then
			chaptersProgress[questID] = {}
		end
	end	
end

---------
function ghost:PrintCharacterProgress(character, realm)
---------
	local name = character.." - "..realm

	local realmProgress = GhostCharacterProgress[realm]
	local characterProgress 
	if(realmProgress ~= nil) then
		characterProgress = GhostCharacterProgress[realm][character]
	end
	local hasMainQuestProgress = characterProgress ~= nil and characterProgress["MainQuestProgress"] ~= nil
	local isCompleted = hasMainQuestProgress and characterProgress["MainQuestProgress"]["completed"] ~= nil
	local isReady = hasMainQuestProgress and characterProgress["MainQuestProgress"]["ready"] ~= nil

	if(isCompleted) then
		ghost:PrintMainQuestProgress(name, true, false)
	elseif(isReady) then
		ghost:PrintMainQuestProgress(name, false, true)
	else
		ghost:PrintMainQuestProgress(name, false, false)
		ghost:PrintChaptersProgress(characterProgress)
	end
end

---------
function ghost:PrintChaptersProgress(progress)
---------
	for _, chapter in pairs(ghost.Chapters) do

		local _, link = GetItemInfo(chapter["itemid"])		
		local questID = chapter["questid"]
		local hasProgress = progress ~= nil and progress["ChapterProgress"] ~= nil and progress["ChapterProgress"][questID] ~= nil

		-- if character has recorded progress
		if(hasProgress) then
			local chapterProgress = progress["ChapterProgress"][questID]
			-- if chapter is already completed
			if(chapterProgress["completed"] == true) then
				ghost:PrintChapterProgress(chapter["name"], true, false)
			-- else if chapter is ready for turn in
			elseif(chapterProgress["ready"] == true) then
				ghost:PrintChapterProgress(chapter["name"], false, true)
			-- else if chapter is incomplete
			else
				ghost:PrintChapterProgress(chapter["name"], false, false)
				ghost:PrintPagesProgress(chapter, chapterProgress)
			end
		else
			-- no recorded progress
			ghost:PrintChapterProgress(chapter["name"], false, false)
			ghost:PrintPagesProgress(chapter, nil)
		end
	end
end

---------
function ghost:PrintPagesProgress(chapter, chapterProgress)
---------
	for _, pageID in pairs(chapter["pages"]) do
		local _, link = GetItemInfo(pageID)
		if(chapterProgress ~= nil and chapterProgress["PageProgress"] ~= nil and chapterProgress["PageProgress"][pageID] ~= nil) then
			ghost:PrintPageProgress(link, true)
		else
			ghost:PrintPageProgress(link, false)
		end
	end
end

---------
function ghost:PrintMainQuestProgress(character, isCompleted, isReady)
---------
	if(isCompleted) then
		ghost:PrintMessageWithGhostPrefix("Quest chain "..GREEN_FONT_COLOR_CODE.."already completed|r for "..YELLOW_FONT_COLOR_CODE..character);
	elseif(isReady) then
		ghost:PrintMessageWithGhostPrefix("Quest chain "..ORANGE_FONT_COLOR_CODE.."ready for turn in|r for "..YELLOW_FONT_COLOR_CODE..character);
	else
		ghost:PrintMessageWithGhostPrefix("Quest chain "..RED_FONT_COLOR_CODE.."incomplete|r for "..YELLOW_FONT_COLOR_CODE..character);
	end
end

---------
function ghost:PrintChapterProgress(chapterName, isCompleted, isReady)
---------
	if(isCompleted) then
		ghost:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..chapterName..": "..GREEN_FONT_COLOR_CODE.."completed!")
	elseif(isReady) then
		ghost:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..chapterName..": "..ORANGE_FONT_COLOR_CODE.."ready for turn in.") 
	else
		ghost:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..chapterName)
	end	
end

---------
function ghost:PrintPageProgress(pageLink, isCollected)
---------
	if(isCollected) then
		ghost:PrintMessage("    "..pageLink..": "..GREEN_FONT_COLOR_CODE.."collected")
	else		
		ghost:PrintMessage("    "..pageLink..": "..RED_FONT_COLOR_CODE.."missing")
	end
end

---------
function ghost:PrintHeader(characterName)
---------
	ghost:PrintMessageWithGhostPrefix("progress for "..YELLOW_FONT_COLOR_CODE..characterName.."...");
end

---------
function ghost:PrintMessageWithGhostPrefix(message)
---------
	ghost:PrintMessage(YELLOW_FONT_COLOR_CODE.."GHOST|r | "..message)
end

---------
function ghost:PrintMessage(message)
---------
	DEFAULT_CHAT_FRAME:AddMessage(message)
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

---------
function ghost:PrintDebug(message)
---------	
	DEFAULT_CHAT_FRAME:AddMessage(YELLOW_FONT_COLOR_CODE.."GHOST|r DEBUG | "..message);
end