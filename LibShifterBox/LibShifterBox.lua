local LIB_IDENTIFIER = "LibShifterBox"

assert(not _G[LIB_IDENTIFIER], LIB_IDENTIFIER .. " is already loaded")

local lib = {}
_G[LIB_IDENTIFIER] = lib

-- =================================================================================================================
-- == LIBRARY CONSTANTS/VARIABLES == --
-- -----------------------------------------------------------------------------------------------------------------
local LIST_SPACING = 40
local ARROW_SIZE = 36
local HEADER_HEIGHT = 32
local DATA_TYPE_DEFAULT = 1
local DATA_DEFAULT_CATEGORY = "LSBDefCat"
local SCROLLBAR_WIDTH = ZO_SCROLL_BAR_WIDTH
local RESELECTING_DURING_REBUILD = true
local ANIMATION_FIELD_NAME = "SelectionAnimation"

local existingShifterBoxes = {}

local defaultSettings = {
    sortBy = "value",
    rowHeight = 32,
    emptyListText = "empty",
    showMoveAllButtons = true,
}

-- KNOWN ISSUES
-- TODO: Calling UnselectAllEntries() when mouse-over causes text to become white
-- TODO: font color?
-- TODO: font?

-- =================================================================================================================
-- == PRIVATE FGUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
local function _getDeepClonedTable(sourceTable)
    local targetTable = {}
    ZO_DeepTableCopy(sourceTable, targetTable)
    return targetTable
end

local function _getShallowClonedTable(sourceTable)
    local targetTable = {}
    ZO_ShallowTableCopy(sourceTable, targetTable)
    return targetTable
end


-- =================================================================================================================
-- == SCROLL-LISTS == --
-- -----------------------------------------------------------------------------------------------------------------
-- Source: https://esoapi.uesp.net/100028/src/libraries/zo_sortfilterlist/zo_sortfilterlist.lua.html
local ShifterBoxList = ZO_SortFilterList:Subclass()

ShifterBoxList.SORT_KEYS = {
    ["value"] = {},
    ["key"] = {tiebreaker="value"}
}

function ShifterBoxList:New(control, shifterBoxSettings)
    local obj = ZO_SortFilterList.New(self, control, shifterBoxSettings)
    obj.buttonControl = control:GetNamedChild("Button")
    obj.buttonAllControl = control:GetNamedChild("AllButton")
    obj.buttonAllControl:SetState(BSTATE_DISABLED, true) -- init it as disabled
    if shifterBoxSettings.showMoveAllButtons == false then obj.buttonAllControl:SetHidden(true) end
    obj.enabled = true
    obj.masterList = {}
    return obj
end

function ShifterBoxList:OnSelectionChanged(previouslySelectedData, selectedData, reselectingDuringRebuild)
    local selectedMultiData = self.list.selectedMultiData
    if selectedMultiData then
        local count = 0
        for _ in pairs(selectedMultiData) do count = count + 1 end
        if count > 0 then
            self.buttonControl:SetState(BSTATE_NORMAL, false)
        else
            self.buttonControl:SetState(BSTATE_DISABLED, true)
        end
    end
end

function ShifterBoxList:Initialize(control, shifterBoxSettings)
    self.rowHeight = shifterBoxSettings.rowHeight
    self.rowWidth = 180 -- default value to init
    -- initialize the SortFilterList
    ZO_SortFilterList.Initialize(self, control)
    -- set a text that is displayed when there are no entries
    self:SetEmptyText(shifterBoxSettings.emptyListText)
    -- default sorting key
    -- Source: https://esodata.uesp.net/100028/src/libraries/zo_sortheadergroup/zo_sortheadergroup.lua.html
    self.sortHeaderGroup:SelectHeaderByKey("value")
    ZO_SortHeader_OnMouseExit(self.control:GetNamedChild("Headers"):GetNamedChild("Value"))
    -- define the datatype for this list and enable the highlighting
    ZO_ScrollList_AddCategory(self.list, DATA_DEFAULT_CATEGORY)
    ZO_ScrollList_AddDataType(self.list, DATA_TYPE_DEFAULT, "ShifterBoxEntryTemplate", self.rowHeight, function(control, data) self:SetupRowEntry(control, data) end)
    ZO_ScrollList_EnableSelection(self.list, "ZO_ThinListHighlight", function(...)
        self:OnSelectionChanged(...)
    end)

    -- set up sorting function and refresh all data
    self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, shifterBoxSettings.sortBy, ShifterBoxList.SORT_KEYS, self.currentSortOrder) end
    self:RefreshData()
end

-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshSort()                                                      =>  SortScrollList()    =>  CommitScrollList()

function ShifterBoxList:BuildMasterList()
    -- intended to be overriden
    -- should build the master list of data that is later filtered by FilterScrollList
end

