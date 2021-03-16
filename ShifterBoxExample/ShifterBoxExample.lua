local _addonName = "ShifterBoxExample"

local LAM2 = LibAddonMenu2 or LibStub("LibAddonMenu-2.0")
local OptionsTable = setmetatable({}, { __index = table })
local OptionSubTable = setmetatable({}, { __index = table })
local PanelData = {
    type = "panel",
    name = "ShifterBoxExample",
    author = "Klingo",
    registerForRefresh = true,
    registerForDefaults = false,
}

local function initShifterBoxExample()
    -- prepare the list of entries; in this case a list of item qualities in matching colour
    local leftListEntries = {
        [ITEM_QUALITY_TRASH] = GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_TRASH):Colorize(GetString("SI_ITEMQUALITY", ITEM_FUNCTIONAL_QUALITY_TRASH)),
        [ITEM_QUALITY_NORMAL] = GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_NORMAL):Colorize(GetString("SI_ITEMQUALITY", ITEM_FUNCTIONAL_QUALITY_NORMAL)),
        [ITEM_QUALITY_MAGIC] = GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_MAGIC):Colorize(GetString("SI_ITEMQUALITY", ITEM_FUNCTIONAL_QUALITY_MAGIC)),
        [ITEM_QUALITY_ARCANE] = GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_ARCANE):Colorize(GetString("SI_ITEMQUALITY", ITEM_FUNCTIONAL_QUALITY_ARCANE)),
        [ITEM_QUALITY_ARTIFACT] = GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_ARTIFACT):Colorize(GetString("SI_ITEMQUALITY", ITEM_FUNCTIONAL_QUALITY_ARTIFACT)),
        [ITEM_QUALITY_LEGENDARY] = GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_LEGENDARY):Colorize(GetString("SI_ITEMQUALITY", ITEM_FUNCTIONAL_QUALITY_LEGENDARY)),
    }
    -- Reminder: When you use colorized texts as values, please be aware that the color-coding becomes part of the value and thus may prevent from sorting in (visualy) alphabetical order!

    -- optionally, we can override the default settings
    local customSettings = {
        sortBy = "key",
        leftList = {
            title = "Available",
            emptyListText = "None",
            rowHeight = 28,
            fontSize = 16
        },
        rightList = {
            title = "Selected",
            emptyListText = "None",
            rowHeight = 28,
            fontSize = 16
        }
    }

    -- create the shifterBox and anchor it to a headerControl; also we can change the dimensions
    local itemQualitiesShifterBox = LibShifterBox("MyShifterBoxExample", "ItemQualities", ShifterBoxExampleMainWindow, customSettings)
    itemQualitiesShifterBox:SetAnchor(TOPLEFT, ShifterBoxExampleMainWindowHeader, BOTTOMLEFT, 0, 20)
    itemQualitiesShifterBox:SetDimensions(300, 200)

    -- finally, the previously defined entries are added to the left list
    itemQualitiesShifterBox:AddEntriesToLeftList(leftListEntries)



    -- --------------------------------------------------------

    local clearLeftListButton = ShifterBoxExampleMainWindow:GetNamedChild("ClearLeftList")
    clearLeftListButton:SetHandler("OnClicked", function(self)
        itemQualitiesShifterBox:ClearLeftList()
    end)

    local clearRightListButton = ShifterBoxExampleMainWindow:GetNamedChild("ClearRightList")
    clearRightListButton:SetHandler("OnClicked", function(self)
        itemQualitiesShifterBox:ClearRightList()
    end)

    local addEntryToLeftButton = ShifterBoxExampleMainWindow:GetNamedChild("AddEntryToLeft")
    local addEntryToLeftListIndexCounter = 99
    addEntryToLeftButton:SetHandler("OnClicked", function(self)
        itemQualitiesShifterBox:AddEntryToLeftList(addEntryToLeftListIndexCounter, "entry_" .. tostring(addEntryToLeftListIndexCounter), true)
        addEntryToLeftListIndexCounter = addEntryToLeftListIndexCounter + 1
    end)



    -- --------------------------------------------------------

    local function myLeftListClearedFunction(shifterBox, hasStillHiddenEntries)
        df("myLEFTListClearedFunction | hasStillHiddenEntries = %s", tostring(hasStillHiddenEntries))
    end
    itemQualitiesShifterBox:RegisterCallback(LibShifterBox.EVENT_LEFT_LIST_CLEARED, myLeftListClearedFunction)

    local function myRightListClearedFunction(shifterBox, hasStillHiddenEntries)
        df("myRIGHTListClearedFunction | hasStillHiddenEntries = %s", tostring(hasStillHiddenEntries))
    end
    itemQualitiesShifterBox:RegisterCallback(LibShifterBox.EVENT_RIGHT_LIST_CLEARED, myRightListClearedFunction)

    --    local function myEntryMovedFunction(shifterBox, key, value, categoryId, isDestListLeftList)
    --        shifterBox:AddEntryToLeftList("allo", "test", true)
    --    end
    --    itemQualitiesShifterBox:RegisterCallback(LibShifterBox.EVENT_ENTRY_MOVED, myEntryMovedFunction)
