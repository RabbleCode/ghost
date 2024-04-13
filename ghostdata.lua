function ghost:LoadQuestData()
	
	local Chapter1 = {}
	Chapter1.QuestID = 339
	Chapter1.ItemID = 2756
	Chapter1.Name = "Chapter I"
	Chapter1.MinimumLevel = 30
	Chapter1.Pages = {				
				2725, -- Page 1
				2728, -- Page 4
				2730, -- Page 6
				2732 -- Page 8
	}

	local Chapter2 = {}
	Chapter2.QuestID = 340
	Chapter2.ItemID = 2757
	Chapter2.Name = "Chapter II"
	Chapter2.MinimumLevel = 30
	Chapter2.Pages = {				
				2734, -- Page 10
				2735, -- Page 11
				2738, -- Page 14
				2740 -- Page 16
	}

	local Chapter3 = {}
	Chapter3.QuestID = 341
	Chapter3.ItemID = 2758
	Chapter3.Name = "Chapter III"
	Chapter3.MinimumLevel = 30
	Chapter3.Pages = {				
				2742, -- Page 18
				2744, -- Page 20
				2745, -- Page 21
				2748 -- Page 24
	}

	local Chapter4 = {}
	Chapter4.QuestID = 342
	Chapter4.ItemID = 2759
	Chapter4.Name = "Chapter IV"
	Chapter4.MinimumLevel = 30
	Chapter4.Pages = {				
				2749, -- Page 25
				2750, -- Page 26
				2751 -- Page 27
	}

	ghost.MainQuest = {}
	ghost.MainQuest.QuestID = 338
	ghost.MainQuest.QuestName = "The Green Hills of Stranglethorn"
	ghost.MainQuest.MinimumLevel = 30
	ghost.MainQuest.Chapters = {Chapter1, Chapter2, Chapter3, Chapter4}
end