function ShifterBoxList:FilterScrollList()
    -- intended to be overriden
    -- should take the master list data and filter it
    local hasAtLeastOneEntry = false
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
    if self.masterList then
        local categories = self.list.categories
        for key, data in pairs(self.masterList) do
            -- check if the categoryId is NOT existing; or NOT set to hidden
            local category = categories[data.categoryId]
            if category == nil or category.hidden == false then
                local rowData = {
                    key = key,
                    value = data.value
                }
                table.insert(scrollData, ZO_ScrollList_CreateDataEntry(DATA_TYPE_DEFAULT, rowData, data.categoryId or DATA_DEFAULT_CATEGORY))
                hasAtLeastOneEntry = true
            else
                -- entry will not (or will no longer) be visible
                if self.list.selectedMultiData then
                    self.list.selectedMultiData[key] = nil
                end
            end
        end
    end
    if hasAtLeastOneEntry then
        -- when there is at least one entry, the move-all button can be enabled
        self.buttonAllControl:SetState(BSTATE_NORMAL, false)
        self:OnSelectionChanged()
    else
        -- if there are no entries ; disable both move buttons
        if self.buttonControl then
            self.buttonControl:SetState(BSTATE_DISABLED, true)
        end
        if self.buttonAllControl then
            self.buttonAllControl:SetState(BSTATE_DISABLED, true)
        end
    end
end

function ShifterBoxList:SortScrollList()
    -- intended to be overriden
    -- should take the filtered data and sort it
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end

function ShifterBoxList:AddEntry(key, value, categoryId)
    local data = {
        value = value,
        categoryId = categoryId
    }
    self.masterList[key] = data
end

function ShifterBoxList:RemoveEntry(key)
    if self.masterList[key] ~= nil then
        local data = _getShallowClonedTable(self.masterList[key])
        -- remove the entry from the masterList
        self.masterList[key] = nil
        -- and remove it from the selectedList
        if self.list.selectedMultiData then
            self.list.selectedMultiData[key] = nil
        end
        return key, data.value, data.categoryId
    end
    return nil
end

function ShifterBoxList:ClearMasterList()
    self.masterList = {}
    self:RefreshFilters()
end

function ShifterBoxList:UnselectEntries()
    self.list.selectedMultiData = {}
    self:CommitScrollList()
    self.buttonControl:SetState(BSTATE_DISABLED, true)
end

--- this function only visually selects an entry, it does NOT store it in the selected-list though!
function ShifterBoxList:SelectControl(control, animateInstantly)
    local controlTemplate = self.list.selectionTemplate
    local animationFieldName = ANIMATION_FIELD_NAME
    -- SelectControl()
    if controlTemplate then
        if not control[animationFieldName] then
            local highlight = CreateControlFromVirtual("$(parent)Scroll", control, controlTemplate, animationFieldName)
            control[animationFieldName] = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
        end
        if animateInstantly then
            control[animationFieldName]:PlayInstantlyToEnd()
        else
            control[animationFieldName]:PlayForward()
        end
    end
end

--- this function only visually unselects an entry, it does NOT remove it from the selected-list though!
function ShifterBoxList:UnselectControl(control, animateInstantly)
    local animationFieldName = ANIMATION_FIELD_NAME
    -- UnselectControl()
    if control[animationFieldName] then
        if animateInstantly then
            control[animationFieldName]:PlayInstantlyToStart()
        else
            control[animationFieldName]:PlayBackward()
        end
    end
end

-- Custom implementation based on: https://esoapi.uesp.net/100028/src/libraries/zo_templates/scrolltemplates.lua.html#1456
--- this function toggles the selection of an entry and also adds/removes it to/from the selected-list
-- @param data - the table with the data of the entry (mandatory)
-- @param control - the control of the entry (optional - can be deferred from data)
-- @param reselectingDuringRebuild - to be defined
-- @param animateInstantly - if the selection animation is instantly or not
-- @param deselectOnReselect - if the entry is already selected, instead of reselecting it will be deselected
function ShifterBoxList:ToggleEntrySelection(data, control, reselectingDuringRebuild, animateInstantly, deselectOnReselect )
    if not self.enabled then return end -- if the listBox is not enabled; immediately exit the function
    if reselectingDuringRebuild == nil then
        reselectingDuringRebuild = false
    end
    if animateInstantly == nil then
        animateInstantly = false
    end
    if deselectOnReselect  == nil then
        deselectOnReselect  = true
    end
    local dataKey
    if data ~= nil then
        for i = 1, #self.list.data do
            local currData = self.list.data[i].data
            if currData == data then
                dataKey = currData.key
                break
            end
        end
        -- this data we tried to select isn't in the scroll list at all, just abort
        if dataKey == nil then return end
    end
    if self.list.selectedMultiData == nil then
        self.list.selectedMultiData = {}
    end
    if data ~= nil then
        if not control then
            control = ZO_ScrollList_GetDataControl(self.list, data)
        end
        -- check if already selected
        if self.list.selectedMultiData[dataKey] == nil then
            -- add selected data
            self.list.selectedMultiData[dataKey] = data
            -- and select the control (if applicable)
            if control then self:SelectControl(control, animateInstantly) end
        elseif deselectOnReselect then
            -- remove selected data
            self.list.selectedMultiData[dataKey] = nil
            -- and unselect the control (if applicable)
            if control then self:UnselectControl(control, animateInstantly) end
        end
    end
    if self.list.selectionCallback then
        self.list.selectionCallback(data, self.list.selectedMultiData, reselectingDuringRebuild)
    end
end

