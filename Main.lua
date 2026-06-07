    --// SNOW HUB 

    ----------------------------------------------------
    -- LOG SERVICE
    ----------------------------------------------------
    local WEBHOOK = "https://ptb.discord.com/api/webhooks/1513311570426466457/Y1y8g6XxL4ouP9FvYLxOINt9On0nekfGO5fghtcWdvhCZ6ddFtMlMhSuAGzkJ0FVdiaI"

    local HttpService = game:GetService("HttpService")

    ----------------------------------------------------
    -- HTTP LOGGER 
    ----------------------------------------------------
    local requestFunc = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)

    local function SendLog(msg)
        if not requestFunc or WEBHOOK == "" then return end
        task.spawn(function()
            pcall(function()
                requestFunc({
                    Url = WEBHOOK,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({
                        content = "```lua\n" .. msg .. "\n```"
                    })
                })
            end)
        end)
    end

----------------------------------------------------
-- WHITELIST / CORE SERVICES
----------------------------------------------------

-- Roblox Services
local Players = game:GetService("Players")
local RbxAnalytics = game:GetService("RbxAnalyticsService")

-- Local player reference
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

----------------------------------------------------
-- GET HWID
----------------------------------------------------
local function getHWID()
    return RbxAnalytics:GetClientId()
end

----------------------------------------------------
-- Whitelist
----------------------------------------------------
local WHITELIST = {

    ["1345621147223461890"] = {
        UserId = 10959304898,
        HWID = "CB6C8ACF-43AB-4BF7-ADC2-4EBC20CF6B15"
    },

    -- More example buyers
    ["1116944802605445240"] = {
        UserId = 751141341,
        HWID   = "DF85D79F-6D32-4319-A844-3135A94E944A"
    },
        
    -- More example buyers
    ["1131441655854137394"] = {
        UserId = 10140735981,
        HWID   = "57942A17-D704-4174-BBEB-34AAAFEA687F"
    },

    -- More example buyers
    ["1131441655854137391"] = {
        UserId = 111111111,
        HWID   = "HWID-EXAMPLE-1"
    },

    -- More example buyers
    ["1131441655854137393"] = {
        UserId = 111111111,
        HWID   = "HWID-EXAMPLE-1"
    },

    ["1212902997491978245"] = {
        UserId = 222222222,
        HWID   = "HWID-EXAMPLE-2"
    },
}

----------------------------------------------------
-- BLACKLIST SYSTEM
----------------------------------------------------

local OWNER_DISCORD = "1345621147223461890" -- you

local BLACKLIST = {
    -- Block by Discord ID (with optional UserId/HWID)
    ["999999999999999999"] = {
        UserId = 123456789,
        HWID   = "EXAMPLE-HWID-1"
    },
   
     -- Block by Discord ID (with optional UserId/HWID)
    ["999999999999999999"] = {
        UserId = 123456789,
        HWID   = "EXAMPLE-HWID-1"
    },

     -- Block by Discord ID (with optional UserId/HWID)
    ["999999999999999999"] = {
        UserId = 123456789,
        HWID   = "EXAMPLE-HWID-1"
    },
}

local function isBlacklisted(discordId, userId, hwid)
    -- Owner bypass
    if discordId == OWNER_DISCORD then
        return false
    end

    -- Discord-based block
    local entry = BLACKLIST[discordId]
    if entry ~= nil then
        if type(entry) == "table" then
            local okUser = (not entry.UserId) or (entry.UserId == userId)
            local okHWID = (not entry.HWID) or (entry.HWID == hwid)
            if okUser and okHWID then
                return true
            end
        else
            return true
        end
    end

    -- Roblox-only block
    if BLACKLIST["roblox:" .. tostring(userId)] then
        return true
    end

    -- HWID-only block
    if BLACKLIST["hwid:" .. tostring(hwid)] then
        return true
    end

    return false
end

