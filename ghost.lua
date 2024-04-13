
function ghost:HandleSlashCommand(cmd)

	if cmd ~= nil and cmd ~= "" then
		if(cmd == "delete all") then			
			ghost:EraseAllCharacterProgress();
		elseif(cmd == "delete") then
			ghost:ErasePlayerProgress();
		else
			local character, realm = ghost:GetCharacterAndRealm(cmd)
			if(realm ~= nil) then
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

function ghost:GetCharacterAndRealm(arguments)
	local character, realm = arguments:match("^(%S*)%s*(.-)$")
	character = ghost:ConvertToTitleCase(character)
	if(realm ~= nil and realm ~= '') then
		realm = ghost:ConvertToTitleCase(realm)	
	else
		realm = nil
	end
	return character, realm
end

function ghost:ConvertToTitleCase(text)
	return string.gsub(text, "(%a)([%w_']*)", function(first, rest) return first:upper()..rest:lower() end)
end

function ghost:GetClassColor(class)
	class = string.upper(class)
	local colorStr = RAID_CLASS_COLORS[class]["colorStr"] or YELLOW_FONT_COLOR_CODE
	return "|c"..colorStr
end

function ghost:GetClassColoredName(class, character, realm)
	return ghost:GetClassColor(class)..character.."|r"..YELLOW_FONT_COLOR_CODE.." - "..realm
end

function ghost:CheckSpecificCharacter(character, realm)

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

function ghost:ErasePlayerProgress()

	ghost:PrintMessageWithGhostPrefix(RED_FONT_COLOR_CODE.."Erasing |rdata for "..YELLOW_FONT_COLOR_CODE..ghost.PlayerNameWithRealm)
	ghost.PlayerProgress = nil
	ghost:SavePlayerProgress()
end

function ghost:EraseAllCharacterProgress()

	ghost:PrintMessageWithGhostPrefix(RED_FONT_COLOR_CODE.."Erasing data for all characters.")		
	GhostCharacterProgress = nil
end

function ghost:SavePlayerProgress()
	if(GhostCharacterProgress[ghost.CurrentRealm] ~= nil) then
		-- Delete character progress if it's nil
		if(ghost.PlayerProgress == nil) then
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

function ghost:UpdatePlayerProgress()


	if(ghost.MainQuest ~= nil and ghost.MainQuest.Chapters ~= nil) then
		ghost:LoadPlayerData()
		ghost.PlayerProgress.Faction = ghost.PlayerFaction
		ghost.PlayerProgress.Level = ghost.PlayerLevel
		ghost.PlayerProgress.Class = ghost.PlayerClass

		local questID = ghost.MainQuest.QuestID

		-- Quest is already completed and turned in
		if C_QuestLog.IsQuestFlaggedCompleted(questID) then
			ghost.PlayerProgress.Completed = true
		-- Quest is complete and ready to be turned in
		elseif IsQuestComplete(questID) then
			ghost.PlayerProgress.Ready = true
		-- Quest is not yet complete, check each individual chapter
		else
			ghost:UpdateChapterProgress()
		end
		
		ghost:SavePlayerProgress();
	else
		ghost:PrintMessageWithGhostPrefix(RED_FONT_COLOR_CODE.."Quest information corrupted. Please reinstall the addon.")
	end
end

function ghost:UpdateChapterProgress()
	
	if(ghost.MainQuest ~= nil and ghost.MainQuest.Chapters ~= nil) then			
		local chapters = 0
		for _, chapter in pairs(ghost.MainQuest.Chapters) do
			
			local chapterProgress = {}
			local questID = chapter.QuestID
			local isComplete = C_QuestLog.IsQuestFlaggedCompleted(questID) 
			local isReady = IsQuestComplete(questID)
			local hasChapter = GetItemCount(chapter.ItemID) > 0
			local hasPages = false
			local pages = {}

			-- If incomplete, record progress on individual pages
			if not isComplete and not isReady then
				hasPages, pages = ghost:FindCollectedPages(chapter)
			end
			
			-- Only cache data if there's something to cache
			if(isComplete) then
				chapters = chapters + 1;
				chapterProgress.Completed = true
			elseif(isReady) then
				chapters = chapters + 1;
				chapterProgress.Ready = true
			elseif(hasPages) then
				chapters = chapters + 1;
				chapterProgress.Pages = pages
			else
				chapterProgress = nil
			end

			-- If progress on this chapter
			if(chapterProgress ~= nil) then
				-- Make sure the base Chapters node isn't empty
				if(ghost.PlayerProgress.Chapters == nil) then
					ghost.PlayerProgress.Chapters = {}
				end
				-- And update the node for this chapter
				ghost.PlayerProgress.Chapters[chapter.QuestID] = chapterProgress
			-- If no progress on this chapter, remove the node for this chapter if it exists
			elseif(ghost.PlayerProgress.Chapters ~= nil) then
				ghost.PlayerProgress.Chapters[chapter.QuestID] = nil	
			end

			-- If no progress on any chapters, remove the entire Chapters node
			if(chapters == 0) then
				ghost.PlayerProgress.Chapters = nil
			end
		end	
	else
		ghost:PrintMessageWithGhostPrefix(RED_FONT_COLOR_CODE.."Quest information corrupted. Please reinstall the addon.")
	end