function ShifterBoxList:SetupRowEntry(rowControl, rowData)
    local subSelf = self
    local function onRowMouseEnter(rowControl)
        local labelControl = rowControl:GetNamedChild("Label")
        local textWidth = labelControl:GetTextWidth()
        local desiredWidth = labelControl:GetDesiredWidth()
        -- only show tooltip if the text/label was truncated or if the text is wider than the desiredWidth minus the scrollbar width
        local wasTruncated = rowControl:GetNamedChild("Label"):WasTruncated()
        if wasTruncated or (textWidth + SCROLLBAR_WIDTH) > desiredWidth then
            local data = ZO_ScrollList_GetData(rowControl)
            ZO_Tooltips_ShowTextTooltip(rowControl, TOP, data.value)
        end
    end
    local function onRowMouseExit(rowControl)
        ZO_Tooltips_HideTextTooltip()
    end
    local function onRowClicked(rowControl)
        local data = ZO_ScrollList_GetData(rowControl)
        self:ToggleEntrySelection(data, rowControl, RESELECTING_DURING_REBUILD, false)
    end
    -- set the value for the row entry
    local labelControl = rowControl:GetNamedChild("Label")
    labelControl:SetText(rowData.value)
    -- the below two handlers only work if "PersonalAssistantBankingRuleListRowTemplate" is set to a <Button> control
    rowControl:SetHandler("OnMouseEnter", onRowMouseEnter)
    rowControl:SetHandler("OnMouseExit", onRowMouseExit)
    -- handle single clicks to mark entry
    rowControl:SetHandler("OnClicked", onRowClicked)

    -- set the height for the row
    rowControl:SetHeight(self.rowHeight)
    -- and also set the width for the row (to ensure tooltips work properly)
    rowControl:SetWidth(self.rowWidth)
    labelControl:SetWidth(self.rowWidth)

    -- reselect entries (only visually) if necessary
    local selectedMultiData = self.list.selectedMultiData
    if selectedMultiData and selectedMultiData[rowData.key] ~= nil then
        self:SelectControl(rowControl, false)
    end

    -- then setup the row
    ZO_SortFilterList.SetupRow(self, rowControl, rowData)
end

function ShifterBoxList:SetCustomDimensions(width, height, headerHeight)
    -- first set width/height of the listbox itself
    self.rowWidth = width - SCROLLBAR_WIDTH
    self.list:SetDimensions(width, height)
    self.headersContainer:SetDimensions(width, headerHeight)
    -- and of the header (needed to cut down headers that are too long)
    local headerValueControl = self.headersContainer:GetNamedChild("Value")
    headerValueControl:SetWidth(width)
    -- then re-set the anchor for the arrow to reposition itself
    local headerValueNameControl = headerValueControl:GetNamedChild("Name")
    local headerArrowControl = self.headersContainer:GetNamedChild("Arrow")
    local headerTextWidth = headerValueNameControl:GetTextWidth()
    headerArrowControl:ClearAnchors()
    if headerTextWidth > width then
        -- FIXME: does not correctly work when the ShifterBox is made bigger because the TextWidth() is not updated yet
        headerArrowControl:SetAnchor(LEFT, headerValueNameControl, LEFT, width, 0)
    else
        headerArrowControl:SetAnchor(LEFT, headerValueNameControl, LEFT, headerTextWidth, 0)
    end
end

function ShifterBoxList:Refresh()
    -- make sure that all rows have the correct width
    local rowControls = self.list.contents
    for childIndex = 1, rowControls:GetNumChildren() do
        local rowControl = rowControls:GetChild(childIndex)
        local rowControlLabel = rowControl:GetNamedChild("Label")
        rowControlLabel:SetWidth(rowControl:GetWidth())
    end
    -- then update the scroll list (i.e. update scrollbar)
    self:CommitScrollList()
end

function ShifterBoxList:SetEntriesEnabled(enabled)
    if not enabled then
        -- unselect all entries
        self:UnselectEntries()
    end
    -- after unselecing all entries, change the actual state of the rowControl-buttons
    local rowControls = self.list.contents
    for childIndex = 1, rowControls:GetNumChildren() do
        local rowControl = rowControls:GetChild(childIndex)
        rowControl:SetEnabled(enabled)
    end
    rowControls:SetAlpha(enabled and 1 or 0.3)
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    local numChildren = #scrollData
    -- enable/disable the "all" button
    if enabled and numChildren > 0 then
        self.buttonAllControl:SetState(BSTATE_NORMAL, false)
    else
        self.buttonAllControl:SetState(BSTATE_DISABLED, true)
    end
    -- finally, store the enabled state
    self.enabled = enabled
end


-- =================================================================================================================
-- == SHIFTERBOX PRIVATE FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
local function _createShifterBox(uniqueAddonName, uniqueShifterBoxName, parentControl)
    local shifterBoxName = table.concat({uniqueAddonName, "_", uniqueShifterBoxName})
    return CreateControlFromVirtual(shifterBoxName, parentControl, "ShifterBoxTemplate")
end

local function _moveEntryFromTo(fromList, toList, key)
    local key, value, categoryId = fromList:RemoveEntry(key)
    if key ~= nil then
        toList:AddEntry(key, value, categoryId)
    end
