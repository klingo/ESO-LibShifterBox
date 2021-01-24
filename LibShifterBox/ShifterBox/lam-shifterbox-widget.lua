--[[shifterBoxData = {
    type = "shifterbox",
    uniqueAddonName = "MyUniqueAddonName", - unique name of your addon for creating the ShifterBox
    uniqueShifterBoxName = "MyUniqueShifterBoxName", -- unique name for this ShifterBox within your addon
    reference = "MyAddonCustomControl", -- unique name for your control to use as reference (optional)
    shifterBoxCustomSettings = {"table", "with", "LibShifterBox", "customSettings"}
    refreshFunc = function(customControl) end, -- function to call when panel/controls refresh (optional)
    width = "full", -- or "half" (optional)
    height = 300, -- minimum height is 220, maximum height is 880 (optional)
    disabled = function() return db.someBooleanSetting end, -- or boolean (optional)
} ]]

local widgetVersion = 1
local LSB = LibShifterBox
local LAM = LibAddonMenu2
if not LAM:RegisterWidget("shifterbox", widgetVersion) then return end

local shifterBox

local function UpdateDisabled(control)
    local disable
    if type(control.data.disabled) == "function" then
        disable = control.data.disabled()
    else
        disable = control.data.disabled
    end

--    control.dropdown:SetEnabled(not disable)
    if disable then
--        control.label:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
    else
--        control.label:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    end
end

local function UpdateValue(control)
    if control.data.refreshFunc then
        control.data.refreshFunc(control)
    end
end

local function GetShifterBox()
    return shifterBox
end

local MIN_HEIGHT = 220
function LAMCreateControl.shifterbox(parent, shifterBoxData, controlName)
    local control = LAM.util.CreateBaseControl(parent, shifterBoxData, controlName)
    local isHalfWidth = control.isHalfWidth
    local width = control:GetWidth()
    control:SetResizeToFitDescendents(true)

    if isHalfWidth then --note these restrictions
        control:SetDimensionConstraints(width / 2, MIN_HEIGHT, width / 2, MIN_HEIGHT * 4)
    else
        control:SetDimensionConstraints(width, MIN_HEIGHT, width, MIN_HEIGHT * 4)
    end

    -- ensure minimum height is adhered to
    -- TODO: height parameter is not working
    if control.data.height == nil or control.data.height < 220 then
        control.data.height = 220
    end

    shifterBox = LSB.Create(control.data.uniqueAddonName, control.data.uniqueShifterBoxName, control, control.data.shifterBoxCustomSettings)
    shifterBox:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    shifterBox:SetDimensions(isHalfWidth and width / 2 or width, control.data.height)


    control.UpdateValue = UpdateValue
    control.UpdateDisabled = UpdateDisabled
    control.GetShifterBox = GetShifterBox

    LAM.util.RegisterForRefreshIfNeeded(control)

    return control
end
