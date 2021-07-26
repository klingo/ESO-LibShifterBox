# LibShifterBox
<a href="https://www.buymeacoffee.com/klingo" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-yellow.png" alt="Buy Me A Coffee"></a>

LibShifterBox, a library add-on for '[The Elder Scrolls Online](https://www.elderscrollsonline.com/ "Home - The Elder Scrolls Online")'

## Download
You can always download the latest version here: https://www.esoui.com/downloads/info2444-LibShifterBox.html


## Quick Start Example
This is a full example of how to use the LibShifterBox.
![alt text][shifterbox-example]
\
\
In your `MyAddon.txt` file, make sure you defined LibShifterBox as a dependency:
```
## DependsOn: LibShifterBox
```
Optionally, you can also define a specific min-version:
```
## DependsOn: LibShifterBox>=17
```
\
\
Then the initial setup of the ShifterBox needs to be done:

```lua
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
        title = "Lefties",
        emptyListText = "None",
        rowHeight = 48,
        fontSize = 24
    },
    rightList = {
        title = "Righties",
        emptyListText = "None",
        rowHeight = 28,
        fontSize = 14
    }
}

-- create the shifterBox and anchor it to a headerControl; also we can change the dimensions
local itemQualitiesShifterBox = LibShifterBox("MyNewAddon", "ItemQualities", parentControl, customSettings)
itemQualitiesShifterBox:SetAnchor(TOPLEFT, headerControl, BOTTOMLEFT, 0, 20)
itemQualitiesShifterBox:SetDimensions(300, 200)

-- finally, the previously defined entries are added to the left list
itemQualitiesShifterBox:AddEntriesToLeftList(leftListEntries)
```
![alt text][shifterbox-example-1]

\
Additional entries can be added, or existing ones replaced:
```lua
-- this adds a new entry to the right list
itemQualitiesShifterBox:AddEntryToRightList(10, "HelloWorld")
-- this replaces the existing [Epic] entry from the left and adds it with a new value to the right list
itemQualitiesShifterBox:AddEntryToRightList(ITEM_QUALITY_ARTIFACT, "Epic-Replacement", true)
```
![alt text][shifterbox-example-2]

\
Entries can be selected by their key:
```lua
itemQualitiesShifterBox:SelectEntryByKey(ITEM_QUALITY_LEGENDARY)
itemQualitiesShifterBox:SelectEntryByKey(10)
```
![alt text][shifterbox-example-3]

\
The whole ShifterBox is set to disabled:
```lua
itemQualitiesShifterBox:SetEnabled(false)
```
![alt text][shifterbox-example-4]


***

