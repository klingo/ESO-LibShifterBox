local LSBStrings = {
    LIBSHIFTERBOX_EMPTY = "пустой"
}

for key, value in pairs(LSBStrings) do
    SafeAddString(_G[key], value, 1)
end