local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuperDecompilerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Main Container Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 160)
frame.Position = UDim2.new(0.5, -150, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 15)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SuperDecompiler by dony."
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = frame

-- Decompile Button
local decompileButton = Instance.new("TextButton")
decompileButton.Size = UDim2.new(0, 200, 0, 45)
decompileButton.Position = UDim2.new(0.5, -100, 0, 85)
decompileButton.BackgroundColor3 = Color3.fromRGB(0, 122, 204)
decompileButton.BorderSizePixel = 0
decompileButton.Text = "Decompile"
decompileButton.TextColor3 = Color3.fromRGB(255, 255, 255)
decompileButton.TextSize = 16
decompileButton.Font = Enum.Font.GothamBold
decompileButton.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = decompileButton

-- Decompilation Logic Execution
local isRunning = false
decompileButton.MouseButton1Click:Connect(function()
    if isRunning then return end
    isRunning = true
    
    decompileButton.Text = "Loading Map..."
    decompileButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

    task.spawn(function()
        local anchorPart
        
        if Workspace.StreamingEnabled then
            print("Streaming is enabled. Calculating map center...")
            local cframe, size = Workspace:GetBoundingBox()
            local centerPos = cframe.Position

            -- Set replication anchor
            anchorPart = Instance.new("Part")
            anchorPart.Size = Vector3.new(1, 1, 1)
            anchorPart.Anchored = true
            anchorPart.CanCollide = false
            anchorPart.Transparency = 1
            anchorPart.Position = centerPos
            anchorPart.Parent = Workspace
            LocalPlayer.ReplicationFocus = anchorPart

            print("Requesting 100,000-stud area stream...")
            pcall(function()
                LocalPlayer:RequestStreamAroundAsync(centerPos)
            end)

            -- Dynamic Streaming Wait
            print("Waiting for assets to stream in...")
            local lastCount = #Workspace:GetDescendants()
            local stableTicks = 0
            
            for i = 1, 45 do
                task.wait(1)
                local currentCount = #Workspace:GetDescendants()
                if currentCount == lastCount then
                    stableTicks = stableTicks + 1
                else
                    stableTicks = 0
                    decompileButton.Text = "Streaming (" .. currentCount .. " items)..."
                end
                lastCount = currentCount
                
                if stableTicks >= 4 then
                    print("Map load stabilized at " .. currentCount .. " instances.")
                    break
                end
            end
        else
            print("Streaming is disabled. Skipping stream request...")
        end

        -- 2. INITIATE SAVER REWRITE
        decompileButton.Text = "Saving Workspace..."
        decompileButton.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
        print("Initiating full save instance sequence (Rewrite)...")
        
        local success, synsaveinstance = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/verysigmapro/UniversalSynSaveInstance-With-Save-Terrain/refs/heads/main/saveinstance_rewrite.luau", true), "saveinstance")()
        end)

        if success and synsaveinstance then
            local SaveinstanceOptions = {
                usekonstantdecompiler = false
            }
            
            pcall(function()
                synsaveinstance(SaveinstanceOptions)
            end)
        else
            warn("Failed to retrieve synsaveinstance rewrite source.")
        end

        -- Clean up center anchor
        if anchorPart then
            anchorPart:Destroy()
        end
        print("Process completed. Check your executor's workspace folder!")
        
        -- Reset Button Visuals
        decompileButton.Text = "Done!"
        decompileButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        task.wait(3)
        decompileButton.Text = "Decompile"
        decompileButton.BackgroundColor3 = Color3.fromRGB(0, 122, 204)
        isRunning = false
    end)
end)
