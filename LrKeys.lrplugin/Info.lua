--[[
LrKeys — keyboard shortcuts for Lightroom Classic masking.

The plugin only exposes menu commands (File > Plug-in Extras). The actual key
combos are bound to those menu titles through macOS App Shortcuts
(NSUserKeyEquivalents), see install.sh. Menu titles below must stay in sync
with install.sh.
]]

return {
	LrSdkVersion = 13.0,
	LrSdkMinimumVersion = 12.0, -- 'objects' AI mask subtype was added in SDK 12

	LrToolkitIdentifier = 'com.danilopolani.lrkeys',
	LrPluginName = 'LrKeys',

	LrExportMenuItems = {
		{ title = 'LrKeys: New Object Mask', file = 'NewObjectMask.lua' },
		{ title = 'LrKeys: Toggle Mask Visibility', file = 'ToggleMaskVisibility.lua' },
		{ title = 'LrKeys: Toggle Mask Overlay', file = 'ToggleMaskOverlay.lua' },
		{ title = 'LrKeys: Select Previous Mask', file = 'SelectPreviousMask.lua' },
		{ title = 'LrKeys: Select Next Mask', file = 'SelectNextMask.lua' },
	},

	VERSION = { major = 1, minor = 0, revision = 0 },
}
