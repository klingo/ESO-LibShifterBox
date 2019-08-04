# LibShifterBox
LibShifterBox, a library add-on for '[The Elder Scrolls Online](https://www.elderscrollsonline.com/ "Home - The Elder Scrolls Online")'



***

## Download
Coming soon to [esoui.com](http://www.esoui.com/) !


## Example
This is a full example of how to use the LibShifterBox.

TO BE COMPLETED

```lua
local leftListData = {
    [1] = "Goodbye_1",
    [2] = "SeeYou_2",
    [3] = "Farewell_3",
    [4] = "Greetings_4",
    [5] = "Alloha_5",
    [6] = "ZeeYa_6",
}
        
local itemQualitiesShifterBox = LibShifterBox("MyNewAddon", "ItemQualities", parentControl)
itemQualitiesShifterBox:SetAnchor(TOPLEFT, headerControl, BOTTOMLEFT, 0, 20)
itemQualitiesShifterBox:SetDimensions(300, 200)
itemQualitiesShifterBox:SetLeftListEntries(leftListData)
```


***

## API Reference
  * [Create](#create)
  * [ShifterBox:SetAnchor](#shifterboxsetanchor)
  * [ShifterBox:SetDimensions](#shifterboxsetdimensions)
  * [ShifterBox:SetEnabled](#shifterboxsetenabled)
  * [ShifterBox:SetHidden](#shifterboxsethidden)
  * [LeftListBox](#leftlistbox)
    * [ShifterBox:SetLeftListEntries](#shifterboxsetleftlistentries)
    * [ShifterBox:GetLeftListEntries](#shifterboxgetleftlistentries)
    * [ShifterBox:AddEntryToLeftList](#shifterboxaddentrytoleftlist)
    * [ShifterBox:RemoveEntryFromLeftList](#shifterboxremoveentryfromleftlist)
    * [ShifterBox:ClearLeftList](#shifterboxclearleftlist)
  * [RightListBox](#rightlistbox)
    * [ShifterBox:SetRightListEntries](#shifterboxsetrightlistentries)
    * [ShifterBox:GetRightListEntries](#shifterboxgetrightlistentries)
    * [ShifterBox:AddEntryToRightList](#shifterboxaddentrytorightlist)
    * [ShifterBox:RemoveEntryFromRightList](#shifterboxremoveentryfromrightlist)
    * [ShifterBox:ClearRightList](#shifterboxclearrightlist)

### Create
Returns a new instance of ShifterBox with the given control name. `leftListTitle` and `rightListTitle` are optional and if provided render headers to sort the list. If not provided the headers are not shown and the list is sorted in ascending order.
```lua
local shifterBox = LibShifterBox(uniqueAddonName, uniqueShifterBoxName, parentControl, leftListTitle, rightListTitle)
```
or
```lua
local shifterBox = LibShifterBox.Create(uniqueAddonName, uniqueShifterBoxName, parentControl, leftListTitle, rightListTitle)
```

### ShifterBox:SetAnchor
Sets the anchor of the ShifterBox to any other control of your UI. Only one anchor is supported and any previous anchors will first be cleared.
```lua
shifterBox:SetAnchor(whereOnMe, anchorTargetControl, whereOnTarget, offsetX, offsetY)
```

### ShifterBox:SetDimensions
Sets the dimensions of the overall ShifterBox (across both listBoxes). The provided width is distributed to the two listBoxes and the space in between (for the buttons). There is a minimum height/width of 80.
```lua
shifterBox:SetDimensions(width, height)
```

### ShifterBox:SetEnabled
Sets the whole ShifterBox to enabled or disabled state. It is no longer possible to select entries or to shift them between the two listBoxes if disabled.
```lua
shifterBox:SetEnabled(enabled)
```

### ShifterBox:SetHidden
Sets the whole ShifterBox to hidden or shown state.
```lua
shifterBox:SetHidden(hidden)
```

### LeftListBox

#### ShifterBox:SetLeftListEntries
Sets the provided list into the left listBox. This replaces any existing entries.
```lua
shifterBox:SetLeftListEntries(entries)
```

#### ShifterBox:GetLeftListEntries
Returns a table with all entries that are currently in the left listBox.
```lua
shifterBox:GetLeftListEntries()
```

#### ShifterBox:AddEntryToLeftList
Adds one additional entry into the left listBox. If the key already exists the entry will not be added unless the `overwrite` param is set to `true`
```lua
shifterBox:AddEntryToLeftList(key, value, overwrite)
```

#### ShifterBox:RemoveEntryFromLeftList
Removes the specified entry from the left listBox.
```lua
shifterBox:RemoveEntryFromLeftList(key)
```

#### ShifterBox:ClearLeftList
Removes all entries from the left listBox.
```lua
shifterBox:ClearLeftList()
```


### RightListBox

#### ShifterBox:SetRightListEntries
Sets the provided list into the right listBox. This replaces any existing entries.
```lua
shifterBox:SetRightListEntries(entries)
```
#### ShifterBox:GetRightListEntries
Returns a table with all entries that are currently in the right listBox.
```lua
shifterBox:GetRightListEntries()
```
#### ShifterBox:AddEntryToRightList
Adds one additional entry into the right listBox. If the key already exists the entry will not be added unless the `overwrite` param is set to `true`
```lua
shifterBox:AddEntryToRightList(key, value, overwrite)
```

#### ShifterBox:RemoveEntryFromRightList
Removes the specified entry from the right listBox.
```lua
shifterBox:RemoveEntryFromRightList(key)
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