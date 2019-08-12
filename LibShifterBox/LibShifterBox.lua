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
local DATA_CATEGORY_DEFAULT = "LSBCatDef"
local SCROLLBAR_WIDTH = ZO_SCROLL_BAR_WIDTH
local RESELECTING_DURING_REBUILD = true
local ANIMATION_FIELD_NAME = "SelectionAnimation"

local existingShifterBoxes = {}

local defaultSettings = {
    sortBy = "value",
--    showLeftAllButton = false,      -- TODO: implement this setting
--    showRightAllButton = false,     -- TODO: implement this setting
    rowHeight = 32,
    emptyListText = "empty",
}

-- OPEN TASKS
-- TODO: ShowAllCategories <-- to be tested!
-- TODO: SelectEntryByKey / SelectEntriesByKeyys
-- TODO: UnselectAllEntries
-- TODO: GetLeftListEntries / GetRightListEntries
-- TODO: GetEntries incl. category
-- TODO: when shifting entries over, they are not sorted anymore --> SortScrollList() ?
-- TODO: when shifting entries over, the button sometimes stays activated? (selectedMultiData is correct)


-- =================================================================================================================
-- == SCROLL-LISTS == --
-- -----------------------------------------------------------------------------------------------------------------
-- Source: https://esoapi.uesp.net/100027/src/libraries/zo_sortfilterlist/zo_sortfilterlist.lua.html
local ShifterBoxList = ZO_SortFilterList:Subclass()

ShifterBoxList.SORT_KEYS = {
    ["value"] = {},
    ["key"] = {tiebreaker="value"}
}

function ShifterBoxList:New(control, shifterBoxSettings)
    local obj = ZO_SortFilterList.New(self, control, shifterBoxSettings)
    obj.buttonControl = control:GetNamedChild("Button")
    -- TODO: instead return obj.list ???
    return obj
end

function ShifterBoxList:OnSelectionChanged(previouslySelectedData, selectedData, reselectingDuringRebuild)
    d("OnSelectionChanged")
--    ZO_ScrollList_SelectData(self.list, selectedData, nil, reselectingDuringRebuild, false)
    -- TODO: to be removed mabye?
end

function ShifterBoxList:Initialize(control, shifterBoxSettings)
    self.rowHeight = shifterBoxSettings.rowHeight
    -- initialize the SortFilterList
    ZO_SortFilterList.Initialize(self, control)
    -- set a text that is displayed when there are no entries
    self:SetEmptyText(shifterBoxSettings.emptyListText)
    -- default sorting key
    self.sortHeaderGroup:SelectHeaderByKey("value")
    ZO_SortHeader_OnMouseExit(self.control:GetNamedChild("Headers"):GetNamedChild("Value"))
    -- define the datatype for this list and enable the highlighting
    ZO_ScrollList_AddCategory(self.list, DATA_CATEGORY_DEFAULT)
    ZO_ScrollList_AddDataType(self.list, DATA_TYPE_DEFAULT, "ShifterBoxEntryTemplate", self.rowHeight, function(control, data) self:SetupRowEntry(control, data) end)

--    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
    ZO_ScrollList_EnableSelection(self.list, "ZO_ThinListHighlight", function(...)
        d("ZO_ScrollList_EnableSelection")
        self:OnSelectionChanged(...)
        -- TODO: to be removed mabye?
    end)

    -- set up sorting function and refresh all data
    self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, shifterBoxSettings.sortBy, ShifterBoxList.SORT_KEYS, self.currentSortOrder) end
    self:RefreshData()
end

function ShifterBoxList:BuildMasterList()
    d("BuildMasterList")
    -- intended to be overriden
    -- should build the master list of data that is later filtered by FilterScrollList
end

function ShifterBoxList:FilterScrollList()
    d("FilterScrollList")
    -- intended to be overriden
    -- should take the master list data and filter it
end

function ShifterBoxList:SortScrollList()
    d("SortScrollList)")
    -- intended to be overriden
    -- should take the filtered data and sort it
end

function ShifterBoxList:AddEntry(key, value, categoryId)
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    local rowData = {
        key = key,
        value = value
    }
    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(DATA_TYPE_DEFAULT, rowData, categoryId or DATA_CATEGORY_DEFAULT))
end

function ShifterBoxList:RemoveEntry(key)
    d("RemoveEntry")
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    for i, entry in ipairs(scrollData) do
        local categoryId = entry.categoryId
        local data = entry.data
        df("data.key = %d    data.value = %s   categoryId = %s", data.key, data.value, tostring(categoryId))
        if data.key == key then
            table.remove(scrollData, i)
            self.list.selectedMultiData[data.key] = nil
            self.list.selectedMultiDataKey[data.key] = nil
            return data.key, data.value, categoryId
        end
    end
    return nil
end

