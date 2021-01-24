local _addonName = "ShifterBoxExample"

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

local function initAddon(_, addOnName)
    if addOnName ~= _addonName then
        return
    end

    EVENT_MANAGER:UnregisterForEvent("ShifterBoxExampleAddonInit", EVENT_ADD_ON_LOADED)

    initShifterBoxExample()
end

EVENT_MANAGER:RegisterForEvent("ShifterBoxExampleAddonInit", EVENT_ADD_ON_LOADED, initAddon)
