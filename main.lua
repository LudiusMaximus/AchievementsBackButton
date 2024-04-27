local started = false

local history = {}

local goingBackFlag = false

local lastCategoryChangeTime = GetTime()
local lastCategoryID = nil
local lastCategoryScrollPosition = nil

local lastAchievementChangeTime = GetTime()
local lastAchievementID = nil
local lastAchievementScrollPosition = nil

local backButton = nil


AchievmentsBack = function()

  if next(history) == nil then
    return
  end

  -- Prevent storing when going back.
  goingBackFlag = true

  -- Titles and category parent not needed yet. Maybe later for history drop down...
  local _, storedAchievementID, _, storedCategoryID, _, _, storedAchievementsScrollPosition, storedCategoriesScrollPosition = unpack(tremove(history))

  -- for k, v in pairs(history) do
    -- print("  ", k, v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
  -- end



  -- ####################################################################
  -- ### Wrath
  -- ####################################################################
  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then

    -- Update the left side pane.
    achievementFunctions.selectedCategory = storedCategoryID
    AchievementFrameCategories_Update()

    -- Update the right window.
    if storedCategoryID == "summary" then
      AchievementFrame_ShowSubFrame(AchievementFrameSummary)
    else
      AchievementFrameAchievements_Update()
    end


    if storedAchievementID then
      AchievementFrame_SelectAchievement(storedAchievementID)
    end



  -- ####################################################################
  -- ### Retail
  -- ####################################################################
  else

    -- Left side pane and right window are both updated by this.
    AchievementFrame_UpdateAndSelectCategory(storedCategoryID)

    if storedAchievementID then
      AchievementFrame_SelectAchievement(storedAchievementID)
    end

    if storedCategoriesScrollPosition ~= nil then
      AchievementFrameCategories.ScrollBar:SetScrollPercentage(storedCategoriesScrollPosition)
    end
    if storedAchievementsScrollPosition ~= nil then
      AchievementFrameAchievements.ScrollBar:SetScrollPercentage(storedAchievementsScrollPosition)
    end

  end
  -- ####################################################################
  -- ### End
  -- ####################################################################


  if next(history) == nil then
    backButton:Disable()
  end

  goingBackFlag = false

end



local function RememberLastState()
  -- Do not remember while going back.
  if goingBackFlag or not lastCategoryID then return end
  -- Do not remember if we have already remembered this change.
  if next(history) and history[#history][1] == GetTime() then return end

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

  -- print(GetTime(), "Storing", lastAchievementID, lastAchievementTitle, lastCategoryID, lastCategoryTitle, lastCategoryParentID, lastAchievementScrollPosition, lastCategoryScrollPosition)

  tinsert(history, {GetTime(), lastAchievementID, lastAchievementTitle, lastCategoryID, lastCategoryTitle, lastCategoryParentID, lastAchievementScrollPosition, lastCategoryScrollPosition})
  -- for k, v in pairs(history) do
    -- print("  ", k, v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
  -- end

  backButton:Enable()
end


hooksecurefunc("UIParentLoadAddOn", function(name)
  if name == "Blizzard_AchievementUI" and not started then

    local buttonParentFrame = nil
    local buttonAnchorFrame = nil

    -- ####################################################################
    -- ### Wrath
    -- ####################################################################
    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then

      hooksecurefunc("AchievementFrameCategories_Update", function()
        if lastCategoryID ~= achievementFunctions.selectedCategory then

          RememberLastState()

          lastCategoryID = achievementFunctions.selectedCategory
          lastCategoryChangeTime = GetTime()

          lastAchievementID = nil
        end
      end)

      -- For Wrath Classic we can use this function for both,
      -- jumping to an achievement and clicking on an achievement.
      hooksecurefunc("AchievementButton_OnClick", function(button)
        local achievementID = button.id
        -- print(GetTime(), "AchievementButton_OnClick", achievementID)

        -- When deselecting an achievement, the button.id is nil, which we are not interested in.
        if achievementID and achievementID ~= lastAchievementID then

          -- Do not remember, when coming from the same category with no achievement selected.
          if lastCategoryID ~= GetAchievementCategory(achievementID) or lastAchievementID then
            RememberLastState()
          end

          lastAchievementChangeTime = GetTime()
          lastAchievementID = achievementID
        end
      end)


      -- Not working in Classic...
      -- local ScrollBar = AchievementFrameAchievementsContainer.scrollBar
      -- ScrollBar:RegisterCallback(ScrollBar.Event.OnScroll, function(_,scrollpercent)
        -- print(scrollpercent)
      -- end)


      buttonParentFrame = AchievementFrameHeader
      buttonAnchorFrame = AchievementFrameHeaderPointBorder


    -- ####################################################################
    -- ### Retail
    -- ####################################################################
    else

      hooksecurefunc("AchievementFrameCategories_OnCategoryChanged", function(categoryID)
        -- print(GetTime(), "AchievementFrameCategories_OnCategoryChanged", categoryID)
        if lastCategoryID ~= categoryID then

          RememberLastState()

          lastCategoryChangeTime = GetTime()
          lastCategoryID = categoryID
          lastCategoryScrollPosition = AchievementFrameCategories.ScrollBox.scrollPercentage

          lastAchievementID = nil
        end
      end)

      -- In Retail, we need this function for jumping to an achievement...
      hooksecurefunc("AchievementFrame_SelectAchievement", function(achievementID)
        -- print(GetTime(), "AchievementFrame_SelectAchievement", achievementID)

        if achievementID and achievementID ~= lastAchievementID then

          RememberLastState()

          lastAchievementChangeTime = GetTime()
          lastAchievementID = achievementID
          lastAchievementScrollPosition = AchievementFrameAchievements.ScrollBox.scrollPercentage

          lastCategoryScrollPosition = AchievementFrameCategories.ScrollBox.scrollPercentage
        end
      end)

      -- ...and this funciton for clicking on an achievement.
      hooksecurefunc(AchievementTemplateMixin, "ProcessClick", function()
        local achievementID = AchievementFrameAchievements_GetSelectedAchievementId()
        -- print("AchievementTemplateMixin.ProcessClick", achievementID, AchievementFrameAchievements.ScrollBox.scrollPercentage)

        -- When deselecting an achievement, GetSelectedAchievementId() returns 0, which we are not interested in.
        if achievementID and achievementID ~= lastAchievementID and achievementID ~= 0 then

          -- Do not remember, when coming from the same category with no achievement selected.
          if lastCategoryID ~= GetAchievementCategory(achievementID) or lastAchievementID then
            RememberLastState()
          end

          lastAchievementChangeTime = GetTime()
          lastAchievementID = achievementID
          lastAchievementScrollPosition = AchievementFrameAchievements.ScrollBox.scrollPercentage

          lastCategoryScrollPosition = AchievementFrameCategories.ScrollBox.scrollPercentage
        end

      end)


      local achievementScrollBar = AchievementFrameAchievements.ScrollBar
      achievementScrollBar:RegisterCallback(achievementScrollBar.Event.OnScroll,function(_, scrollPercent)
        -- print(GetTime(), "achievementScrollBar", scrollPercent)
        if lastAchievementChangeTime == GetTime() and lastAchievementScrollPosition ~= scrollPercent then
          -- print(GetTime(), "Overriding lastAchievementScrollPosition", lastAchievementScrollPosition, "with", scrollPercent)
          lastAchievementScrollPosition = scrollPercent
        end
      end)

      local categoryScrollBar = AchievementFrameCategories.ScrollBar
      categoryScrollBar:RegisterCallback(categoryScrollBar.Event.OnScroll,function(_, scrollPercent)
        -- print(GetTime(), "categoryScrollBar", scrollPercent)
        if (lastCategoryChangeTime == GetTime() or lastAchievementChangeTime == GetTime()) and lastCategoryScrollPosition ~= scrollPercent then
          -- print(GetTime(), "Overriding lastCategoryScrollPosition", lastCategoryScrollPosition, "with", scrollPercent)
          lastCategoryScrollPosition = scrollPercent
        end
      end)

      buttonParentFrame = AchievementFrame.Header
      buttonAnchorFrame = AchievementFrame.Header.PointBorder
    end
    -- ####################################################################
    -- ### End
    -- ####################################################################


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
