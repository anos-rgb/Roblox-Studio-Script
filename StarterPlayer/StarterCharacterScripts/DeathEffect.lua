local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

humanoid.Died:Connect(function()
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
    
    rootPart.CFrame = rootPart.CFrame * CFrame.Angles(math.rad(90), 0, 0)
    
    local blood = Instance.new("Part")
    blood.Name = "Blood"
    blood.Size = Vector3.new(6, 0.1, 6)
    blood.CFrame = rootPart.CFrame * CFrame.new(0, -3, 0)
    blood.BrickColor = BrickColor.new("Crimson")
    blood.Material = Enum.Material.Glass
    blood.Transparency = 0.3
    blood.CanCollide = false
    blood.Anchored = true
    blood.Parent = workspace
    
    local decal = Instance.new("Decal")
    decal.Texture = "rbxassetid://1182597308"
    decal.Face = Enum.NormalId.Top
    decal.Transparency = 0.2
    decal.Parent = blood
    
    game:GetService("Debris"):AddItem(blood, 10)
end)
