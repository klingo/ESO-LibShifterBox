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
local DATA_CATEGORY_DEFAULT = 1
local SCROLLBAR_WIDTH = ZO_SCROLL_BAR_WIDTH

local existingShifterBoxes = {}

lib.defaultSettings = {
    sortBy = "value",
    showLeftAllButton = false,      -- TODO: implement this setting
    showRightAllButton = false,     -- TODO: implement this setting
    rowHeight = 32,
}

-- =================================================================================================================
-- == LIBRARY LISTS == --
-- -----------------------------------------------------------------------------------------------------------------
local ShifterBoxList = ZO_SortFilterList:Subclass()

ShifterBoxList.SORT_KEYS = {
    ["value"] = {},
    ["key"] = {tiebreaker="value"}
}

function ShifterBoxList:New(control, shifterBoxSettings)
    local obj = ZO_SortFilterList.New(self, control, shifterBoxSettings)
    obj.buttonControl = control:GetNamedChild("Button")
    obj.numSelected = 0
    return obj
end

function ShifterBoxList:Initialize(control, shifterBoxSettings)
    self.rowHeight = shifterBoxSettings.rowHeight
    -- initialize the SortFilterList
    ZO_SortFilterList.Initialize(self, control)
    -- set a text that is displayed when there are no entries
    self:SetEmptyText("empty")
    -- default sorting key
    self.sortHeaderGroup:SelectHeaderByKey("value")
    ZO_SortHeader_OnMouseExit(self.control:GetNamedChild("Headers"):GetNamedChild("Value"))
    -- define the datatype for this list and enable the highlighting
    ZO_ScrollList_AddDataType(self.list, DATA_TYPE_DEFAULT, "ShifterBoxEntryTemplate", self.rowHeight, function(control, data) self:SetupRowEntry(control, data) end)
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
    -- set up sorting function and refresh all data
    self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, shifterBoxSettings.sortBy, ShifterBoxList.SORT_KEYS, self.currentSortOrder) end
    self:RefreshData()
end

function ShifterBoxList:FilterScrollList()
    -- get the data of the scrollist and index it
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
    -- populate the table that is used as source for the list
    for key, value in pairs(self.control.entries) do
        local rowData = {
            key = key,
            value = value
        }
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(DATA_TYPE_DEFAULT, rowData, DATA_CATEGORY_DEFAULT))
    end
end

function ShifterBoxList:SortScrollList()
    -- get all data and sort it
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
    if self.numSelected and self.numSelected > 0 then
        self:UnselectAll()
    end
end

function ShifterBoxList:SetupRowEntry(rowControl, rowData)
    local function onRowMouseEnter(rowControl)
        local labelControl = rowControl:GetNamedChild("Label")
        local textWidth = labelControl:GetTextWidth()
        local desiredWidth = labelControl:GetDesiredWidth()
        -- only show tooltip if the text/label was truncated or if the text is wider than the desiredWidth minus the scrollbar width
        local wasTruncated = rowControl:GetNamedChild("Label"):WasTruncated()
        if wasTruncated or (textWidth + SCROLLBAR_WIDTH) > desiredWidth then
            ZO_Tooltips_ShowTextTooltip(rowControl, TOP, rowControl.data.value)
        end
    end
    local function onRowMouseExit(rowControl)
        ZO_Tooltips_HideTextTooltip()
    end
    local function onRowClicked(rowControl)
        if rowControl.selected and rowControl.selected == true then
            self:Row_OnMouseExit(rowControl)
            rowControl.selected = false
            self.numSelected = self.numSelected - 1
        else
            self:Row_OnMouseEnter(rowControl)
            rowControl.selected = true
            self.numSelected = self.numSelected + 1
        end

        -- update the buttonState
        if self.numSelected == 0 then
            self.buttonControl:SetState(BSTATE_DISABLED, true)
        else
            self.buttonControl:SetState(BSTATE_NORMAL, false)
        end
    end

    -- store the rowData on the control so it can be accessed from other places
    rowControl.data = rowData

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
    -- first refresh the data
    self:RefreshData()
    -- then make sure that all rows have the correct width
    local rowControls = self.list.contents
    for childIndex = 1, rowControls:GetNumChildren() do
        local rowControl = rowControls:GetChild(childIndex)
        local rowControlLabel = rowControl:GetNamedChild("Label")
        rowControlLabel:SetWidth(rowControl:GetWidth())
    end