end

function ghost:FindCollectedPages(chapter)
	local hasPages = false
	local pages = {}

	for _, pageID in pairs(chapter.Pages) do			
		if GetItemCount(pageID) > 0 then
			hasPages = true;
			pages[pageID] = true
		end
	end

	return hasPages, pages
end

function ghost:PrintCharacterProgress(character, realm)


	local realmProgress = GhostCharacterProgress[realm]
	local characterProgress 
	if(realmProgress ~= nil) then
		characterProgress = GhostCharacterProgress[realm][character]
	end

	-- Progress flags
	local hasProgress = characterProgress ~= nil
	local isCompleted = hasProgress and characterProgress.Completed == true
	local isReady = hasProgress and characterProgress.Ready == true
	
	-- Character info
	local faction = characterProgress.Faction or "UNKNOWN"
	local level = characterProgress.Level or 0
	local class = characterProgress.Class or "UNKNOWN"
	local classColoredName = ghost:GetClassColoredName(class, character, realm)

	if(isCompleted) then
		ghost:PrintMessageWithGhostPrefix("Quest chain "..GREEN_FONT_COLOR_CODE.."already completed|r for "..YELLOW_FONT_COLOR_CODE..classColoredName);
	elseif(isReady) then
		ghost:PrintMessageWithGhostPrefix("Quest chain "..ORANGE_FONT_COLOR_CODE.."ready for turn in|r for "..YELLOW_FONT_COLOR_CODE..classColoredName);
	else
		ghost:PrintMessageWithGhostPrefix("Quest chain "..RED_FONT_COLOR_CODE.."incomplete|r for "..YELLOW_FONT_COLOR_CODE..classColoredName);
		ghost:PrintChaptersProgress(characterProgress)
	end
end

function ghost:PrintChaptersProgress(progress)

	for _, chapter in pairs(ghost.MainQuest.Chapters) do

		local questID = chapter.QuestID
		local name = chapter.Name
		local hasProgress = progress ~= nil and progress.Chapters ~= nil and progress.Chapters[questID] ~= nil

		-- if character has recorded progress
		if(hasProgress) then
			local chapterProgress = progress.Chapters[questID]
			-- if chapter is already completed
			if(chapterProgress.Completed == true) then
				ghost:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..name..": "..GREEN_FONT_COLOR_CODE.."completed!")
			-- else if chapter is ready for turn in
			elseif(chapterProgress.Ready == true) then
				ghost:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..name..": "..ORANGE_FONT_COLOR_CODE.."ready for turn in.") 
			-- else if chapter is incomplete
			else
				ghost:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..name)
				ghost:PrintPagesProgress(chapter, chapterProgress)
			end
		else
			-- no recorded progress
		ghost:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..name)
			ghost:PrintPagesProgress(chapter, nil)
		end
	end
end

function ghost:PrintPagesProgress(chapter, chapterProgress)

	for _, pageID in pairs(chapter.Pages) do
		local _, link = GetItemInfo(pageID)
		if(chapterProgress ~= nil and chapterProgress.Pages ~= nil and chapterProgress.Pages[pageID] ~= nil) then
			ghost:PrintMessage("    "..link..": "..GREEN_FONT_COLOR_CODE.."collected")
		else
			ghost:PrintMessage("    "..link..": "..RED_FONT_COLOR_CODE.."missing")
		end
	end
end

function ghost:PrintHeader(characterName)

	ghost:PrintMessageWithGhostPrefix("progress for "..YELLOW_FONT_COLOR_CODE..characterName.."...");
end

function ghost:PrintMessageWithGhostPrefix(message)

	ghost:PrintMessage(YELLOW_FONT_COLOR_CODE.."GHOST|r | "..message)
end

function ghost:PrintMessage(message)

	DEFAULT_CHAT_FRAME:AddMessage(message)
end

function ghost:PrintFooter(completed)

	ghost:PrintSeparatorLine();
end

function ghost:PrintSeparatorLine()

	DEFAULT_CHAT_FRAME:AddMessage("|r");
end

function ghost:PrintDebug(message)
	
	DEFAULT_CHAT_FRAME:AddMessage(YELLOW_FONT_COLOR_CODE.."GHOST|r DEBUG | "..message);
end