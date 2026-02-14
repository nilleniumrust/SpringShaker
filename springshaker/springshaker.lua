--[[
SpringShaker by kasym77777 
Forked from sleitnick's CamShaker module. 

Upgraded/modified version of sleitnick's CamShaker portable, opensource module.
https://github.com/Sleitnick/RbxCameraShaker

WORK IN PROGRESS - STEADY WORK
]]

local SpringShaker = {}
local SpringShakerPresets = {}

local BuiltIn = require(script.BuiltIn)
local Presets = BuiltIn.BuildInPresets
local PresetConfig = Presets.__presetConfig

local CurrentCamera = workspace.CurrentCamera

local ShakerInstances = require(script.ShakerInstances)
local RunService = game:GetService("RunService")

local __classInstances = {}
export type __SpringShakerClassDef  = typeof(SpringShakerPresets) & BuiltIn.__camShakePreset

SpringShakerPresets.__index = function(self, __indexmap)
	local internal_rawdata = rawget(self, __indexmap)
	if internal_rawdata ~= nil then 
		return internal_rawdata 
	end

	local PRESET_CONNECTOR = {
		[PresetConfig.MAGNITUDE] = function() return self.Magnitude end,
		[PresetConfig.ROUGHNESS] = function() return self.Roughness end,
		[PresetConfig.FADEINTIME] = function() return self.FadeInTime end,
		[PresetConfig.FADEOUTTIME] = function() return self.FadeOutTime end
	}

	local __connector = PRESET_CONNECTOR[__indexmap]
	if __connector then 
		return __connector()
	end

	return SpringShaker[__indexmap]
end

---@class SpringShaker_Constructor 
--- Creates a brand new Springy camera shaker that will be stored until you will trigger. 
---@param Magnitude number -- The magnitude of the camera shake. 
---@param Roughness number -- The roughness of the camera shake.
---@param FadeInTime number -- At what time, should the shake be started. 
---@param PosInflux Vector3 -- Amount of Vector3 position that affects the Camera shake sequence
---@param RotInflux Vector3 -- Amount of (Vector3 -> CFrame) rotation that affects the Camera shake sequence
---@param FadeOutTime number -- At what time, should the shake be stopped.
---@param __RenderPriority -- used for the RunService:BindToRenderStep() function. 
---@return __SpringShakerClass -- returns an important table data which you can use with term functions
function SpringShaker.new(Magnitude: number, PosInflux: Vector3, RotInflux: Vector3, Roughness: number, FadeInTime: number, FadeOutTime: number, __RenderPriority: Enum.RenderPriority): __SpringShakerClassDef
	assert(RunService:IsClient(), "Cannot be run on server for complicated terms. Only can be applied on client.")
	assert(typeof(PosInflux) == "Vector3" and typeof(RotInflux) == "Vector3", "in vector mathematics any types of given to posInflux and rotInflux are unacceptable, therefore they cannot be correctly converted.")

	local __SpringShakerClass: BuiltIn.__camShakePreset = setmetatable({
		Active = true,
		Magnitude = Magnitude or 0.4, 

		Roughness = Roughness or 0.2, 
		FadeInTime = FadeInTime or 0.1, 
		FadeOutTime = FadeOutTime or 0.5,
		
		RotInflux = RotInflux or Vector3.zero, 
		PosInflux = PosInflux or Vector3.zero, 
		
		__Callback = nil,
		__RenderPriority = __RenderPriority or Enum.RenderPriority.Camera.Value, 
		__RenderName = "SpringShaker",
	}, SpringShakerPresets) 

	table.insert(__classInstances, __SpringShakerClass)
	return __SpringShakerClass
end

