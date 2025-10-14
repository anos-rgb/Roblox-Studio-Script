local model = script.Parent
if not model.PrimaryPart then
	for _, p in pairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			model.PrimaryPart = p
			break
		end
	end
end

local startY, endY = 1308.102, 1940.467 --awa dan akhir kordinat ketinggian
local playersOnModel = {}
local targetPosition = startY
local currentVelocity = 0
local smoothing = 0.15
local holdTime = 0.1 -- buat nahan biar gak langsung turun

local function countPlayers()
	local n = 0
	for c in pairs(playersOnModel) do
		if c and c.Parent then
			n += 1
		else
			playersOnModel[c] = nil
		end
	end
	return n
end

local function updateModelPosition()
	local count = countPlayers()
	if count >= 2 then
		targetPosition = endY
		holdTime = 1 -- tahan 1 detik di atas
	elseif count < 2 and holdTime <= 0.1 then
		targetPosition = startY
	end
end

if targetPosition == endY and holdTime > 0.1 then
	holdTime -= 0.1
elseif targetPosition == endY and holdTime <= 0.1 and countPlayers() < 2 then
	targetPosition = startY
end


task.spawn(function()
	while true do
		local cf = model:GetPrimaryPartCFrame()
		local currentY = cf.Y
		local distance = targetPosition - currentY

		if math.abs(distance) > 0.5 then
			local speed = (targetPosition == endY) and 10 or 50
			local targetVelocity = math.clamp(distance, -speed, speed)
			currentVelocity = currentVelocity + (targetVelocity - currentVelocity) * smoothing
			local newY = currentY + currentVelocity * 0.1
			cf = CFrame.new(cf.X, newY, cf.Z) * (cf - cf.Position)
			model:SetPrimaryPartCFrame(cf)
		else
			model:SetPrimaryPartCFrame(CFrame.new(cf.X, targetPosition, cf.Z) * (cf - cf.Position))
			currentVelocity = 0
		end

		if holdTime > 0 then
			holdTime -= 0.1
			if holdTime <= 0 and countPlayers() < 2 then
				targetPosition = startY
			end
		end

		task.wait(0.1)
	end
end)


for _, part in pairs(model:GetDescendants()) do
	if part:IsA("BasePart") then
		part.Touched:Connect(function(hit)
			local hum = hit.Parent:FindFirstChild("Humanoid")
			if hum then
				local c = hit.Parent
				if not playersOnModel[c] then
					playersOnModel[c] = true
					updateModelPosition()
				end
			end
		end)

		part.TouchEnded:Connect(function(hit)
			local hum = hit.Parent:FindFirstChild("Humanoid")
			if hum then
				local c = hit.Parent
				if playersOnModel[c] then
					playersOnModel[c] = nil
					task.wait(0.5)
					updateModelPosition()
				end
			end
		end)
	end
end

print("Elevator aktif")