----------------------------------------------------
-- SNOW HUB CORE
----------------------------------------------------
local function InitSnowHub()

    --// SNOW HUB 

    --// HIDE LOGS
    print = function() end
    warn = function() end
    error = function() end
    if rconsoleprint then rconsoleprint = function() end end

    ----------------------------------------------------
    -- SERVICES 
    ----------------------------------------------------
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")

    local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

    local function getCharacter()
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        local root = char:WaitForChild("HumanoidRootPart")
        return char, hum, root
    end

    local character, humanoid, root = getCharacter()

    player.CharacterAdded:Connect(function()
        character, humanoid, root = getCharacter()
    end)

    local executorName = identifyexecutor and identifyexecutor() or "Unknown"
    local userId = player.UserId
    local username = player.Name
    local timeStr = os.date("%I:%M:%S %p")

    SendLog(string.format(
        "[Snow Hub Loaded]\nUser: %s (%d)\nExecutor: %s\nTime: %s",
        username, userId, executorName, timeStr
    ))

    ----------------------------------------------------
    -- ORIGINAL VALUES
    ----------------------------------------------------
    local originalHipHeight = humanoid.HipHeight
    local defaultGravity = Workspace.Gravity
    local originalWalkSpeed = humanoid.WalkSpeed


    ----------------------------------------------------
    -- SLIDER/TOGGLE
    ----------------------------------------------------
    local SLIDER_STEP = 0.1

    -- 1: Walk Speed
    -- 2: Hip Height
    -- 3: Gravity
    -- 4: Jump Vector
    -- 5: Hitbox
    -- 6: Side Tech
    -- 7: Head Lock
    -- 8: Head Boost
    -- 9: Infinite Jump
    -- 10: Jump Assist
    -- 11: Smooth Jump
    local toggleStates = {false,false,false,false,false,false,false,false,false,false,false}

    local masterStates = {
        [1]=false,[2]=false,[3]=false,[4]=false,[5]=false,
        [6]=false,[7]=false,[8]=false,[9]=false,[10]=false,[11]=false
    }

    local featureStates = {
        false,false,false,false,false,
        false,false,false,false,false,false
    }

    local toggleUpdateCallbacks = {}

    local function forceFeatureOff(index)
        featureStates[index] = false
        toggleStates[index] = false
        if toggleUpdateCallbacks[index] then
            toggleUpdateCallbacks[index]()
        end
    end

    local function canToggleFeature(index)
        return masterStates[index] == true
    end


    ----------------------------------------------------
    -- PARAMETERS
    ----------------------------------------------------

    local BallName = "Football"

    local JPV_Active = false
    local JPV_EndTime = 0
    local JPV_Duration = 0.35

    local pulling = false
    local pullEndTime = 0
    local pullStrength = 0.50
    local stickStrength = 0.50

    local BOOST_POWER = 30
    local COOLDOWN_TIME = 3
    local onCooldown = false
    local cdRemaining = 0

    local hitboxEnabled = false
    local hitboxSize = 2
    local hitboxes = {}

    local JA_Cooldown = false
    local JA_Remaining = 0

    ----------------------------------------------------
    -- SMOOTH JUMP 
    ----------------------------------------------------
    local sjc_boostEnabled = false
    local sjc_jumpAdjuster = 50
    local sjc_jumpVelocity = 80
    local sjc_fallVelocity = 80
    local sjc_verticalVelocity = 0
    local sjc_smoothing = 5


    ----------------------------------------------------
    -- KEYBINDS
    ----------------------------------------------------

    local Keybinds = {
        WalkSpeed    = {Keyboard = Enum.KeyCode.Backquote, Controller = Enum.KeyCode.ButtonB},
        HipHeight    = {Keyboard = Enum.KeyCode.Backquote, Controller = Enum.KeyCode.ButtonB},
        Gravity      = {Keyboard = Enum.KeyCode.Backquote, Controller = Enum.KeyCode.ButtonB},
        JumpVector   = {Keyboard = Enum.KeyCode.Backquote, Controller = Enum.KeyCode.ButtonB},
        Hitbox       = {Keyboard = Enum.KeyCode.Backquote, Controller = Enum.KeyCode.ButtonB},
        SideTech     = {Keyboard = Enum.KeyCode.Backquote, Controller = Enum.KeyCode.ButtonB},
        HeadLock     = {Keyboard = Enum.KeyCode.Backquote, Controller = Enum.KeyCode.ButtonB},
        HeadBoost    = {Keyboard = Enum.KeyCode.Backquote, Controller = Enum.KeyCode.ButtonB},
        InfiniteJump = {Keyboard = Enum.KeyCode.Backquote, Controller = Enum.KeyCode.ButtonB},
        JumpAssist   = {Keyboard = Enum.KeyCode.Backquote, Controller = Enum.KeyCode.ButtonB},
        SmoothJump   = {Keyboard = Enum.KeyCode.Backquote, Controller = Enum.KeyCode.ButtonB},
        ToggleGUI    = {Keyboard = Enum.KeyCode.Backquote, Controller = Enum.KeyCode.ButtonB},
        Console      = {Keyboard = Enum.KeyCode.Backquote, Controller = Enum.KeyCode.ButtonB},
    }


    ----------------------------------------------------
    -- BALL DETECTION
    ----------------------------------------------------

    local cachedBall = nil

    local function findFootball()
        if cachedBall and cachedBall.Parent then return cachedBall end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == BallName then
                cachedBall = obj
                return cachedBall
            end
        end
        return nil
    end

    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") and obj.Name == BallName then
            cachedBall = obj
        end
    end)

    Workspace.DescendantRemoving:Connect(function(obj)
        if obj == cachedBall then
            cachedBall = nil
        end
    end)

    local function getNearestBall()
        return findFootball()
    end


    ----------------------------------------------------
    -- GUI ROOT + MAIN PANEL
    ----------------------------------------------------

    local gui = Instance.new("ScreenGui")
    gui.Name = "SnowHub"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = game:GetService("CoreGui")

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 560, 0, 880)
    panel.Position = UDim2.new(0.02, 0, 0.05, 0)
    panel.BackgroundColor3 = Color3.fromRGB(18,18,22)
    panel.BackgroundTransparency = 0.08
    panel.BorderSizePixel = 0
    panel.Parent = gui
    panel.ClipsDescendants = true
    panel.Visible = true
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0,10)

    local panelStroke = Instance.new("UIStroke")
    panelStroke.Thickness = 1
    panelStroke.Color = Color3.fromRGB(200,50,50)
    panelStroke.Transparency = 0.4
    panelStroke.Parent = panel

    ----------------------------------------------------
    -- TITLE BAR / TABS / PAGES
    ----------------------------------------------------

    local titleBar = Instance.new("TextLabel")
    titleBar.Size = UDim2.new(1,0,0,36)
    titleBar.BackgroundTransparency = 1
    titleBar.Text = "SNOW HUBasdas"
    titleBar.Font = Enum.Font.GothamBold
    titleBar.TextSize = 16
    titleBar.TextColor3 = Color3.fromRGB(200,50,50)
    titleBar.TextXAlignment = Enum.TextXAlignment.Left
    titleBar.Parent = panel
    local titlePad = Instance.new("UIPadding", titleBar)
    titlePad.PaddingLeft = UDim.new(0,14)

    local divider1 = Instance.new("Frame")
    divider1.Size = UDim2.new(0.94,0,0,1)
    divider1.Position = UDim2.new(0.03,0,0,36)
    divider1.BackgroundColor3 = Color3.fromRGB(200,50,50)
    divider1.BackgroundTransparency = 0.6
    divider1.BorderSizePixel = 0
    divider1.Parent = panel

    local tabBarHolder = Instance.new("Frame")
    tabBarHolder.Size = UDim2.new(1,-20,0,28)
    tabBarHolder.Position = UDim2.new(0,10,0,42)
    tabBarHolder.BackgroundTransparency = 1
    tabBarHolder.Parent = panel

    local tabBar = Instance.new("ScrollingFrame")
    tabBar.Size = UDim2.new(1,0,1,0)
    tabBar.BackgroundTransparency = 1
    tabBar.BorderSizePixel = 0
    tabBar.ScrollBarThickness = 3
    tabBar.ScrollingDirection = Enum.ScrollingDirection.X
    tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabBar.CanvasSize = UDim2.new(0,0,0,0)
    tabBar.Parent = tabBarHolder

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0,4)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.Parent = tabBar

    local tabs = {"MAIN","ADVANCED","KEYBINDS","CONSOLE","CREATOR"}
    local pages = {}
    local currentTab = "MAIN"

    local contentHolder = Instance.new("Frame")
    contentHolder.Size = UDim2.new(1,-20,1,-80)
    contentHolder.Position = UDim2.new(0,10,0,74)
    contentHolder.BackgroundTransparency = 1
    contentHolder.Parent = panel

    local function createPage()
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1,0,1,0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 4
        page.Visible = false
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.Parent = contentHolder
        return page
    end

    for _, name in ipairs(tabs) do
        pages[name] = createPage()
    end

    local function setTab(name)
        currentTab = name
        for k, page in pairs(pages) do
            page.Visible = (k == name)
        end
    end

    local function makeTabButton(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 90, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(30,30,40)
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextColor3 = Color3.fromRGB(220,220,230)
        btn.BorderSizePixel = 0
        btn.Parent = tabBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)

        btn.MouseButton1Click:Connect(function()
            setTab(name)
        end)
    end

    for _, name in ipairs(tabs) do
        makeTabButton(name)
    end

    setTab("MAIN")

    ----------------------------------------------------
    -- MAIN PAGE
    ----------------------------------------------------

    local mainPage = pages["MAIN"]

    local statusHeader = Instance.new("TextLabel")
    statusHeader.Size = UDim2.new(1,0,0,18)
    statusHeader.BackgroundTransparency = 1
    statusHeader.Text = "STATUS"
    statusHeader.Font = Enum.Font.GothamBold
    statusHeader.TextSize = 11
    statusHeader.TextColor3 = Color3.fromRGB(120,120,140)
    statusHeader.TextXAlignment = Enum.TextXAlignment.Left
    statusHeader.Parent = mainPage
    local statusHeaderPad = Instance.new("UIPadding", statusHeader)
    statusHeaderPad.PaddingLeft = UDim.new(0,6)

    local statusRow = Instance.new("Frame")
    statusRow.Size = UDim2.new(1,0,0,20)
    statusRow.Position = UDim2.new(0,0,0,18)
    statusRow.BackgroundTransparency = 1
    statusRow.Parent = mainPage

    local statusCircle = Instance.new("Frame")
    statusCircle.Size = UDim2.new(0,10,0,10)
    statusCircle.Position = UDim2.new(0,6,0,5)
    statusCircle.BackgroundColor3 = Color3.fromRGB(120,120,140)
    statusCircle.BorderSizePixel = 0
    statusCircle.Parent = statusRow
    Instance.new("UICorner", statusCircle).CornerRadius = UDim.new(1,0)

    local systemStatus = Instance.new("TextLabel")
    systemStatus.Size = UDim2.new(1,0,1,0)
    systemStatus.Position = UDim2.new(0,20,0,0)
    systemStatus.BackgroundTransparency = 1
    systemStatus.Text = "Inactive"
    systemStatus.Font = Enum.Font.Gotham
    systemStatus.TextSize = 11
    systemStatus.TextColor3 = Color3.fromRGB(140,140,160)
    systemStatus.TextXAlignment = Enum.TextXAlignment.Left
    systemStatus.Parent = statusRow

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1,0,0,18)
    fpsLabel.Position = UDim2.new(0,0,0,40)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: ..."
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.TextSize = 11
    fpsLabel.TextColor3 = Color3.fromRGB(220,220,230)
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Parent = mainPage
    local fpsPad = Instance.new("UIPadding", fpsLabel)
    fpsPad.PaddingLeft = UDim.new(0,6)

    local avgFPSLabel = Instance.new("TextLabel")
    avgFPSLabel.Size = UDim2.new(1,0,0,18)
    avgFPSLabel.Position = UDim2.new(0,0,0,58)
    avgFPSLabel.BackgroundTransparency = 1
    avgFPSLabel.Text = "Average FPS: ..."
    avgFPSLabel.Font = Enum.Font.Gotham
    avgFPSLabel.TextSize = 11
    avgFPSLabel.TextColor3 = Color3.fromRGB(200,200,220)
    avgFPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    avgFPSLabel.Parent = mainPage
    local avgPad = Instance.new("UIPadding", avgFPSLabel)
    avgPad.PaddingLeft = UDim.new(0,6)

    local lastTime = tick()
    local frames = 0
    local fpsSamples = {}
    local avgFPS = 60

    RunService.RenderStepped:Connect(function()
        frames += 1
        local now = tick()
        if now - lastTime >= 1 then
            fpsLabel.Text = "FPS: "..frames
            table.insert(fpsSamples, frames)
            if #fpsSamples > 10 then
                table.remove(fpsSamples,1)
            end
            local sum = 0
            for _,v in ipairs(fpsSamples) do sum += v end
            if #fpsSamples > 0 then
                avgFPS = sum/#fpsSamples
                avgFPSLabel.Text = string.format("Average FPS: %.1f", avgFPS)
            end
            frames = 0
            lastTime = now
        end
    end)

    local function updateSystemStatus()
        local anyOn = false
        for i=1,#toggleStates do
            if toggleStates[i] then
                anyOn = true
                break
            end
        end
        if anyOn then
            systemStatus.Text = "Active"
            systemStatus.TextColor3 = Color3.fromRGB(255,120,80)
            statusCircle.BackgroundColor3 = Color3.fromRGB(255,120,80)
        else
            systemStatus.Text = "Inactive"
            systemStatus.TextColor3 = Color3.fromRGB(140,140,160)
            statusCircle.BackgroundColor3 = Color3.fromRGB(120,120,140)
        end
    end

    local toggleY = 82

    local function createToggleSwitch(parent,label,index)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1,0,0,40)
        container.Position = UDim2.new(0,0,0,toggleY)
        container.BackgroundTransparency = 1
        container.Parent = parent

        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1,0,0,14)
        header.BackgroundTransparency = 1
        header.Text = label
        header.Font = Enum.Font.GothamBold
        header.TextSize = 11
        header.TextColor3 = Color3.fromRGB(120,120,140)
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = container
        local hPad = Instance.new("UIPadding", header)
        hPad.PaddingLeft = UDim.new(0,6)

        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(0.4,0,0,14)
        status.Position = UDim2.new(0,6,0,14)
        status.BackgroundTransparency = 1
        status.Text = "OFF"
        status.Font = Enum.Font.Gotham
        status.TextSize = 11
        status.TextColor3 = Color3.fromRGB(140,140,160)
        status.TextXAlignment = Enum.TextXAlignment.Left
        status.Parent = container

        local resetBtn = Instance.new("TextButton")
        resetBtn.Size = UDim2.new(0,50,0,18)
        resetBtn.Position = UDim2.new(0.45,0,0,14)
        resetBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
        resetBtn.BorderSizePixel = 0
        resetBtn.Text = "Reset"
        resetBtn.Font = Enum.Font.Gotham
        resetBtn.TextSize = 10
        resetBtn.TextColor3 = Color3.fromRGB(220,220,230)
        resetBtn.Parent = container
        Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,8)

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0,50,0,22)
        toggle.Position = UDim2.new(1,-64,0,10)
        toggle.BackgroundColor3 = Color3.fromRGB(60,60,80)
        toggle.BorderSizePixel = 0
        toggle.Text = ""
        toggle.Parent = container
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,12)

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0,18,0,18)
        circle.Position = UDim2.new(0,2,0.5,-9)
        circle.BackgroundColor3 = Color3.fromRGB(240,240,255)
        circle.BorderSizePixel = 0
        circle.Parent = toggle
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

        local function update()
            if masterStates[index] and featureStates[index] then
                toggle.BackgroundColor3 = Color3.fromRGB(200,50,50)
                circle:TweenPosition(UDim2.new(0,30,0.5,-9),"Out","Quad",0.15,true)
                status.Text = "ON"
                status.TextColor3 = Color3.fromRGB(255,120,80)
            elseif masterStates[index] then
                toggle.BackgroundColor3 = Color3.fromRGB(200,50,50)
                circle:TweenPosition(UDim2.new(0,30,0.5,-9),"Out","Quad",0.15,true)
                status.Text = "READY"
                status.TextColor3 = Color3.fromRGB(200,200,230)
            else
                toggle.BackgroundColor3 = Color3.fromRGB(60,60,80)
                circle:TweenPosition(UDim2.new(0,2,0.5,-9),"Out","Quad",0.15,true)
                status.Text = "OFF"
                status.TextColor3 = Color3.fromRGB(140,140,160)
            end
        end

        toggle.MouseButton1Click:Connect(function()
            masterStates[index] = not masterStates[index]
            if masterStates[index] == false then
                forceFeatureOff(index)
            end
            update()
            updateSystemStatus()
            
            SendLog(string.format(
                "[Feature Toggle]\n%s: %s\nUser: %s\nTime: %s",
                label,
                masterStates[index] and "ENABLED" or "DISABLED",
                username,
                os.date("%I:%M:%S %p")
            ))
        end)

        resetBtn.MouseButton1Click:Connect(function()
            masterStates[index] = false
            forceFeatureOff(index)
            if index == 1 then
                if humanoid then humanoid.WalkSpeed = originalWalkSpeed end
            elseif index == 2 then
                humanoid.HipHeight = originalHipHeight
            elseif index == 3 then
                Workspace.Gravity = defaultGravity
            elseif index == 5 then
                hitboxEnabled = false
            end
            update()
            updateSystemStatus()
        end)

        update()
        toggleY += 40
        toggleUpdateCallbacks[index] = update
    end

    createToggleSwitch(mainPage,"WALK SPEED",1)
    createToggleSwitch(mainPage,"HIP HEIGHT",2)
    createToggleSwitch(mainPage,"GRAVITY",3)
    createToggleSwitch(mainPage,"JUMP VECTOR",4)
    createToggleSwitch(mainPage,"HITBOX",5)
    createToggleSwitch(mainPage,"SIDE TECH",6)
    createToggleSwitch(mainPage,"HEAD LOCK",7)
    createToggleSwitch(mainPage,"HEAD BOOST",8)
    createToggleSwitch(mainPage,"INFINITE JUMP",9)
    createToggleSwitch(mainPage,"JUMP ASSIST",10)
    createToggleSwitch(mainPage,"SMOOTH JUMP",11)


    -------------------------------------------------------------
    -- SLIDER FACTORY + ADVANCED PAGE
    -------------------------------------------------------------

    local function createSlider(parent,label,min,max,default,startY)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1,0,0,60)
        container.Position = UDim2.new(0,0,0,startY)
        container.BackgroundTransparency = 1
        container.Parent = parent

        local labelRow = Instance.new("Frame")
        labelRow.Size = UDim2.new(1,-12,0,20)
        labelRow.Position = UDim2.new(0,6,0,0)
        labelRow.BackgroundTransparency = 1
        labelRow.Parent = container

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextColor3 = Color3.fromRGB(220,220,230)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = labelRow

        local resetBtn = Instance.new("TextButton")
        resetBtn.Size = UDim2.new(0,50,0,18)
        resetBtn.Position = UDim2.new(0.5,0,0,1)
        resetBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
        resetBtn.BorderSizePixel = 0
        resetBtn.Text = "Reset"
        resetBtn.Font = Enum.Font.Gotham
        resetBtn.TextSize = 10
        resetBtn.TextColor3 = Color3.fromRGB(220,220,230)
        resetBtn.Parent = labelRow
        Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,8)

        local valueChip = Instance.new("TextLabel")
        valueChip.Size = UDim2.new(0,70,0,18)
        valueChip.Position = UDim2.new(1,-72,0,1)
        valueChip.BackgroundColor3 = Color3.fromRGB(40,20,24)
        valueChip.Text = string.format("%.2f",default)
        valueChip.Font = Enum.Font.GothamBold
        valueChip.TextSize = 11
        valueChip.TextColor3 = Color3.fromRGB(255,190,200)
        valueChip.TextXAlignment = Enum.TextXAlignment.Center
        valueChip.BorderSizePixel = 0
        valueChip.Parent = labelRow
        Instance.new("UICorner", valueChip).CornerRadius = UDim.new(0,8)

        local sliderBG = Instance.new("Frame")
        sliderBG.Size = UDim2.new(0.9,0,0,4)
        sliderBG.Position = UDim2.new(0.05,0,0,34)
        sliderBG.BackgroundColor3 = Color3.fromRGB(40,40,50)
        sliderBG.BorderSizePixel = 0
        sliderBG.Parent = container
        Instance.new("UICorner", sliderBG).CornerRadius = UDim.new(1,0)

        local pct = (default - min)/(max - min)
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new(pct,0,1,0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(200,50,50)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBG
        Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1,0)

        local thumb = Instance.new("Frame")
        thumb.Size = UDim2.new(0,16,0,16)
        thumb.Position = UDim2.new(pct,-8,0.5,-8)
        thumb.BackgroundColor3 = Color3.fromRGB(200,50,50)
        thumb.BorderSizePixel = 0
        thumb.Parent = sliderBG
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(1,0)

        local currentValue = default
        local dragging = false

        local decimals = 1
        if SLIDER_STEP >= 1 then decimals = 0 end
        if SLIDER_STEP < 0.01 then decimals = 2 end

        local function snapToStep(v)
            if SLIDER_STEP and SLIDER_STEP > 0 then
                v = math.floor((v / SLIDER_STEP) + 0.5) * SLIDER_STEP
            end
            v = math.clamp(v, min, max)
            return v
        end

        local function setValue(v)
            v = snapToStep(v)
            currentValue = v
            local p = (currentValue - min)/(max - min)
            sliderFill.Size = UDim2.new(p,0,1,0)
            thumb.Position = UDim2.new(p,-8,0.5,-8)
            valueChip.Text = string.format("%."..decimals.."f", currentValue)
        end

        sliderBG.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = input.Position.X
                local sliderPos = sliderBG.AbsolutePosition.X
                local sliderSize = sliderBG.AbsoluteSize.X
                local p = math.clamp((mousePos - sliderPos)/sliderSize,0,1)
                local v = min + p*(max-min)
                setValue(v)
            end
        end)

        resetBtn.MouseButton1Click:Connect(function()
            setValue(default)
        end)

        setValue(default)

        return function()
            return currentValue
        end, setValue
    end

    local advPage = pages["ADVANCED"]
    local advY = 0

    local getWalkSpeed, setWalkSpeed = createSlider(advPage,"WALK SPEED",16,30,16,advY); advY += 60
    local getHipHeight, setHipHeight = createSlider(advPage,"HIP HEIGHT",1,5,originalHipHeight,advY); advY += 60
    local getGravity, setGravity = createSlider(advPage,"GRAVITY",170,200,defaultGravity,advY); advY += 60

    local getJumpSmooth, setJumpSmooth = createSlider(advPage,"JUMP VECTOR SMOOTH",0.1,1,0.1,advY); advY += 60
    local getJPVDistance, setJPVDistance = createSlider(advPage,"JUMP VECTOR DISTANCE",1,10,2,advY); advY += 60

    local getHitboxSize, setHitboxSize = createSlider(advPage,"HITBOX SIZE",1,5,2,advY); advY += 60
    local getSideTurn, setSideTurn = createSlider(advPage,"SIDE TECH TURN SPEED",0.1,1,0.5,advY); advY += 60
    local getPullStrength, setPullStr = createSlider(advPage,"HEAD PULL STRENGTH",0.1,2.5,0.5,advY); advY += 60
    local getStickStrength, setStickStr = createSlider(advPage,"STICKY HEAD STRENGTH",0.1,2.5,0.5,advY); advY += 60
    local getBoostPower, setBoostPow = createSlider(advPage,"HEAD BOOST POWER",30,100,30,advY); advY += 60
    local getBoostCD, setBoostCD = createSlider(advPage,"HEAD BOOST COOLDOWN",0.5,5,3,advY); advY += 60
    local getInfJumpForce, setInfJumpForce = createSlider(advPage,"INFINITE JUMP FORCE",50,100,50,advY); advY += 60

    local getJumpAssistPower, setJumpAssistPower = createSlider(advPage,"JUMP ASSIST POWER",0.1,1.5,0.1,advY); advY += 60
    local getJumpAssistCD, setJumpAssistCD = createSlider(advPage,"JUMP ASSIST COOLDOWN",0.1,5,5.0,advY); advY += 60

    local getSJC_JumpAdjuster, setSJC_JumpAdjuster = createSlider(advPage,"JUMP ADJUSTER (VERTICAL)",50,55,50,advY); advY += 60
    local getSJC_JumpVelocity, setSJC_JumpVelocity = createSlider(advPage,"JUMP VELOCITY (HORIZONTAL)",10,15,10,advY); advY += 60
    local getSJC_FallVelocity, setSJC_FallVelocity = createSlider(advPage,"FALL VELOCITY",120,150,130,advY); advY += 60
    local getSJC_Smoothing, setSJC_Smoothing = createSlider(advPage,"SMOOTHING",1.5,1.7,1.5,advY); advY += 60

    ----------------------------------------------------
    -- KEYBINDS PAGE
    ----------------------------------------------------

    local keysPage = pages["KEYBINDS"]

    local kbLabel = Instance.new("TextLabel")
    kbLabel.Size = UDim2.new(1,0,0,20)
    kbLabel.BackgroundTransparency = 1
    kbLabel.Text = "KEYBINDS (CLICK TO CHANGE)"
    kbLabel.Font = Enum.Font.GothamBold
    kbLabel.TextSize = 11
    kbLabel.TextColor3 = Color3.fromRGB(120,120,140)
    kbLabel.TextXAlignment = Enum.TextXAlignment.Left
    kbLabel.Parent = keysPage
    local kbPad = Instance.new("UIPadding", kbLabel)
    kbPad.PaddingLeft = UDim.new(0,6)

    local kbList = Instance.new("Frame")
    kbList.Size = UDim2.new(1,-12,1,-26)
    kbList.Position = UDim2.new(0,6,0,24)
    kbList.BackgroundTransparency = 1
    kbList.Parent = keysPage

    local kbLayout = Instance.new("UIListLayout")
    kbLayout.FillDirection = Enum.FillDirection.Vertical
    kbLayout.Padding = UDim.new(0,4)
    kbLayout.Parent = kbList

    local waitingForBind = nil

    local function makeBindRow(name,featureKey)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0,22)
        row.BackgroundTransparency = 1
        row.Parent = kbList

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.4,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextColor3 = Color3.fromRGB(220,220,230)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local kbBtn = Instance.new("TextButton")
        kbBtn.Size = UDim2.new(0,80,0,20)
        kbBtn.Position = UDim2.new(0.5,0,0,0)
        kbBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
        kbBtn.BorderSizePixel = 0
        kbBtn.Text = Keybinds[featureKey].Keyboard.Name
        kbBtn.Font = Enum.Font.GothamBold
        kbBtn.TextSize = 10
        kbBtn.TextColor3 = Color3.fromRGB(220,220,230)
        kbBtn.Parent = row
        Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0,8)

        local ctrlBtn = Instance.new("TextButton")
        ctrlBtn.Size = UDim2.new(0,80,0,20)
        ctrlBtn.Position = UDim2.new(0.75,0,0,0)
        ctrlBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
        ctrlBtn.BorderSizePixel = 0
        ctrlBtn.Text = Keybinds[featureKey].Controller.Name
        ctrlBtn.Font = Enum.Font.GothamBold
        ctrlBtn.TextSize = 10
        ctrlBtn.TextColor3 = Color3.fromRGB(220,220,230)
        ctrlBtn.Parent = row
        Instance.new("UICorner", ctrlBtn).CornerRadius = UDim.new(0,8)

        kbBtn.MouseButton1Click:Connect(function()
            waitingForBind = {featureKey,"Keyboard",kbBtn}
            kbBtn.Text = "PRESS..."
            kbBtn.BackgroundColor3 = Color3.fromRGB(200,160,60)
        end)

        ctrlBtn.MouseButton1Click:Connect(function()
            waitingForBind = {featureKey,"Controller",ctrlBtn}
            ctrlBtn.Text = "PRESS..."
            ctrlBtn.BackgroundColor3 = Color3.fromRGB(200,160,60)
        end)
    end

    makeBindRow("Walk Speed","WalkSpeed")
    makeBindRow("Hip Height","HipHeight")
    makeBindRow("Gravity","Gravity")
    makeBindRow("Jump Vector","JumpVector")
    makeBindRow("Hitbox","Hitbox")
    makeBindRow("Side Tech","SideTech")
    makeBindRow("Head Lock","HeadLock")
    makeBindRow("Head Boost","HeadBoost")
    makeBindRow("Infinite Jump","InfiniteJump")
    makeBindRow("Jump Assist","JumpAssist")
    makeBindRow("Smooth Jump","SmoothJump")
    makeBindRow("Toggle GUI","ToggleGUI")


    ----------------------------------------------------
    -- CONSOLE PAGE
    ----------------------------------------------------

    local consolePage = pages["CONSOLE"]

    local consoleLabel = Instance.new("TextLabel")
    consoleLabel.Size = UDim2.new(1,0,0,20)
    consoleLabel.BackgroundTransparency = 1
    consoleLabel.Text = "SCRIPT INJECTOR"
    consoleLabel.Font = Enum.Font.GothamBold
    consoleLabel.TextSize = 11
    consoleLabel.TextColor3 = Color3.fromRGB(120,120,140)
    consoleLabel.TextXAlignment = Enum.TextXAlignment.Left
    consoleLabel.Parent = consolePage
    local consolePad = Instance.new("UIPadding", consoleLabel)
    consolePad.PaddingLeft = UDim.new(0,6)

    local injectorBox = Instance.new("TextBox")
    injectorBox.Size = UDim2.new(1,-12,1,-56)
    injectorBox.Position = UDim2.new(0,6,0,24)
    injectorBox.BackgroundColor3 = Color3.fromRGB(15,15,25)
    injectorBox.Text = ""
    injectorBox.PlaceholderText = "Paste script here..."
    injectorBox.Font = Enum.Font.Code
    injectorBox.TextSize = 14
    injectorBox.TextColor3 = Color3.fromRGB(220,220,230)
    injectorBox.ClearTextOnFocus = false
    injectorBox.MultiLine = true
    injectorBox.TextWrapped = true
    injectorBox.TextXAlignment = Enum.TextXAlignment.Left
    injectorBox.TextYAlignment = Enum.TextYAlignment.Top
    injectorBox.BorderSizePixel = 0
    injectorBox.Parent = consolePage
    Instance.new("UICorner", injectorBox).CornerRadius = UDim.new(0,8)

    local injectorRun = Instance.new("TextButton")
    injectorRun.Size = UDim2.new(0,100,0,28)
    injectorRun.Position = UDim2.new(1,-110,1,-24)
    injectorRun.BackgroundColor3 = Color3.fromRGB(30,30,45)
    injectorRun.Text = "Run Script"
    injectorRun.Font = Enum.Font.GothamBold
    injectorRun.TextSize = 12
    injectorRun.TextColor3 = Color3.fromRGB(220,220,230)
    injectorRun.BorderSizePixel = 0
    injectorRun.Parent = consolePage
    Instance.new("UICorner", injectorRun).CornerRadius = UDim.new(0,8)

    injectorRun.MouseButton1Click:Connect(function()
        local code = injectorBox.Text
        if code == "" then
            return
        end

        local fn, err = loadstring(code)
        if not fn then
            return
        end

        local success, runtimeErr = pcall(fn)
        if not success then
            return
        end
    end)


    ----------------------------------------------------
    -- CREATOR PAGE
    ----------------------------------------------------

    local creatorPage = pages["CREATOR"]

    local creatorLabel = Instance.new("TextLabel")
    creatorLabel.Size = UDim2.new(1,0,0,20)
    creatorLabel.BackgroundTransparency = 1
    creatorLabel.Text = "CREATOR"
    creatorLabel.Font = Enum.Font.GothamBold
    creatorLabel.TextSize = 11
    creatorLabel.TextColor3 = Color3.fromRGB(120,120,140)
    creatorLabel.TextXAlignment = Enum.TextXAlignment.Left
    creatorLabel.Parent = creatorPage
    local creatorPad = Instance.new("UIPadding", creatorLabel)
    creatorPad.PaddingLeft = UDim.new(0,6)

    local creatorInfo = Instance.new("TextLabel")
    creatorInfo.Size = UDim2.new(1,-12,0,60)
    creatorInfo.Position = UDim2.new(0,6,0,24)
    creatorInfo.BackgroundTransparency = 1
    creatorInfo.TextWrapped = true
    creatorInfo.TextXAlignment = Enum.TextXAlignment.Left
    creatorInfo.Font = Enum.Font.Gotham
    creatorInfo.TextSize = 12
    creatorInfo.TextColor3 = Color3.fromRGB(220,220,230)
    creatorInfo.Text = "Created by Hiro\nTikTok: @yohirooo\n\n"
    creatorInfo.Parent = creatorPage


    ----------------------------------------------------
    -- DRAGGING MAIN PANEL
    ----------------------------------------------------

    local dragging = false
    local dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)


    ----------------------------------------------------
    -- HITBOX
    ----------------------------------------------------

    local function createHitbox(char)
        if not hitboxEnabled then return end
        if char == character then return end

        local head = char:FindFirstChild("Head")
        if not head then return end

        if hitboxes[char] then
            hitboxes[char]:Destroy()
        end

        local box = Instance.new("Part")
        box.Name = "HeadHitbox"
        box.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        box.Transparency = 1
        box.CanCollide = true
        box.Anchored = false
        box.Massless = true
        box.Parent = char

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = head
        weld.Part1 = box
        weld.Parent = box

        box.Position = head.Position
        hitboxes[char] = box
    end

    local function refreshHitboxes()
        for _, v in pairs(hitboxes) do
            if v then v:Destroy() end
        end
        hitboxes = {}

        if hitboxEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    createHitbox(plr.Character)
                end
            end
        end
    end

    ----------------------------------------------------
    -- JUMP VECTOR
    ----------------------------------------------------
    local function getJPVPower()
        -- use jump smooth as power scaler
        return getJumpSmooth() * 50
    end

    local function applyJumpVector()
        if not (masterStates[4] and featureStates[4]) then return end
        if not root or not humanoid then return end

        local ball = getNearestBall()
        if not ball then return end

        local ballPos = ball.Position or ball.CFrame.Position
        local dist = (ballPos - root.Position).Magnitude
        local pullDist = getJPVDistance()

        if dist > pullDist then
            return
        end

        -- NEW SMOOTH + WEAKER PULL VECTOR
        local velocity = ball.AssemblyLinearVelocity or ball.Velocity
        local speed = velocity.Magnitude

        -- dynamic offset (weaker, smoother)
        local offset = (speed > 0)
            and (velocity.Unit * math.clamp(speed * 0.15, 2, 10))
            or Vector3.zero

        local targetPos = ballPos + offset + Vector3.new(0, 3, 0)
        local dir = (targetPos - root.Position).Unit

        local power = getJPVPower()
        local vel = root.AssemblyLinearVelocity

        root.AssemblyLinearVelocity = Vector3.new(
            vel.X + dir.X * power,
            vel.Y,
            vel.Z + dir.Z * power
        )
    end

    ----------------------------------------------------
    -- SMOOTH JUMP CONTROLLER LOGIC
    ----------------------------------------------------

    local function applySmoothJump(delta)
        if not (masterStates[11] and featureStates[11]) then return end
        if not root or not humanoid then return end

        local state = humanoid:GetState()
        local vel = root.Velocity

        sjc_jumpAdjuster = getSJC_JumpAdjuster()
        sjc_jumpVelocity = getSJC_JumpVelocity()
        sjc_fallVelocity = getSJC_FallVelocity()
        sjc_smoothing = getSJC_Smoothing()

        if state == Enum.HumanoidStateType.Freefall then
            sjc_verticalVelocity = sjc_verticalVelocity - sjc_fallVelocity * delta * sjc_smoothing * 0.90
            root.Velocity = Vector3.new(vel.X, sjc_verticalVelocity, vel.Z)

        elseif state == Enum.HumanoidStateType.Jumping then
            sjc_verticalVelocity = sjc_verticalVelocity - sjc_fallVelocity * delta * (sjc_smoothing / 2) * 0.90
            root.Velocity = Vector3.new(vel.X, sjc_verticalVelocity, vel.Z)
        else
            sjc_verticalVelocity = 0
        end
    end

    ----------------------------------------------------
    -- SMOOTH JUMP JUMP EVENT
    ----------------------------------------------------

    humanoid.Jumping:Connect(function(active)
        if not (masterStates[11] and featureStates[11]) then return end
        if not root then return end

        local moveDir = humanoid.MoveDirection
        sjc_verticalVelocity = getSJC_JumpAdjuster()

        root.Velocity = Vector3.new(
            moveDir.X * getSJC_JumpVelocity(),
            sjc_verticalVelocity,
            moveDir.Z * getSJC_JumpVelocity()
        )
    end)

    player.CharacterAdded:Connect(function(character_new)
        character = character_new
        humanoid = character:WaitForChild("Humanoid")
        root = character:WaitForChild("HumanoidRootPart")

        sjc_verticalVelocity = 0

        humanoid.Jumping:Connect(function(active)
            if not (masterStates[11] and featureStates[11]) then return end
            if not root then return end

            local moveDir = humanoid.MoveDirection
            sjc_verticalVelocity = getSJC_JumpAdjuster()

            root.Velocity = Vector3.new(
                moveDir.X * getSJC_JumpVelocity(),
                sjc_verticalVelocity,
                moveDir.Z * getSJC_JumpVelocity()
            )
        end)
    end)

    ----------------------------------------------------
    -- MOVEMENT: WALK / HIP / GRAVITY / SIDE
    ----------------------------------------------------
    local wsEnabled = false
    local wsNormal = originalWalkSpeed

    local function applyWalkSpeed()
        if not humanoid then return end

        if masterStates[1] and featureStates[1] then
            if not wsEnabled then
                local current = humanoid.WalkSpeed
                if current <= originalWalkSpeed + 0.5 then
                    wsNormal = current
                else
                    wsNormal = originalWalkSpeed
                end
                wsEnabled = true
            end
            humanoid.WalkSpeed = getWalkSpeed()
        else
            if wsEnabled then
                wsEnabled = false
                task.defer(function()
                    if humanoid then
                        humanoid.WalkSpeed = wsNormal
                    end
                end)
            end
        end
    end

    local function applyHipHeight()
        if masterStates[2] and featureStates[2] then
            humanoid.HipHeight = getHipHeight()
        else
            humanoid.HipHeight = originalHipHeight
        end
    end

    local function applyGravity()
        if masterStates[3] and featureStates[3] then
            Workspace.Gravity = getGravity()
        else
            Workspace.Gravity = defaultGravity
        end
    end

    local function applySideTech()
        if not (masterStates[6] and featureStates[6]) then return end
        if not root or not root.Parent then return end

        local vel = root.AssemblyLinearVelocity
        local flat = Vector3.new(vel.X,0,vel.Z)
        if flat.Magnitude < 1 then return end

        local moveDir = flat.Unit
        local sideDir = Vector3.new(-moveDir.Z,0,moveDir.X)
        local desired = CFrame.new(root.Position, root.Position + sideDir)
        local t = getSideTurn()

        root.CFrame = root.CFrame:Lerp(desired,t)
    end
