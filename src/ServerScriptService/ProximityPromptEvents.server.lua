local ProximityPromptService = game:GetService("ProximityPromptService")
local ServerScriptService = game:GetService("ServerScriptService")

local ProximityPromptActions = require(ServerScriptService.ProximityPromptActions)

ProximityPromptService.PromptTriggered:Connect(function(promptObject, player)
	ProximityPromptActions.promptTriggeredActions(promptObject, player)
end)

--ProximityPromptService.PromptButtonHoldBegan:Connect(function(promptObject, player)
--	ProximityPromptActions.promptButtonHoldBeganActions(promptObject, player)
--end)

--ProximityPromptService.PromptButtonHoldEnded:Connect(function(promptObject, player)
--	ProximityPromptActions.promptButtonHoldEndedActions(promptObject, player)
--end)
