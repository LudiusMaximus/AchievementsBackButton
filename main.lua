

local history = {}
local lastCategory = nil
local backButton = nil

AchievmentsBack = function()

  if next(history) == nil then
    return
  end
  
  category, title, parentCategoryID = unpack(tremove(history))  
  lastCategory = nil
  AchievementFrame_UpdateAndSelectCategory(category)

  if next(history) == nil then
    backButton:Disable()
  end

end



hooksecurefunc("UIParentLoadAddOn", function(name)
  if name == "Blizzard_AchievementUI" then
  
    hooksecurefunc("AchievementFrameCategories_OnCategoryChanged", function(category, ...)
      -- print("AchievementFrameCategories_OnCategoryChanged", category, ...)
    
      if lastCategory then

        if lastCategory == "summary" then
          title, parentCategoryID = ACHIEVEMENT_SUMMARY_CATEGORY, -1
        else
          title, parentCategoryID = GetCategoryInfo(lastCategory)
        end
        -- print(title, parentCategoryID)

        tinsert(history, {lastCategory, title, parentCategoryID})
        -- for k, v in pairs(history) do
          -- print ("  ", k, v[1], v[2], v[3])
        -- end
      
        backButton:Enable()
      end
      
      lastCategory = category
      
    end)
    
    
    backButton = CreateFrame("Button", nil, AchievementFrame.Header)
    backButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    backButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    backButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
    backButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    backButton:SetSize(29, 29)
    backButton:SetPoint("LEFT", AchievementFrame.Header.PointBorder, "RIGHT", 10, 1)
    backButton:SetScript("OnClick", function()
        AchievmentsBack()
      end)
    backButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(AUCTION_HOUSE_BACK_BUTTON)
      end)
    backButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
      end)
      
    backButton:Disable()
    
  end
end)

