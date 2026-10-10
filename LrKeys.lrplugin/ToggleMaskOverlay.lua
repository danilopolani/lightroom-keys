-- Unbound by default: toggle the colored mask overlay (same as the O key, but works anywhere).

local LrDevelopController = import 'LrDevelopController'
local Develop = require 'Develop'

Develop.run('Toggle Mask Overlay', function()
	Develop.ensureMaskingTool()
	LrDevelopController.toggleOverlay()
end)
