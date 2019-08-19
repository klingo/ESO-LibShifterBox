local LSBStrings = {
    LIBSHIFTERBOX_EMPTY = "leer"
}

for key, value in pairs(LSBStrings) do
    SafeAddString(key, value, 1)
end