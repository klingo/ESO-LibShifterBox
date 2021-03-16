--[[shifterBoxData = {
    type = "shifterbox",
    uniqueAddonName = "MyUniqueAddonName", - unique name of your addon for creating the ShifterBox
    uniqueShifterBoxName = "MyUniqueShifterBoxName", -- unique name for this ShifterBox within your addon
    shifterBoxCustomSettings = {"table", "with", "LibShifterBox", "customSettings"},
    createFunc = function(shifterBox) end, -- function to call when the shifterBox was created (optional)
    refreshFunc = function(customControl) end, -- function to call when panel/controls refresh (optional)
    leftListEntries = {[key] = value, [key] = value, [key] = value}, -- key/value pairs, or function returning key/value pairs to initialise left list (optional)
    rightListEntries = {[key] = value, [key] = value, [key] = value}, -- key/value pairs, or function returning key/value pairs to initialise right list (optional)
    width = "full", -- or "half" (optional)
    height = 220, -- minimum height is 220, maximum height is 440 (optional)
    disabled = function() return db.someBooleanSetting end, -- or boolean (optional)
    reference = "MyAddonShifterBoxControl", -- unique name for your shifterBox control to use as reference (optional)
} ]]

-- TODO: refreshFunc
-- TODO: getLeftListEntries
-- TODO: getRightListEntries

local widgetVersion = 1

local LSB = LibShifterBox
if not LSB then return end

local LAM = LibAddonMenu2
if not LAM:RegisterWidget("shifterbox", widgetVersion) then return end

local MIN_HEIGHT = 220
local MAX_HEIGHT = MIN_HEIGHT * 2

local function UpdateDisabled(control)
    local disable
    if type(control.data.disabled) == "function" then
        disable = control.data.disabled()
    else
        disable = control.data.disabled
    end
    control.shifterBox:SetEnabled(not disable)
end

local function UpdateValue(control)
    if control.data.refreshFunc then
        control.data.refreshFunc(control)
    end
end

local function UpdateLeftList(control, entries)
    local leftListEntries
    if type(entries) == "function" then
        leftListEntries = entries()
    elseif type(entries) == "table" then
        leftListEntries = entries
    end
    control.shifterBox:AddEntriesToLeftList(leftListEntries)
end

local function UpdateRightList(control, entries)
    local rightListEntries
    if type(entries) == "function" then
        rightListEntries = entries()
    elseif type(entries) == "table" then
        rightListEntries = entries
    end
    control.shifterBox:AddEntriesToRightList(rightListEntries)
end

function LAMCreateControl.shifterbox(parent, shifterBoxData, controlName)
    local control = LAM.util.CreateBaseControl(parent, shifterBoxData, controlName)
    local isHalfWidth = control.isHalfWidth
    local width = control:GetWidth()
    local height = MIN_HEIGHT
    control:SetResizeToFitDescendents(true)

    -- ensure minimum/maximum height is adhered to
    if shifterBoxData.height ~= nil then
        if shifterBoxData.height < MAX_HEIGHT then
            height = shifterBoxData.height
        else
            height = MAX_HEIGHT
        end
    end

    if isHalfWidth then
        control:SetDimensionConstraints(width / 2, height, width / 2, MAX_HEIGHT)
    else
        control:SetDimensionConstraints(width, height, width, MAX_HEIGHT)
    end

    -- create the actual shifterBox
    control.shifterBox = LSB.Create(control.data.uniqueAddonName, control.data.uniqueShifterBoxName, control, control.data.shifterBoxCustomSettings)
    control.shifterBox:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    control.shifterBox:SetDimensions(isHalfWidth and width / 2 or width, height)

    -- TODO: check if to be removed
    control.UpdateValue = UpdateValue

    if shifterBoxData.disabled ~= nil then
        control.UpdateDisabled = UpdateDisabled
        control:UpdateDisabled()
    end

    control.UpdateLeftList = UpdateLeftList
    control:UpdateLeftList(shifterBoxData.leftListEntries)
    control.UpdateRightList = UpdateRightList
    control:UpdateRightList(shifterBoxData.rightListEntries)


    -- TODO: check if to be removed
    LAM.util.RegisterForRefreshIfNeeded(control)

    if control.data.createFunc then control.data.createFunc(control) end

    return control
end