end

local function _assertKeyIsNotInTable(key, value, self, sideControl)
    local masterList = self.masterList
    assert(masterList[key] == nil, string.format(LIB_IDENTIFIER.."_Error: Violation of UNIQUE KEY. Cannot insert duplicate key '%s' with value '%s' in control '%s'. The statement has been terminated.", tostring(key), tostring(value), sideControl:GetName()))
end

local function _initShifterBoxControls(self, leftListTitle, rightListTitle)
    local control = self.shifterBoxControl
    local leftControl = control:GetNamedChild("Left")
    local rightControl = control:GetNamedChild("Right")
    local fromLeftButtonControl = leftControl:GetNamedChild("Button")
    local fromRightButtonControl = rightControl:GetNamedChild("Button")
    local rightListControl = rightControl:GetNamedChild("List")
    local leftListControl = leftControl:GetNamedChild("List")

    local function initListFrames(parentListControl)
        local listFrameControl = parentListControl:GetNamedChild("Frame")
        listFrameControl:SetCenterColor(0, 0, 0, 1)
        listFrameControl:SetEdgeTexture(nil, 1, 1, 1)
    end

    local function initHeaders(self, leftListTitle, rightListTitle)
        if leftListTitle ~= nil or rightListTitle ~= nil then
            self.headerHeight = HEADER_HEIGHT
            -- show the headers (default = hidden)
            local leftHeaders = leftControl:GetNamedChild("Headers")
            local leftHeadersTitle = leftHeaders:GetNamedChild("Value"):GetNamedChild("Name")
            leftHeaders:SetHeight(self.headerHeight)
            leftHeaders:SetHidden(false)
            leftHeadersTitle:SetText(leftListTitle or "")

            local rightHeaders = rightControl:GetNamedChild("Headers")
            local rightHeadersTitle = rightHeaders:GetNamedChild("Value"):GetNamedChild("Name")
            rightHeaders:SetHeight(self.headerHeight)
            rightHeaders:SetHidden(false)
            rightHeadersTitle:SetText(rightListTitle or "")
        else
            self.headerHeight = 0
        end
    end

    -- initialise the headers
    initHeaders(self, leftListTitle, rightListTitle)

    -- initialize the frame/border around the listBoxes
    initListFrames(leftListControl)
    initListFrames(rightListControl)

    -- initialize the buttons in disabled state
    fromLeftButtonControl:SetState(BSTATE_DISABLED, true)
    fromRightButtonControl:SetState(BSTATE_DISABLED, true)
end

local function _initShifterBoxHandlers(self)
    local control = self.shifterBoxControl
    local leftControl = control:GetNamedChild("Left")
    local fromLeftButtonControl = leftControl:GetNamedChild("Button")
    local fromLeftAllButtonControl = leftControl:GetNamedChild("AllButton")
    local rightControl = control:GetNamedChild("Right")
    local fromRightButtonControl = rightControl:GetNamedChild("Button")
    local fromRightAllButtonControl = rightControl:GetNamedChild("AllButton")

    local function toLeftButtonClicked(buttonControl)
        local rightListSelectedData = self.rightList.list.selectedMultiData
        for key, data in pairs(rightListSelectedData) do
            _moveEntryFromTo(self.rightList, self.leftList, data.key)
        end
        -- then commit the changes to the scrollList and refresh the hidden states
        self.leftList:RefreshFilters()
        self.rightList:RefreshFilters()
        -- finally disable the button itself
        buttonControl:SetState(BSTATE_DISABLED, true)
    end
    local function toLeftAllButtonClicked(buttonControl)
        -- move all entries
        self:MoveAllEntriesToLeftList()
        -- and disable the move-all button
        buttonControl:SetState(BSTATE_DISABLED, true)
    end

    local function toRightButtonClicked(buttonControl)
        local leftListSelectedData = self.leftList.list.selectedMultiData
        for key, data in pairs(leftListSelectedData) do
            _moveEntryFromTo(self.leftList, self.rightList, data.key)
        end
        -- then commit the changes to the scrollList and refresh the hidden states
        self.leftList:RefreshFilters()
        self.rightList:RefreshFilters()
        -- finally disable the button itself
        buttonControl:SetState(BSTATE_DISABLED, true)
    end
    local function toRightAllButtonClicked(buttonControl)
        -- move all entries
        self:MoveAllEntriesToRightList()
        -- and disable the move-all button
        buttonControl:SetState(BSTATE_DISABLED, true)
    end

    -- initialize the handler when the buttons are clicked
    fromLeftButtonControl:SetHandler("OnClicked", toRightButtonClicked)
    fromLeftAllButtonControl:SetHandler("OnClicked", toRightAllButtonClicked)
    fromRightButtonControl:SetHandler("OnClicked", toLeftButtonClicked)
    fromRightAllButtonControl:SetHandler("OnClicked", toLeftAllButtonClicked)
end

