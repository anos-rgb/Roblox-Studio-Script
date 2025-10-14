local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local FALL_DAMAGE_HEIGHT = 20
local INSTANT_DEATH_HEIGHT = 40
local DAMAGE_MULTIPLIER = 2

local lastYPosition = rootPart.Position.Y
local isFalling = false

humanoid.StateChanged:Connect(function(old, new)
    if new == Enum.HumanoidStateType.Freefall then
        isFalling = true
        lastYPosition = rootPart.Position.Y
    elseif old == Enum.HumanoidStateType.Freefall and new == Enum.HumanoidStateType.Landed then
        if isFalling then
            local fallDistance = lastYPosition - rootPart.Position.Y
            
            if fallDistance > INSTANT_DEATH_HEIGHT then
                humanoid.Health = 0
            elseif fallDistance > FALL_DAMAGE_HEIGHT then
                local damage = (fallDistance - FALL_DAMAGE_HEIGHT) * DAMAGE_MULTIPLIER
                humanoid:TakeDamage(damage)
            end
            
            isFalling = false
        end
    end
end)