end

function ShifterBoxList:UnselectAll()
    local rowControls = self.list.contents
    for childIndex = 1, rowControls:GetNumChildren() do
        local rowControl = rowControls:GetChild(childIndex)
        rowControl.selected = nil
    end
    -- when unselecting all entries, disable the button
    self.numSelected = 0
    self.buttonControl:SetState(BSTATE_DISABLED, true)
    -- and refresh the view
    self:Refresh()
end

function ShifterBoxList:SetEntriesEnabled(enabled)
    -- first unselect all entries (which also disables the buttons)
    self:UnselectAll()
    -- then change the actual state of the rowControl-buttons
    local rowControls = self.list.contents
    for childIndex = 1, rowControls:GetNumChildren() do
        local rowControl = rowControls:GetChild(childIndex)
        rowControl:SetEnabled(enabled)
    end
    rowControls:SetAlpha(enabled and 1 or 0.4)
end


-- =================================================================================================================
-- == PRIVATE FUNCTIONS == --
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
    toList[key] = fromList[key]
    fromList[key] = nil
end

local function _assertKeyIsNotInTable(key, sideControl)
    assert(sideControl.entries[key] == nil, string.format("[ShifterBox]Error: Violation of UNIQUE KEY. Cannot insert duplicate key '%s' in control '%s'. The statement has been terminated.", tostring(key), sideControl:GetName()))
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

    local function initHeaders(leftListTitle, rightListTitle)
        if leftListTitle ~= nil or rightListTitle ~= nil then
            -- show the headers (default = hidden)
            local leftHeaders = leftControl:GetNamedChild("Headers")
            local leftHeadersTitle = leftHeaders:GetNamedChild("Value"):GetNamedChild("Name")
            leftHeaders:SetHeight(HEADER_HEIGHT)
            leftHeaders:SetHidden(false)
            leftHeadersTitle:SetText(leftListTitle)

            local rightHeaders = rightControl:GetNamedChild("Headers")
            local rightHeadersTitle = rightHeaders:GetNamedChild("Value"):GetNamedChild("Name")
            rightHeaders:SetHeight(HEADER_HEIGHT)
            rightHeaders:SetHidden(false)
            rightHeadersTitle:SetText(rightListTitle)
        end
    end

    local function initButton(buttonControl)
        buttonControl:SetState(BSTATE_DISABLED, true)
    end

    -- initialise the headers
    initHeaders(leftListTitle, rightListTitle)

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
        local rightListContents = self.rightList.list.contents
        for childIndex = 1, rightListContents:GetNumChildren() do
            local rowControl = rightListContents:GetChild(childIndex)
            if rowControl.selected and rowControl.selected == true then
                _moveEntryFromTo(rightControl.entries, leftControl.entries, rowControl.data.key)
            end
        end
        -- then "unselect" all entries (and inheretly refresh the display)
        self.leftList:UnselectAll()
        self.rightList:UnselectAll()
    end

    local function toRightButtonClicked(buttonControl)
        local leftListContents = self.leftList.list.contents
        for childIndex = 1, leftListContents:GetNumChildren() do
            local rowControl = leftListContents:GetChild(childIndex)
            if rowControl.selected and rowControl.selected == true then
                _moveEntryFromTo(leftControl.entries, rightControl.entries, rowControl.data.key)
            end
        end
        -- then "unselect" all entries (and inheretly refresh the display)
        self.leftList:UnselectAll()
        self.rightList:UnselectAll()
    end

    -- initialize the handler when the buttons are clicked
    fromLeftButtonControl:SetHandler("OnClicked", toRightButtonClicked)
    fromRightButtonControl:SetHandler("OnClicked", toLeftButtonClicked)
end