function ShifterBoxList:ClearEntries()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
end

function ShifterBoxList:RefreshCategoriesHiddenState()
    local categories = self.list.categories
    for categoryId, category in pairs(categories) do
        if category.hidden then
            ZO_ScrollList_HideCategory(self.list, categoryId)
        end
    end
end

function ShifterBoxList:RefreshSelectedControls()
    local selectedMultiData = self.list.selectedMultiData
    if selectedMultiData then
        for key, data in pairs(selectedMultiData) do
            local control = ZO_ScrollList_GetDataControl(self, data)
            self:SelectControl(control, false)
        end
    end
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

-- Custom implementation based on: https://esoapi.uesp.net/100027/src/libraries/zo_templates/scrolltemplates.lua.html#1456
--- this function toggles the selection of an entry and also adds/removes it to/from the selected-list
-- @param data - the table with the data of the entry (mandatory)
-- @param control - the control of the entry (optional - can be deferred from data)
-- @param reselectingDuringRebuild - to be defined
-- @param animateInstantly - if the selection animation is instantly or not
function ShifterBoxList:ToggleEntrySelection(data, control, reselectingDuringRebuild, animateInstantly)
    d("SelectEntry")
    if reselectingDuringRebuild == nil then
        reselectingDuringRebuild = false
    end
    if animateInstantly == nil then
        animateInstantly = false
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
        self.list.selectedMultiDataKey = {}
    end
    if data ~= nil then
        if not control then
            control = ZO_ScrollList_GetDataControl(self, data)
        end
        if control then
            -- check if already selected
            if self.list.selectedMultiDataKey[dataKey] ~= nil then
                -- remove selected data
                self.list.selectedMultiData[dataKey] = nil
                self.list.selectedMultiDataKey[dataKey] = nil
                -- and unselect the control
                self:UnselectControl(control, animateInstantly)
            else
                -- add selected data
                self.list.selectedMultiData[dataKey] = data
                self.list.selectedMultiDataKey[dataKey] = true
                -- and select the control
                self:SelectControl(control, animateInstantly)
            end
        end
    end
    if self.list.selectionCallback then
        self.list.selectionCallback(data, self.list.selectedMultiData, reselectingDuringRebuild)
    end
end

function ShifterBoxList:SortScrollList()
    d("SortScrollList")
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end

function ShifterBoxList:SetupRowEntry(rowControl, rowData)
    d("SetupRowEntry")
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
        d("onRowClicked")
        local data = ZO_ScrollList_GetData(rowControl)
        self:ToggleEntrySelection(data, rowControl, RESELECTING_DURING_REBUILD, false)

        local selectedMultiDataKey = self.list.selectedMultiDataKey
        local count = 0
        for _ in pairs(selectedMultiDataKey) do count = count + 1 end

        if count > 0 then
            self.buttonControl:SetState(BSTATE_NORMAL, false)
        else
            self.buttonControl:SetState(BSTATE_DISABLED, true)
        end
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

    -- reselect entries (only visually) if necessary
    local selectedMultiDataKey = self.list.selectedMultiDataKey
    if selectedMultiDataKey and selectedMultiDataKey[rowData.key] ~= nil then
        self:SelectControl(rowControl, false)
    end

    -- then setup the row
    ZO_SortFilterList.SetupRow(self, rowControl, rowData)
end

function ShifterBoxList:SetCustomDimensions(width, height, headerHeight)
    -- first set width/height of the listbox itself
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
    d("Refresh")
    self:RefreshData()
    -- after data is refreshed,  make sure that all rows have the correct width
    local rowControls = self.list.contents
    for childIndex = 1, rowControls:GetNumChildren() do
        local rowControl = rowControls:GetChild(childIndex)
        local rowControlLabel = rowControl:GetNamedChild("Label")
        rowControlLabel:SetWidth(rowControl:GetWidth())
    end
end

function ShifterBoxList:SetEntriesEnabled(enabled)
    -- after unselecing all entries, change the actual state of the rowControl-buttons
    local rowControls = self.list.contents
    for childIndex = 1, rowControls:GetNumChildren() do
        local rowControl = rowControls:GetChild(childIndex)
        rowControl:SetEnabled(enabled)
    end
    rowControls:SetAlpha(enabled and 1 or 0.4)
end


-- =================================================================================================================
-- == SHIFTERBOX PRIVATE FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
local function _createShifterBox(uniqueAddonName, uniqueShifterBoxName, parentControl)
    local shifterBoxName = table.concat({uniqueAddonName, "_", uniqueShifterBoxName})
    return CreateControlFromVirtual(shifterBoxName, parentControl, "ShifterBoxTemplate")
end

local function _getDeepClonedTable(sourceTable)
    local targetTable = {}
    ZO_DeepTableCopy(sourceTable, targetTable)
    return targetTable
end