## API Reference
  * [Create](#create)
  * [GetShifterBox](#getshifterbox)
  * [GetControl](#getcontrol)
  * [ShifterBox:GetControl](#shifterboxgetcontrol)
  * [ShifterBox:SetAnchor](#shifterboxsetanchor)
  * [ShifterBox:SetDimensions](#shifterboxsetdimensions)
  * [ShifterBox:SetEnabled](#shifterboxsetenabled)
  * [ShifterBox:SetHidden](#shifterboxsethidden)
  * [ShifterBox:ShowCategory](#shifterboxshowcategory)
  * [ShifterBox:ShowOnlyCategory](#shifterboxshowonlycategory)
  * [ShifterBox:ShowAllCategories](#shifterboxshowallcategories)
  * [ShifterBox:HideCategory](#shifterboxhidecategory)
  * [ShifterBox:SelectEntryByKey](#shifterboxselectentrybykey)
  * [ShifterBox:SelectEntriesByKey](#shifterboxselectentriesbykey)
  * [ShifterBox:UnselectAllEntries](#shifterboxunselectallentries)
  * [ShifterBox:RemoveEntryByKey](#shifterboxremoveentrybykey)
  * [ShifterBox:RemoveEntriesByKey](#shifterboxremoveentriesbykey)
  * [ShifterBox:RegisterCallback](#shifterboxregistercallback)
  * [ShifterBox:UnregisterCallback](#shifterboxunregistercallback)
  * [LeftListBox](#leftlistbox)
    * [ShifterBox:GetLeftListEntries](#shifterboxgetleftlistentries)
    * [ShifterBox:GetLeftListEntriesFull](#shifterboxgetleftlistentriesfull)
    * [ShifterBox:AddEntryToLeftList](#shifterboxaddentrytoleftlist)
    * [ShifterBox:AddEntriesToLeftList](#shifterboxaddentriestoleftlist)
    * [ShifterBox:MoveEntryToLeftList](#shifterboxmoveentrytoleftlist)
    * [ShifterBox:MoveEntriesToLeftList](#shifterboxmoveentriestoleftlist)
    * [ShifterBox:ClearLeftList](#shifterboxclearleftlist)
  * [RightListBox](#rightlistbox)
    * [ShifterBox:GetRightListEntries](#shifterboxgetrightlistentries)
    * [ShifterBox:GetRightListEntriesFull](#shifterboxgetrightlistentriesfull)
    * [ShifterBox:AddEntryToRightList](#shifterboxaddentrytorightlist)
    * [ShifterBox:AddEntriesToRightList](#shifterboxaddentriestorightlist)
    * [ShifterBox:MoveEntryToRightList](#shifterboxmoveentrytorightlist)
    * [ShifterBox:MoveEntriesToRightList](#shifterboxmoveentriestorightlist)
    * [ShifterBox:MoveAllEntriesToRightList](#shifterboxmoveallentriestorightlist)
    * [ShifterBox:ClearRightList](#shifterboxclearrightlist)

### Create
Returns a new instance of ShifterBox with the given control name. `customSettings` can optionally be provided (with individual values), otherwise the default settings are used. Furthermore the optional `anchorOptions`, `dimensionOptions`, `leftListEntries`, and `rightListEntries` can shortcut the separate calling of `shifterBox:SetAnchor`, `shifterBox:SetDimensions`, `shifterBox:AddEntriesToLeftList` and `shifterBox:AddEntriesToRightList` respectively.
```lua
local shifterBox = LibShifterBox(uniqueAddonName, uniqueShifterBoxName, parentControl, customSettings, anchorOptions, dimensionOptions, leftListEntries, rightListEntries)
```
or
```lua
local shifterBox = LibShifterBox.Create(uniqueAddonName, uniqueShifterBoxName, parentControl, customSettings, anchorOptions, dimensionOptions, leftListEntries, rightListEntries)
```
is the same as:
```lua
local shifterBox = LibShifterBox.Create(uniqueAddonName, uniqueShifterBoxName, parentControl, customSettings)
shifterBox:SetAnchor(unpack(anchorOptions))
shifterBox:SetDimensions(unpack(dimensionOptions))
shifterBox:AddEntriesToLeftList(leftListEntries)
shifterBox:AddEntriesToRightList(rightListEntries)
```

#### customSettings
Optionally custom settings can be passed on when the ShifterBox is created.
\
The following values can be set:
```lua
customSettings = {
    showMoveAllButtons = true,  -- the >> and << buttons to move all entries can be hidden if set to false
    dragDropEnabled = true,     -- entries can be moved between lsit with drag-and-drop
    sortEnabled = true,         -- sorting of the entries can be disabled
    sortBy = "value",           -- sort the list by value or key (allowed are: "value" or "key")
    leftList = {                -- list-specific settings that apply to the LEFT list
        title = "",                                         -- the title/header of the list
        rowHeight = 32,                                     -- the height of an individual row/entry
        rowTemplateName = "ShifterBoxEntryTemplate",        -- an individual XML (cirtual) control can be provided for the rows/entries
        emptyListText = GetString(LIBSHIFTERBOX_EMPTY),     -- the text to be displayed if there are no entries left in the list
        fontSize = 18,                                      -- size of the font
        rowDataTypeSelectSound = SOUNDS.ABILITY_SLOTTED,    -- an optional sound to play when a row of this data type is selected
        rowOnMouseRightClick = function(rowControl, data)   -- an optional callback function when a right-click is done inside a row element (e.g. for custom context menus)
            d("LSB: OnMouseRightClick: "..tostring(data.tooltipText))   -- reading custom 'tooltipText' from 'rowSetupAdditionalDataCallback'
        end,
        rowSetupCallback = function(rowControl, data)       -- function that will be called when a control of this type becomes visible
            d("LSB: RowSetupCallback")                      -- Calls self:SetupRowEntry, then this function, finally ZO_SortFilterList.SetupRow
        end,
        rowSetupAdditionalDataCallback = function(rowControl, data) -- data can be extended with additional data during the 'rowSetupCallback'
            d("LSB: SetupAdditionalDataCallback")
            data.tooltipText = data.value
            return rowControl, data                         -- this callback function must return the rowControl and (enriched) data again
        end,
        rowResetControlCallback = function()                -- an optional callback when the datatype control gets reset
            d("LSB: RowResetControlCallback")
        end,                    
        callbackRegister = {                                -- directly register callback functions to any of the exposed events
            [LibShifterBox.EVENT_LEFT_LIST_ROW_ON_MOUSE_ENTER] = function(rowControl, shifterBox, data)
                d("LSB: LeftListRowOnMouseEnter")
            end,
            [LibShifterBox.EVENT_LEFT_LIST_ROW_ON_MOUSE_EXIT] = function(rowControl, shifterBox, data)
                d("LSB: LeftListRowOnMouseExit")
            end
        }
    },
    rightList = {               -- list-specific settings that apply to the RIGHT list
        title = "",                                         -- the title/header of the list
        rowHeight = 32,                                     -- the height of an individual row/entry
        rowTemplateName = "ShifterBoxEntryTemplate",        -- an individual XML (cirtual) control can be provided for the rows/entries
        emptyListText = GetString(LIBSHIFTERBOX_EMPTY),     -- the text to be displayed if there are no entries left in the list
        fontSize = 18,                                      -- size of the font
        rowDataTypeSelectSound = SOUNDS.ABILITY_SLOTTED,    -- an optional sound to play when a row of this data type is selected
        rowOnMouseRightClick = function(rowControl, data)   -- an optional callback function when a right-click is done inside a row element (e.g. for custom context menus)
            d("LSB: OnMouseRightClick: "..tostring(data.tooltipText))   -- reading custom 'tooltipText' from 'rowSetupAdditionalDataCallback'
        end,
        rowSetupCallback = function(rowControl, data)       -- function that will be called when a control of this type becomes visible
            d("LSB: RowSetupCallback")                      -- Calls self:SetupRowEntry, then this function, finally ZO_SortFilterList.SetupRow
        end,
        rowSetupAdditionalDataCallback = function(rowControl, data) -- data can be extended with additional data during the 'rowSetupCallback'
            d("LSB: SetupAdditionalDataCallback")
            data.tooltipText = data.value
            return rowControl, data                         -- this callback function must return the rowControl and (enriched) data again
        end,
        rowResetControlCallback = function()                -- an optional callback when the datatype control gets reset
            d("LSB: RowResetControlCallback")
        end,
        callbackRegister = {                                -- directly register callback functions to any of the exposed events
            [LibShifterBox.EVENT_RIGHT_LIST_ROW_ON_MOUSE_ENTER] = function(rowControl, shifterBox, data)
                d("LSB: LeftListRowOnMouseEnter")
            end,
            [LibShifterBox.EVENT_RIGHT_LIST_ROW_ON_MOUSE_EXIT] = function(rowControl, shifterBox, data)
                d("LSB: LeftListRowOnMouseExit")
            end
        }
    }    
}
```
For `rowDataTypeSelectSound`, you may look at the overview of [Sounds](https://wiki.esoui.com/Sounds) in the ESOUI Wiki.

#### anchorOptions
Optionally anchorOptions can be passed on when the ShifterBox is created. This replaces the separate call of `shifterBox:SetAnchors()`.
\
The following values can be set:
```
anchorOptions = {
    number whereOnMe,
    object anchorTargetControl,
    number whereOnTarget, 
    number offsetX, 
    number offsetY
}
```

#### dimensionOptions
Optionally dimensionOptions can be passed on when the ShifterBox is created. This replaces the separate call of `shifterBox:SetDimensions()`.
\
The following values can be set:
```
dimensionOptions = {
    number width,
    number height
}
```

#### leftListEntries
Optionally leftListEntries can be passed on when the ShifterBox is created to directly populate the left listBox. This replaces the separate call of `shifterBox:AddEntriesToLeftList()`. Note though that this way no `categoryId` can be provided for the entries.
\
The `leftListEntries` must either be a table with the following format, or a function return such table:
```
{
    [key] = value,
    [key] = value
}
```

#### rightListEntries
Optionally rightListEntries can be passed on when the ShifterBox is created to directly populate the right listBox. This replaces the separate call of `shifterBox:AddEntriesToRightList()`. Note though that this way no `categoryId` can be provided for the entries.
\
The `rightListEntries` must either be a table with the following format, or a function return such table:
```
{
    [key] = value,
    [key] = value
}
```


### GetShifterBox
Returns the (first to be created) ShifterBox instance based on the `uniqueAddonName` and `uniqueShifterBoxName`.
```lua
local shifterBox = LibShifterBox.GetShifterBox(uniqueAddonName, uniqueShifterBoxName)
```

### GetControl
Returns the CT_CONTROL object of the (first to be created) ShifterBox based on the `uniqueAddonName` and `uniqueShifterBoxName`. This can be used to e.g. anchor other controls to the ShifterBox.
Additionally, as second return parameter the instance of the shifterBox itself is returned.
\
It is preferred to use the `:GetControl()` function of your instantiated shifterBox (see below).
```lua
local shifterBoxControl, shifterBox = LibShifterBox.GetControl(uniqueAddonName, uniqueShifterBoxName)
```

### ShifterBox:GetControl
Returns the CT_CONTROL object of the instantiated shifterBox. This can be used to e.g. anchor other controls to the ShifterBox.
Additionally, as second return parameter the instance of the shifterBox itself is returned.
```lua
local shifterBoxControl, shifterBox = shifterBox:GetControl()
```

### ShifterBox:SetAnchor
Sets the anchor of the ShifterBox to any other control of your UI. Only one anchor is supported and any previous anchors will first be cleared.
```lua
shifterBox:SetAnchor(whereOnMe, anchorTargetControl, whereOnTarget, offsetX, offsetY)
```

### ShifterBox:SetDimensions
Sets the dimensions of the overall ShifterBox (across both listBoxes and including header titles if applicable). The provided width is distributed to the two listBoxes and the space in between (for the buttons). There is a minimum height/width of 80x80.
```lua
shifterBox:SetDimensions(width, height)
```

### ShifterBox:SetEnabled
Sets the whole ShifterBox to enabled or disabled state. It is no longer possible to select entries or to shift them between the two listBoxes if disabled.
```lua
shifterBox:SetEnabled(enabled)
```

### ShifterBox:SetHidden
Sets the whole ShifterBox to hidden or shows it again.
```lua
shifterBox:SetHidden(hidden)
```

### ShifterBox:ShowCategory
Shows all entries that have been added to the shifterBox under the provided `categoryId`.
```lua
shifterBox:ShowCategory(categoryId)
```

### ShifterBox:ShowOnlyCategory
Shows all entries that have been added to the shifterBox under the provided `categoryId`. All entries with a different `categoryId` will be hidden.
```lua
shifterBox:ShowOnlyCategory(categoryId)
```

### ShifterBox:ShowAllCategories
Shows all entries that have been hidden with `shifterBox:HideCategory(categoryId)`.
```lua
shifterBox:ShowAllCategories()
```

### ShifterBox:HideCategory
Hides all entries that have been added to the shifterBox under the provided `categoryId`.
```lua
shifterBox:HideCategory(categoryId)
```

### ShifterBox:SelectEntryByKey
Selects (or deselects if already selected) an entry on either listBox based on the provided key.
```lua
shifterBox:SelectEntryByKey(key)
```

### ShifterBox:SelectEntriesByKey
Selects (or deselects if already selected) a list of entries on either listBox. The provided `keys` must be a table with keys such as `keys = {1, 2, 3}`.
```lua
shifterBox:SelectEntriesByKey(keys)
```

### ShifterBox:UnselectAllEntries
Deselects all entries on either listBox.
```lua
shifterBox:UnselectAllEntries()
```

### ShifterBox:RemoveEntryByKey
Removes an entry on either listBox based on the provided key.
```lua
shifterBox:RemoveEntryByKey(key)
```

### ShifterBox:RemoveEntriesByKey
Removes a list of entries on either listBox. The provided `keys` must be a table with keys such as `keys = {1, 2, 3}`.
```lua
shifterBox:RemoveEntriesByKey(keys)
```

### ShifterBox:RegisterCallback
Register your own `callbackFunction` that is executed upon various shifterBox events.
```lua
shifterBox:RegisterCallback(shifterBoxEvent, callbackFunction)
```
The following values for `shifterBoxEvent` are currently supported:

#### LibShifterBox.EVENT_ENTRY_HIGHLIGHTED
This event is triggered when an entry is highlighted (i.e. clicked on with the mouse, or by calling `ShifterBox:SelectEntryByKey` and `ShifterBox:SelectEntriesByKey`).
```lua
-- @param control object referencing the entry/row that has been highlighted
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param key string with the key of the highlighted entry
-- @param value string with the (displayed) value of the highlighted entry
-- @categoryId string with the category of the highlighted entry (can be nil)
-- @isLeftList boolean whether the highlighted entry is in the left listBox
local function myEntryHighlightedFunction(control, shifterBox, key, value, categoryId, isLeftList)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_ENTRY_HIGHLIGHTED, myEntryHighlightedFunction)
```

#### LibShifterBox.EVENT_ENTRY_UNHIGHLIGHTED
This event is triggered when an entry is un-highlighted (i.e. clicked on a highlighted entry with the mouse)
```lua
-- @param control object referencing the entry/row that has been un-highlighted
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param key string with the key of the highlighted entry
-- @param value string with the (displayed) value of the un-highlighted entry
-- @categoryId string with the category of the un-highlighted entry (can be nil)
-- @isLeftList boolean whether the un-highlighted entry is in the left listBox
local function myEntryUnhighlightedFunction(control, shifterBox, key, value, categoryId, isLeftList)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_ENTRY_UNHIGHLIGHTED, myEntryUnhighlightedFunction)
```

#### LibShifterBox.EVENT_ENTRY_MOVED
This event is triggered when an entry is moved from one list to another, either with the [<] and [>] buttons, by drag-and-drop or with any of the library functions. \
Note that when you move multiple entries, this event is also triggered multiple times (once per moved entry).
```lua
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param key string with the key of the moved entry
-- @param value string with the (displayed) value of the moved entry
-- @categoryId string with the category of the moved entry (can be nil)
-- @isDestListLeftList boolean whether the entry is is moved to the left listBox
-- @fromList object a list of all entries from the source list, AFTER the move
-- #toList object a list of all entries from the destination list, AFTER the move 
local function myEntryMovedFunction(shifterBox, key, value, categoryId, isDestListLeftList, fromList, toList)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_ENTRY_MOVED, myEntryMovedFunction)
```

#### LibShifterBox.EVENT_LEFT_LIST_CLEARED
This event is triggered when the left list has been cleared from all (shown) entries, i.e. the entries have been moved to the right list, or got deleted from it. \
It does not check for entries that are part of a category that is currently hidden, only entries from shown categories are considered when evaluating if the left list is cleared or not. The event however can be triggered when `ShifterBox:HideCategory` or `ShifterBox:ShowOnlyCategory` are called and the left list does not have any entries left.
```lua
-- @param shifterBox object referencing the shifterBox that triggered this event
local function myLeftListClearedFunction(shifterBox)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_LEFT_LIST_CLEARED, myLeftListClearedFunction)
```

#### LibShifterBox.EVENT_RIGHT_LIST_CLEARED
This event is triggered when the right list has been cleared from all (shown) entries, i.e. the entries have been moved to the left list, or got deleted from it. \
It does not check for entries that are part of a category that is currently hidden, only entries from shown categories are considered when evaluating if the right list is cleared or not. The event however can be triggered when `ShifterBox:HideCategory` or `ShifterBox:ShowOnlyCategory` are called and the right list does not have any entries left.
```lua
-- @param shifterBox object referencing the shifterBox that triggered this event
local function myRightListClearedFunction(shifterBox)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_RIGHT_LIST_CLEARED, myRightListClearedFunction)
```

#### LibShifterBox.EVENT_LEFT_LIST_ENTRY_ADDED
This event is triggered whenever a new entry is added to the left list with `ShifterBox:AddEntryToLeftList` (once) or `ShifterBox:AddEntriesToLeftList` (multiple times). \
It is NOT triggered when items are moved from the right list to the left list.
```lua
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param list object referencing the left ShifterBoxList (subclass of ZO_SortFilterList)
-- @param entryAdded table containing details about the added entry
local function myLeftListEntryAddedFunction(shifterBox, list, entryAdded)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_LEFT_LIST_ENTRY_ADDED, myLeftListEntryAddedFunction)
```
The returned `entryAdded` has the following structure:
```lua
entryAdded = {
    key=key,
    value=value,
    categoryId=categoryId,
}
```

#### LibShifterBox.EVENT_RIGHT_LIST_ENTRY_ADDED
This event is triggered whenever a new entry is added to the left list with `ShifterBox:AddEntryToRightList` (once) or `ShifterBox:AddEntriesToRightList` (multiple times). \
It is NOT triggered when items are moved from the left list to the right list.
```lua
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param list object referencing the left ShifterBoxList (subclass of ZO_SortFilterList)
-- @param entryAdded table containing details about the added entry
local function myRightListEntryAddedFunction(shifterBox, list, entryAdded)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_RIGHT_LIST_ENTRY_ADDED, myRightListEntryAddedFunction)
```
The returned `entryAdded` has the following structure:
```lua
entryAdded = {
    key=key,
    value=value,
    categoryId=categoryId,
}
```

#### LibShifterBox.EVENT_LEFT_LIST_ENTRY_REMOVED
This event is triggered whenever an existing entry is removed from the left list with `ShifterBox:RemoveEntryByKey` (once) or `ShifterBox:RemoveEntriesByKey` (multiple times). It can also be triggered by `ShifterBox:AddEntryTo___List` (once) and `ShifterBox:AddEntriesTo___List` (multiple times) when `replace=true` and an entry with the same key already exists. In that case it will first be removed, and then a new entry is added. \
It is NOT triggered when items are moved from the left list to the right list.  
```lua
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param list object referencing the left ShifterBoxList (subclass of ZO_SortFilterList)
-- @param entryRemoved table containing details about the removed entry
local function myLeftListEntryRemovedFunction(shifterBox, list, entryRemoved)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_LEFT_LIST_ENTRY_REMOVED, myLeftListEntryRemovedFunction)
```
The returned `entryRemoved` has the following structure:
```lua
entryRemoved = {
    key=key,
}
```

#### LibShifterBox.EVENT_RIGHT_LIST_ENTRY_REMOVED
This event is triggered whenever an existing entry is removed from the right list with `ShifterBox:RemoveEntryByKey` (once) or `ShifterBox:RemoveEntriesByKey` (multiple times). It can also be triggered by `ShifterBox:AddEntryTo___List` (once) and `ShifterBox:AddEntriesTo___List` (multiple times) when `replace=true` and an entry with the same key already exists. In that case it will first be removed, and then a new entry is added. \
It is NOT triggered when items are moved from the right list to the left list.
```lua
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param list object referencing the left ShifterBoxList (subclass of ZO_SortFilterList)
-- @param entryRemoved table containing details about the removed entry
local function myRightListEntryRemovedFunction(shifterBox, list, entryRemoved)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_RIGHT_LIST_ENTRY_REMOVED, myRightListEntryRemovedFunction)
```
The returned `entryRemoved` has the following structure:
```lua
entryRemoved = {
    key=key,
}
```

#### LibShifterBox.EVENT_LEFT_LIST_CREATED
This event is triggered when the left list has been created and thus is accessible now to other functions such as for adding new entries to it.
```lua
-- @param leftListControl object referencing the left list control that has been created
-- @param shifterBox object referencing the shifterBox that triggered this event
local function myLeftListCreatedFunction(leftListControl, shifterBox)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_LEFT_LIST_CREATED, myLeftListCreatedFunction)
```

#### LibShifterBox.EVENT_RIGHT_LIST_CREATED
This event is triggered when the right list has been created and thus is accessible now to other functions such as for adding new entries to it.
```lua
-- @param rightListControl object referencing the right list control that has been created
-- @param shifterBox object referencing the shifterBox that triggered this event
local function myRightListCreatedFunction(rightListControl, shifterBox)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_RIGHT_LIST_CREATED, myRightListCreatedFunction)
```

#### LibShifterBox.EVENT_LEFT_LIST_ROW_ON_MOUSE_ENTER
This event is triggered when the mouse cursor enters the control of a row in the left list. When the mouse cursors leaves the control of the row again, a different event `LibShifterBox.EVENT_LEFT_LIST_ROW_ON_MOUSE_EXIT` is triggered.
```lua
-- @param rowControl object referencing the row control that the mouse cursor has entered
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param rawRowData object with the raw data from the row
local function myLeftListRowMouseEnterFunction(rowControl, shifterBox, rawRowData)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_LEFT_LIST_ROW_ON_MOUSE_ENTER, myLeftListRowMouseEnterFunction)
```

#### LibShifterBox.EVENT_RIGHT_LIST_ROW_ON_MOUSE_ENTER
This event is triggered when the mouse cursor enters the control of a row in the right list. When the mouse cursors leaves the control of the row again, a different event `LibShifterBox.EVENT_LEFT_RIGHT_ROW_ON_MOUSE_EXIT` is triggered.
```lua
-- @param rowControl object referencing the row control that the mouse cursor has entered
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param rawRowData object with the raw data from the row
local function myRightListRowMouseEnterFunction(rowControl, shifterBox, rawRowData)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_RIGHT_LIST_ROW_ON_MOUSE_ENTER, myRightListRowMouseEnterFunction)
```

#### LibShifterBox.EVENT_LEFT_LIST_ROW_ON_MOUSE_EXIT
This event is triggered when the mouse cursor leaves the control of a row in the left list.
```lua
-- @param rowControl object referencing the row control that the mouse cursor has left
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param rawRowData object with the raw data from the row
local function myLeftListRowMouseExitFunction(rowControl, shifterBox, rawRowData)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_LEFT_LIST_ROW_ON_MOUSE_EXIT, myLeftListRowMouseExitFunction)
```

#### LibShifterBox.EVENT_RIGHT_LIST_ROW_ON_MOUSE_EXIT
This event is triggered when the mouse cursor leaves the control of a row in the right list.
```lua
-- @param rowControl object referencing the row control that the mouse cursor has left
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param rawRowData object with the raw data from the row
local function myRightListRowMouseExitFunction(rowControl, shifterBox, rawRowData)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_RIGHT_LIST_ROW_ON_MOUSE_EXIT, myRightListRowMouseExitFunction)
```

#### LibShifterBox.EVENT_LEFT_LIST_ROW_ON_MOUSE_UP
This event is triggered when a mouse button is pressed and released again while hovering over a row in the left list.
```lua
-- @param rowControl object referencing the row control that the mouse cursor clicked on
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param mouseButton number referencing the mouse button that was pressed and release
-- @param isInside boolean indicating whether the mouse cursor was still hovering the control when release (TO-BE-CONFIRMED)
-- @param altKey boolean indicating whether the ALT key modifier was pressed
-- @param shiftKey boolean indicating whether the SHIFT key modifier was pressed
-- @param commandKey boolean indicating whether the CMD key modifier was pressed (macOS)
-- @param rawRowData object with the raw data from the row
local function myLeftListRowMouseUpFunction(rowControl, shifterBox, mouseButton, isInside, altKey, shiftKey, commandKey, rawRowData)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_LEFT_LIST_ROW_ON_MOUSE_UP, myLeftListRowMouseUpFunction)
```

#### LibShifterBox.EVENT_RIGHT_LIST_ROW_ON_MOUSE_UP
This event is triggered when a mouse button is pressed and released again while hovering over a row in the right list.
```lua
-- @param rowControl object referencing the row control that the mouse cursor clicked on
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param mouseButton number referencing the mouse button that was pressed and release
-- @param isInside boolean indicating whether the mouse cursor was still hovering the control when release (TO-BE-CONFIRMED)
-- @param altKey boolean indicating whether the ALT key modifier was pressed
-- @param shiftKey boolean indicating whether the SHIFT key modifier was pressed
-- @param commandKey boolean indicating whether the CMD key modifier was pressed (macOS)
-- @param rawRowData object with the raw data from the row
local function myRightListRowMouseUpFunction(rowControl, shifterBox, mouseButton, isInside, altKey, shiftKey, commandKey, rawRowData)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_RIGHT_LIST_ROW_ON_MOUSE_UP, myRightListRowMouseUpFunction)
```

#### LibShifterBox.EVENT_LEFT_LIST_ROW_ON_DRAG_START
This event is triggered when either one row in the left list was clicked on and then started to drag it out while still holding down the mouse key.
It can also be triggered for multiple entries if they get selected before.
```lua
-- @param draggedControl object referencing the row control that the mouse cursor started to drag
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param mouseButton number referencing the mouse button that was pressed and release
-- @param rawDraggedRowData object with the raw data from the row, enriched with additional data
local function myLeftListRowDragStartFunction(draggedControl, shifterBox, mouseButton, rawDraggedRowData)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_LEFT_LIST_ROW_ON_DRAG_START, myLeftListRowDragStartFunction)
```
The returned `rawDraggedRowData` is additionally enriched with the following attributes:
```
_sourceListControl          CT_CONTROL
_sourceDraggedControl       CT_CONTROL
_isSelected                 boolean
_hasMultipleRowsSelected    boolean
_numRowsSelected            number
_isFromLeftList             boolean
_draggedText                string
_draggedAdditionalText      string
```

#### LibShifterBox.EVENT_RIGHT_LIST_ROW_ON_DRAG_START
This event is triggered when either one row in the right list was clicked on and then started to drag it out while still holding down the mouse key.
It can also be triggered for multiple entries if they get selected before.
```lua
-- @param draggedControl object referencing the row control that the mouse cursor started to drag
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param mouseButton number referencing the mouse button that was pressed and release
-- @param rawDraggedRowData object with the raw data from the row, enriched with additional data
local function myRightListRowDragStartFunction(draggedControl, shifterBox, mouseButton, rawDraggedRowData)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_RIGHT_LIST_ROW_ON_DRAG_START, myRightListRowDragStartFunction)
```
The returned `rawDraggedRowData` is additionally enriched with the following attributes:
```
_sourceListControl          CT_CONTROL
_sourceDraggedControl       CT_CONTROL
_isSelected                 boolean
_hasMultipleRowsSelected    boolean
_numRowsSelected            number
_isFromLeftList             boolean
_draggedText                string
_draggedAdditionalText      string
```

#### LibShifterBox.EVENT_LEFT_LIST_ROW_ON_DRAG_END
This event is triggered when the mouse key is let go again after dragging a row from the left list.
Entries can only be dragged to a list that belongs to the same shifterBox as the source list; the event gets triggered in all cases though.
```lua
-- @param draggedOnToControl object referencing the control that the mouse cursor stopped to drag
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param mouseButton number referencing the mouse button that was pressed and release
-- @param rawDraggedRowData object with the raw data from the row, enriched with additional data
-- @param hasSameShifterBoxParent boolean indicating if the target list is of the same shifterBox
-- @param wasDragSuccessful boolean indicating whether the dragged data was successfully moved to the right list
local function myLeftListRowDragEndFunction(draggedOnToControl, shifterBox, mouseButton, rawDraggedRowData, hasSameShifterBoxParent, wasDragSuccessful)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_LEFT_LIST_ROW_ON_DRAG_END, myLeftListRowDragEndFunction)
```
The returned `rawDraggedRowData` is additionally enriched with the following attributes:
```
_sourceListControl          CT_CONTROL
_sourceDraggedControl       CT_CONTROL
_isSelected                 boolean
_hasMultipleRowsSelected    boolean
_numRowsSelected            number
_isFromLeftList             boolean
_draggedText                string
_draggedAdditionalText      string
```

#### LibShifterBox.EVENT_RIGHT_LIST_ROW_ON_DRAG_END
This event is triggered when the mouse key is let go again after dragging a row from the left list.
Entries can only be dragged to a list that belongs to the same shifterBox as the source list; the event gets triggered in all cases though.
```lua
-- @param draggedOnToControl object referencing the control that the mouse cursor stopped to drag
-- @param shifterBox object referencing the shifterBox that triggered this event
-- @param mouseButton number referencing the mouse button that was pressed and release
-- @param rawDraggedRowData object with the raw data from the row, enriched with additional data
-- @param hasSameShifterBoxParent boolean indicating if the target list is of the same shifterBox
-- @param wasDragSuccessful boolean indicating whether the dragged data was successfully moved to the left list
local function myRightListRowDragEndFunction(draggedOnToControl, shifterBox, mouseButton, rawDraggedRowData, hasSameShifterBoxParent, wasDragSuccessful)
    -- do something
end
shifterBox:RegisterCallback(LibShifterBox.EVENT_RIGHT_LIST_ROW_ON_DRAG_END, myRightListRowDragEndFunction)
```
The returned `rawDraggedRowData` is additionally enriched with the following attributes:
```
_sourceListControl          CT_CONTROL
_sourceDraggedControl       CT_CONTROL
_isSelected                 boolean
_hasMultipleRowsSelected    boolean
_numRowsSelected            number
_isFromLeftList             boolean
_draggedText                string
_draggedAdditionalText      string
```

### ShifterBox:UnregisterCallback
Unregisters the before set `callbackFunction` for the given `shifterBoxEvent`. The same events as for `RegisterCallback` are valid.
```lua
shifterBox:UnregisterCallback(shifterBoxEvent, callbackFunction)
```


### LeftListBox

#### ShifterBox:GetLeftListEntries
Returns a table with all visible entries in the left listBox that are not part of a hidden category. If `withCategoryId` is omitted or set to `false`, only key/value pairs are returned. If set to `true` then also the `categoryId` is returned per entry.
```lua
shifterBox:GetLeftListEntries(withCategoryId)
```

#### ShifterBox:GetLeftListEntriesFull
Returns a table with **all** entries in the left listBox, including ones that are part of a hidden category. If `withCategoryId` is omitted or set to `false`, only key/value pairs are returned. If set to `true` then also the `categoryId` is returned per entry.
```lua
shifterBox:GetLeftListEntriesFull(withCategoryId)
```

#### ShifterBox:AddEntryToLeftList
Adds one additional entry into the left listBox. If the key already exists in either listBox, the entry will not be added; unless if `replace` is set to `true`, then the entry with the same key in **either** listBox will be replaced.
\
Optionally a `categoryId` can be provided to assign the entry to a specific category. These then can be shown/hidden with `ShowCategory(categoryId)` and `HideCategory(categoryId)`. If not provided, the default categoryId is used (`LibShifterBox.DEFAULT_CATEGORY`)
```lua
shifterBox:AddEntryToLeftList(key, value, replace, categoryId)
```

#### ShifterBox:AddEntriesToLeftList
Adds a list of entries into the left listBox. If any of the keys already exists in either listBox, the entry will not be added; unless if `replace` is set to `true`, then the entry with the same key in **either** listBox will be replaced.
\
The `entries` can either be a table with entries, or a function that returns a table. The format must be like: `{ [key] = value, [key] = value }`
\
Optionally a `categoryId` can be provided to assign the entries to a specific category. These then can be shown/hidden with `ShowCategory(categoryId)` and `HideCategory(categoryId)`. If not provided, the default categoryId is used (`LibShifterBox.DEFAULT_CATEGORY`)
```lua
shifterBox:AddEntriesToLeftList(entries, replace, categoryId)
```

#### ShifterBox:MoveEntryToLeftList
Moves a single entry from the right listBox into the left listBox.
```lua
shifterBox:MoveEntryToLeftList(key)
```

#### ShifterBox:MoveEntriesToLeftList
Moves a list of entries from the right listBox into the left listBox. The provided `keys` must be a table with keys such as `keys = {1, 2, 3}`.
```lua
shifterBox:MoveEntriesToLeftList(keys)
```

#### ShifterBox:MoveAllEntriesToLeftList
Moves all entries (including hidden ones) from the right listBox into the left listBox.
```lua
shifterBox:MoveAllEntriesToLeftList()
```

#### ShifterBox:ClearLeftList
Removes all entries from the left listBox.
```lua
shifterBox:ClearLeftList()
```


### RightListBox

#### ShifterBox:GetRightListEntries
Returns a table with all visible entries in the right listBox that are not part of a hidden category. If `withCategoryId` is omitted or set to `false`, only key/value pairs are returned. If set to `true` then also the `categoryId` is returned per entry.
```lua
shifterBox:GetRightListEntries(withCategoryId)
```

#### ShifterBox:GetRightListEntriesFull
Returns a table with **all** entries in the right listBox, including ones that are part of a hidden category. If `withCategoryId` is omitted or set to `false`, only key/value pairs are returned. If set to `true` then also the `categoryId` is returned per entry.
```lua
shifterBox:GetRightListEntriesFull(withCategoryId)
```

#### ShifterBox:AddEntryToRightList
Adds one additional entry into the right listBox. If the key already exists in either listBox, the entry will not be added; unless if `replace` is set to `true`, then the entry with the same key in **either** listBox will be replaced.
\
Optionally a `categoryId` can be provided to assign the entry to a specific category. These then can be shown/hidden with `ShowCategory(categoryId)` and `HideCategory(categoryId)`. If not provided, the default categoryId is used (`LibShifterBox.DEFAULT_CATEGORY`)
```lua
shifterBox:AddEntryToRightList(key, value, replace, categoryId)
```

#### ShifterBox:AddEntriesToRightList
Adds a list of entries into the right listBox. If any of the keys already exists in either listBox, the entry will not be added; unless if `replace` is set to `true`, then the entry with the same key in **either** listBox will be replaced.
\
The `entries` can either be a table with entries, or a function that returns a table. The format must be like: `{ [key] = value, [key] = value }`
\
Optionally a `categoryId` can be provided to assign the entries to a specific category. These then can be shown/hidden with `ShowCategory(categoryId)` and `HideCategory(categoryId)`. If not provided, the default categoryId is used (`LibShifterBox.DEFAULT_CATEGORY`)
```lua
shifterBox:AddEntriesToRightList(entries, replace, categoryId)
```

#### ShifterBox:MoveEntryToRightList
Moves a single entry from the left listBox into the right listBox.
```lua
shifterBox:MoveEntryToRightList(key)
```

#### ShifterBox:MoveEntriesToRightList
Moves a list of entries from the left listBox into the right listBox. The provided `keys` must be a table with keys such as `keys = {1, 2, 3}`.
```lua
shifterBox:MoveEntriesToRightList(keys)
```

#### ShifterBox:MoveAllEntriesToRightList
Moves all entries (including hidden ones) from the left listBox into the right listBox.
```lua
shifterBox:MoveAllEntriesToRightList()
```

#### ShifterBox:ClearRightList
Removes all entries from the right listBox.
```lua
shifterBox:ClearRightList()
```


***

## Addons using LibShifterBox
Here you can find an (incomplete) list of [Addons using LibShifterBox](https://github.com/klingo/ESO-LibShifterBox/wiki/Addons-using-LibShifterBox).

***

## Disclaimer

**Disclaimer:**
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.


[shifterbox-example]: ./info/images/ShifterBox_Example.png "ShifterBox Example"
[shifterbox-example-1]: ./info/images/ShifterBox_Example_1.png "ShifterBox Example - Init"
[shifterbox-example-2]: ./info/images/ShifterBox_Example_2.png "ShifterBox Example - Added/Replaced"
[shifterbox-example-3]: ./info/images/ShifterBox_Example_3.png "ShifterBox Example - Selected"
[shifterbox-example-4]: ./info/images/ShifterBox_Example_4.png "ShifterBox Example - Disabled"
