local LSBStrings = {
    LIBSHIFTERBOX_EMPTY = "vide"
}

for key, value in pairs(LSBStrings) do
    SafeAddString(_G[key], value, 1)
end