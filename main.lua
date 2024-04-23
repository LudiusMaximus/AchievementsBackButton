
local started = false

local history = {}

local lastCategoryChangeTime = GetTime()
local lastCategoryID = nil
local lastAchievementID = nil

-- TODO: Track scroll position...
local lastScrollPosition = 0


local backButton = nil


AchievmentsBack = function()

  if next(history) == nil then
    return
  end


  -- Titles and category parent not needed yet. Maybe later for history drop down...
  local storedAchievementID, _, storedCategoryID, _, _ = unpack(tremove(history))

  -- Prevent storing when going back.
  lastCategoryID = nil
  lastAchievementID = nil

  -- for k, v in pairs(history) do
    -- print ("  ", k, v[1], v[2], v[3])
  -- end

  -- Wrath.
  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
    achievementFunctions.selectedCategory = storedCategoryID

    AchievementFrameCategories_Update()
    if storedCategoryID == "summary" then
      AchievementFrame_ShowSubFrame(AchievementFrameSummary)
    else
      AchievementFrameAchievements_Update()
    end

  -- Retail.
  else
    AchievementFrame_UpdateAndSelectCategory(storedCategoryID)

    if storedAchievementID then
      AchievementFrame_SelectAchievement(storedAchievementID)
    end

  end

  if next(history) == nil then
    backButton:Disable()
  end

end



local function RememberLastState()
  if not lastCategoryID then return end

  -- Titles and category parent not needed yet. Maybe later for history drop down...
  local lastAchievementTitle, lastCategoryTitle, lastCategoryParentID

  if lastAchievementID then
    _, lastAchievementTitle = GetAchievementInfo(lastAchievementID)
  end

  if lastCategoryID == "summary" then
    lastCategoryTitle, lastCategoryParentID = ACHIEVEMENT_SUMMARY_CATEGORY, -1
  else
    lastCategoryTitle, lastCategoryParentID = GetCategoryInfo(lastCategoryID)
  end

  -- print("Storing", lastAchievementID, lastAchievementTitle, lastCategoryID, lastCategoryTitle, lastCategoryParentID)


  tinsert(history, {lastAchievementID, lastAchievementTitle, lastCategoryID, lastCategoryTitle, lastCategoryParentID})
  -- for k, v in pairs(history) do
    -- print ("  ", k, v[1], v[2], v[3])
  -- end

  backButton:Enable()
end


hooksecurefunc("UIParentLoadAddOn", function(name)
  if name == "Blizzard_AchievementUI" and not started then

    local buttonParentFrame = nil
    local buttonAnchorFrame = nil

    -- Wrath.
    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
      hooksecurefunc("AchievementFrameCategories_Update", function()
        if lastCategoryID ~= achievementFunctions.selectedCategory then
          RememberLastState()
          lastCategoryID = achievementFunctions.selectedCategory
        end
      end)

      buttonParentFrame = AchievementFrameHeader
      buttonAnchorFrame = AchievementFrameHeaderPointBorder

    -- Retail.
    else

      hooksecurefunc("AchievementFrameCategories_OnCategoryChanged", function(categoryID)
        -- print(GetTime(), "AchievementFrameCategories_OnCategoryChanged", categoryID)
        if lastCategoryID ~= categoryID then

          if lastCategoryChangeTime < GetTime() then
            RememberLastState()
          end

          lastCategoryID = categoryID
          lastCategoryChangeTime = GetTime()

          lastAchievementID = nil
        end
      end)


      hooksecurefunc("AchievementFrame_SelectAchievement", function(achievementID)
        -- print(GetTime(), "AchievementFrame_SelectAchievement", achievementID)
        if lastAchievementID ~= achievementID then

          if lastCategoryChangeTime < GetTime() then
            RememberLastState()
          end

          lastAchievementID = achievementID
        end
      end)


      -- TODO: Track clicked (expanded) achievements.

      -- TODO: Track scroll position...

      -- AchievementFrameAchievements.ScrollBox:HookScript("OnMouseWheel", function(self)
        -- print(AchievementFrameAchievements.ScrollBox.scrollPercentage)
      -- end)

      -- AchievementFrameAchievements.ScrollBar:HookScript("OnMouseWheel", function(self)
        -- print(AchievementFrameAchievements.ScrollBox.scrollPercentage)
      -- end)


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


    started = true

  end
end)