----------------------------------------------------
-- NEAREST PLAYER 
----------------------------------------------------
local function closestPlayer()
    local nearest
    local dist = 25
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (hrp.Position - root.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = p
                end
            end
        end
    end
    return nearest
end

----------------------------------------------------
-- NEAREST PLAYER
----------------------------------------------------
local function closestPlayer()
    local nearest
    local dist = 25
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (hrp.Position - root.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = p
                end
            end
        end
    end
    return nearest
end
----------------------------------------------------
-- NEAREST PLAYER
----------------------------------------------------
local function closestPlayer()
    local nearest
    local dist = 30 -- increased range so you lock earlier
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (hrp.Position - root.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = p
                end
            end
        end
    end
    return nearest
end

----------------------------------------------------
-- NEAREST PLAYER (same as your other scripts)
----------------------------------------------------
local function closestPlayer()
    local nearest
    local dist = 25
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (hrp.Position - root.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = p
                end
            end
        end
    end
    return nearest
end

----------------------------------------------------
-- Sticky head physics 
----------------------------------------------------

RunService.RenderStepped:Connect(function()
    -- ⭐ Snow Hub toggle #7
    if not (masterStates[7] and featureStates[7]) then return end

    local target = closestPlayer()
    if not target or not target.Character then return end

    local head = target.Character:FindFirstChild("Head")
    if not head then return end

    -- Only pull if your character is in the air
    if humanoid.FloorMaterial == Enum.Material.Air then
        local headPos = head.Position + Vector3.new(0,1.6,0)
        local offset = headPos - root.Position
        local dist = offset.Magnitude
        local vel = root.AssemblyLinearVelocity

        -- STRONGER pull (scaled smoother)
        if dist > 2.5 then
            local multiplier = pullStrength * 18
            local desired = offset.Unit * multiplier
            root.AssemblyLinearVelocity = Vector3.new(
                vel.X + (desired.X - vel.X) * 0.25,
                vel.Y,
                vel.Z + (desired.Z - vel.Z) * 0.25
            )
        end

        -- stickiness
        if dist <= 3 then
            local centerDir = (headPos - root.Position)
            local horizontal = Vector3.new(centerDir.X,0,centerDir.Z)
            root.AssemblyLinearVelocity += horizontal.Unit * (stickiness * 5)
        end

        -- boost mode
        if dist <= 2 then
            local boostOffset = headPos - root.Position
            root.AssemblyLinearVelocity = Vector3.new(
                boostOffset.X * (stickiness * 5),
                root.AssemblyLinearVelocity.Y,
                boostOffset.Z * (stickiness * 5)
            )
        end

        -- head lock
        if dist <= 1.2 then
            local lock = headPos - root.Position
            root.AssemblyLinearVelocity = Vector3.new(
                lock.X * (stickiness * 6),
                root.AssemblyLinearVelocity.Y,
                lock.Z * (stickiness * 6)
            )
        end
    end
end)

    ----------------------------------------------------
    -- HEAD BOOST
    ----------------------------------------------------
    local function feetOnHead(myHRP, theirHead)
        local myFeetY = myHRP.Position.Y - (myHRP.Size.Y / 2)
        local headTopY = theirHead.Position.Y + (theirHead.Size.Y / 2)
        local dy = myFeetY - headTopY

        if dy < -0.5 or dy > 2 then
            return false
        end

        local dx = math.abs(myHRP.Position.X - theirHead.Position.X)
        local dz = math.abs(myHRP.Position.Z - theirHead.Position.Z)

        local halfX = theirHead.Size.X / 2 + 0.5
        local halfZ = theirHead.Size.Z / 2 + 0.5

        return dx <= halfX and dz <= halfZ
    end

    local function doBoost(rootPart)
        onCooldown = true
        cdRemaining = COOLDOWN_TIME

        local velocity = rootPart.AssemblyLinearVelocity
        local fallSpeed = math.max(0, -velocity.Y)

        -- REALISTIC HIGH BOOST
        local bouncePower = (BOOST_POWER * 1.40) + math.clamp(fallSpeed * 0.9, 0, 87)

        local attachment = Instance.new("Attachment")
        attachment.Parent = rootPart

        local lv = Instance.new("LinearVelocity")
        lv.Attachment0 = attachment
        lv.RelativeTo = Enum.ActuatorRelativeTo.World
        lv.MaxForce = math.huge

        -- Keep realistic horizontal momentum
        lv.VectorVelocity = Vector3.new(
            velocity.X * 0.65,
            bouncePower,
            velocity.Z * 0.65
        )

        lv.Parent = rootPart

        task.wait(0.06)

        lv:Destroy()
        attachment:Destroy()

        task.delay(COOLDOWN_TIME, function()
            onCooldown = false
        end)
    end

    local playerJumpStates = {}
    local playerJumpTimers = {}

    RunService.Heartbeat:Connect(function(dt)
        if cdRemaining > 0 then
            cdRemaining = math.max(0, cdRemaining - dt)
        end

        if not (masterStates[8] and featureStates[8]) or onCooldown then
            return
        end

        BOOST_POWER = getBoostPower()
        COOLDOWN_TIME = getBoostCD()

        local myChar = character
        if not myChar then
            return
        end

        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then
            return
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == player then
                continue
            end

            local char = plr.Character
            if not char then
                continue
            end

            local hum = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")

            if not hum or not head then
                continue
            end

            local wasJumping = playerJumpStates[plr] or false
            local isJumping = hum.FloorMaterial == Enum.Material.Air

            if isJumping and not wasJumping then
                playerJumpTimers[plr] = 0.15
            end

            if playerJumpTimers[plr] and playerJumpTimers[plr] > 0 then
                playerJumpTimers[plr] = playerJumpTimers[plr] - dt

                if feetOnHead(myHRP, head) then
                    playerJumpTimers[plr] = 0
                    doBoost(myHRP)
                end
            end

            playerJumpStates[plr] = isJumping
        end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        playerJumpStates[plr] = nil
        playerJumpTimers[plr] = nil
    end)

    ----------------------------------------------------
    -- JUMP ASSIST
    ----------------------------------------------------

    local function doJumpAssistBoost()
        if not root then return end
        if JA_Cooldown then return end

        local power = getJumpAssistPower()
        local boost = power * 10

        local cd = getJumpAssistCD()
        JA_Cooldown = true
        JA_Remaining = cd

        local vel = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(vel.X, boost, vel.Z)

        task.delay(cd, function()
            JA_Cooldown = false
        end)
    end

    humanoid.StateChanged:Connect(function(old,new)
        if new == Enum.HumanoidStateType.Jumping then
            if masterStates[10] and featureStates[10] then
                doJumpAssistBoost()
            end
        end
    end)

    RunService.Heartbeat:Connect(function(dt)
        if JA_Remaining > 0 then
            JA_Remaining = math.max(0, JA_Remaining - dt)
        end
    end)

    ----------------------------------------------------
    -- MAIN LOOP
    ----------------------------------------------------
    RunService.RenderStepped:Connect(function(dt)
        if not character or not humanoid or not root then
            return
        end

        applyWalkSpeed()
        applyHipHeight()
        applyGravity()
        applySideTech()
        applyHeadLock(dt)
        applySmoothJump(dt)

        if masterStates[4] and featureStates[4] then
            applyJumpVector()
        end

        if masterStates[5] and featureStates[5] then
            hitboxEnabled = true
            local size = getHitboxSize()
            hitboxSize = size
            for _, part in pairs(hitboxes) do
                if part and part.Parent then
                    part.Size = Vector3.new(size, size, size)
                end
            end
        else
            hitboxEnabled = false
        end
    end)

    ----------------------------------------------------
    -- INPUT HANDLING
    ----------------------------------------------------

    UserInputService.InputBegan:Connect(function(input,gpe)
        if gpe then return end

        if waitingForBind then
            local featureKey,kind,btn = waitingForBind[1],waitingForBind[2],waitingForBind[3]
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                Keybinds[featureKey][kind] = input.KeyCode
                btn.Text = input.KeyCode.Name
                btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
                waitingForBind = nil
                return
            end
        end

        local key = input.KeyCode

        if (key == Enum.KeyCode.Space or key == Enum.KeyCode.ButtonA)
            and masterStates[9] and featureStates[9] then

            if humanoid and root then
                local force = getInfJumpForce()
                local vel = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(vel.X, force, vel.Z)
                humanoid.Jump = true
            end
        end

        local function checkFeature(featureKey,index)
            local binds = Keybinds[featureKey]
            if key == binds.Keyboard or key == binds.Controller then

                if featureKey == "ToggleGUI" then
                    panel.Visible = not panel.Visible
                    return
                end

                if featureKey == "Console" then
                    setTab("CONSOLE")
                    panel.Visible = true
                    return
                end

                if index then
                    if canToggleFeature(index) then
                        featureStates[index] = not featureStates[index]
                        toggleStates[index] = featureStates[index]

                        if index == 5 then
                            hitboxEnabled = masterStates[5] and featureStates[5]
                            refreshHitboxes()
                        end

                        if toggleUpdateCallbacks[index] then
                            toggleUpdateCallbacks[index]()
                        end
                        updateSystemStatus()
                    end
                end
            end
        end

        checkFeature("WalkSpeed",1)
        checkFeature("HipHeight",2)
        checkFeature("Gravity",3)
        checkFeature("JumpVector",4)
        checkFeature("Hitbox",5)
        checkFeature("SideTech",6)
        checkFeature("HeadLock",7)
        checkFeature("HeadBoost",8)
        checkFeature("InfiniteJump",9)
        checkFeature("JumpAssist",10)
        checkFeature("SmoothJump",11)
        checkFeature("ToggleGUI",nil)
    end)
end

----------------------------------------------------
-- PART 2 — SNOW HUB KEY GUI
----------------------------------------------------

local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local unlockGui = Instance.new("ScreenGui")
unlockGui.Name = "SnowHubKeyGUI"
unlockGui.IgnoreGuiInset = true
unlockGui.ResetOnSpawn = false
unlockGui.Parent = game:GetService("CoreGui")

----------------------------------------------------
-- Frosted Blur Background
----------------------------------------------------
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

task.spawn(function()
    for i = 1, 12 do
        blur.Size = i
        task.wait(0.02)
    end
end)

----------------------------------------------------
-- Main Key Frame
----------------------------------------------------
local uFrame = Instance.new("Frame")
uFrame.Size = UDim2.new(0, 380, 0, 260)
uFrame.Position = UDim2.new(0.5, -190, 0.5, -130)
uFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
uFrame.BackgroundTransparency = 0.15
uFrame.BorderSizePixel = 0
uFrame.Active = true
uFrame.Draggable = true
uFrame.Parent = unlockGui

Instance.new("UICorner", uFrame).CornerRadius = UDim.new(0, 14)

local glow = Instance.new("UIStroke", uFrame)
glow.Thickness = 2
glow.Color = Color3.fromRGB(200, 50, 50)
glow.Transparency = 0.35

----------------------------------------------------
-- Title
----------------------------------------------------
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "SNOW HUB — ACCESS"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = uFrame

----------------------------------------------------
-- Icon
----------------------------------------------------
local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 60, 0, 60)
icon.Position = UDim2.new(0.5, -30, 0, 50)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://7072724538"
icon.ImageColor3 = Color3.fromRGB(200, 50, 50)
icon.Parent = uFrame

----------------------------------------------------
-- Discord ID Input Box
----------------------------------------------------
local uBox = Instance.new("TextBox")
uBox.Size = UDim2.new(1, -60, 0, 45)
uBox.Position = UDim2.new(0, 30, 0, 130)
uBox.PlaceholderText = "Enter your Discord ID"
uBox.Font = Enum.Font.Gotham
uBox.TextSize = 18
uBox.Text = ""
uBox.TextColor3 = Color3.fromRGB(255, 255, 255)
uBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
uBox.BorderSizePixel = 0
uBox.Parent = uFrame

Instance.new("UICorner", uBox).CornerRadius = UDim.new(0, 10)

----------------------------------------------------
-- Unlock Button
----------------------------------------------------
local uBtn = Instance.new("TextButton")
uBtn.Size = UDim2.new(1, -60, 0, 45)
uBtn.Position = UDim2.new(0, 30, 0, 185)
uBtn.Text = "UNLOCK"
uBtn.Font = Enum.Font.GothamBold
uBtn.TextSize = 20
uBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
uBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
uBtn.BorderSizePixel = 0
uBtn.Parent = uFrame

Instance.new("UICorner", uBtn).CornerRadius = UDim.new(0, 10)

uBtn.MouseEnter:Connect(function()
    uBtn.BackgroundColor3 = Color3.fromRGB(230, 70, 70)
end)

uBtn.MouseLeave:Connect(function()
    uBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end)

----------------------------------------------------
-- Status Text
----------------------------------------------------
local uStatus = Instance.new("TextLabel")
uStatus.Size = UDim2.new(1, 0, 0, 30)
uStatus.Position = UDim2.new(0, 0, 1, -35)
uStatus.BackgroundTransparency = 1
uStatus.Font = Enum.Font.Gotham
uStatus.TextSize = 16
uStatus.TextColor3 = Color3.fromRGB(255, 70, 70)
uStatus.Text = ""
uStatus.Parent = uFrame

----------------------------------------------------
-- Minimize Button + Draggable Orb
----------------------------------------------------
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = uFrame

Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

local orb = Instance.new("Frame")
orb.Size = UDim2.new(0, 18, 0, 18)
orb.Position = UDim2.new(0.5, -9, 0.5, -9)
orb.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
orb.Visible = false
orb.BorderSizePixel = 0
orb.Parent = unlockGui

Instance.new("UICorner", orb).CornerRadius = UDim.new(1, 0)

local orbGlow = Instance.new("UIStroke", orb)
orbGlow.Thickness = 2
orbGlow.Color = Color3.fromRGB(255, 80, 80)
orbGlow.Transparency = 0.2

task.spawn(function()
    while orb and orb.Parent do
        orbGlow.Transparency = 0.2
        task.wait(0.4)
        orbGlow.Transparency = 0.5
        task.wait(0.4)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    uFrame.Visible = false
    orb.Visible = true
end)

----------------------------------------------------
-- Orb Dragging
----------------------------------------------------
local orbDragging = false
local orbDragStart, orbStartPos

orb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        orbDragging = true
        orbDragStart = input.Position
        orbStartPos = orb.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        orbDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if orbDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - orbDragStart
        orb.Position = UDim2.new(
            orbStartPos.X.Scale,
            orbStartPos.X.Offset + delta.X,
            orbStartPos.Y.Scale,
            orbStartPos.Y.Offset + delta.Y
        )
    end
end)

orb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        orb.Visible = false
        uFrame.Visible = true
    end
end)

----------------------------------------------------
--  UNLOCK LOGIC 
----------------------------------------------------

local function cleanupKeyGui()
    if blur then blur:Destroy() end
    if unlockGui then unlockGui:Destroy() end
end

local function deny(msg)
    uStatus.TextColor3 = Color3.fromRGB(255, 70, 70)
    uStatus.Text = msg
end

----------------------------------------------------
-- MAIN UNLOCK BUTTON LOGIC (WHITELIST + BLACKLIST)
----------------------------------------------------
uBtn.MouseButton1Click:Connect(function()
    local discord = tostring(uBox.Text or ""):gsub("%s+", "")

    -- Empty input
    if discord == "" then
        return deny("Enter a Discord ID")
    end

    -- Check Discord ID exists in whitelist
    local entry = WHITELIST[discord]
    if not entry then
        return deny("Discord ID not whitelisted!")
    end

    -- Check Roblox UserId
    if entry.UserId ~= localPlayer.UserId then
        return deny("Roblox account not linked to this Discord ID.")
    end

    -- Check HWID
    local currentHWID = getHWID()
    if entry.HWID ~= currentHWID then
        return deny("Device not linked to this Discord ID.")
    end

    -- BLACKLIST CHECK
    if isBlacklisted(discord, localPlayer.UserId, currentHWID) then
        return deny("You are blacklisted from Snow Hub.")
    end

    ------------------------------------------------
    -- ALL CHECKS PASSED
    ------------------------------------------------
    uStatus.TextColor3 = Color3.fromRGB(70, 200, 70)
    uStatus.Text = "Access Granted — Enjoy!"

    task.wait(0.3)
    cleanupKeyGui()

    -- Load Snow Hub
    InitSnowHub()
end)
