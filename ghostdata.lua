function ghost:LoadData()

	GhostCharacterProgress = GhostCharacterProgress or {}

	ghost.CurrentRealm = GetRealmName();

	ghost.MainQuest = {
		["id"] = 338,
		["name"] = "The Green Hills of Stranglethorn",
		["minimumlevel"] = 30,
		["items"] = {
			2756, -- Chapter I
			2757, -- Chapter II
			2758, -- Chapter III
			2759 -- Chapter IV
		}		
	}
	ghost.ChapterQuests = {
		{
			["id"] = 339,
			["name"] = "Chapter I",
			["minimumlevel"] = 30,
			["items"] = {				
				2725, -- Page 1
				2728, -- Page 4
				2730, -- Page 6
				2732 -- Page 8
			}
		},
		{
			["id"] = 340,
			["name"] = "Chapter II",
			["minimumlevel"] = 30,
			["items"] = {				
				2734, -- Page 10
				2735, -- Page 11
				2738, -- Page 14
				2740 -- Page 16
			}
		},
		{
			["id"] = 341,
			["name"] = "Chapter III",
			["minimumlevel"] = 30,
			["items"] = {				
				2742, -- Page 18
				2744, -- Page 20
				2745, -- Page 21
				2748 -- Page 24
			}
		},
		{
			["id"] = 342,
			["name"] = "Chapter IV",
			["minimumlevel"] = 30,
			["items"] = {				
				2749, -- Page 25
				2750, -- Page 26
				2751 -- Page 27
			}
		}
	}

	GhostCharacterProgress = {	
		[ghost.CurrentRealm] = {}	
		-- 	["server"] = {
		-- 		["name"] = {
		-- 			["items"] = {}
		-- 			["quests"] = {}
		--		}
		-- }
	}
end