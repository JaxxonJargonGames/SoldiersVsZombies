local Chat = game:GetService("Chat")
local ClientChatModules = Chat:WaitForChild("ClientChatModules")
local ChatSettings = require(ClientChatModules:WaitForChild("ChatSettings"))

local extraOffset = (7 * 2) + (5 * 2) -- Extra chatbar vertical offset

ChatSettings.BubbleChatEnabled = true
ChatSettings.ClassicChatEnabled = true
ChatSettings.DefaultWindowSizeDesktop = UDim2.new(0.35, 0, 0.5, extraOffset)
