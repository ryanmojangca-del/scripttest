-- KAMUI respawn/touch diagnostic. Run alongside the main script.
-- Local display only: no data is transmitted and no inputs are simulated.
local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local player = Players.LocalPlayer
local pg = player:WaitForChild('PlayerGui')
local prior = pg:FindFirstChild('KamuiRespawnTouchDiagnostic')
if prior then prior:Destroy() end
local gui = Instance.new('ScreenGui')
gui.Name = 'KamuiRespawnTouchDiagnostic'
gui.ResetOnSpawn = false
gui.DisplayOrder = 10000
gui.Parent = pg
local frame = Instance.new('Frame')
frame.Size = UDim2.new(0, 440, 0, 176)
frame.Position = UDim2.new(0, 12, 0, 120)
frame.BackgroundColor3 = Color3.fromRGB(16,16,19)
frame.BorderSizePixel = 0
frame.Parent = gui
local corner = Instance.new('UICorner', frame); corner.CornerRadius = UDim.new(0, 10)
local stroke = Instance.new('UIStroke', frame); stroke.Color = Color3.fromRGB(196,21,40)
local close = Instance.new('TextButton')
close.Size = UDim2.new(0, 32, 0, 30); close.Position = UDim2.new(1, -36, 0, 4)
close.Text = '×'; close.TextSize = 20; close.Font = Enum.Font.Gotham
close.TextColor3 = Color3.new(1,1,1); close.BackgroundTransparency = 1; close.Parent = frame
local text = Instance.new('TextLabel')
text.Position = UDim2.new(0, 10, 0, 8); text.Size = UDim2.new(1, -50, 1, -16)
text.TextColor3 = Color3.fromRGB(235,235,238); text.BackgroundTransparency = 1
text.Font = Enum.Font.Code; text.TextSize = 14; text.TextXAlignment = Enum.TextXAlignment.Left
text.TextYAlignment = Enum.TextYAlignment.Top; text.TextWrapped = true; text.Parent = frame
local connections = {}
local active = true
local after = 'Waiting for respawn'
local last = 'No touch recorded'
local function snapshot()
    local preferred = 'unavailable'
    pcall(function() preferred = UIS.PreferredInput.Name end)
    local touchGui = pg:FindFirstChild('TouchGui')
    local touchState = touchGui and tostring(touchGui.Enabled) or 'missing'
    return 'last=' .. UIS:GetLastInputType().Name .. ' preferred=' .. preferred .. ' TouchGui=' .. touchState
end
local before = snapshot()
local function paint()
    if not active then return end
    text.Text = 'RESPAWN TOUCH TEST (local only)\nBefore: ' .. before .. '\nRespawn: ' .. after .. '\nLast touch: ' .. last .. '\nAfter respawn, tap a broken button; screenshot.'
end
connections[#connections+1] = player.CharacterAdded:Connect(function(char)
    after = 'Character added; waiting 2s'
    paint()
    task.delay(2, function()
        if active and player.Character == char then after = snapshot(); paint() end
    end)
end)
connections[#connections+1] = UIS.InputBegan:Connect(function(input, processed)
    if input.UserInputType ~= Enum.UserInputType.Touch then return end
    local pos = input.Position
    local names = {}
    pcall(function()
        local objects = pg:GetGuiObjectsAtPosition(pos.X, pos.Y)
        for _, object in ipairs(objects) do
            if not object:IsDescendantOf(gui) and #names < 3 then
                names[#names+1] = object.Name
            end
        end
    end)
    last = 'processed=' .. tostring(processed) .. ' targets=' .. (#names > 0 and table.concat(names, ',') or 'none/other GUI') .. '\n  ' .. snapshot()
    paint()
end)
close.Activated:Connect(function() gui:Destroy() end)
gui.Destroying:Connect(function()
    active = false
    for _, c in ipairs(connections) do c:Disconnect() end
end)
paint()