function SpringShaker:Start(SpringDef: __SpringShakerClassDef)
	assert(SpringDef, "SpringDef must be of type table")
	assert(SpringDef.Active, "SpringDef is not currently active!")
	
	if self.__running then return end
	self.__running = true
	
	SpringDef.__Callback = RunService:BindToRenderStep(SpringDef.__RenderName, SpringDef.__RenderPriority, function(DeltaTime)
		print(#__classInstances)
		
		if #__classInstances == 0 then 
			RunService:UnbindFromRenderStep(SpringDef.__RenderName)
			self.__running = not self.__running
			return
		end
		CurrentCamera.CFrame *= self:UpdateAll(DeltaTime)
	end)
end

function SpringShaker:Halt(SpringDef: __SpringShakerClassDef)
	assert(SpringDef, "SpringDef must be of type table")
	assert(SpringDef.Active, "SpringDef is not currently active!")
	
	if SpringDef.__Callback then 
		RunService:UnbindFromRenderStep(SpringDef.__RenderName)
		SpringDef.__Callback = nil
	end
end


function SpringShaker:UpdateAll(dx: number): CFrame
	if #__classInstances == 0 then return CFrame.identity end
	
	local __posdef = Vector3.zero 
	local __rotdef = Vector3.zero

	for i = #__classInstances, 1, -1 do 
		local __SpringShakerClass = __classInstances[i]
		local __SpringShakeInstance = __SpringShakerClass.__SpringShakeInstance 

		local currentState = __SpringShakeInstance:GetState()

		if currentState == BuiltIn.BuildInPresets.__camShakeStates.Inactive or __SpringShakeInstance:IsDead() then 
			self:Recycle(__SpringShakeInstance)
			table.remove(__classInstances, i) 
			continue
		end

		local __componentFunction = __SpringShakeInstance:Update(dx)
		__posdef += (__componentFunction * __SpringShakeInstance.PositionInfluence)
		__rotdef += (__componentFunction * __SpringShakeInstance.RotationInfluence)
	end

	local sum = CFrame.Angles(0, math.rad(__rotdef.Y), 0) * CFrame.Angles(math.rad(__rotdef.X), 0, math.rad(__rotdef.Z))
	return sum
end

function SpringShaker:Recycle(__SpringShakeInstance: __SpringShakerClassDef)
	assert(__SpringShakeInstance, "value does not exist or not found")

	if __SpringShakeInstance.__Callback then 
		__SpringShakeInstance.__Callback:UnbindToRenderStep()
		__SpringShakeInstance.__Callback = nil
	end
	
	__SpringShakeInstance.SpringShakeInstance = nil
	table.clear(__SpringShakeInstance)
	return
end

function SpringShaker:Append(__SpringShakeInstance: __SpringShakerClassDef)
	assert(__SpringShakeInstance, "__SpringShakeInstance does not exist or not found")
	table.insert(__classInstances, __SpringShakeInstance)
end

function SpringShaker:Shake(__SpringShakeInstance: __SpringShakerClassDef): () -> CFrame
	assert(__SpringShakeInstance, "spring shaker class does not exist or was not given!")
	__SpringShakeInstance.__SpringShakeInstance = ShakerInstances.new(__SpringShakeInstance)
	__SpringShakeInstance.__SpringShakeInstance:FadeIn(__SpringShakeInstance.FadeInTime)
	
	self:Append(__SpringShakeInstance)
	self:Start(__SpringShakeInstance)
	
	
	return function() 
		return __SpringShakeInstance.__CFCallback or CFrame.identity
	end
end

function SpringShaker:ShakeOnce(SpringDef: __SpringShakerClassDef, Duration: number)
	assert(SpringDef, "spring shaker class does not exist or was not given!")
	SpringDef.__SpringShakeInstance = ShakerInstances.new(SpringDef)
	self:Append(SpringDef)
	self:Start(SpringDef)
	
	task.delay(Duration or 1, function()
		if SpringDef then
			print(SpringDef)
			SpringDef.__SpringShakeInstance:FadeOut(SpringDef.__SpringShakeInstance.FadeOutTime or 0.5)
		end
	end)
end


return SpringShaker