end

local function initLAMMenuWithShifterBoxExample()
    local fullWidthShifterBoxDisabled = true

    OptionsTable:insert({
        type = "header",
        name = "ShifterBox Example"
    })

    OptionsTable:insert({
        type = "description",
        text = "Here it comes in full-width:"
    })

    OptionsTable:insert({
        type = "shifterbox",
        uniqueAddonName = "ShifterBoxExample",
        uniqueShifterBoxName = "ExampleFullWidth",
        shifterBoxCustomSettings = {
            showMoveAllButtons = true,
            dragDropEnabled = true,
            sortEnabled = true,
            sortBy = "value",
            leftList = {
                title = "Lefties",
                rowHeight = 24,
                rowTemplateName = "ShifterBoxEntryTemplate",
                emptyListText = GetString(LIBSHIFTERBOX_EMPTY),
                fontSize = 14,
            },
            rightList = {
                title = "Righties",
                rowHeight = 32,
                rowTemplateName = "ShifterBoxEntryTemplate",
                emptyListText = GetString(LIBSHIFTERBOX_EMPTY),
                fontSize = 18,
            }
        },
        leftListEntries = function() return {[1] = "Hello", [2] = "from", [3] = "the"} end,
        rightListEntries = {[4] = "other", [5] = "side"},
        width = "full",
        height = 50,
        disabled = function() return fullWidthShifterBoxDisabled end,
        reference = "SHIFTERBOXEXAMPLE_FULL",
    })

    OptionsTable:insert({
        type = "checkbox",
        name = "Dummy Entry",
        getFunc = function() return false end,
        setFunc = function() end,
        disabled = function() return fullWidthShifterBoxDisabled end,
    })

    OptionsTable:insert({
        type = "checkbox",
        name = "Disable above shifterBox?",
        getFunc = function() return fullWidthShifterBoxDisabled end,
        setFunc = function(value) fullWidthShifterBoxDisabled = value end,
    })

    OptionsTable:insert({
        type = "description",
        text = "And here in half-width:"
    })

    OptionsTable:insert({
        type = "shifterbox",
        uniqueAddonName = "ShifterBoxExample",
        uniqueShifterBoxName = "ExampleHalfWidth",
        shifterBoxCustomSettings = {
            showMoveAllButtons = true,
            dragDropEnabled = false,
            sortEnabled = false,
            sortBy = "value",
            leftList = {
                title = "Available",
            },
            rightList = {
                title = "Selected",
            }
        },
        leftListEntries = function() return {[1] = "The", [2] = "quick", [3] = "brown", [4] = "fox", [5] = "jumps", [6] = "over", [7] = "the", [8] = "lazy", [9] = "dog"} end,
        width = "half",
        height = 400,
        reference = "SHIFTERBOXEXAMPLE_HALF",
    })

    OptionsTable:insert({
        type = "description",
        text = "<-- This is a LibShifterBox half-width",
        width = "half",
    })

    -- ----------------------------------------------

    OptionSubTable:insert({
        type = "description",
        text = "And this is a sub-level, half-width shifterbox:"
    })

    OptionSubTable:insert({
        type = "description",
        text = "This is a sub-level LibShifterBox half-width -->",
        width = "half",
    })

    OptionSubTable:insert({
        type = "shifterbox",
        uniqueAddonName = "ShifterBoxExample",
        uniqueShifterBoxName = "ExampleNestedHalfWidth",
        shifterBoxCustomSettings = {
            showMoveAllButtons = true,
            dragDropEnabled = false,
            sortEnabled = false,
            sortBy = "value",
            leftList = {
                title = "Available",
            },
            rightList = {
                title = "Selected",
            }
        },
        leftListEntries = function() return {[1] = "The", [2] = "quick", [3] = "brown", [4] = "fox", [5] = "jumps", [6] = "over", [7] = "the", [8] = "lazy", [9] = "dog"} end,
        width = "half",
        height = 200,
        reference = "SHIFTERBOXEXAMPLE_NESTED_HALF",
    })

    OptionsTable:insert({
        type = "submenu",
        name = "Shifterbox in sub-level menu",
        controls = OptionSubTable,
    })

    LAM2:RegisterAddonPanel("ShifterBoxExampleAddonOptions", PanelData)
    LAM2:RegisterOptionControls("ShifterBoxExampleAddonOptions", OptionsTable)
end

local function initAddon(_, addOnName)
    if addOnName ~= _addonName then
        return
    end

    EVENT_MANAGER:UnregisterForEvent("ShifterBoxExampleAddonInit", EVENT_ADD_ON_LOADED)

    initShifterBoxExample()

    initLAMMenuWithShifterBoxExample()
end

EVENT_MANAGER:RegisterForEvent("ShifterBoxExampleAddonInit", EVENT_ADD_ON_LOADED, initAddon)
