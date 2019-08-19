local LSBStrings = {
    LIBSHIFTERBOX_EMPTY = "空の"
}

for key, value in pairs(LSBStrings) do
    SafeAddString(key, value, 1)
end