local function _moveEntryFromTo(fromList, toList, key)
    local key, value, categoryId = fromList:RemoveEntry(key)
    if key ~= nil then
        toList:AddEntry(key, value, categoryId)
    end
end

local function _assertKeyIsNotInTable(key, value, list, sideControl)
    local scrollData = ZO_ScrollList_GetDataList(list.list)
    for i, entry in ipairs(scrollData) do
        assert(entry.key ~= key, string.format(LIB_IDENTIFIER.."_Error: Violation of UNIQUE KEY. Cannot insert duplicate key '%s' with value '%s' in control '%s'. The statement has been terminated.", tostring(key), tostring(value), sideControl:GetName()))
    end
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

    local function initButton(buttonControl)
        buttonControl:SetState(BSTATE_DISABLED, true)
    end

    -- initialise the headers
    initHeaders(self, leftListTitle, rightListTitle)

    -- initialize the frame/border around the listBoxes
    initListFrames(leftListControl)
    initListFrames(rightListControl)

    -- initialize the buttons in disabled state
    initButton(fromLeftButtonControl)
    initButton(fromRightButtonControl)
end

local function _initShifterBoxHandlers(self)
    local control = self.shifterBoxControl
    local leftControl = control:GetNamedChild("Left")
    local fromLeftButtonControl = leftControl:GetNamedChild("Button")
    local rightControl = control:GetNamedChild("Right")
    local fromRightButtonControl = rightControl:GetNamedChild("Button")

    local function toLeftButtonClicked(buttonControl)
        local rightListSelectedData = self.rightList.list.selectedMultiData
        for key, data in pairs(rightListSelectedData) do
            _moveEntryFromTo(self.rightList, self.leftList, data.key)
        end
        -- then commit the changes to the scrollList and refresh the hidden states
        self.leftList:CommitScrollList()
        self.leftList:RefreshCategoriesHiddenState()
        self.rightList:CommitScrollList()
        self.rightList:RefreshCategoriesHiddenState()
    end

    local function toRightButtonClicked(buttonControl)
        local leftListSelectedData = self.leftList.list.selectedMultiData
        for key, data in pairs(leftListSelectedData) do
            _moveEntryFromTo(self.leftList, self.rightList, data.key)
        end
        -- then commit the changes to the scrollList and refresh the hidden states
        self.leftList:CommitScrollList()
        self.leftList:RefreshCategoriesHiddenState()
        self.rightList:CommitScrollList()
        self.rightList:RefreshCategoriesHiddenState()
    end

    -- initialize the handler when the buttons are clicked
    fromLeftButtonControl:SetHandler("OnClicked", toRightButtonClicked)
    fromRightButtonControl:SetHandler("OnClicked", toLeftButtonClicked)
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
    return settings
end

local function _getListBoxWidthAndArrowOffset(width, height)
    -- widh must be at least three times the space between the listBoxes
    if width < (3 * LIST_SPACING) then width = (3 * LIST_SPACING) end
    -- the width of a listBox is the total width minus the spacing divided by two
    local singleListWidth = (width - LIST_SPACING) / 2
    -- height must be at least 2x the height of the arrows
    if height < (2 * ARROW_SIZE) then height = (2 * ARROW_SIZE) end
    -- the offset of the arrow is 1/4th of the remaining height
    local arrowOffset = (height - (2 * ARROW_SIZE)) / 4
    return singleListWidth, arrowOffset
end

local function _setListBoxDimensions(list, singleListWidth, height, headerHeight, buttonAnchorOptions)
    local buttonControl = list.control:GetNamedChild("Button")
    buttonControl:ClearAnchors()
    buttonControl:SetAnchor(unpack(buttonAnchorOptions))
    list:SetCustomDimensions(singleListWidth, height, headerHeight)
    list:Refresh()
end

-- ---------------------------------------------------------------------------------------------------------------------

local function _selectEntries(list, keys)
    -- TODO: to be refactored!!!
    local function selectRowByKey(rowControls, key)
        for childIndex = 1, rowControls:GetNumChildren() do
            local rowControl = rowControls:GetChild(childIndex)
            local data = ZO_ScrollList_GetData(rowControl)
            if data.key == key then
                local onRowClicked = rowControl:GetHandler("OnClicked")
                if onRowClicked ~= nil then onRowClicked(rowControl) end
                return
            end
        end
    end

    local listEntries = list.control.entries
    local listContents = list.list.contents
    for _, key in pairs(keys) do
        if listEntries[key] ~= nil then
             selectRowByKey(listContents, key)
        end
    end
end

local function _selectEntry(list, key)
    local keys = { key }
    _selectEntries(list, keys)
end

