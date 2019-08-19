local LSBStrings = {
    LIBSHIFTERBOX_EMPTY = "empty"
}

for key, value in pairs(LSBStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end