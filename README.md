# ShifterBoxLib
ShifterBoxLib, a Library Add-on for '[The Elder Scrolls Online](https://www.elderscrollsonline.com/ "Home - The Elder Scrolls Online")'

***

## Download
Not yet available


***

## How to use
Not yet available




## API Reference
  * [Create](#create)
  * [ShifterBox:SetAnchor](#shifterbox-setanchor)
  * [ShifterBox:SetDimensions](#shifterbox-setdimensions)
  * [ShifterBox:SetEnabled](#shifterbox-setenabled)
  * [ShifterBox:SetHidden](#shifterbox-sethidden)

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

***

## Disclaimer

**Disclaimer:**
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.