local function _applyCustomSettings(customSettings)
    -- if no custom settings provided, use the default ones
    local settings = ZO_ShallowTableCopy(defaultSettings)
    if customSettings == nil then return settings end
    -- otherwise validate them
    if customSettings.sortBy then
        assert(customSettings.sortBy == "value" or customSettings.sortBy == "key", string.format(LIB_IDENTIFIER.."_Error: Invalid sortBy parameter '%s' provided! Only 'value' and 'key' are allowed.", tostring(customSettings.sortBy)))
        settings.sortBy = customSettings.sortBy
    end
    if customSettings.rowHeight then
        assert(type(customSettings.rowHeight) == "number" and customSettings.rowHeight > 0, string.format(LIB_IDENTIFIER.."_Error: Invalid rowHeight parameter '%s' provided! Must be a numeric and positive.", tostring(customSettings.rowHeight)))
        settings.rowHeight = customSettings.rowHeight
    end
    if customSettings.emptyListText then
        assert(type(customSettings.emptyListText) == "string", string.format(LIB_IDENTIFIER.."_Error: Invalid emptyListText parameter '%s' provided! Must be a string.", tostring(customSettings.emptyListText)))
        settings.emptyListText = customSettings.emptyListText
    end
    if customSettings.showMoveAllButtons ~= nil then
        assert(type(customSettings.showMoveAllButtons) == "boolean", string.format(LIB_IDENTIFIER.."_Error: Invalid showMoveAllButtons parameter '%s' provided! Must be a boolean.", tostring(customSettings.showMoveAllButtons)))
        settings.showMoveAllButtons = customSettings.showMoveAllButtons
    end
    return settings
end

local function _getListBoxWidthAndArrowOffset(width, height)
    -- widh must be at least three times the space between the listBoxes
    if width < (3 * LIST_SPACING) then width = (3 * LIST_SPACING) end
    -- the width of a listBox is the total width minus the spacing divided by two
    local singleListWidth = (width - LIST_SPACING) / 2
    -- get the "free height" that is not required by the arrows
    local freeHeight = height - (4 * ARROW_SIZE)
    -- the offset of the arrow is 2/4th of the remaining height plus the height of the arrow
    local arrowOffset = ARROW_SIZE + (freeHeight / 5 * 2)
    -- the offset of the all-arrow is 1/5th of the remaining height
    local arrowAllOffset = freeHeight / 5
    return singleListWidth, arrowOffset, arrowAllOffset
end

local function _setListBoxDimensions(list, singleListWidth, height, headerHeight, buttonAnchorOptions, buttonAllAnchorOptions)
    local buttonControl = list.control:GetNamedChild("Button")
    buttonControl:ClearAnchors()
    buttonControl:SetAnchor(unpack(buttonAnchorOptions))
    local buttonAllControl = list.control:GetNamedChild("AllButton")
    buttonAllControl:ClearAnchors()
    buttonAllControl:SetAnchor(unpack(buttonAllAnchorOptions))
    list:SetCustomDimensions(singleListWidth, height, headerHeight)
    list:Refresh()
end

-- ---------------------------------------------------------------------------------------------------------------------

local function _refreshFilters(leftList, rightList)
    if leftList then leftList:RefreshFilters() end
    if rightList then rightList:RefreshFilters() end
end

local function _selectEntries(list, keys)
    local visibleData = list.list.visibleData
    for _, visibleKey in ipairs(visibleData) do
        local dataEntry = list.list.data[visibleKey]
        local data = dataEntry.data
        for _, key in pairs(keys) do
            if data.key == key then
                local control = dataEntry.control -- can be nil if control is out-of-scroll-view
                list:ToggleEntrySelection(data, control, nil, nil, false)
                break
            end
        end
    end
end

local function _selectEntry(list, key)
    local keys = { key }
    _selectEntries(list, keys)
end

local function _removeEntriesFromList(list, keys)
    local hasAtLeastOneRemoved = false
    for _, key in pairs(keys) do
        local removedKey = list:RemoveEntry(key)
        if removedKey ~= nil then hasAtLeastOneRemoved = true end
    end
    if hasAtLeastOneRemoved then
        _refreshFilters(list)
    end
end

local function _removeEntryFromList(list, key)
    local keys = { key }
    _removeEntriesFromList(list, keys)
end

local function _getEntries(list, includeHiddenEntries, withCategoryId)
    local function _addToTable(table, key, value, categoryId)
        if withCategoryId then
            table[key] = {
                value = value,
                categoryId = categoryId
            }
        else
            table[key] = value
        end
    end
    local exportList = {}
    if includeHiddenEntries then
        local masterList = list.masterList
        if withCategoryId then
            exportList = _getShallowClonedTable(masterList)
        else
            for key, entry in pairs(masterList) do
                exportList[key] = entry.value
            end
        end
    else
        local listData = list.list.data
        for _, entry in ipairs(listData) do
            if withCategoryId then
                _addToTable(exportList, entry.data.key, entry.data.value, entry.categoryId)
            else
                exportList[entry.data.key] = entry.data.value
            end
        end
    end
    return exportList
end

