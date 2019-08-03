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

-- TODO: remove if no default settings to be added
lib.defaultSettings = {

}

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
    -- place where the entries are stored
    self.entries = {}
    -- define the datatype for this list and enable the highlighting
    ZO_ScrollList_AddDataType(self.list, DATA_TYPE_DEFAULT, "ShifterBoxEntryTemplate", 36, function(control, data) self:SetupRowEntry(control, data) end)
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
    -- set up sorting function and refresh all data
    self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, ShifterBoxList.SORT_KEYS, self.currentSortOrder) end
    self:RefreshData()
end

function ShifterBoxList:SetDataList(dataList)
    self.entries = {}
    for _, data in pairs(dataList) do
        table.insert(self.entries, data)
    end
end

function ShifterBoxList:FilterScrollList()
    -- get the data of the scrollist and index it
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
    -- populate the table that is used as source for the list
    for _, entry in pairs(self.entries) do
        local rowData = {
            key = entry.key,
            value = entry.value
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
        self:Row_OnMouseEnter(rowControl)
    end
    local function onRowMouseExit(rowControl)
        self:Row_OnMouseExit(rowControl)
    end

    -- store the rowData on the control so it can be accessed from other places
    rowControl.data = rowData

    -- set the value for the row entry
    local labelControl = rowControl:GetNamedChild("Label")
    labelControl:SetText(rowData.value)

    -- the below two handlers only work if "PersonalAssistantBankingRuleListRowTemplate" is set to a <Button> control
    rowControl:SetHandler("OnMouseEnter", onRowMouseEnter)
    rowControl:SetHandler("OnMouseExit", onRowMouseExit)

    ZO_SortFilterList.SetupRow(self, rowControl, rowData)
end

function ShifterBoxList:Refresh()
    self:RefreshData()
end


-- =================================================================================================================
-- == PRIVATE FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
local function createShifterBox(uniqueAddonName, uniqueShifterBoxName, parentControl)
    local shifterBoxName = table.concat({uniqueAddonName, "_", uniqueShifterBoxName})
    return CreateControlFromVirtual(shifterBoxName, parentControl, "ShifterBoxTemplate")
end

local function initShifterBoxControls(parentObj, leftListTitle, rightListTitle)
    local control = parentObj.shifterBoxControl

    local leftControl = control:GetNamedChild("Left")
    local leftListControl = leftControl:GetNamedChild("List")
    local leftListContentsControl = leftListControl:GetNamedChild("Contents")
    local leftButtonControl = leftControl:GetNamedChild("Button")

    local rightControl = control:GetNamedChild("Right")
    local rightListControl = rightControl:GetNamedChild("List")
    local rightListContentsControl = rightListControl:GetNamedChild("Contents")
    local rightButtonControl = rightControl:GetNamedChild("Button")

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

    local function initButtonState(buttonControl, listContentControl)
        local listRowCount = listContentControl:GetNumChildren()
        if listRowCount == 0 then
            buttonControl:SetState(BSTATE_DISABLED, true)
        end
    end

    local function leftButtonClicked(buttonControl)
        d("One to the left!")

        -- TODO: implement whole entry-moving!
        --      get the "entries" index
        --      remove the entries index
        --      add it to the other table
        --      refresh both tables

        local rightListRowCount = rightListContentsControl:GetNumChildren()
        if rightListRowCount == 0 then
            buttonControl:SetState(BSTATE_DISABLED, true)
        else
            buttonControl:SetState(BSTATE_NORMAL, false)
        end
    end

    local function rightButtonClicked(buttonControl)
        d("One to the right!")

        -- TODO: implement whole entry-moving!

        local leftListRowCount = leftListContentsControl:GetNumChildren()
        if leftListRowCount == 0 then
            buttonControl:SetState(BSTATE_DISABLED, true)
        else
            buttonControl:SetState(BSTATE_NORMAL, false)
        end
    end

    -- initialise the headers
    initHeaders(leftListTitle, rightListTitle)

    -- initialize the frame/border around the listBoxes
    initListFrames(leftListControl)
    initListFrames(rightListControl)

    -- initialize the button state (i.e. disable button when there are no entries to be moved)
    initButtonState(leftButtonControl, leftListContentsControl)
    initButtonState(rightButtonControl, rightListContentsControl)

    -- initialize the handler when the buttons are clicked
    leftButtonControl:SetHandler("OnClicked", leftButtonClicked)
    rightButtonControl:SetHandler("OnClicked", rightButtonClicked)


    -- TODO: initialize the titles for the two listBoxes (or not if omitted)
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

    -- initialize the ShifterBoxLists
    obj.leftList = ShifterBoxList:New(obj.shifterBoxControl:GetNamedChild("Left"))
    obj.rightList = ShifterBoxList:New(obj.shifterBoxControl:GetNamedChild("Right"))

    -- TODO: Temporary - remove later!
    obj.leftList:SetDataList({
        { key = 1, value = "Goodbye_1"},
        { key = 2, value = "SeeYou_2"},
        { key = 3, value = "Farewell_3"},
        { key = 4, value = "Greetings_4"},
        { key = 5, value = "Alloha_5"},
        { key = 6, value = "ZeeYa_6"},
    })

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

function ShifterBox:AddEntryToLeftList(key, value)
    -- TODO: find correct list to populate
    d("self.leftList.entries")
    d(self.leftList.entries)
    table.insert(self.leftList.entries, { key = key, value = value })

    -- Refresh the visualisation of the data
    self.leftList:Refresh()

    -- TODO: Add entry to left list
end

function ShifterBox:AddEntryToRightList(key, value)
    -- TODO: Add entry to right list
end

function ShifterBox:RemoveEntryFromLeftList(key)
    -- TODO: Remove entry from left list
end

function ShifterBox:RemoveEntryFromRightList(key)
    -- TODO: Remove entry from right list
end

function ShifterBox:GetLeftListEntries()
    -- TODO: get a list of all entiers on the left side
end

function ShifterBox:GetRightListEntries()
    -- TODO: get a list of all entiers on the right side
end

function ShifterBox:ClearLeftList()
    -- TODO: clear the left list (remove all entries)
end

function ShifterBox:ClearRightList()
    -- TODO: clear the right list (remove all entries)
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
