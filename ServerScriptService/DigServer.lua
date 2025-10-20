--SCRIPT
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Buat RemoteEvent
local digEvent = Instance.new("RemoteEvent")
digEvent.Name = "DigPartEvent"
digEvent.Parent = ReplicatedStorage

-- Konfigurasi
local DIG_AMOUNT = 0.2 -- Sangat kecil, lebih detail
local MIN_SIZE = 0.1 -- Batas minimum sangat kecil
local COOLDOWN = 0.5 -- Cooldown lebih lama (0.5 detik)
local playerCooldowns = {}

-- Handle dig request
digEvent.OnServerEvent:Connect(function(player, targetPart, positionData)
	if not targetPart then 
		return 
	end

	-- TERIMA part "gali" ATAU terrain
	local isValidTarget = false
	if targetPart:IsA("BasePart") and targetPart.Name == "gali" then
		isValidTarget = true
	elseif targetPart:IsA("Terrain") then
		isValidTarget = true
	end

	if not isValidTarget then
		return
	end

	-- Konversi table menjadi Vector3
	local clickPosition
	if typeof(positionData) == "table" and positionData.X and positionData.Y and positionData.Z then
		clickPosition = Vector3.new(positionData.X, positionData.Y, positionData.Z)
	elseif typeof(positionData) == "Vector3" then
		clickPosition = positionData
	else
		warn("❌ Invalid position data received:", positionData, "| Type:", typeof(positionData))
		return
	end

	-- Cek cooldown
	local userId = player.UserId
	if playerCooldowns[userId] and tick() - playerCooldowns[userId] < COOLDOWN then
		return
	end
	playerCooldowns[userId] = tick()

	-- GALI TERRAIN di posisi klik
	local terrain = workspace.Terrain
	-- Radius horizontal kecil (X,Z), tapi dalam (Y)
	local HORIZONTAL_RADIUS = 0.5 -- Sangat kecil horizontal
	local VERTICAL_DEPTH = 2 -- Gali ke bawah

	local region = Region3.new(
		clickPosition - Vector3.new(HORIZONTAL_RADIUS, 0, HORIZONTAL_RADIUS), -- Atas
		clickPosition + Vector3.new(HORIZONTAL_RADIUS, -VERTICAL_DEPTH, HORIZONTAL_RADIUS) -- Bawah
	)
	region = region:ExpandToGrid(4)

	-- Baca dan gali terrain
	local materials, sizes = terrain:ReadVoxels(region, 4)
	local size = materials.Size
	local hasDiggable = false

	-- Material yang TIDAK BISA digali (rock/batu)
	local undiggableMaterials = {
		Enum.Material.Rock,
		Enum.Material.Slate,
		Enum.Material.Concrete,
		Enum.Material.Granite,
		Enum.Material.Basalt,
		Enum.Material.CrackedLava,
		Enum.Material.Limestone,
		Enum.Material.Pavement,
		Enum.Material.Brick,
		Enum.Material.Cobblestone
	}

	-- Fungsi untuk cek apakah material tidak bisa digali
	local function isUndiggable(material)
		for _, undig in pairs(undiggableMaterials) do
			if material == undig then
				return true
			end
		end
		return false
	end

	-- Gali semua material KECUALI yang undiggable
	for x = 1, size.X do
		for y = 1, size.Y do
			for z = 1, size.Z do
				local currentMaterial = materials[x][y][z]

				-- Jangan gali Air atau material yang tidak bisa digali
				if currentMaterial ~= Enum.Material.Air and not isUndiggable(currentMaterial) then
					materials[x][y][z] = Enum.Material.Air
					hasDiggable = true
				end
			end
		end
	end

	if hasDiggable then
		terrain:WriteVoxels(region, 4, materials, sizes)
	end

	-- KURANGI SIZE PART juga (jika target adalah part "gali")
	if targetPart:IsA("BasePart") and targetPart.Name == "gali" then
		if targetPart.Size.Y > MIN_SIZE then
			local newSize = targetPart.Size - Vector3.new(0, DIG_AMOUNT, 0)
			local newPosition = targetPart.Position - Vector3.new(0, DIG_AMOUNT / 2, 0)

			targetPart.Size = newSize
			targetPart.Position = newPosition
		else
			-- Efek hancur
			for i = 1, 5 do
				local debris = Instance.new("Part")
				debris.Size = Vector3.new(0.3, 0.3, 0.3)
				debris.Position = targetPart.Position + Vector3.new(
					math.random(-2, 2),
					math.random(0, 2),
					math.random(-2, 2)
				)
				debris.BrickColor = targetPart.BrickColor
				debris.Material = targetPart.Material
				debris.Parent = workspace

				game:GetService("Debris"):AddItem(debris, 2)
			end

			targetPart:Destroy()
			return
		end
	end

	-- Efek visual di posisi klik
	local effect = Instance.new("Part")
	effect.Size = Vector3.new(0.3, 0.3, 0.3) -- Lebih kecil
	effect.Position = clickPosition
	effect.Anchored = true
	effect.CanCollide = false
	effect.Transparency = 0.5
	effect.BrickColor = BrickColor.new("Brown")
	effect.Material = Enum.Material.Ground
	effect.Parent = workspace

	game:GetService("Debris"):AddItem(effect, 0.2)

	-- Sound (opsional - hapus jika error)
	-- local sound = Instance.new("Sound")
	-- sound.SoundId = "rbxassetid://3581383408"
	-- sound.Volume = 0.3
	-- sound.Parent = effect
	-- sound:Play()
end)
