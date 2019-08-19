local strings = {
    LIBSHIFTERBOX_EMPTY = "пустой"
}
for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end