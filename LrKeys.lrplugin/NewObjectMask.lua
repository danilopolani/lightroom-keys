-- Cmd+O: start a new "Select Object" AI mask (same as Masking > New Mask > Objects).

local LrDevelopController = import 'LrDevelopController'
local Develop = require 'Develop'

Develop.run('New Object Mask', function()
	Develop.ensureMaskingTool()
	LrDevelopController.createNewMask('aiSelection', 'objects')
end)
