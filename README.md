# LibShifterBox
LibShifterBox, a library add-on for '[The Elder Scrolls Online](https://www.elderscrollsonline.com/ "Home - The Elder Scrolls Online")'

![alt text][shifterbox-example]


***

## Download
Coming soon to [esoui.com](http://www.esoui.com/) !


## Quick Start Example
This is a full example of how to use the LibShifterBox.
\
\
First the initial setup of the ShifterBox needs to be done:

```lua
-- prepare the list of entries; in this case a list of item qualities in matching colour
local leftListEntries = {
    [ITEM_QUALITY_TRASH] = GetItemQualityColor(ITEM_QUALITY_TRASH):Colorize(GetString("SI_ITEMQUALITY", ITEM_QUALITY_TRASH)),
    [ITEM_QUALITY_NORMAL] = GetItemQualityColor(ITEM_QUALITY_NORMAL):Colorize(GetString("SI_ITEMQUALITY", ITEM_QUALITY_NORMAL)),
    [ITEM_QUALITY_MAGIC] = GetItemQualityColor(ITEM_QUALITY_MAGIC):Colorize(GetString("SI_ITEMQUALITY", ITEM_QUALITY_MAGIC)),
    [ITEM_QUALITY_ARCANE] = GetItemQualityColor(ITEM_QUALITY_ARCANE):Colorize(GetString("SI_ITEMQUALITY", ITEM_QUALITY_ARCANE)),
    [ITEM_QUALITY_ARTIFACT] = GetItemQualityColor(ITEM_QUALITY_ARTIFACT):Colorize(GetString("SI_ITEMQUALITY", ITEM_QUALITY_ARTIFACT)),
    [ITEM_QUALITY_LEGENDARY] = GetItemQualityColor(ITEM_QUALITY_LEGENDARY):Colorize(GetString("SI_ITEMQUALITY", ITEM_QUALITY_LEGENDARY)),
}
-- Reminder: When you use colorized texts as values, please be aware that the color-coding becomes part of the value and thus may prevent from sorting in (visualy) alphabetical order!

-- optionally, we can override the default settings
local customSettings = {
    rowHeight = 30,
    sortBy = "key",
    emptyListText = "empty"
}

-- create the shifterBox and anchor it to a headerControl; also we can change the dimensions
local itemQualitiesShifterBox = LibShifterBox("MyNewAddon", "ItemQualities", parentControl, "Lefties", "Righties", customSettings)
itemQualitiesShifterBox:SetAnchor(TOPLEFT, headerControl, BOTTOMLEFT, 0, 20)
itemQualitiesShifterBox:SetDimensions(300, 200)

-- finally, the previously defined entries are added to the left list
itemQualitiesShifterBox:SetLeftListEntries(leftListEntries)
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
  * [ShifterBox:ShowAllCategories](#shifterboxshowallcategories)
  * [ShifterBox:HideCategory](#shifterboxhidecategory)
  * [ShifterBox:SelectEntryByKey](#shifterboxselectentrybykey)
  * [ShifterBox:SelectEntriesByKey](#shifterboxselectentriesbykey)
  * [ShifterBox:UnselectAllEntries](#shifterboxunselectallentries)
  * [ShifterBox:RemoveEntryByKey](#shifterboxremoveentrybykey)
  * [ShifterBox:RemoveEntriesByKey](#shifterboxremoveentriesbykey)
  * [LeftListBox](#leftlistbox)
    * [ShifterBox:GetLeftListEntries](#shifterboxgetleftlistentries)
    * [ShifterBox:AddEntryToLeftList](#shifterboxaddentrytoleftlist)
    * [ShifterBox:AddEntriesToLeftList](#shifterboxaddentriestoleftlist)
    * [ShifterBox:MoveEntryToLeftList](#shifterboxmoveentrytoleftlist)
    * [ShifterBox:MoveEntriesToLeftList](#shifterboxmoveentriestoleftlist)
    * [ShifterBox:ClearLeftList](#shifterboxclearleftlist)
  * [RightListBox](#rightlistbox)
    * [ShifterBox:GetRightListEntries](#shifterboxgetrightlistentries)
    * [ShifterBox:AddEntryToRightList](#shifterboxaddentrytorightlist)
    * [ShifterBox:AddEntriesToRightList](#shifterboxaddentriestorightlist)
    * [ShifterBox:MoveEntryToRightList](#shifterboxmoveentrytorightlist)
    * [ShifterBox:MoveEntriesToRightList](#shifterboxmoveentriestorightlist)
    * [ShifterBox:ClearRightList](#shifterboxclearrightlist)

### Create
Returns a new instance of ShifterBox with the given control name. `leftListTitle` and `rightListTitle` are optional and if provided render headers to sort the list. If not provided the headers are not shown and the list is sorted in ascending order. `customSettings` can also optionally be provided (with individual values), otherwise the default settings are used.
```lua
local shifterBox = LibShifterBox(uniqueAddonName, uniqueShifterBoxName, parentControl, leftListTitle, rightListTitle, customSettings)
```
or
```lua
local shifterBox = LibShifterBox.Create(uniqueAddonName, uniqueShifterBoxName, parentControl, leftListTitle, rightListTitle, customSettings)
```

#### CustomSettings
Optionally custom settings can be passed on when the ShifterBox is created. The following values can be set:
```lua
customSettings = {
    sortBy = "value",           -- sort the list by value or key (allowed are: "value" or "key")
    rowHeight = 32,             -- the height of an entry row
    emptyListText = "empty"     -- the text to be displayed when there is no row/entry in a list
}
```

### GetShifterBox
Returns the (first to be created) ShifterBox instance based on the `uniqueAddonName` and `uniqueShifterBoxName`.
```lua
local shifterBox = LibShifterBox.GetShifterBox(uniqueAddonName, uniqueShifterBoxName)
```

### GetControl
Returns the CT_CONTROL object of the (first to be created) ShifterBox based on the `uniqueAddonName` and `uniqueShifterBoxName`. This can be used to e.g. anchor other controls to the ShifterBox.
\
It is preferred to use the `:GetControl()` function of your instantiated shifterBox (see below).
```lua
local shifterBoxControl = LibShifterBox.GetControl(uniqueAddonName, uniqueShifterBoxName)
```

### ShifterBox:GetControl
Returns the CT_CONTROL object of the instantiated shifterBox. This can be used to e.g. anchor other controls to the ShifterBox.
```lua
local shifterBoxControl = shifterBox:GetControl()
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


### LeftListBox

#### ShifterBox:GetLeftListEntries
Returns a table with **all** entries that are currently in the left listBox (including the hidden ones). If `withCategoryId` is omitted or set to `false`, only key/value pairs are returned. If set to `true` then also the `categoryId` is returned per entry.
```lua
shifterBox:GetLeftListEntries(withCategoryId)
```

#### ShifterBox:GetLeftListVisibleEntries
Returns a table with all entries that are currently in the left listBox and that are not hidden. If `withCategoryId` is omitted or set to `false`, only key/value pairs are returned. If set to `true` then also the `categoryId` is returned per entry.
```lua
shifterBox:GetLeftListVisibleEntries(withCategoryId)
```

#### ShifterBox:AddEntryToLeftList
Adds one additional entry into the left listBox. If the key already exists the entry will not be added; unless if `replace` is set to `true`, then the entry with the same key in **either** listBox will be replaced.
\
Optionally a `categoryId` can be provided to assign the entry to a specific category. These then can be shown/hidden with `ShowCategory(categoryId)` and `HideCategory(categoryId)`. If not provided, the default categoryId is used (`LibShifterBox.DEFAULT_CATEGORY`)
```lua
shifterBox:AddEntryToLeftList(key, value, replace, categoryId)
```

#### ShifterBox:AddEntriesToLeftList
Adds a list of entries into the left listBox. If any of the keys already exists the entry will not be added; unless if `replace` is set to `true`, then the entry with the same key in **either** listBox will be replaced.
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

#### ShifterBox:ClearLeftList
Removes all entries from the left listBox.
```lua
shifterBox:ClearLeftList()
```


### RightListBox

#### ShifterBox:GetRightListEntries
Returns a table with **all** entries that are currently in the right listBox (including the hidden ones). If `withCategoryId` is omitted or set to `false`, only key/value pairs are returned. If set to `true` then also the `categoryId` is returned per entry.
```lua
shifterBox:GetRightListEntries(withCategoryId)
```

#### ShifterBox:GetRightListVisibleEntries
Returns a table with all entries that are currently in the right listBox and that are not hidden. If `withCategoryId` is omitted or set to `false`, only key/value pairs are returned. If set to `true` then also the `categoryId` is returned per entry.
```lua
shifterBox:GetRightListVisibleEntries(withCategoryId)
```

#### ShifterBox:AddEntryToRightList
Adds one additional entry into the right listBox. If the key already exists the entry will not be added; unless if `replace` is set to `true`, then the entry with the same key in **either** listBox will be replaced.
\
Optionally a `categoryId` can be provided to assign the entry to a specific category. These then can be shown/hidden with `ShowCategory(categoryId)` and `HideCategory(categoryId)`. If not provided, the default categoryId is used (`LibShifterBox.DEFAULT_CATEGORY`)
```lua
shifterBox:AddEntryToRightList(key, value, replace, categoryId)
```

#### ShifterBox:AddEntriesToRightList
Adds a list of entries into the right listBox. If any of the keys already exists the entry will not be added; unless if `replace` is set to `true`, then the entry with the same key in **either** listBox will be replaced.
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

#### ShifterBox:ClearRightList
Removes all entries from the right listBox.
```lua
shifterBox:ClearRightList()
```


***

## Disclaimer

**Disclaimer:**
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.


[shifterbox-example]: ./info/images/ShifterBox_Example.png "ShifterBox Example"
[shifterbox-example-1]: ./info/images/ShifterBox_Example_1.png "ShifterBox Example - Init"
[shifterbox-example-2]: ./info/images/ShifterBox_Example_2.png "ShifterBox Example - Added/Replaced"
[shifterbox-example-3]: ./info/images/ShifterBox_Example_3.png "ShifterBox Example - Selected"
[shifterbox-example-4]: ./info/images/ShifterBox_Example_4.png "ShifterBox Example - Disabled"
