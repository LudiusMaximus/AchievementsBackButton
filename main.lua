

local history = {}
local lastCategory = nil
local backButton = nil


-- /run AchievmentsBack()
AchievmentsBack = function()

  if next(history) == nil then
    return
  end

  category, title, parentCategoryID = unpack(tremove(history))
  lastCategory = nil

  -- for k, v in pairs(history) do
    -- print ("  ", k, v[1], v[2], v[3])
  -- end

  -- Wrath.
  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
    achievementFunctions.selectedCategory = category

    AchievementFrameCategories_Update()
    if category == "summary" then
      AchievementFrame_ShowSubFrame(AchievementFrameSummary)
    else
      AchievementFrameAchievements_Update()
    end

  -- Retail.
  else
    AchievementFrame_UpdateAndSelectCategory(category)
  end

  if next(history) == nil then
    backButton:Disable()
  end

end



local function RememberLastCategory()
  if not lastCategory then return end

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


hooksecurefunc("UIParentLoadAddOn", function(name)
  if name == "Blizzard_AchievementUI" then

    local buttonParentFrame = nil
    local buttonAnchorFrame = nil

    -- Wrath.
    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
      hooksecurefunc("AchievementFrameCategories_Update", function()
        if lastCategory ~= achievementFunctions.selectedCategory then
          RememberLastCategory()
          lastCategory = achievementFunctions.selectedCategory
        end
      end)
      
      buttonParentFrame = AchievementFrameHeader
      buttonAnchorFrame = AchievementFrameHeaderPointBorder

    -- Retail.
    else
      hooksecurefunc("AchievementFrameCategories_OnCategoryChanged", function(category)
        if lastCategory ~= category then
          RememberLastCategory()
          lastCategory = category
        end
      end)
      
      buttonParentFrame = AchievementFrame.Header
      buttonAnchorFrame = AchievementFrame.Header.PointBorder
    end


    backButton = CreateFrame("Button", nil, buttonParentFrame)
    backButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    backButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    backButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
    backButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    backButton:SetSize(29, 29)
    backButton:SetPoint("LEFT", buttonAnchorFrame, "RIGHT", 10, 1)
    
    backButton:SetScript("OnClick", function()
        AchievmentsBack()
      end)
    backButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(HEIRLOOMS_CATEGORY_BACK)
      end)
    backButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
      end)

    backButton:Disable()

  end
end)

