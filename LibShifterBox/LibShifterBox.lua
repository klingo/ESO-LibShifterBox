local LIB_IDENTIFIER = "LibShifterBox"

assert(not _G[LIB_IDENTIFIER], LIB_IDENTIFIER .. " is already loaded")

local lib = {}
_G[LIB_IDENTIFIER] = lib

-- =================================================================================================================
-- == LIBRARY CONSTANTS == --
-- -----------------------------------------------------------------------------------------------------------------
local LIST_SPACING = 40
local ARROW_SIZE = 36

-- =================================================================================================================
-- == LIBRARY VARIABLES == --
-- -----------------------------------------------------------------------------------------------------------------
lib.defaultSettings = {

}

local existingShifterBoxes = {}



-- =================================================================================================================
-- == PRIVATE FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
local function createShifterBox(uniqueAddonName, uniqueShifterBoxName, parentControl)
    local shifterBoxName = table.concat({uniqueAddonName, "_", uniqueShifterBoxName})
    return CreateControlFromVirtual(shifterBoxName, parentControl, "ShifterBoxTemplate")
end

local function initShifterBoxControls(control, leftListTitle, rightListTitle)
    local leftList = control:GetNamedChild("LeftList")
    local leftListContents = leftList:GetNamedChild("Contents")
    local rightList = control:GetNamedChild("RightList")
    local rightListContents = rightList:GetNamedChild("Contents")
    local toLeftButton = control:GetNamedChild("ToLeftButton")
    local toRightButton = control:GetNamedChild("ToRightButton")

    local function initListFrames(parentList)
        local listFrame = parentList:GetNamedChild("Frame")
        listFrame:SetCenterColor(0, 0, 0, 1)
        listFrame:SetEdgeTexture(nil, 1, 1, 1)
    end

    local function initButtonState(buttonControl, listContentControl)
        local listRowCount = listContentControl:GetNumChildren()
        if listRowCount == 0 then
            buttonControl:SetState(BSTATE_DISABLED, true)
        end
    end

    local function toLeftButtonClicked(buttonControl)
        d("One to the left!")

        -- TODO: implement whole entry-moving!

        local rightListRowCount = rightListContents:GetNumChildren()
        if rightListRowCount == 0 then
            buttonControl:SetState(BSTATE_DISABLED, true)
        else
            buttonControl:SetState(BSTATE_NORMAL, false)
        end
    end

    local function toRightButtonClicked(buttonControl)
        d("One to the right!")

        -- TODO: implement whole entry-moving!

        local leftListRowCount = leftListContents:GetNumChildren()
        if leftListRowCount == 0 then
            buttonControl:SetState(BSTATE_DISABLED, true)
        else
            buttonControl:SetState(BSTATE_NORMAL, false)
        end
    end

    -- initialize the frame/border around the listBoxes
    initListFrames(leftList)
    initListFrames(rightList)

    -- initialize the button state (i.e. disable button when there are no entries to be moved)
    initButtonState(toLeftButton, leftListContents)
    initButtonState(toRightButton, rightListContents)

    -- initialize the handler when the buttons are clicked
    toLeftButton:SetHandler("OnClicked", toLeftButtonClicked)
    toRightButton:SetHandler("OnClicked", toRightButtonClicked)

    -- TODO: initialize the titles for the two listBoxes (or not if omitted)
end

-- =================================================================================================================
-- == SHIFTERBOX FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
local ShifterBox = ZO_Object:Subclass()

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
    initShifterBoxControls(obj.shifterBoxControl, leftListTitle, rightListTitle)

    addonShifterBoxes[uniqueShifterBoxName] = obj
    return addonShifterBoxes[uniqueShifterBoxName]
end

function ShifterBox:SetAnchor(...)
    self.shifterBoxControl:SetAnchor(...)
end

function ShifterBox:SetDimensions(width, height)
    local leftList = self.shifterBoxControl:GetNamedChild("LeftList")
    local rightList = self.shifterBoxControl:GetNamedChild("RightList")
    local toLeftButton = self.shifterBoxControl:GetNamedChild("ToLeftButton")
    local toRightButton = self.shifterBoxControl:GetNamedChild("ToRightButton")

    -- widh must be at least three times the space between the listBoxes
    if width < (3 * LIST_SPACING) then width = (3 * LIST_SPACING) end
    -- the width of a listBox is the total width minus the spacing divided by two
    local singleListWidth = (width - LIST_SPACING) / 2

    -- height must be at least 2x the height of the arrows
    if height < (2 * ARROW_SIZE) then height = (2 * ARROW_SIZE) end
    -- the offset of the arrow is 1/4th of the remaining height
    local arrowOffset = (height - (2 * ARROW_SIZE)) / 4

    -- set the dimenions of the listBoxes
    leftList:SetDimensions(singleListWidth, height)
    rightList:SetDimensions(singleListWidth, height)

    -- for both buttons, clear the anchors first and then set new ones with the updated offsets
    toLeftButton:ClearAnchors()
    toLeftButton:SetAnchor(BOTTOMLEFT, leftList, BOTTOMRIGHT, -2, arrowOffset * -1) -- lower arrow requires negative offset

    toRightButton:ClearAnchors()
    toRightButton:SetAnchor(TOPRIGHT, rightList, TOPLEFT, 0, arrowOffset)
end

function ShifterBox:SetEnabled(isEnabled)
    -- TODO: Set buttons disabled

    -- TODO: Set listBoxes disabled
end

function ShifterBox:AddEntryToLeftList(key, value)
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
function lib.Create(...)
    return ShifterBox:New(...)
end
setmetatable(lib, { __call = function(_, ...) return lib.Create(...) end })