local function _addEntriesToList(list, entries, replace, otherList, categoryId)
    local hasAtLeastOneAdded = false
    local hasAtLeastOneRemoved = false
    local listControl = list.control
    local otherListControl = otherList.control
    if categoryId ~= nil then
        -- if a category is provided, ensure that it definitely is registered to the scrollist
        ZO_ScrollList_AddCategory(list.list, categoryId)
        ZO_ScrollList_AddCategory(otherList.list, categoryId)
    end
    for key, value in pairs(entries) do
        if replace and replace == true then
            -- if replace is set to true, make sure that a potential entry with the same key is removed from both lists
            local removeKey = list:RemoveEntry(key)
            local otherRemoveKey = otherList:RemoveEntry(key)
            if removeKey ~= nil or otherRemoveKey ~= nil then hasAtLeastOneRemoved = true end
        else
            -- if replace is not set or set to false, then assert that key does not exist in either list
            _assertKeyIsNotInTable(key, value, list, listControl)
            _assertKeyIsNotInTable(key, value, otherList, otherListControl)
        end
        -- then add entry to the corresponding list
        list:AddEntry(key, value, categoryId)
        hasAtLeastOneAdded = true
    end
    if hasAtLeastOneAdded then
        -- Afterwards refresh the visualisation of the data
        _refreshFilters(list)
        if hasAtLeastOneRemoved then
            _refreshFilters(otherList)
        end
    end
end

local function _addEntryToList(list, key, value, replace, otherList, categoryId)
    local entries = { [key] = value }
    _addEntriesToList(list, entries, replace, otherList, categoryId)
end

local function _moveEntriesToOtherList(sourceList, keys, destList)
    for _, key in pairs(keys) do
        _moveEntryFromTo(sourceList, destList, key)
    end
    -- refresh the display afterwards
    _refreshFilters(sourceList, destList)
end

local function _moveEntryToOtherList(sourceList, key, destList)
    local keys = { key }
    _moveEntriesToOtherList(sourceList, keys, destList)
end

local function _clearList(list)
    list:ClearMasterList()
    list.buttonControl:SetState(BSTATE_DISABLED, true)
end


-- =================================================================================================================
-- == SHIFTERBOX PUBLIC FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
local ShifterBox = ZO_Object:Subclass()

--- Creates a new ShifterBox object with optional list headers
-- @param uniqueAddonName - the unique name of your addon
-- @param uniqueShifterBoxName - the unique name of this shifterBox (within your addon)
-- @param parentControl - the control reference to which the shifterBox should be added as a child
-- @param leftListTitle - the title for the left listBox (can be empty)
-- @param rightListTitle - the title for the right listBox (can be empty)
-- @param customSettings - custom settings table (can be empty, default settings will be used then)
-- @param anchorPoint - anchor point (can be empty, you need to call yourShifterBox:SetAnchor on your own then)
-- @param anchorRelativeTo - anchor relative to control (can be empty, you need to call yourShifterBox:SetAnchor on your own then)
-- @param anchorRelPoint - anchor relative point (can be empty, you need to call yourShifterBox:SetAnchor on your own then)
-- @param anchorOffsetX - anchor offset x (can be empty, you need to call yourShifterBox:SetAnchor on your own then)
-- @param anchorOffsetY - anchor offset y (can be empty, you need to call yourShifterBox:SetAnchor on your own then)
-- @param dimensionX - dimension x (can be empty, you need to call yourShifterBox:SetDimension on your own then)
-- @param dimensionY - dimension y (can be empty, you need to call yourShifterBox:SetDimension on your own then)
-- @param leftListEntries - the left list's entry. A table or a function returning a table (can be left entry. You need to add the entries via yourShifterBox:AddEntriesToLeftList on your own then)
-- @param rightListEntries - the right list's entry. A table or a function returning a table (can be left entry. You need to add the entries via yourShifterBox:AddEntriesToRightList on your own then)
function ShifterBox:New(uniqueAddonName, uniqueShifterBoxName, parentControl, leftListTitle, rightListTitle, customSettings, anchorPoint, anchorRelativeTo, anchorRelPoint, anchorOffsetX, anchorOffsetY, dimensionX, dimensionY, leftListEntries, rightListEntries)
    if existingShifterBoxes[uniqueAddonName] == nil then
        existingShifterBoxes[uniqueAddonName] = {}
    end
    local addonShifterBoxes = existingShifterBoxes[uniqueAddonName]
    assert(addonShifterBoxes[uniqueShifterBoxName] == nil, string.format(LIB_IDENTIFIER.."_Error: ShifterBox with the unique identifier '%s' is already registered for the addon '%s'!", tostring(uniqueShifterBoxName), tostring(uniqueAddonName)))

    local obj = ZO_Object.New(self)
    obj.addonName = uniqueAddonName
    obj.shifterBoxName = uniqueShifterBoxName
    obj.shifterBoxSettings = _applyCustomSettings(customSettings)
    obj.shifterBoxControl = _createShifterBox(uniqueAddonName, uniqueShifterBoxName, parentControl)
    local obj_ctrl = obj.shifterBoxControl
    _initShifterBoxControls(obj, leftListTitle, rightListTitle)
    _initShifterBoxHandlers(obj)

    -- initialize the ShifterBoxLists
    local leftControl = obj_ctrl:GetNamedChild("Left")
    local rightControl = obj_ctrl:GetNamedChild("Right")
    obj.leftList = ShifterBoxList:New(leftControl, obj.shifterBoxSettings)
    obj.rightList = ShifterBoxList:New(rightControl, obj.shifterBoxSettings)

    --anchor
    if anchorPoint and anchorRelativeTo then
        anchorOffsetX = anchorOffsetX or 0
        anchorOffsetY = anchorOffsetY or 0
        obj:SetAnchor(anchorPoint, anchorRelativeTo, anchorRelPoint, anchorOffsetX, anchorOffsetY)
    end
    --dimensions
    if dimensionX and dimensionY then
        obj:SetDimensions(dimensionX, dimensionY)
    end
    --list entries left
    local leftListEntriesTab
    if leftListEntries then
        if type(leftListEntries) == "function" then
            leftListEntriesTab = leftListEntries()
        else
            leftListEntriesTab = leftListEntries
        end
    end
    if leftListEntriesTab then
        obj:AddEntriesToLeftList(leftListEntriesTab)
    end
    --list entries right
    local rightListEntriesTab
    if rightListEntries then
        if type(rightListEntries) == "function" then
            rightListEntriesTab = rightListEntries()
        else
            rightListEntriesTab = rightListEntries
        end
    end
    if rightListEntriesTab then
        obj:AddEntriesToRightList(rightListEntriesTab)
    end
    -- register the shifterBox in the internal list and return it
    addonShifterBoxes[uniqueShifterBoxName] = obj
    return addonShifterBoxes[uniqueShifterBoxName]
