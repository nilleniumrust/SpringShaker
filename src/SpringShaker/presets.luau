--[[
You can add any types of Presets here as long as it follows the format below:
PresetName = {
    Magnitude: number, 
    Roughness: number, 
    FadeInTime: number, 
    FadeOutTime: number, 
    Tension: number, 
    Damping: number, 
    RotationInfluence: Vector3, 

	Critical damping threshold: Damping ≈ 2 * sqrt(Tension)
	e.g. Tension=150 → ideal Damping ≈ 24.5, so 22–28 is a good cinematic range
	Going below this gives a subtle ring/bounce; going above kills motion too fast.
	RotationInfluence should stay small (0.2–1.5) for cinematic subtlety.
	Roughness above ~10 starts feeling artificial/jittery rather than physical.
}
To run it, you just have to use the function of :GetPreset() and enter a valid Preset (string).
]]

local Presets = {

	-- A distant, heavy detonation. Slow low-frequency roll felt through the ground.
	Explosion = {
		Magnitude = 3.5,
		Roughness = 3.2,
		FadeInTime = 0,
		FadeOutTime = 1.8,
		Tension = 160,
		Damping = 22, -- Slightly underdamped (crit ~25) for a subtle tail ring
		RotationInfluence = Vector3.new(1.2, 0.5, 0.3),
	},

	-- A sharp, close-range blast underfoot. Snappy and disorienting but brief.
	Landmine = {
		Magnitude = 2.2,
		Roughness = 7.5,
		FadeInTime = 0,
		FadeOutTime = 0.55,
		Tension = 420,
		Damping = 48, -- Near-critical (crit ~41) for a fast, clean stop
		RotationInfluence = Vector3.new(1.0, 0.4, 0.2),
	},

	-- A slow, building ground tremor. Low and heavy, weighted toward vertical sway.
	Earthquake = {
		Magnitude = 1.4,
		Roughness = 2.8,
		FadeInTime = 2.5,
		FadeOutTime = 9.0,
		Tension = 280,
		Damping = 58, -- Overdamped (crit ~33) — kills resonance risk entirely
		RotationInfluence = Vector3.new(0.6, 1.2, 0.5),
	},

	-- A micro-impact. Fast tick with minimal arc, like a rifle round hitting nearby cover.
	ExplosiveBullet = {
		Magnitude = 0.9,
		Roughness = 9.0,
		FadeInTime = 0,
		FadeOutTime = 0.18,
		Tension = 800,
		Damping = 72, -- Near-critical (crit ~57) — very tight, no ring
		RotationInfluence = Vector3.new(0.8, 0.25, 0.1),
	},

	-- Mechanical rumble, like an engine or generator close by. Tight and even.
	Vibration = {
		Magnitude = 0.25,
		Roughness = 18.0,
		FadeInTime = 1.2,
		FadeOutTime = 1.2,
		Tension = 950,
		Damping = 95, -- Overdamped (crit ~62) — intentionally stiff for mechanical feel
		RotationInfluence = Vector3.new(0.08, 0.06, 0.04),
	},

	-- A single heavy footstep or landing impact. Vertical dip with a light roll.
	Bounce = {
		Magnitude = 1.6,
		Roughness = 2.5,
		FadeInTime = 0,
		FadeOutTime = 0.7,
		Tension = 220,
		Damping = 20, -- Slightly underdamped (crit ~30) for a natural rebound feel
		RotationInfluence = Vector3.new(1.4, 0.1, 0.3),
	},

	-- A sustained, building environmental shake. Like something massive approaching.
	Resonance = {
		Magnitude = 1.8,
		Roughness = 4.5,
		FadeInTime = 3.5,
		FadeOutTime = 4.0,
		Tension = 300,
		Damping = 52, -- Slightly overdamped (crit ~35) — controlled swell, no spin risk
		RotationInfluence = Vector3.new(0.9, 0.8, 0.6),
	},

	-- A light environmental tremor, like a distant vehicle or structural stress.
	Rumble = {
		Magnitude = 0.6,
		Roughness = 3.8,
		FadeInTime = 1.8,
		FadeOutTime = 3.5,
		Tension = 200,
		Damping = 34, -- Near-critical (crit ~28) for a smooth, organic sway
		RotationInfluence = Vector3.new(0.4, 0.6, 0.3),
	},

	-- A single sharp hit to the player. Punchy recoil with a fast return.
	Impact = {
		Magnitude = 1.8,
		Roughness = 5.0,
		FadeInTime = 0,
		FadeOutTime = 0.35,
		Tension = 500,
		Damping = 50, -- Near-critical (crit ~45) — snappy without buzzing
		RotationInfluence = Vector3.new(1.1, 0.3, 0.15),
	},
}

return Presets