local function _applyCustomSettings(customSettings)
    -- if no custom settings provided, use the default ones
    if customSettings == nil then return lib.defaultSettings end
    -- otherwise validate them
    if customSettings.sortBy then
        assert(customSettings.sortBy == "value" or customSettings.sortBy == "key", string.format("[LibShifterBox]Error: Invalid sortBy parameter '%s' provided! Only 'value' and 'key' are allowed.", tostring(customSettings.sortBy)))
    end
    if customSettings.rowHeight then
        assert(type(customSettings.rowHeight) == "number" and customSettings.rowHeight > 0, string.format("[LibShifterBox]Error: Invalid rowHeight parameter '%s' provided! Must be a numeric and positive.", tostring(customSettings.rowHeight)))
    end
    return {
        sortBy = customSettings.sortBy or lib.defaultSettings.sortBy,
        showLeftAllButton = customSettings.showLeftAllButton or lib.defaultSettings.showLeftAllButton,
        showRightAllButton = customSettings.showRightAllButton or lib.defaultSettings.showRightAllButton,
        rowHeight = customSettings.rowHeight or lib.defaultSettings.rowHeight,
    }
end


-- =================================================================================================================
-- == SHIFTERBOX FUNCTIONS == --
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
    assert(addonShifterBoxes[uniqueShifterBoxName] == nil, string.format("[LibShifterBox]Error: ShifterBox with the unique identifier '%s' is already registered for the addon '%s'!", tostring(uniqueShifterBoxName), tostring(uniqueAddonName)))

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
    leftControl.entries = {}
    rightControl.entries = {}
    obj.leftList = ShifterBoxList:New(leftControl, obj.shifterBoxSettings)
    obj.rightList = ShifterBoxList:New(rightControl, obj.shifterBoxSettings)

    -- register the shifterBox in the internal list and return it
    addonShifterBoxes[uniqueShifterBoxName] = obj
    return addonShifterBoxes[uniqueShifterBoxName]
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
    local fromLeftButton = self.leftList.control:GetNamedChild("Button")
    local fromRightButton = self.rightList.control:GetNamedChild("Button")
    local leftList = self.leftList.list
    local rightList = self.rightList.list

    -- widh must be at least three times the space between the listBoxes
    if width < (3 * LIST_SPACING) then width = (3 * LIST_SPACING) end
    -- the width of a listBox is the total width minus the spacing divided by two
    local singleListWidth = (width - LIST_SPACING) / 2

    -- height must be at least 2x the height of the arrows
    if height < (2 * ARROW_SIZE) then height = (2 * ARROW_SIZE) end
    -- the offset of the arrow is 1/4th of the remaining height
    local arrowOffset = (height - (2 * ARROW_SIZE)) / 4

    -- set the dimenions of the listBoxes
    self.leftList:SetCustomDimensions(singleListWidth, height, HEADER_HEIGHT)
    self.rightList:SetCustomDimensions(singleListWidth, height, HEADER_HEIGHT)

    -- for both buttons, clear the anchors first and then set new ones with the updated offsets
    fromRightButton:ClearAnchors()
    fromRightButton:SetAnchor(BOTTOMRIGHT, rightList, BOTTOMLEFT, -2, arrowOffset * -1) -- lower arrow requires negative offset

    fromLeftButton:ClearAnchors()
    fromLeftButton:SetAnchor(TOPLEFT, leftList, TOPRIGHT, 0, arrowOffset)

    -- Refresh the visualisation of the data
    self.leftList:Refresh()
    self.rightList:Refresh()
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

function ShifterBox:SelectEntryByKey(key)
    local function selectRowByKey(rowControls, key)
        for childIndex = 1, rowControls:GetNumChildren() do
            local rowControl = rowControls:GetChild(childIndex)
            if rowControl.data.key == key then
                local onRowClicked = rowControl:GetHandler("OnClicked")
                if onRowClicked ~= nil then onRowClicked(rowControl) end
                return
            end
        end
    end

    local leftListControl = self.leftList.control
    if leftListControl.entries[key] ~= nil then
        local leftList = self.leftList.list
        selectRowByKey(leftList.contents, key)
    else
        local rightListControl = self.rightList.control
        if rightListControl.entries[key] ~= nil then
            local rightList = self.rightList.list
            selectRowByKey(rightList.contents, key)
        end
    end
