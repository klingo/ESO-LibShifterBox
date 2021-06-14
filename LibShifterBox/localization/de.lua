local LSBStrings = {
    LIBSHIFTERBOX_ALLREADY_LOADED   = "Ist bereits geladen",
    LIBSHIFTERBOX_EMPTY             = "leer"
}

for key, value in pairs(LSBStrings) do
    SafeAddString(_G[key], value, 1)
end