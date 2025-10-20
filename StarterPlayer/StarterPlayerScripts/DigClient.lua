-- LOCAL SCRIPT - CLIENT (FIXED VERSION)
-- Taruh di StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Tunggu RemoteEvent
wait(1)
local digEvent = ReplicatedStorage:WaitForChild("DigPartEvent", 10)
if not digEvent then
	warn("❌ DigPartEvent not found!")
	return
end

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Variabel untuk tracking
local lastClickTime = 0
local CLICK_COOLDOWN = 0.5

-- Fungsi untuk mendapatkan posisi klik dengan raycast
local function getClickPosition()
	local character = player.Character
	if not character then return nil, nil end

	-- Raycast dari kamera ke posisi mouse
	local mousePos = UserInputService:GetMouseLocation()
	local unitRay = camera:ScreenPointToRay(mousePos.X, mousePos.Y)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {character}

	local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 100, raycastParams)

	if result then
		return result.Position, result.Instance
	end

	return nil, nil
end

-- Fungsi untuk handle klik
local function handleClick()
	local now = tick()
	if now - lastClickTime < CLICK_COOLDOWN then
		return
	end

	-- Dapatkan posisi dan part yang diklik
	local clickPosition, hitPart = getClickPosition()
	if not clickPosition then
		return
	end

	if not hitPart then
		return
	end

	-- Cek apakah target valid untuk digali
	local isValidTarget = false
	local targetType = ""

	if hitPart:IsA("BasePart") and hitPart.Name == "gali" then
		isValidTarget = true
		targetType = "part: gali"
	elseif hitPart:IsA("Terrain") then
		isValidTarget = true
		targetType = "terrain"
	end

	if isValidTarget then
		lastClickTime = now

		-- PENTING: Kirim sebagai table {X, Y, Z} bukan Vector3 langsung
		local positionData = {
			X = clickPosition.X,
			Y = clickPosition.Y,
			Z = clickPosition.Z
		}

		-- Kirim ke server
		pcall(function()
			digEvent:FireServer(hitPart, positionData)
		end)
	end
end

-- PC: Mouse click
if not isMobile then
	mouse.Button1Down:Connect(handleClick)
end

-- Mobile: Touch
if isMobile then
	UserInputService.TouchTap:Connect(function(touchPositions, gameProcessed)
		if not gameProcessed then
			handleClick()
		end
	end)
end

-- Visual feedback: Highlight part saat hover
mouse.Move:Connect(function()
	local _, hitPart = getClickPosition()

	-- Reset semua part "gali"
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "gali" then
			obj.BrickColor = BrickColor.new("Bright green")
		end
	end

	-- Highlight target
	if hitPart and hitPart:IsA("BasePart") and hitPart.Name == "gali" then
		hitPart.BrickColor = BrickColor.new("Lime green")
	end
end)
