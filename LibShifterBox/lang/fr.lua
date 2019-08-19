local strings = {
    LIBSHIFTERBOX_EMPTY = "vide"
}
for stringId, stringValue in pairs(strings) do
    SafeAddString(stringId, stringValue, 1)
end