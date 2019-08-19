local LSBStrings = {
    LIBSHIFTERBOX_EMPTY = "vide"
}

for key, value in pairs(LSBStrings) do
    SafeAddString(key, value, 1)
end