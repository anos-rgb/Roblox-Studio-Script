-- SCRIPT OPTIMASI UNTUK PERANGKAT LOW-END (RAM 2GB)
-- Letakkan script ini di StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ========== KONFIGURASI ==========
local CONFIG = {
	-- Jarak render (dalam studs)
	RENDER_DISTANCE = 150, -- Jarak render objek (lebih kecil = lebih smooth)
	DETAIL_DISTANCE = 80,  -- Jarak detail tinggi
	
	-- Update interval (dalam detik)
	UPDATE_INTERVAL = 0.5, -- Seberapa sering mengecek jarak
	
	-- Optimasi tambahan
	REDUCE_PARTICLES = true,    -- Kurangi partikel
	REDUCE_SHADOWS = true,       -- Matikan bayangan
	REDUCE_TEXTURES = true,      -- Turunkan kualitas tekstur
	SIMPLIFY_TERRAIN = true,     -- Sederhanakan terrain
}

-- ========== FUNGSI OPTIMASI GRAFIS ==========
local function OptimizeGraphics()
	-- Set rendering quality ke low
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	
	if CONFIG.REDUCE_SHADOWS then
		-- Matikan global shadows
		game:GetService("Lighting").GlobalShadows = false
	end
	
	-- Set performance stats
	game:GetService("UserInputService").MouseIconEnabled = true
end

-- ========== FUNGSI RENDER DISTANCE ==========
local objectStates = {} -- Menyimpan state original objek

local function UpdateObjectVisibility(obj, distance)
	if not obj or not obj:IsA("BasePart") then return end
	
	-- Simpan state original
	if not objectStates[obj] then
		objectStates[obj] = {
			transparency = obj.Transparency,
			castShadow = obj.CastShadow,
			material = obj.Material,
		}
	end
	
	local state = objectStates[obj]
	
	if distance > CONFIG.RENDER_DISTANCE then
		-- Terlalu jauh - sembunyikan sepenuhnya
		obj.Transparency = 1
		obj.CanCollide = false
		obj.CastShadow = false
		
	elseif distance > CONFIG.DETAIL_DISTANCE then
		-- Jauh - render sederhana
		obj.Transparency = state.transparency
		obj.CanCollide = true
		obj.CastShadow = false
		
		-- Ganti material kompleks dengan sederhana
		if CONFIG.REDUCE_TEXTURES then
			if obj.Material == Enum.Material.Fabric or 
			   obj.Material == Enum.Material.Granite or
			   obj.Material == Enum.Material.Marble then
				obj.Material = Enum.Material.SmoothPlastic
			end
		end
		
	else
		-- Dekat - render penuh
		obj.Transparency = state.transparency
		obj.CanCollide = true
		obj.CastShadow = not CONFIG.REDUCE_SHADOWS
		obj.Material = state.material
	end
	
	-- Optimasi partikel
	if CONFIG.REDUCE_PARTICLES then
		for _, child in pairs(obj:GetChildren()) do
			if child:IsA("ParticleEmitter") or child:IsA("Trail") then
				if distance > CONFIG.DETAIL_DISTANCE then
					child.Enabled = false
				else
					child.Enabled = true
					-- Kurangi rate untuk performa
					if child:IsA("ParticleEmitter") then
						child.Rate = math.min(child.Rate, 10)
					end
				end
			end
		end
	end
end

-- ========== FUNGSI UTAMA RENDER LOOP ==========
local lastUpdate = 0

local function UpdateRenderDistance()
	local now = tick()
	if now - lastUpdate < CONFIG.UPDATE_INTERVAL then
		return
	end
	lastUpdate = now
	
	local character = player.Character
	if not character then return end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	
	local playerPos = rootPart.Position
	
	-- Loop semua objek di workspace
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj ~= rootPart then
			-- Hitung jarak
			local distance = (obj.Position - playerPos).Magnitude
			
			-- Update visibility
			UpdateObjectVisibility(obj, distance)
		end
	end
end

-- ========== OPTIMASI TERRAIN ==========
local function OptimizeTerrain()
	if not CONFIG.SIMPLIFY_TERRAIN then return end
	
	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		terrain.Decoration = false
	end
end

-- ========== CLEANUP MEMORY ==========
local function CleanupMemory()
	-- Bersihkan cache setiap 30 detik
	while true do
		wait(30)
		
		-- Force garbage collection
		game:GetService("RunService"):Set3dRenderingEnabled(true)
		
		-- Cleanup unused objects
		for obj, state in pairs(objectStates) do
			if not obj or not obj.Parent then
				objectStates[obj] = nil
			end
		end
	end
end

-- ========== INISIALISASI ==========
OptimizeGraphics()
OptimizeTerrain()

-- Jalankan cleanup di background
spawn(CleanupMemory)

-- Connect ke RenderStepped untuk update realtime
RunService.RenderStepped:Connect(UpdateRenderDistance)

-- Info untuk player
print("=================================")
print("LOW-END OPTIMIZATION LOADED")
print("Render Distance: " .. CONFIG.RENDER_DISTANCE)
print("=================================")
