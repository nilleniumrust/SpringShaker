local BuiltIn = {}

export type  __camShakePreset = {
	Magnitude: number, 
	Roughness: number, 
	FadeInTime: number, 
	FadeOutTime: number, 
	__RenderName: string, 
	__RenderPriority: Enum.RenderPriority,
	__CFCallback: CFrame,
	__Callback: () -> (),
}


export type Constants = {
	Magnitude: (number) -> number;
	Roughness: (number) -> number
}

local __camShakeStates = {
	Reserved = -1, 
	Inactive = 0,
	Active = 1,
	FadeInProgress = 2, 
	FadeOutProgress = 3
}

export type CamShakeStates = typeof(__camShakeStates)

local __camShakePresetConfiguration = {
	MAGNITUDE = "Magnitude",
	ROUGHNESS = "Roughness",
	FADEOUTTIME = "FadeOutTime",
	FADEINTIME = "FadeInTime"
}


BuiltIn.BuildInPresets = {
	__presetConfig = __camShakePresetConfiguration,
	__camShakeStates = __camShakeStates
}

return BuiltIn
