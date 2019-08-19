local strings = {
    LIBSHIFTERBOX_EMPTY = "leer"
}
for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end