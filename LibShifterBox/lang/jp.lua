local strings = {
    LIBSHIFTERBOX_EMPTY = "空の"
}
for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end