end

-- ---------------------------------------------------------------------------------------------------------------------

function ShifterBox:SetLeftListEntries(entries)
    -- assert that key does not exist yet in the other list
    local rightControl = self.rightList.control
    for key, _ in pairs(entries) do
        _assertKeyIsNotInTable(key, rightControl)
    end

    -- now the entries can be added to the left list
    local leftControl = self.leftList.control
    leftControl.entries = _getDeepClonedTable(entries)
    -- Unselect/Refresh the visualisation of the data
    self.leftList:UnselectAll()
end

function ShifterBox:GetLeftListEntries()
    local leftListEntries = self.leftList.control.entries
    return leftListEntries
end

function ShifterBox:AddEntryToLeftList(key, value, replace)
    local leftControl = self.leftList.control
    local rightControl = self.rightList.control
    if replace and replace == true then
        -- if replace is set to true, make sure that a potential entry with the same key is removed from the other list
        if rightControl.entries[key] ~= nil then
            rightControl.entries[key] = nil
            self.rightList:UnselectAll()
        end
    else
        -- if replace is not set or set to false, then assert that key does not exist in either list
        _assertKeyIsNotInTable(key, leftControl)
        _assertKeyIsNotInTable(key, rightControl)
    end
    -- then add entry to the corresponding list
    table.insert(leftControl.entries, key, value)
    -- Unselect/Refresh the visualisation of the data
    self.leftList:UnselectAll()
end

function ShifterBox:RemoveEntryFromLeftList(key)
    local leftControl = self.leftList.control
    leftControl.entries[key] = nil
    self.leftList:UnselectAll()
end

function ShifterBox:ClearLeftList()
    local leftControl = self.leftList.control
    -- remove the entries
    leftControl.entries = {}
    -- and refresh the visualisation of the data
    self.leftList:Refresh()
end

-- ---------------------------------------------------------------------------------------------------------------------

function ShifterBox:SetRightListEntries(entries)
    -- assert that key does not exist yet in the other list
    local leftControl = self.leftList.control
    for key, _ in pairs(entries) do
        _assertKeyIsNotInTable(key, leftControl)
    end

    -- now the entries can be added to the left list
    local rightControl = self.rightList.control
    rightControl.entries = _getDeepClonedTable(entries)
    -- Unselect/Refresh the visualisation of the data
    self.rightList:UnselectAll()
end

function ShifterBox:GetRightListEntries()
    local rightListEntries = self.rightList.control.entries
    return rightListEntries
end

function ShifterBox:AddEntryToRightList(key, value, replace)
    local leftControl = self.leftList.control
    local rightControl = self.rightList.control
    if replace and replace == true then
        -- if replace is set to true, make sure that a potential entry with the same key is removed from the other list
        if leftControl.entries[key] ~= nil then
            leftControl.entries[key] = nil
            self.leftList:UnselectAll()
        end
    else
        -- if replace is not set or set to false, then assert that key does not exist in either list
        _assertKeyIsNotInTable(key, leftControl)
        _assertKeyIsNotInTable(key, rightControl)
    end
    -- then add entry to the corresponding list
    table.insert(rightControl.entries, key, value)
    -- Unselect/Refresh the visualisation of the data
    self.rightList:UnselectAll()
end

function ShifterBox:RemoveEntryFromRightList(key)
    local rightControl = self.rightList.control
    rightControl.entries[key] = nil
    self.rightList:UnselectAll()
end

function ShifterBox:ClearRightList()
    local rightControl = self.rightList.control
    -- remove the entries
    rightControl.entries = {}
    -- and refresh the visualisation of the data
    self.rightList:Refresh()
end

-- ---------------------------------------------------------------------------------------------------------------------


-- =================================================================================================================
-- == LIBRARY FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
function lib.GetShifterBox(uniqueAddonName, uniqueShifterBoxName)
    local addonShifterBoxes = existingShifterBoxes[uniqueAddonName]
    if addonShifterBoxes ~= nil then
        return addonShifterBoxes[uniqueShifterBoxName]
    end
    return nil
end

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
