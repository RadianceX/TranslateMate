local utf8lib = TSMATE.libs.utf8


TranslateMate = {}
function TranslateMate:new()
    local private = {}
    local public = {}

        function private:login_event_handler(event, arg0, arg1, arg2, arg3, arg4)
            --[[
            Prints greeting message when Player log in
            :param event: WoW event
            ]]
            if (event == "PLAYER_ENTERING_WORLD") then
                local version = GetAddOnMetadata("TranslateMate", "Version");
                private:addon_message("TranslateMate v"..version.." loaded. Type /translatemate for usage.")
            end
        end

        function private:addon_message(msg)
            --[[
            Append addon message to chat
            :param msg: message
            ]]
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFAA11"..msg.."|r")
        end

        function private:send_encoded(msg, language)
            --[[
            Send encoded version of input message to the chat
            :param msg: input message
            :param language: message language
            ]]
            local encoded = self.translator:encode(msg)
            SendChatMessage(encoded, "SAY", language)
        end

        function private:chat_message_event_handler(eventType, msg, speaker, language, ...)
            --[[
            Chat message event handler
            :param eventType: ???
            :param msg: message text
            :param speaker: message speaker
            :param language: message language
            :return: false or decoded message
            ]]
            -- Ensure that message was told in supported language
            if (string.find(private.supported_languages, language)) == nil then
                return false
            end

            -- Check if message is encoded
            if private.translator:is_encoded(msg) == false then
                return false
            end

            -- Decode message
            local decoded = private.translator:decode(msg)
            if decoded ~= nil then
                return false, decoded, speaker, "|cFFFFAA11"..language.."|r", ...;
            end

            -- Nothing was decoded
            return false
        end

        function private:setup_supported_languages()
            --[[
            Contcat supported languages to string
            ]]
            for key, val in pairs(TSMATE.languages) do
                private.supported_languages = private.supported_languages .. key
            end
        end

        function private:player_input_handler(msg, editBox)
            --[[
            Checks user input.
            If message has correct len - encode it. Otherwise print help
            :param msg: input message
            :param editBox: chat window???
            :return: nil
            ]]

            -- Actions for empty message
            if (not msg or msg == "") then
                private:addon_message("TranslateMate by RadianceX")
                private:addon_message("/translatemate to show this message")
                private:addon_message("/ts or /translatemate <message> to send translated message")
                private:addon_message("Max message len is " .. private.max_message_len)
                return
            end

            -- Check message lenght
            if (utf8lib.utf8len(msg) > private.max_message_len) then
                private:addon_message("Message too long to encode. Max lenght is " .. private.max_message_len)
                return
            end
            -- Send encoded message
            private:send_encoded(msg, editBox.language)
        end

        private.player_language = nil
        private.max_message_len = 36
        private.supported_languages = ""

        function public:init()
            local this = CreateFrame("Frame", "TranslateMate", UIParent)
            this:SetScript("OnEvent", private.prepare)
            this:RegisterEvent("PLAYER_ENTERING_WORLD")
        end

        function public:prepare()
            --[[
            Constructor
            ]]
            -- Register addon commands handler
            SLASH_TS1 = "/ts"
            SLASH_TS2 = "/translatemate"
            SlashCmdList["TS"] = function(msg, editBox) private:player_input_handler(msg, editBox) end

            -- Set OnLogin greeting
            local this = CreateFrame("Frame", "TranslateMate", UIParent)
            this:SetScript("OnEvent", private.login_event_handler)
            this:RegisterEvent("PLAYER_ENTERING_WORLD")

            -- Init translator
            private.player_language = GetDefaultLanguage("player")
            private.translator = TSMATE.backend:new(TSMATE.languages[private.player_language])
            private:setup_supported_languages()

            -- Set chat message event handler
            ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", private.chat_message_event_handler)
        end

    setmetatable(public,self)
    self.__index = self; return public
end


local tsmate = TranslateMate:new()
tsmate:prepare()