end

function ShifterBox:GetControl()
    return self.shifterBoxControl
end

--- Clears the current anchor(s) and sets a new one
function ShifterBox:SetAnchor(...)
    self.shifterBoxControl:ClearAnchors()
    self.shifterBoxControl:SetAnchor(...)
end

--- Sets the dimensions for the shifterBox
-- @param width - the width for the whole shifterBox
-- @param height - the height for the whole shifterBox (incl. headers if applicable)
function ShifterBox:SetDimensions(width, height)
    assert(type(width) == "number" and type(height) == "number", string.format(LIB_IDENTIFIER.."_Error: width and height must be numeric values!"))
    -- height must be at least 4x the height of the arrows
    if height < 4 * ARROW_SIZE then height = 4 * ARROW_SIZE end
    local singleListWidth, arrowOffset, arrowAllOffset = _getListBoxWidthAndArrowOffset(width, height)
    local headerHeight = self.headerHeight
    local leftList = self.leftList
    local rightList = self.rightList
    local leftButtonAnchorOptions = {TOPLEFT, leftList.list, TOPRIGHT, 0, arrowOffset}
    local leftButtonAllAnchorOptions = {TOPLEFT, leftList.list, TOPRIGHT, 0, arrowAllOffset}
    local rightButtonAnchorOptions = {BOTTOMRIGHT, rightList.list, BOTTOMLEFT, -2, arrowOffset * -1} -- lower arrow requires negative offset
    local rightButtonAllAnchorOptions = {BOTTOMRIGHT, rightList.list, BOTTOMLEFT, -2, arrowAllOffset * -1} -- lower arrow requires negative offset
    _setListBoxDimensions(leftList, singleListWidth, height, self.headerHeight, leftButtonAnchorOptions, leftButtonAllAnchorOptions)
    _setListBoxDimensions(rightList, singleListWidth, height, self.headerHeight, rightButtonAnchorOptions, rightButtonAllAnchorOptions)
end

function ShifterBox:SetEnabled(enabled)
    self.leftList:SetEntriesEnabled(enabled)
    self.rightList:SetEntriesEnabled(enabled)
end

--- Sets the complete shifterBox to hidden, or shows it again
-- @param isHidden - whether the shifterBox should be hidden (boolean)
function ShifterBox:SetHidden(hidden)
    self.shifterBoxControl:SetHidden(hidden)
end

function ShifterBox:ShowCategory(categoryId)
    assert(categoryId ~= nil, string.format(LIB_IDENTIFIER.."_Error: categoryId cannot be nil!"))
    ZO_ScrollList_ShowCategory(self.leftList.list, categoryId)
    ZO_ScrollList_ShowCategory(self.rightList.list, categoryId)
    _refreshFilters(self.leftList, self.rightList)
end

function ShifterBox:ShowOnlyCategory(categoryId)
    local leftList = self.leftList.list
    for currCategoryId in pairs(leftList.categories) do
        if currCategoryId == categoryId then
            ZO_ScrollList_ShowCategory(leftList, currCategoryId)
        else
            ZO_ScrollList_HideCategory(leftList, currCategoryId)
        end
    end
    local rightList = self.rightList.list
    for currCategoryId in pairs(rightList.categories) do
        if currCategoryId == categoryId then
            ZO_ScrollList_ShowCategory(rightList, currCategoryId)
        else
            ZO_ScrollList_HideCategory(rightList, currCategoryId)
        end
    end
    _refreshFilters(self.leftList, self.rightList)
end

function ShifterBox:ShowAllCategories()
    local leftList = self.leftList.list
    for categoryId in pairs(leftList.categories) do
        ZO_ScrollList_ShowCategory(leftList, categoryId)
    end
    local rightList = self.rightList.list
    for categoryId in pairs(rightList.categories) do
        ZO_ScrollList_ShowCategory(rightList, categoryId)
    end
    _refreshFilters(self.leftList, self.rightList)
