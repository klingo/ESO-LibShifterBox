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

local existingShifterBoxes = {}

-- =================================================================================================================
-- == LIBRARY LISTS == --
-- -----------------------------------------------------------------------------------------------------------------
local ShifterBoxList = ZO_SortFilterList:Subclass()

ShifterBoxList.SORT_KEYS = {
    ["value"] = {},
    ["key"] = {tiebreaker="value"}
}

function ShifterBoxList:New(control)
    local obj = ZO_SortFilterList.New(self, control)
    return obj
end

function ShifterBoxList:Initialize(control)
    -- initialize the SortFilterList
    ZO_SortFilterList.Initialize(self, control)
    -- set a text that is displayed when there are no entries
    self:SetEmptyText("empty")
    -- default sorting key
    self.sortHeaderGroup:SelectHeaderByKey("value")
    ZO_SortHeader_OnMouseExit(self.control:GetNamedChild("Headers"):GetNamedChild("Value"))
    -- define the datatype for this list and enable the highlighting
    ZO_ScrollList_AddDataType(self.list, DATA_TYPE_DEFAULT, "ShifterBoxEntryTemplate", 36, function(control, data) self:SetupRowEntry(control, data) end)
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
    -- set up sorting function and refresh all data
    self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, ShifterBoxList.SORT_KEYS, self.currentSortOrder) end
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
end

function ShifterBoxList:SetupRowEntry(rowControl, rowData)
    local function onRowMouseEnter(rowControl)
--        self:Row_OnMouseEnter(rowControl)
    end
    local function onRowMouseExit(rowControl)
--        self:Row_OnMouseExit(rowControl)
    end
    local function onRowClicked(rowControl)
        if rowControl.selected and rowControl.selected == true then
            self:Row_OnMouseExit(rowControl)
            rowControl.selected = false
        else
            self:Row_OnMouseEnter(rowControl)
            rowControl.selected = true
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

    ZO_SortFilterList.SetupRow(self, rowControl, rowData)
end

function ShifterBoxList:Refresh()
    self:RefreshData()
end

function ShifterBoxList:UnselectAll()
    local rowControls = self.list.contents
    for childIndex = 1, rowControls:GetNumChildren() do
        local rowControl = rowControls:GetChild(childIndex)
        rowControl.selected = nil
    end
    self:Refresh()
end








-- =================================================================================================================
-- == PRIVATE FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
local function createShifterBox(uniqueAddonName, uniqueShifterBoxName, parentControl)
    local shifterBoxName = table.concat({uniqueAddonName, "_", uniqueShifterBoxName})
    return CreateControlFromVirtual(shifterBoxName, parentControl, "ShifterBoxTemplate")
end

local function moveEntryFromTo(fromList, toList, key)
    toList[key] = fromList[key]
    fromList[key] = nil
end

local function initShifterBoxControls(self, leftListTitle, rightListTitle)
    local control = self.shifterBoxControl
    local leftControl = control:GetNamedChild("Left")
    local rightControl = control:GetNamedChild("Right")
    self.rightListControl = rightControl:GetNamedChild("List")
    self.leftListControl = leftControl:GetNamedChild("List")

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

    -- initialise the headers
    initHeaders(leftListTitle, rightListTitle)

    -- initialize the frame/border around the listBoxes
    initListFrames(self.leftListControl)
    initListFrames(self.rightListControl)
end