local function _removeEntriesFromList(list, keys)
    local hasAtLeastOneRemoved = false
    for aaa, key in pairs(keys) do
        local removedKey = list:RemoveEntry(key)
        if removedKey ~= nil then hasAtLeastOneRemoved = true end
    end
    if hasAtLeastOneRemoved then
        list:CommitScrollList()
        list:RefreshCategoriesHiddenState()
    end
end

local function _removeEntryFromList(list, key)
    local keys = { key }
    _removeEntriesFromList(list, keys)
end

local function _getEntries(list)
    -- TODO: to be refactored!!!
    local listEntries = list.control.entries
    return listEntries
end

local function _addEntriesToList(list, entries, replace, otherList, categoryId)
    local hasAtLeastOneAdded = false
    local listControl = list.control
    local otherListControl = otherList.control
    if categoryId ~= nil then
        -- if a category is provided, ensure that it definitely is registered to the scrollist
        ZO_ScrollList_AddCategory(list.list, categoryId)
        ZO_ScrollList_AddCategory(otherList.list, categoryId)
    end
    for key, value in pairs(entries) do
        if replace and replace == true then
            -- if replace is set to true, make sure that a potential entry with the same key is removed from the other list
            otherList:RemoveEntry(key)
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
        -- Afterwards unselect/refresh the visualisation of the data
        -- TODO: something needs to be done here?
    end
end

local function _addEntryToList(list, key, value, replace, otherList, categoryId)
    local entries = { [key] = value }
    _addEntriesToList(list, entries, replace, otherList, categoryId)
end

local function _moveEntriesToOtherList(sourceList, keys, destList)
    local atLeastOneMoved = false
    for _, key in pairs(keys) do
        local moved = _moveEntryFromTo(sourceList, destList, key)
        if moved then atLeastOneMoved = true end
    end
    if atLeastOneMoved then
        -- if an entry was moved, "unselect" all entries (and inheretly refresh the display)
        sourceList:CommitScrollList()
        sourceList:RefreshCategoriesHiddenState()
        destList:CommitScrollList()
        destList:RefreshCategoriesHiddenState()
    end
end

local function _moveEntryToOtherList(sourceList, key, destList)
    local keys = { key }
    _moveEntriesToOtherList(sourceList, keys, destList)
end

local function _clearList(list)
    list:ClearEntries()
    list:Refresh() -- TODO: check if needed?
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
function ShifterBox:New(uniqueAddonName, uniqueShifterBoxName, parentControl, leftListTitle, rightListTitle, customSettings)
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
    _initShifterBoxControls(obj, leftListTitle, rightListTitle)
    _initShifterBoxHandlers(obj)

    -- initialize the ShifterBoxLists
    local leftControl = obj.shifterBoxControl:GetNamedChild("Left")
    local rightControl = obj.shifterBoxControl:GetNamedChild("Right")
    obj.leftList = ShifterBoxList:New(leftControl, obj.shifterBoxSettings)
    obj.rightList = ShifterBoxList:New(rightControl, obj.shifterBoxSettings)

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
    local singleListWidth, arrowOffset = _getListBoxWidthAndArrowOffset(width, height)
    local headerHeight = self.headerHeight
    local leftList = self.leftList
    local rightList = self.rightList
    local leftButtonAnchorOptions = {TOPLEFT, leftList.list, TOPRIGHT, 0, arrowOffset}
    local rightButtonAnchorOptions = {BOTTOMRIGHT, rightList.list, BOTTOMLEFT, -2, arrowOffset * -1} -- lower arrow requires negative offset
    _setListBoxDimensions(leftList, singleListWidth, height, self.headerHeight, leftButtonAnchorOptions)
    _setListBoxDimensions(rightList, singleListWidth, height, self.headerHeight, rightButtonAnchorOptions)
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
end

function ShifterBox:HideCategory(categoryId)
    assert(categoryId ~= nil, string.format(LIB_IDENTIFIER.."_Error: categoryId cannot be nil!"))
    ZO_ScrollList_HideCategory(self.leftList.list, categoryId)
    ZO_ScrollList_HideCategory(self.rightList.list, categoryId)
end

function ShifterBox:SelectEntryByKey(key)
    _selectEntry(self.leftList, key)
    _selectEntry(self.rightList, key)
end

function ShifterBox:SelectEntriesByKey(keys)
    _selectEntries(self.leftList, keys)
    _selectEntries(self.rightList, keys)
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

function ShifterBox:GetLeftListEntries()
    return _getEntries(self.leftList)
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

function ShifterBox:ClearLeftList()
    _clearList(self.leftList)
end

-- ---------------------------------------------------------------------------------------------------------------------

function ShifterBox:GetRightListEntries()
    return _getEntries(self.rightList)
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

function ShifterBox:ClearRightList()
    _clearList(self.rightList)
end


-- =================================================================================================================
-- == LIBRARY FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
lib.DEFAULT_CATEGORY = DATA_CATEGORY_DEFAULT

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