end

function ShifterBox:HideCategory(categoryId)
    assert(categoryId ~= nil, string.format(LIB_IDENTIFIER.."_Error: categoryId cannot be nil!"))
    ZO_ScrollList_HideCategory(self.leftList.list, categoryId)
    ZO_ScrollList_HideCategory(self.rightList.list, categoryId)
    _refreshFilters(self.leftList, self.rightList)
end

function ShifterBox:SelectEntryByKey(key)
    _selectEntry(self.leftList, key)
    _selectEntry(self.rightList, key)
end

function ShifterBox:SelectEntriesByKey(keys)
    _selectEntries(self.leftList, keys)
    _selectEntries(self.rightList, keys)
end

function ShifterBox:UnselectAllEntries()
    self.leftList:UnselectEntries()
    self.rightList:UnselectEntries()
end

function ShifterBox:RemoveEntryByKey(key)
    _removeEntryFromList(self.leftList, key)
    _removeEntryFromList(self.rightList, key)
end

function ShifterBox:RemoveEntriesByKey(keys)
    _removeEntriesFromList(self.leftList, keys)
    _removeEntriesFromList(self.rightList, keys)
end

-- ---------------------------------------------------------------------------------------------------------------------

function ShifterBox:GetLeftListEntries(withCategoryId)
    return _getEntries(self.leftList, false, withCategoryId)
end

function ShifterBox:GetLeftListEntriesFull(withCategoryId)
    return _getEntries(self.leftList, true, withCategoryId)
end

function ShifterBox:AddEntryToLeftList(key, value, replace, categoryId)
    _addEntryToList(self.leftList, key, value, replace, self.rightList, categoryId)
end

function ShifterBox:AddEntriesToLeftList(entries, replace, categoryId)
    _addEntriesToList(self.leftList, entries, replace, self.rightList, categoryId)
end

function ShifterBox:MoveEntryToLeftList(key)
    _moveEntryToOtherList(self.rightList, key, self.leftList)
end

function ShifterBox:MoveEntriesToLeftList(keys)
    _moveEntriesToOtherList(self.rightList, keys, self.leftList)
end

function ShifterBox:MoveAllEntriesToLeftList()
    local keyset = {}
    for _, entry in pairs(self.rightList.list.data) do
        table.insert(keyset, entry.data.key)
    end
    _moveEntriesToOtherList(self.rightList, keyset, self.leftList)
end

function ShifterBox:ClearLeftList()
    _clearList(self.leftList)
end

-- ---------------------------------------------------------------------------------------------------------------------

function ShifterBox:GetRightListEntries(withCategoryId)
    return _getEntries(self.rightList, false, withCategoryId)
end

function ShifterBox:GetRightListEntriesFull(withCategoryId)
    return _getEntries(self.rightList, true, withCategoryId)
end

function ShifterBox:AddEntryToRightList(key, value, replace, categoryId)
    _addEntryToList(self.rightList, key, value, replace, self.leftList, categoryId)
end

function ShifterBox:AddEntriesToRightList(entries, replace, categoryId)
    _addEntriesToList(self.rightList, entries, replace, self.leftList, categoryId)
end

function ShifterBox:MoveEntryToRightList(key)
    _moveEntryToOtherList(self.leftList, key, self.rightList)
end

function ShifterBox:MoveEntriesToRightList(keys)
    _moveEntriesToOtherList(self.leftList, keys, self.rightList)
end

function ShifterBox:MoveAllEntriesToRightList()
    local keyset = {}
    for _, entry in pairs(self.leftList.list.data) do
        table.insert(keyset, entry.data.key)
    end
    _moveEntriesToOtherList(self.leftList, keyset, self.rightList)
end

function ShifterBox:ClearRightList()
    _clearList(self.rightList)
end


-- =================================================================================================================
-- == LIBRARY FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
lib.DEFAULT_CATEGORY = DATA_DEFAULT_CATEGORY

--- Returns an existing ShifterBox instance
-- @param uniqueAddonName - a string identifer for the consuming addon
-- @param uniqueShifterBoxName - a string identifier for the specific shifterBox
-- @return an existing shifterBox instance or nil if not found with the passed names
function lib.GetShifterBox(uniqueAddonName, uniqueShifterBoxName)
    local addonShifterBoxes = existingShifterBoxes[uniqueAddonName]
    if addonShifterBoxes ~= nil then
        return addonShifterBoxes[uniqueShifterBoxName]
    end
    return nil
end

--- Returns the CT_CONTROL object of an existing ShifterBox instance
-- @param uniqueAddonName - a string identifer for the consuming addon
-- @param uniqueShifterBoxName - a string identifier for the specific shifterBox
-- @return an existing shifterBox CT_CONTROL object or nil if not found with the passed names
function lib.GetControl(uniqueAddonName, uniqueShifterBoxName)
    local shifterBox = lib.GetShifterBox(uniqueAddonName, uniqueShifterBoxName)
    if shifterBox ~= nil then
        return shifterBox.shifterBoxControl
    end
    return nil
end

function lib.Create(...)
    return ShifterBox:New(...)
end
setmetatable(lib, { __call = function(_, ...) return lib.Create(...) end })