local function initShifterBoxHandlers(self)
    local control = self.shifterBoxControl
    local leftControl = control:GetNamedChild("Left")
    local leftButtonControl = leftControl:GetNamedChild("Button")
    local rightControl = control:GetNamedChild("Right")
    local rightButtonControl = rightControl:GetNamedChild("Button")

    local function toLeftButtonClicked(buttonControl)
        local rightListContents = self.rightListControl.contents
        for childIndex = 1, rightListContents:GetNumChildren() do
            local rowControl = rightListContents:GetChild(childIndex)
            if rowControl.selected and rowControl.selected == true then
                moveEntryFromTo(rightControl.entries, leftControl.entries, rowControl.data.key)
            end
        end
        -- then "unselect" all entries (and inheretly refresh the display)
        self.leftList:UnselectAll()
        self.rightList:UnselectAll()
    end

    local function toRightButtonClicked(buttonControl)
        local leftListContents = self.leftListControl.contents
        for childIndex = 1, leftListContents:GetNumChildren() do
            local rowControl = leftListContents:GetChild(childIndex)
            if rowControl.selected and rowControl.selected == true then
                moveEntryFromTo(leftControl.entries, rightControl.entries, rowControl.data.key)
            end
        end
        -- then "unselect" all entries (and inheretly refresh the display)
        self.leftList:UnselectAll()
        self.rightList:UnselectAll()
    end

    -- initialize the handler when the buttons are clicked
    leftButtonControl:SetHandler("OnClicked", toLeftButtonClicked)
    rightButtonControl:SetHandler("OnClicked", toRightButtonClicked)
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
function ShifterBox:New(uniqueAddonName, uniqueShifterBoxName, parentControl, leftListTitle, rightListTitle)
    if existingShifterBoxes[uniqueAddonName] == nil then
        existingShifterBoxes[uniqueAddonName] = {}
    end
    local addonShifterBoxes = existingShifterBoxes[uniqueAddonName]
    assert(addonShifterBoxes[uniqueShifterBoxName] == nil, string.format("[LibShifterBox]Error: ShifterBox with the unique identifier [%s] is already registered for the addon [%s]!", tostring(uniqueShifterBoxName), tostring(uniqueAddonName)))

    local obj = ZO_Object.New(self)
    obj.addonName = uniqueAddonName
    obj.shifterBoxName = uniqueShifterBoxName
    obj.shifterBoxControl = createShifterBox(uniqueAddonName, uniqueShifterBoxName, parentControl)
    initShifterBoxControls(obj, leftListTitle, rightListTitle)
    initShifterBoxHandlers(obj)

    -- initialize the ShifterBoxLists
    local leftControl = obj.shifterBoxControl:GetNamedChild("Left")
    local rightControl = obj.shifterBoxControl:GetNamedChild("Right")
    leftControl.entries = {}
    rightControl.entries = {}
    obj.leftList = ShifterBoxList:New(leftControl)
    obj.rightList = ShifterBoxList:New(rightControl)

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
    local leftButton = self.leftList.control:GetNamedChild("Button")
    local rightButton = self.rightList.control:GetNamedChild("Button")
    local leftListControl = self.leftList.list
    local rightListControl = self.rightList.list
    local leftHeadersControl = leftListControl:GetParent():GetNamedChild("Headers")
    local rightHeadersControl = rightListControl:GetParent():GetNamedChild("Headers")

    -- widh must be at least three times the space between the listBoxes
    if width < (3 * LIST_SPACING) then width = (3 * LIST_SPACING) end
    -- the width of a listBox is the total width minus the spacing divided by two
    local singleListWidth = (width - LIST_SPACING) / 2

    -- height must be at least 2x the height of the arrows
    if height < (2 * ARROW_SIZE) then height = (2 * ARROW_SIZE) end
    -- the offset of the arrow is 1/4th of the remaining height
    local arrowOffset = (height - (2 * ARROW_SIZE)) / 4

    -- set the dimenions of the listBoxes
    leftListControl:SetDimensions(singleListWidth, height)
    leftHeadersControl:SetDimensions(singleListWidth, HEADER_HEIGHT)
    rightListControl:SetDimensions(singleListWidth, height)
    rightHeadersControl:SetDimensions(singleListWidth, HEADER_HEIGHT)

    -- for both buttons, clear the anchors first and then set new ones with the updated offsets
    leftButton:ClearAnchors()
    leftButton:SetAnchor(BOTTOMLEFT, leftListControl, BOTTOMRIGHT, -2, arrowOffset * -1) -- lower arrow requires negative offset

    rightButton:ClearAnchors()
    rightButton:SetAnchor(TOPRIGHT, rightListControl, TOPLEFT, 0, arrowOffset)
end

function ShifterBox:SetEnabled(enabled)
    -- TODO: Set buttons disabled

    -- TODO: Set listBoxes disabled
end

--- Sets the complete shifterBox to hidden, or shows it again
-- @param isHidden - whether the shifterBox should be hidden (boolean)
function ShifterBox:SetHidden(hidden)
    self:SetHidden(hidden)
end

function ShifterBox:SetLeftListData(dataList)
    local leftControl = self.leftList.control
    leftControl.entries = dataList
    self.leftList:Refresh()
end

function ShifterBox:AddEntryToLeftList(key, value, overwrite)
    local leftControl = self.leftList.control
    -- only add entry to list if key does not exist yet, or if overwrite is set to true
    if leftControl.entries[key] == nil or overwrite == true then
        table.insert(leftControl.entries, key, value)
        -- Refresh the visualisation of the data
        self.leftList:Refresh()
    end
end

function ShifterBox:SetRightListData(dataList)
    local rightControl = self.rightList.control
    rightControl.entries = dataList
    self.rightList:Refresh()
end

function ShifterBox:AddEntryToRightList(key, value, overwrite)
    local rightControl = self.rightList.control
    -- only add entry to list if key does not exist yet, or if overwrite is set to true
    if rightControl.entries[key] == nil or overwrite == true then
        table.insert(rightControl.entries, key, value)
        -- Refresh the visualisation of the data
        self.rightList:Refresh()
    end
end

function ShifterBox:RemoveEntryFromLeftList(key)
    -- TODO: Remove entry from left list
end

function ShifterBox:RemoveEntryFromRightList(key)
    -- TODO: Remove entry from right list
end

function ShifterBox:GetLeftListEntries()
    local leftControl = self.leftList.control
    return leftControl.entries
end

function ShifterBox:GetRightListEntries()
    local rightControl = self.rightList.control
    return rightControl.entries
end

function ShifterBox:ClearLeftList()
    local leftControl = self.leftList.control
    -- remove the entries
    leftControl.entries = {}
    -- and refresh the visualisation of the data
    self.leftList:Refresh()
end

function ShifterBox:ClearRightList()
    local rightControl = self.rightList.control
    -- remove the entries
    rightControl.entries = {}
    -- and refresh the visualisation of the data
    self.rightList:Refresh()
end


-- =================================================================================================================
-- == LIBRARY FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
function lib.GetControl(uniqueAddonName, uniqueShifterBoxName)
    local addonShifterBoxes = existingShifterBoxes[uniqueAddonName]
    if addonShifterBoxes ~= nil then
        return addonShifterBoxes[uniqueShifterBoxName]
    end
    return nil
end

function lib.Create(...)
    return ShifterBox:New(...)
end
setmetatable(lib, { __call = function(_, ...) return lib.Create(...) end })
