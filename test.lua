local Translator = TSMATE.backend
local languages = TSMATE.languages

local original_message = "Qwйї і123!№"

local common_translator = Translator:new(languages.Common)
local orcish_translator = Translator:new(languages.Orcish)

local common_message = common_translator:encode(original_message)
local orcish_message = orcish_translator:encode(original_message)


local decoded_common_common = common_translator:decode(common_message)
local decoded_orcish_orcish = orcish_translator:decode(orcish_message)
local decoded_common_orcish = orcish_translator:decode(common_message)
local decoded_orcish_common = common_translator:decode(orcish_message)

local messages = {
    original_message = original_message,
    common_message = common_message,
    orcish_message = orcish_message,
    decoded_common_common = decoded_common_common,
    decoded_orcish_orcish = decoded_orcish_orcish,
    decoded_common_orcish = decoded_common_orcish,
    decoded_orcish_common = decoded_orcish_common
}

for key, value in pairs(messages) do
    print(key .. " = " .. value)
end