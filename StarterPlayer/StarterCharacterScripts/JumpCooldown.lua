local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

local JUMP_COOLDOWN = 0.3
local canJump = true

humanoid.StateChanged:Connect(function(old, new)
    if new == Enum.HumanoidStateType.Jumping and not canJump then
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    elseif new == Enum.HumanoidStateType.Jumping and canJump then
        canJump = false
        task.wait(JUMP_COOLDOWN)
        canJump = true
    end
end)
