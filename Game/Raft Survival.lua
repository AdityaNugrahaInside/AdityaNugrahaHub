local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Deteksi nama game otomatis
local function GetGameName()
    local success, result = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    return success and result or "Roblox Game"
end

local currentGameName = GetGameName()

-- Color Scheme
local Colors = {
    Background = Color3.fromRGB(25, 25, 32),
    MainFrame = Color3.fromRGB(22, 22, 28),
    Sidebar = Color3.fromRGB(32, 32, 40),
    TitleBar = Color3.fromRGB(35, 35, 45),
    Primary = Color3.fromRGB(35, 35, 45),
    Secondary = Color3.fromRGB(45, 45, 55),
    Accent = Color3.fromRGB(88, 101, 242),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(170, 170, 170),
    TextHeader = Color3.fromRGB(230, 230, 240),
    Exit = Color3.fromRGB(237, 66, 69),
    Minimize = Color3.fromRGB(245, 166, 35),
    ShowButton = Color3.fromRGB(88, 101, 242),
    ToggleOn = Color3.fromRGB(87, 242, 135),
    ToggleOff = Color3.fromRGB(114, 118, 125),
    MiscButton = Color3.fromRGB(50, 50, 70),
    ProfileCard = Color3.fromRGB(40, 40, 50),
    OnlineStatus = Color3.fromRGB(87, 242, 135),
    OfflineStatus = Color3.fromRGB(114, 118, 125),
    IdleStatus = Color3.fromRGB(250, 166, 26),
    ToastSuccess = Color3.fromRGB(87, 242, 135),
    ToastError = Color3.fromRGB(237, 66, 69),
    ToastWarning = Color3.fromRGB(250, 166, 26),
    ToastInfo = Color3.fromRGB(88, 101, 242),
    Dropdown = Color3.fromRGB(40, 40, 50),
    DropdownHover = Color3.fromRGB(50, 50, 65),
    SearchBox = Color3.fromRGB(35, 35, 45),
    Section = Color3.fromRGB(30, 30, 38),
    DropdownContent = Color3.fromRGB(28, 28, 36),
    Premium = Color3.fromRGB(255, 215, 0) -- Warna emas untuk premium
}

local Fonts = {
    Bold = Enum.Font.GothamBold,
    Medium = Enum.Font.GothamMedium,
    Black = Enum.Font.GothamBlack
}

-- Library Configuration
local Library = {
    Name = "ANHub_Premium",
    Elements = {},
    Toggles = {},
    CollectToggles = {},
    Connections = {},
    Toasts = {},
    SelectedFarms = {},
    AutoFarmEnabled = false,
    AutoCollectEnabled = false,
    AutoUpgradeEnabled = false,
    AutoSellEnabled = false,
    AutoUpgradeStandEnabled = false,
    AutoFishingEnabled = false
}

-- Utility Functions
local function Create(instanceType, properties)
    local inst = Instance.new(instanceType)
    local children = {}

    for prop, value in pairs(properties) do
        if type(prop) == "number" then
            table.insert(children, value)
        else
            inst[prop] = value
        end
    end

    for _, child in ipairs(children) do
        child.Parent = inst
    end

    return inst
end

local function AddHoverEffect(button, defaultColor, hoverColor)
    local connection
    connection = button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = hoverColor
        })
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = defaultColor
        })
        tween:Play()
    end)
    
    table.insert(Library.Connections, connection)
end

-- Toast Notification System yang diperbaiki
function Library:ShowToast(message, toastType, duration)
    duration = duration or 3
    
    local toastId = HttpService:GenerateGUID(false)
    Library.Toasts[toastId] = true
    
    -- Hitung ukuran text untuk menentukan lebar toast
    local textSize = TextService:GetTextSize(message, 14, Fonts.Medium, Vector2.new(400, 100))
    local toastWidth = math.max(280, math.min(500, textSize.X + 80)) -- Min 280, max 500
    local toastHeight = math.max(50, textSize.Y + 30) -- Min 50, adjust berdasarkan tinggi text
    
    local toastFrame = Create("Frame", {
        Name = "Toast_" .. toastId,
        Size = UDim2.new(0, toastWidth, 0, toastHeight),
        Position = UDim2.new(0.5, -toastWidth/2, 1, 60),
        BackgroundColor3 = Colors.MainFrame,
        AnchorPoint = Vector2.new(0.5, 0),
        Parent = Library.Elements.ScreenGui,
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {
            Thickness = 2,
            Color = Colors.Accent
        })
    })
    
    local accentBar = Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = Colors[toastType],
        BorderSizePixel = 0,
        Parent = toastFrame
    })
    
    local iconMap = {
        ToastSuccess = "✅",
        ToastError = "❌",
        ToastWarning = "⚠️",
        ToastInfo = "ℹ️"
    }
    
    local messageLabel = Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        Text = iconMap[toastType] .. " " .. message,
        TextColor3 = Colors.Text,
        Font = Fonts.Medium,
        TextSize = 14,
        TextWrapped = true, -- Enable text wrapping
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        BackgroundTransparency = 1,
        Parent = toastFrame
    })
    
    local enterTween = TweenService:Create(toastFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -toastWidth/2, 1, -70)
    })
    enterTween:Play()
    
    task.delay(duration, function()
        if Library.Toasts[toastId] then
            local exitTween = TweenService:Create(toastFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -toastWidth/2, 1, 60)
            })
            exitTween:Play()
            
            exitTween.Completed:Connect(function()
                toastFrame:Destroy()
                Library.Toasts[toastId] = nil
            end)
        end
    end)
    
    return toastId
end

-- Profile Section
function Library:CreateProfileSection()
    local Elements = Library.Elements
    
    Elements.ProfileCard = Create("Frame", {
        Name = "ProfileCard",
        Size = UDim2.new(0.9, 0, 0, 80),
        BackgroundColor3 = Colors.ProfileCard,
        Parent = Elements.Sidebar,
        Create("UICorner", {CornerRadius = UDim.new(0, 8)})
    })
    
    Elements.Avatar = Create("ImageLabel", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Colors.Accent,
        Parent = Elements.ProfileCard,
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIStroke", {
            Thickness = 2,
            Color = Colors.OnlineStatus
        })
    })
    
    pcall(function()
        local userId = LocalPlayer.UserId
        local thumbType = Enum.ThumbnailType.AvatarThumbnail
        local thumbSize = Enum.ThumbnailSize.Size100x100
        local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
        Elements.Avatar.Image = content
    end)
    
    local usernameFrame = Create("Frame", {
        Size = UDim2.new(1, -60, 0, 20),
        Position = UDim2.new(0, 60, 0, 15),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = Elements.ProfileCard
    })
    
    Elements.UsernameLabel = Create("TextLabel", {
        Size = UDim2.new(2, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Text = LocalPlayer.Name,
        TextColor3 = Colors.Text,
        Font = Fonts.Medium,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = usernameFrame
    })
    
    local function startMarquee()
        local textWidth = Elements.UsernameLabel.TextBounds.X
        local frameWidth = usernameFrame.AbsoluteSize.X
        
        if textWidth > frameWidth then
            local marqueeConnection
            marqueeConnection = RunService.Heartbeat:Connect(function(delta)
                if not Elements.UsernameLabel or not Elements.UsernameLabel.Parent then
                    marqueeConnection:Disconnect()
                    return
                end
                
                local currentPosition = Elements.UsernameLabel.Position
                local newX = currentPosition.X.Offset - (80 * delta)
                
                if newX < -textWidth then
                    newX = frameWidth
                end
                
                Elements.UsernameLabel.Position = UDim2.new(0, newX, 0, 0)
            end)
            table.insert(Library.Connections, marqueeConnection)
        end
    end
    
    task.spawn(function()
        wait(0.5)
        startMarquee()
    end)
    
    Create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 15),
        Position = UDim2.new(0, 60, 0, 35),
        Text = "ID: " .. LocalPlayer.UserId,
        TextColor3 = Colors.TextDim,
        Font = Fonts.Medium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = Elements.ProfileCard
    })
    
    Elements.StatusIndicator = Create("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0, 48, 0, 48),
        BackgroundColor3 = Colors.OnlineStatus,
        BorderSizePixel = 0,
        Parent = Elements.ProfileCard,
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
end

-- Item Icon System
function Library:GetItemIcon(displayName)
    local success, icon = pcall(function()
        local ToolImages = require(ReplicatedStorage:WaitForChild("Utility"):WaitForChild("Tools"):WaitForChild("Images"))
        
        if ToolImages[displayName] then
            return ToolImages[displayName]
        end
        
        return ToolImages["Default"] or "rbxassetid://129120459025842"
    end)
    
    return (success and icon) or "rbxassetid://129120459025842"
end

-- Farm Selection System
function Library:CreateFarmSelection()
    local Elements = Library.Elements
    
    local selectionContainer = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 40),
        BackgroundColor3 = Colors.Primary,
        Parent = Elements.FarmingPanel,
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {
            Thickness = 1,
            Color = Color3.fromRGB(60, 60, 70)
        })
    })
    
    local dropdownButton = Create("TextButton", {
        Size = UDim2.new(1, -20, 1, -8),
        Position = UDim2.new(0, 10, 0, 4),
        BackgroundColor3 = Colors.Dropdown,
        Text = "🔽 SELECT FARM BUILDINGS",
        TextColor3 = Colors.Text,
        Font = Fonts.Medium,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = selectionContainer,
        Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    AddHoverEffect(dropdownButton, Colors.Dropdown, Colors.DropdownHover)
    
    local dropdownContent = Create("Frame", {
        Name = "DropdownContent",
        Size = UDim2.new(1, -10, 0, 250),
        Position = UDim2.new(0, 5, 1, 5),
        BackgroundColor3 = Colors.DropdownContent,
        Visible = false,
        ZIndex = 10,
        Parent = Elements.FarmingPanel,
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {
            Thickness = 2,
            Color = Colors.Accent
        })
    })
    
    local searchBox = Create("TextBox", {
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Colors.SearchBox,
        TextColor3 = Colors.Text,
        PlaceholderColor3 = Colors.TextDim,
        PlaceholderText = "🔍 Search farm buildings...",
        Font = Fonts.Medium,
        TextSize = 14,
        Text = "",
        ZIndex = 11,
        Parent = dropdownContent,
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        })
    })
    
    local itemsScrolling = Create("ScrollingFrame", {
        Size = UDim2.new(1, -20, 0, 150),
        Position = UDim2.new(0, 10, 0, 55),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Accent,
        ZIndex = 11,
        Parent = dropdownContent,
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })
    
    local buttonContainer = Create("Frame", {
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 1, -45),
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = dropdownContent
    })
    
    local selectAllBtn = Create("TextButton", {
        Size = UDim2.new(0.48, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Colors.MiscButton,
        Text = "SELECT ALL",
        TextColor3 = Colors.Text,
        Font = Fonts.Medium,
        TextSize = 12,
        ZIndex = 12,
        Parent = buttonContainer,
        Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    local clearAllBtn = Create("TextButton", {
        Size = UDim2.new(0.48, 0, 1, 0),
        Position = UDim2.new(0.52, 0, 0, 0),
        BackgroundColor3 = Colors.MiscButton,
        Text = "CLEAR ALL",
        TextColor3 = Colors.Text,
        Font = Fonts.Medium,
        TextSize = 12,
        ZIndex = 12,
        Parent = buttonContainer,
        Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    AddHoverEffect(selectAllBtn, Colors.MiscButton, Colors.Accent)
    AddHoverEffect(clearAllBtn, Colors.MiscButton, Colors.Exit)
    
    local FarmData = Library.FarmData
    
    local dropdownItems = {}
    local allItems = {}
    
    local function updateDropdownText()
        local selectedCount = 0
        for _ in pairs(Library.SelectedFarms) do
            selectedCount += 1
        end
        
        if selectedCount == 0 then
            dropdownButton.Text = "🔽 SELECT FARM BUILDINGS"
        else
            dropdownButton.Text = "🔽 SELECTED: " .. selectedCount .. " ITEMS"
        end
    end
    
    local function createDropdownItem(baseName, displayName, index)
        local itemIcon = Library:GetItemIcon(displayName)
        
        local itemFrame = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = index % 2 == 0 and Colors.DropdownContent or Colors.Primary,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 12,
            Parent = itemsScrolling,
            LayoutOrder = index
        })
        
        local iconLabel = Create("ImageLabel", {
            Size = UDim2.new(0, 25, 0, 25),
            Position = UDim2.new(0, 8, 0.5, -12.5),
            BackgroundTransparency = 1,
            ZIndex = 13,
            Parent = itemFrame
        })
        
        pcall(function()
            iconLabel.Image = itemIcon
        end)
        
        local nameLabel = Create("TextLabel", {
            Size = UDim2.new(1, -80, 1, 0),
            Position = UDim2.new(0, 40, 0, 0),
            Text = displayName,
            TextColor3 = Colors.Text,
            Font = Fonts.Medium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            ZIndex = 13,
            Parent = itemFrame
        })
        
        local checkbox = Create("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(1, -30, 0.5, -9),
            BackgroundColor3 = Colors.Secondary,
            ZIndex = 13,
            Parent = itemFrame,
            Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
            Create("UIStroke", {
                Thickness = 1,
                Color = Colors.Accent
            })
        })
        
        local checkmark = Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            Text = "✓",
            TextColor3 = Colors.Text,
            Font = Fonts.Bold,
            TextSize = 12,
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 14,
            Parent = checkbox
        })
        
        local itemData = {
            Frame = itemFrame,
            Checkbox = checkbox,
            Checkmark = checkmark,
            BaseName = baseName,
            DisplayName = displayName,
            Icon = itemIcon,
            Selected = false
        }
        
        table.insert(dropdownItems, itemData)
        table.insert(allItems, itemData)
        
        AddHoverEffect(itemFrame, itemFrame.BackgroundColor3, Colors.DropdownHover)
        
        itemFrame.MouseButton1Click:Connect(function()
            itemData.Selected = not itemData.Selected
            checkmark.Visible = itemData.Selected
            checkbox.BackgroundColor3 = itemData.Selected and Colors.ToggleOn or Colors.Secondary
            
            if itemData.Selected then
                Library.SelectedFarms[baseName] = true
            else
                Library.SelectedFarms[baseName] = nil
            end
            
            updateDropdownText()
        end)
    end
    
    local index = 1
    for baseName, displayName in pairs(FarmData) do
        createDropdownItem(baseName, displayName, index)
        index += 1
    end
    
    itemsScrolling.CanvasSize = UDim2.new(0, 0, 0, #dropdownItems * 40)
    
    local function updateSearch(searchText)
        searchText = string.lower(searchText)
        
        for _, item in ipairs(allItems) do
            local displayLower = string.lower(item.DisplayName)
            local shouldShow = searchText == "" or string.find(displayLower, searchText, 1, true)
            item.Frame.Visible = shouldShow
        end
        
        local visibleCount = 0
        for _, item in ipairs(allItems) do
            if item.Frame.Visible then
                item.Frame.LayoutOrder = visibleCount + 1
                visibleCount += 1
            end
        end
        
        itemsScrolling.CanvasSize = UDim2.new(0, 0, 0, math.max(visibleCount * 40, 150))
    end
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        updateSearch(searchBox.Text)
    end)
    
    selectAllBtn.MouseButton1Click:Connect(function()
        local selectedCount = 0
        for _, item in ipairs(allItems) do
            if item.Frame.Visible then
                item.Selected = true
                item.Checkmark.Visible = true
                item.Checkbox.BackgroundColor3 = Colors.ToggleOn
                Library.SelectedFarms[item.BaseName] = true
                selectedCount += 1
            end
        end
        updateDropdownText()
        Library:ShowToast("Selected " .. selectedCount .. " farm buildings", "ToastSuccess", 2)
    end)
    
    clearAllBtn.MouseButton1Click:Connect(function()
        for _, item in ipairs(allItems) do
            item.Selected = false
            item.Checkmark.Visible = false
            item.Checkbox.BackgroundColor3 = Colors.Secondary
            Library.SelectedFarms[item.BaseName] = nil
        end
        updateDropdownText()
        Library:ShowToast("Cleared all selections", "ToastInfo", 2)
    end)
    
    local isDropdownOpen = false
    dropdownButton.MouseButton1Click:Connect(function()
        isDropdownOpen = not isDropdownOpen
        dropdownContent.Visible = isDropdownOpen
        
        if isDropdownOpen then
            dropdownButton.Text = string.gsub(dropdownButton.Text, "🔽", "🔼")
            dropdownContent.ZIndex = 10
        else
            dropdownButton.Text = string.gsub(dropdownButton.Text, "🔼", "🔽")
        end
    end)
    
    local function closeDropdown()
        if isDropdownOpen then
            isDropdownOpen = false
            dropdownContent.Visible = false
            dropdownButton.Text = string.gsub(dropdownButton.Text, "🔼", "🔽")
        end
    end
    
    Library.CloseDropdown = closeDropdown
    
    return {
        Container = selectionContainer,
        SelectedFarms = Library.SelectedFarms,
        CloseDropdown = closeDropdown
    }
end

-- Fishing Functions
function Library:StartAutoFishing()
    Library.AutoFishingEnabled = true
    
    task.spawn(function()
        while Library.AutoFishingEnabled do
            local success, result = pcall(function()
                return ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.EventService.RF.GetRandomFish:InvokeServer(LocalPlayer)
            end)
            
            if success then
                if Library.Elements.FishingStatus then
                    Library.Elements.FishingStatus.Text = "🎣 Fishing... Success!"
                    Library.Elements.FishingStatus.TextColor3 = Colors.ToastSuccess
                end
            else
                if Library.Elements.FishingStatus then
                    Library.Elements.FishingStatus.Text = "🎣 Fishing... Failed"
                    Library.Elements.FishingStatus.TextColor3 = Colors.ToastError
                end
            end
            
            task.wait(1)
        end
    end)
end

function Library:StopAutoFishing()
    Library.AutoFishingEnabled = false
    if Library.Elements.FishingStatus then
        Library.Elements.FishingStatus.Text = "🎣 Auto Fishing Stopped"
        Library.Elements.FishingStatus.TextColor3 = Colors.TextDim
    end
end

-- Farming Controls
function Library:CreateFarmingControls()
    local Elements = Library.Elements
    
    local sectionHeader = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Colors.Section,
        Parent = Elements.FarmingPanel,
        Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = "🚜 FARMING CONTROLS",
        TextColor3 = Colors.TextHeader,
        Font = Fonts.Bold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = sectionHeader
    })
    
    local function createControl(title, icon, controlName)
        local control = Create("Frame", {
            Size = UDim2.new(1, -10, 0, 50),
            BackgroundColor3 = Colors.Primary,
            Parent = Elements.FarmingPanel,
            Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
            Create("UIStroke", {
                Thickness = 1,
                Color = Color3.fromRGB(60, 60, 70)
            })
        })
        
        Create("TextLabel", {
            Size = UDim2.new(0.7, 0, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            Text = icon .. " " .. title,
            TextColor3 = Colors.Text,
            Font = Fonts.Medium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Parent = control
        })
        
        local toggle = Create("TextButton", {
            Size = UDim2.new(0, 70, 0, 25),
            Position = UDim2.new(1, -80, 0.5, -12.5),
            BackgroundColor3 = Colors.ToggleOff,
            Text = "START",
            TextColor3 = Colors.Text,
            Font = Fonts.Bold,
            TextSize = 11,
            Parent = control,
            Create("UICorner", {CornerRadius = UDim.new(0, 6)})
        })
        
        AddHoverEffect(toggle, Colors.ToggleOff, Color3.fromRGB(100, 100, 110))
        
        return toggle
    end
    
    local farmToggle = createControl("AUTO FARM", "🌾", "Farm")
    local collectToggle = createControl("AUTO COLLECT STORAGE", "📦", "Collect")
    local upgradeToggle = createControl("AUTO UPGRADE WORKER", "⚡", "Upgrade")
    local upgradeStandToggle = createControl("AUTO UPGRADE STAND", "🏪", "UpgradeStand")
    local sellToggle = createControl("AUTO SELL ITEMS", "💰", "Sell")
    
    -- Fishing Control
    local fishingControl = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 50),
        BackgroundColor3 = Colors.Primary,
        Parent = Elements.FarmingPanel,
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {
            Thickness = 1,
            Color = Color3.fromRGB(60, 60, 70)
        })
    })
    
    Create("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        Text = "🎣 AUTO FISHING",
        TextColor3 = Colors.Text,
        Font = Fonts.Medium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = fishingControl
    })
    
    local fishingToggle = Create("TextButton", {
        Size = UDim2.new(0, 70, 0, 25),
        Position = UDim2.new(1, -80, 0.5, -12.5),
        BackgroundColor3 = Colors.ToggleOff,
        Text = "START",
        TextColor3 = Colors.Text,
        Font = Fonts.Bold,
        TextSize = 11,
        Parent = fishingControl,
        Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    AddHoverEffect(fishingToggle, Colors.ToggleOff, Color3.fromRGB(100, 100, 110))
    
    local statusInfo = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 40),
        BackgroundColor3 = Colors.Section,
        Parent = Elements.FarmingPanel,
        Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    local statusLabel = Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = "💤 Ready to farm...",
        TextColor3 = Colors.TextDim,
        Font = Fonts.Medium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = statusInfo
    })
    
    Library.Elements.FishingStatus = statusLabel
    
    -- Toggle Handlers
    farmToggle.MouseButton1Click:Connect(function()
        if Library.AutoFarmEnabled then
            Library.AutoFarmEnabled = false
            farmToggle.Text = "START"
            farmToggle.BackgroundColor3 = Colors.ToggleOff
            AddHoverEffect(farmToggle, Colors.ToggleOff, Color3.fromRGB(100, 100, 110))
            
            for baseName, _ in pairs(Library.SelectedFarms) do
                Library:StopAutoFarm(baseName)
            end
            
            statusLabel.Text = "💤 Auto Farm Stopped"
            statusLabel.TextColor3 = Colors.TextDim
            Library:ShowToast("Auto Farm Stopped", "ToastInfo", 2)
        else
            local selectedCount = 0
            for baseName, _ in pairs(Library.SelectedFarms) do
                Library:StartAutoFarm(baseName)
                selectedCount += 1
            end
            
            if selectedCount > 0 then
                Library.AutoFarmEnabled = true
                farmToggle.Text = "STOP"
                farmToggle.BackgroundColor3 = Colors.ToggleOn
                AddHoverEffect(farmToggle, Colors.ToggleOn, Color3.fromRGB(100, 242, 155))
                statusLabel.Text = "🌾 Farming " .. selectedCount .. " buildings..."
                statusLabel.TextColor3 = Colors.ToastSuccess
                Library:ShowToast("Auto Farm Started (" .. selectedCount .. " selected)", "ToastSuccess", 2)
            else
                Library:ShowToast("Please select at least one farm building", "ToastWarning", 2)
            end
        end
    end)
    
    collectToggle.MouseButton1Click:Connect(function()
        if Library.AutoCollectEnabled then
            Library.AutoCollectEnabled = false
            collectToggle.Text = "START"
            collectToggle.BackgroundColor3 = Colors.ToggleOff
            AddHoverEffect(collectToggle, Colors.ToggleOff, Color3.fromRGB(100, 100, 110))
            
            for baseName, _ in pairs(Library.SelectedFarms) do
                Library:StopAutoCollect(baseName)
            end
            
            statusLabel.Text = "💤 Auto Collect Stopped"
            statusLabel.TextColor3 = Colors.TextDim
            Library:ShowToast("Auto Collect Storage Stopped", "ToastInfo", 2)
        else
            local selectedCount = 0
            for baseName, _ in pairs(Library.SelectedFarms) do
                Library:StartAutoCollect(baseName)
                selectedCount += 1
            end
            
            if selectedCount > 0 then
                Library.AutoCollectEnabled = true
                collectToggle.Text = "STOP"
                collectToggle.BackgroundColor3 = Colors.ToggleOn
                AddHoverEffect(collectToggle, Colors.ToggleOn, Color3.fromRGB(100, 242, 155))
                statusLabel.Text = "📦 Collecting from " .. selectedCount .. " storages..."
                statusLabel.TextColor3 = Colors.ToastSuccess
                Library:ShowToast("Auto Collect Storage Started", "ToastSuccess", 2)
            else
                Library:ShowToast("Please select at least one farm building", "ToastWarning", 2)
            end
        end
    end)
    
    upgradeToggle.MouseButton1Click:Connect(function()
        if Library.AutoUpgradeEnabled then
            Library.AutoUpgradeEnabled = false
            upgradeToggle.Text = "START"
            upgradeToggle.BackgroundColor3 = Colors.ToggleOff
            AddHoverEffect(upgradeToggle, Colors.ToggleOff, Color3.fromRGB(100, 100, 110))
            
            statusLabel.Text = "💤 Auto Upgrade Stopped"
            statusLabel.TextColor3 = Colors.TextDim
            Library:ShowToast("Auto Upgrade Worker Stopped", "ToastInfo", 2)
        else
            local selectedCount = 0
            for _ in pairs(Library.SelectedFarms) do
                selectedCount += 1
            end
            
            if selectedCount > 0 then
                Library.AutoUpgradeEnabled = true
                upgradeToggle.Text = "STOP"
                upgradeToggle.BackgroundColor3 = Colors.ToggleOn
                AddHoverEffect(upgradeToggle, Colors.ToggleOn, Color3.fromRGB(100, 242, 155))
                statusLabel.Text = "⚡ Checking workers for upgrade..."
                statusLabel.TextColor3 = Colors.ToastSuccess
                
                task.spawn(function()
                    local maxLevelNotified = false
                    
                    while Library.AutoUpgradeEnabled do
                        local upgradedAny = false
                        local allMax = true
                        
                        for baseName, _ in pairs(Library.SelectedFarms) do
                            if not Library.AutoUpgradeEnabled then break end
                            
                            local displayName = Library:GetDisplayName(baseName)
                            if displayName then
                                pcall(function()
                                    local workers = LocalPlayer:WaitForChild("Workers")
                                    local worker = workers:FindFirstChild(displayName)
                                    
                                    if worker and worker.Value < 100 then
                                        allMax = false
                                        local args = { displayName }
                                        ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("EventService"):WaitForChild("RF"):WaitForChild("UpgradeWorker"):InvokeServer(unpack(args))
                                        upgradedAny = true
                                        statusLabel.Text = "⚡ Upgrading " .. displayName
                                        task.wait(0.3)
                                    end
                                end)
                            end
                        end
                        
                        if allMax then
                            statusLabel.Text = "🎉 All workers max level!"
                            if not maxLevelNotified then
                                Library:ShowToast("All workers at maximum level!", "ToastSuccess", 3)
                                maxLevelNotified = true
                            end
                            
                            task.wait(1)
                            if Library.AutoUpgradeEnabled then
                                Library.AutoUpgradeEnabled = false
                                upgradeToggle.Text = "START"
                                upgradeToggle.BackgroundColor3 = Colors.ToggleOff
                                AddHoverEffect(upgradeToggle, Colors.ToggleOff, Color3.fromRGB(100, 100, 110))
                            end
                            break
                        end
                        
                        if not upgradedAny then
                            statusLabel.Text = "⏳ Checking upgrade conditions..."
                            task.wait(2)
                        else
                            task.wait(1)
                        end
                    end
                end)
                
                Library:ShowToast("Auto Upgrade Worker Started", "ToastSuccess", 2)
            else
                Library:ShowToast("Please select at least one farm building", "ToastWarning", 2)
            end
        end
    end)
    
    upgradeStandToggle.MouseButton1Click:Connect(function()
        if Library.AutoUpgradeStandEnabled then
            Library.AutoUpgradeStandEnabled = false
            upgradeStandToggle.Text = "START"
            upgradeStandToggle.BackgroundColor3 = Colors.ToggleOff
            AddHoverEffect(upgradeStandToggle, Colors.ToggleOff, Color3.fromRGB(100, 100, 110))
            
            statusLabel.Text = "💤 Auto Upgrade Stand Stopped"
            statusLabel.TextColor3 = Colors.TextDim
            Library:ShowToast("Auto Upgrade Stand Stopped", "ToastInfo", 2)
        else
            local selectedCount = 0
            for _ in pairs(Library.SelectedFarms) do
                selectedCount += 1
            end
            
            if selectedCount > 0 then
                Library.AutoUpgradeStandEnabled = true
                upgradeStandToggle.Text = "STOP"
                upgradeStandToggle.BackgroundColor3 = Colors.ToggleOn
                AddHoverEffect(upgradeStandToggle, Colors.ToggleOn, Color3.fromRGB(100, 242, 155))
                statusLabel.Text = "🏪 Auto Upgrading Stands..."
                statusLabel.TextColor3 = Colors.ToastSuccess
                
                task.spawn(function()
                    local maxLevelNotified = false
                    
                    while Library.AutoUpgradeStandEnabled do
                        local upgradedAny = false
                        local allMax = true
                        
                        for baseName, _ in pairs(Library.SelectedFarms) do
                            if not Library.AutoUpgradeStandEnabled then break end
                            
                            local displayName = Library:GetDisplayName(baseName)
                            if displayName then
                                pcall(function()
                                    local upgrades = LocalPlayer:WaitForChild("Upgrades")
                                    local upgrade = upgrades:FindFirstChild(displayName)
                                    
                                    if upgrade and upgrade.Value < 100 then
                                        allMax = false
                                        local args = { displayName }
                                        ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("EventService"):WaitForChild("RF"):WaitForChild("UpgradeStand"):InvokeServer(unpack(args))
                                        upgradedAny = true
                                        statusLabel.Text = "🏪 Upgrading " .. displayName
                                        task.wait(0.3)
                                    end
                                end)
                            end
                        end
                        
                        if allMax then
                            statusLabel.Text = "🎉 All stands max level!"
                            if not maxLevelNotified then
                                Library:ShowToast("All stands at maximum level!", "ToastSuccess", 3)
                                maxLevelNotified = true
                            end
                            
                            task.wait(1)
                            if Library.AutoUpgradeStandEnabled then
                                Library.AutoUpgradeStandEnabled = false
                                upgradeStandToggle.Text = "START"
                                upgradeStandToggle.BackgroundColor3 = Colors.ToggleOff
                                AddHoverEffect(upgradeStandToggle, Colors.ToggleOff, Color3.fromRGB(100, 100, 110))
                            end
                            break
                        end
                        
                        if not upgradedAny then
                            statusLabel.Text = "⏳ Checking upgrade conditions..."
                            task.wait(2)
                        else
                            task.wait(1)
                        end
                    end
                end)
                
                Library:ShowToast("Auto Upgrade Stand Started", "ToastSuccess", 2)
            else
                Library:ShowToast("Please select at least one farm building", "ToastWarning", 2)
            end
        end
    end)
    
    sellToggle.MouseButton1Click:Connect(function()
        if Library.AutoSellEnabled then
            Library.AutoSellEnabled = false
            sellToggle.Text = "START"
            sellToggle.BackgroundColor3 = Colors.ToggleOff
            AddHoverEffect(sellToggle, Colors.ToggleOff, Color3.fromRGB(100, 100, 110))
            
            statusLabel.Text = "💤 Auto Sell Stopped"
            statusLabel.TextColor3 = Colors.TextDim
            Library:ShowToast("Auto Sell Stopped", "ToastInfo", 2)
        else
            local selectedCount = 0
            for _ in pairs(Library.SelectedFarms) do
                selectedCount += 1
            end
            
            if selectedCount > 0 then
                Library.AutoSellEnabled = true
                sellToggle.Text = "STOP"
                sellToggle.BackgroundColor3 = Colors.ToggleOn
                AddHoverEffect(sellToggle, Colors.ToggleOn, Color3.fromRGB(100, 242, 155))
                statusLabel.Text = "💰 Selling all items..."
                statusLabel.TextColor3 = Colors.ToastSuccess
                Library:ShowToast("Auto Sell Started", "ToastSuccess", 2)
                
                task.spawn(function()
                    while Library.AutoSellEnabled do
                        if not Library.AutoSellEnabled then break end
                        
                        local sellTable = {}
                        for baseName, _ in pairs(Library.SelectedFarms) do
                            local displayName = Library:GetDisplayName(baseName)
                            if displayName then
                                sellTable[displayName] = displayName
                            end
                        end
                        
                        if next(sellTable) then
                            local args = { sellTable }
                            local success, result = pcall(function()
                                return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("EventService"):WaitForChild("RF"):WaitForChild("Sell"):InvokeServer(unpack(args))
                            end)
                            
                            if success then
                                statusLabel.Text = "💰 Sold " .. #Library.SelectedFarms .. " item types"
                            else
                                statusLabel.Text = "💰 Selling items..."
                            end
                        end
                        
                        task.wait(3)
                    end
                end)
            else
                Library:ShowToast("Please select at least one farm building", "ToastWarning", 2)
            end
        end
    end)
    
    -- Fishing Toggle Handler
    fishingToggle.MouseButton1Click:Connect(function()
        if Library.AutoFishingEnabled then
            Library:StopAutoFishing()
            fishingToggle.Text = "START"
            fishingToggle.BackgroundColor3 = Colors.ToggleOff
            AddHoverEffect(fishingToggle, Colors.ToggleOff, Color3.fromRGB(100, 100, 110))
            Library:ShowToast("Auto Fishing Stopped", "ToastInfo", 2)
        else
            Library:StartAutoFishing()
            fishingToggle.Text = "STOP"
            fishingToggle.BackgroundColor3 = Colors.ToggleOn
            AddHoverEffect(fishingToggle, Colors.ToggleOn, Color3.fromRGB(100, 242, 155))
            statusLabel.Text = "🎣 Auto Fishing Started"
            statusLabel.TextColor3 = Colors.ToastSuccess
            Library:ShowToast("Auto Fishing Started", "ToastSuccess", 2)
        end
    end)
    
    return {
        FarmToggle = farmToggle,
        CollectToggle = collectToggle,
        UpgradeToggle = upgradeToggle,
        UpgradeStandToggle = upgradeStandToggle,
        SellToggle = sellToggle,
        FishingToggle = fishingToggle,
        StatusLabel = statusLabel
    }
end

-- Core Library Functions
function Library:Destroy()
    Library.Toggles = {}
    Library.CollectToggles = {}
    Library.SelectedFarms = {}
    Library.AutoFarmEnabled = false
    Library.AutoCollectEnabled = false
    Library.AutoUpgradeEnabled = false
    Library.AutoSellEnabled = false
    Library.AutoUpgradeStandEnabled = false
    Library.AutoFishingEnabled = false
    
    for _, conn in ipairs(Library.Connections) do
        conn:Disconnect()
    end
    Library.Connections = {}
    
    if Library.Elements.ScreenGui then
        Library.Elements.ScreenGui:Destroy()
    end
    Library.Elements = nil
    Library = nil
end

function Library:SwitchTab(panelToShow)
    local Elements = Library.Elements
    Elements.FarmingPanel.Visible = false
    Elements.MiscPanel.Visible = false
    Elements.btnFarming.BackgroundColor3 = Colors.Secondary
    Elements.btnMisc.BackgroundColor3 = Colors.Secondary
    panelToShow.Visible = true
    
    if Library.CloseDropdown then
        Library.CloseDropdown()
    end
    
    if panelToShow == Elements.FarmingPanel then
        Elements.btnFarming.BackgroundColor3 = Colors.Accent
    elseif panelToShow == Elements.MiscPanel then
        Elements.btnMisc.BackgroundColor3 = Colors.Accent
    end
end

function Library:ToggleMinimize(isMinimized)
    Library.Elements.MainContainer.Visible = not isMinimized
    Library.Elements.ShowBtn.Visible = isMinimized
end

function Library:CreateChannelButton(text, icon)
    local btn = Create("TextButton", {
        Size = UDim2.new(0.9, 0, 0, 40),
        BackgroundColor3 = Colors.Secondary,
        TextColor3 = Colors.TextDim,
        Font = Fonts.Medium,
        TextSize = 14,
        Text = "  " .. icon .. " " .. text,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Parent = Library.Elements.Sidebar,
        Create("UICorner", { CornerRadius = UDim.new(0, 8) })
    })
    
    AddHoverEffect(btn, Colors.Secondary, Color3.fromRGB(50, 50, 65))
    return btn
end

-- Farm Data
Library.FarmData = {
    ["Wood Tree"] = "Wood",
    ["Coin Tree"] = "Coins",
    ["Fish Net"] = "Fish",
    ["Big Fish Net"] = "Big Fish",
    ["Crab Net"] = "Crab",
    ["Squid Net"] = "Squid",
    ["PlasticBottle Net"] = "Plastic Bottle",
    ["Can Net"] = "Tin Can",
    ["Silver Net"] = "Silver",
    ["Gold Net"] = "Gold",
    ["Pearl Net"] = "Pearl",
    ["Lobster Net"] = "Lobster",
    ["Starfish Net"] = "Starfish",
    ["Melon Crop"] = "Melon",
    ["Coconut Crop"] = "Coconut",
    ["Eggplant Crop"] = "Eggplant",
    ["Carrot Crop"] = "Carrot",
    ["Pineapple Crop"] = "Pineapple",
    ["Banana Crop"] = "Banana",
    ["Strawberry Crop"] = "Strawberry",
    ["Cherry Crop"] = "Cherry",
    ["Grape Crop"] = "Grapes",
    ["Bird Nest"] = "Egg",
    ["Seagull Nest"] = "Seagull Egg",
    ["Eagle Nest"] = "Eagle Egg"
}

function Library:GetDisplayName(baseName)
    return self.FarmData[baseName] or baseName
end

-- Game Functions
function Library:Harvest(name)
    pcall(function()
        ReplicatedStorage.Packages["_Index"]["sleitnick_knit@1.7.0"]
            .knit.Services.EventService.RF.MineHarvestable
            :InvokeServer(name)
    end)
end

function Library:CollectStorage(itemName)
    local args = { itemName }
    local success, result = pcall(function()
        return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("EventService"):WaitForChild("RF"):WaitForChild("CollectStorage"):InvokeServer(unpack(args))
    end)
    return success, result
end

function Library:UpgradeWorker(workerName)
    local args = { workerName }
    local success, result = pcall(function()
        return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("EventService"):WaitForChild("RF"):WaitForChild("UpgradeWorker"):InvokeServer(unpack(args))
    end)
    return success, result
end

function Library:UpgradeStand(standName)
    local args = { standName }
    local success, result = pcall(function()
        return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("EventService"):WaitForChild("RF"):WaitForChild("UpgradeStand"):InvokeServer(unpack(args))
    end)
    return success, result
end

function Library:SellItems(sellTable)
    local args = { sellTable }
    local success, result = pcall(function()
        return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("EventService"):WaitForChild("RF"):WaitForChild("Sell"):InvokeServer(unpack(args))
    end)
    return success, result
end

-- Auto Farm Functions
function Library:StartAutoFarm(baseName)
    if Library.Toggles[baseName] then return end
    Library.Toggles[baseName] = true

    task.spawn(function()
        while Library.Toggles[baseName] do
            local buildings = LocalPlayer:FindFirstChild("Buildings")
            if buildings then
                for _, obj in ipairs(buildings:GetChildren()) do
                    if obj.Name:find(baseName) then
                        Library:Harvest(obj.Name)
                        task.wait(0.15)
                    end
                    if not Library.Toggles[baseName] then break end
                end
            end
            task.wait(1)
        end
    end)
end

function Library:StopAutoFarm(baseName)
    Library.Toggles[baseName] = false
end

function Library:StartAutoCollect(baseName)
    if Library.CollectToggles[baseName] then return end
    Library.CollectToggles[baseName] = true

    task.spawn(function()
        while Library.CollectToggles[baseName] do
            local displayName = Library:GetDisplayName(baseName)
            if displayName then
                Library:CollectStorage(displayName)
            end
            task.wait(0.15)
        end
    end)
end

function Library:StopAutoCollect(baseName)
    Library.CollectToggles[baseName] = false
end

-- UI Building dengan perubahan yang diminta
function Library:Build()
    local Elements = Library.Elements

    Elements.ScreenGui = Create("ScreenGui", {
        Name = Library.Name,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        Parent = CoreGui
    })

    Elements.MainContainer = Create("Frame", {
        Name = "MainContainer",
        Size = UDim2.new(0, 480, 0, 320),
        Position = UDim2.new(0.5, -240, 0.5, -160),
        BackgroundTransparency = 1,
        Parent = Elements.ScreenGui
    })
    
    Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        BackgroundTransparency = 1,
        Parent = Elements.MainContainer
    })

    Elements.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        Parent = Elements.MainContainer,
        Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        Create("UIStroke", {
            Thickness = 1,
            Color = Color3.fromRGB(60, 60, 70)
        })
    })

    Elements.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Colors.TitleBar,
        BorderSizePixel = 0,
        Parent = Elements.MainFrame,
        Create("UICorner", {
            CornerRadius = UDim.new(0, 12),
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 0),
                PaddingBottom = UDim.new(0, 0),
                PaddingLeft = UDim.new(0, 0),
                PaddingRight = UDim.new(0, 0)
            })
        })
    })

    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Colors.TitleBar,
        BorderSizePixel = 0,
        Parent = Elements.TitleBar
    })

    -- Title dengan ANHub dan nama game + Premium Badge
    local titleContainer = Create("Frame", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Parent = Elements.TitleBar
    })

    -- Icon dari Roblox Asset
    local titleIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 0, 0.5, -12),
        BackgroundTransparency = 1,
        Image = "rbxassetid://109266060342925",
        Parent = titleContainer
    })

    -- ANHub Text dengan nama game - menggunakan TextLabel yang lebih fleksibel
    local titleText = "ANHub - " .. currentGameName
    local titleLabel = Create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0), -- Size akan diatur otomatis
        Position = UDim2.new(0, 30, 0, 0),
        Text = titleText,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Fonts.Bold,
        TextSize = 16,
        BackgroundTransparency = 1,
        Parent = titleContainer
    })

    -- Tunggu sebentar untuk mendapatkan ukuran text yang tepat
    task.spawn(function()
        task.wait(0.1)
        local textSize = TextService:GetTextSize(titleText, 16, Fonts.Bold, Vector2.new(1000, 34))
        titleLabel.Size = UDim2.new(0, textSize.X + 5, 1, 0)
        
        -- Premium Badge dengan posisi yang dinamis berdasarkan ukuran text
        local premiumBadge = Create("Frame", {
            Size = UDim2.new(0, 70, 0, 18),
            Position = UDim2.new(0, textSize.X + 35, 0.5, -9), -- Posisi disesuaikan dengan lebar text
            BackgroundColor3 = Colors.Premium,
            Parent = titleContainer,
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", {
                Thickness = 2,
                Color = Color3.fromRGB(0, 255, 0) -- Border hijau
            })
        })

        Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            Text = "PREMIUM",
            TextColor3 = Color3.fromRGB(0, 0, 0), -- Text hitam untuk kontras
            Font = Fonts.Bold,
            TextSize = 10,
            BackgroundTransparency = 1,
            Parent = premiumBadge
        })
    end)

    local controlFrame = Create("Frame", {
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -80, 0, 0),
        BackgroundTransparency = 1,
        Parent = Elements.TitleBar
    })

    Elements.MinBtn = Create("TextButton", {
        Name = "MinBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 5, 0.5, -15),
        Text = "—",
        TextSize = 18,
        Font = Fonts.Bold,
        BackgroundColor3 = Colors.Minimize,
        TextColor3 = Colors.Text,
        Parent = controlFrame,
        Create("UICorner", { CornerRadius = UDim.new(0, 6) })
    })

    Elements.ExitBtn = Create("TextButton", {
        Name = "ExitBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 40, 0.5, -15),
        Text = "✖",
        TextSize = 14,
        Font = Fonts.Bold,
        BackgroundColor3 = Colors.Exit,
        TextColor3 = Colors.Text,
        Parent = controlFrame,
        Create("UICorner", { CornerRadius = UDim.new(0, 6) })
    })

    Elements.Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 120, 1, -34),
        Position = UDim2.new(0, 0, 0, 34),
        BackgroundColor3 = Colors.Sidebar,
        BorderSizePixel = 0,
        Parent = Elements.MainFrame,
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })

    Elements.Content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -120, 1, -34),
        Position = UDim2.new(0, 120, 0, 34),
        BackgroundColor3 = Colors.MainFrame,
        BorderSizePixel = 0,
        Parent = Elements.MainFrame
    })

    Elements.FarmingPanel = Create("ScrollingFrame", {
        Name = "FarmingPanel",
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Accent,
        Visible = true,
        Parent = Elements.Content,
        Create("UIListLayout", {
            Name = "ListLayout",
            Padding = UDim.new(0, 8)
        }),
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        })
    })

    Elements.MiscPanel = Create("ScrollingFrame", {
        Name = "MiscPanel",
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Accent,
        Visible = false,
        Parent = Elements.Content,
        Create("UIListLayout", {
            Name = "ListLayout",
            Padding = UDim.new(0, 8)
        }),
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        })
    })

    Elements.ShowBtn = Create("TextButton", {
        Name = "ShowBtn",
        Size = UDim2.new(0, 100, 0, 36),
        Position = UDim2.new(0.5, -50, 0.9, 0),
        BackgroundColor3 = Colors.ShowButton,
        Text = "📂 Show Hub",
        TextColor3 = Colors.Text,
        Font = Fonts.Medium,
        TextSize = 14,
        Visible = false,
        Parent = Elements.ScreenGui,
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", {
            Thickness = 1,
            Color = Colors.Accent
        })
    })

    Elements.ToastContainer = Create("Frame", {
        Name = "ToastContainer",
        Size = UDim2.new(0, 300, 0, 200),
        Position = UDim2.new(1, -320, 1, -220),
        BackgroundTransparency = 1,
        Parent = Elements.ScreenGui
    })
end

-- Initialization
function Library:Init()
    Library:Build()
    local Elements = Library.Elements
    pcall(function()
        game:GetService("Players").LocalPlayer.Gamepasses["Infinite Storage"].Value = true
    end)

    Library:CreateProfileSection()

    Elements.btnFarming = Library:CreateChannelButton("Farming", "🌾")
    Elements.btnMisc = Library:CreateChannelButton("Misc", "🎭")
    
    table.insert(Library.Connections, Elements.btnFarming.MouseButton1Click:Connect(function()
        Library:SwitchTab(Elements.FarmingPanel)
    end))
    table.insert(Library.Connections, Elements.btnMisc.MouseButton1Click:Connect(function()
        Library:SwitchTab(Elements.MiscPanel)
    end))
    
    Library:SwitchTab(Elements.FarmingPanel)

    AddHoverEffect(Elements.ExitBtn, Colors.Exit, Color3.fromRGB(220, 60, 65))
    AddHoverEffect(Elements.MinBtn, Colors.Minimize, Color3.fromRGB(235, 150, 30))
    AddHoverEffect(Elements.ShowBtn, Colors.ShowButton, Color3.fromRGB(98, 111, 252))

    table.insert(Library.Connections, Elements.ExitBtn.MouseButton1Click:Connect(function()
        Library:ShowToast("Closing ANHub...", "ToastWarning", 1)
        task.wait(1)
        Library:Destroy()
    end))
    table.insert(Library.Connections, Elements.MinBtn.MouseButton1Click:Connect(function()
        Library:ToggleMinimize(true)
        Library:ShowToast("Hub minimized", "ToastInfo", 1)
    end))
    table.insert(Library.Connections, Elements.ShowBtn.MouseButton1Click:Connect(function()
        Library:ToggleMinimize(false)
    end))

    Library:CreateFarmSelection()
    Library:CreateFarmingControls()
    
    -- Misc Panel Content
    local hwidFrame = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 80),
        BackgroundColor3 = Colors.ProfileCard,
        Parent = Elements.MiscPanel,
        Create("UICorner", {CornerRadius = UDim.new(0, 8)})
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 5),
        Text = "🔐 SYSTEM INFO",
        TextColor3 = Colors.TextHeader,
        Font = Fonts.Bold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = hwidFrame
    })
    
    local hwidText = "HWID: " .. game:GetService("RbxAnalyticsService"):GetClientId()
    local hwidLabel = Create("TextLabel", {
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 10, 0, 30),
        Text = hwidText,
        TextColor3 = Colors.TextDim,
        Font = Fonts.Medium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = hwidFrame
    })
    
    local copyBtn = Create("TextButton", {
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -70, 0, 30),
        BackgroundColor3 = Colors.MiscButton,
        Text = "COPY",
        TextColor3 = Colors.Text,
        Font = Fonts.Medium,
        TextSize = 10,
        Parent = hwidFrame,
        Create("UICorner", {CornerRadius = UDim.new(0, 4)})
    })
    
    AddHoverEffect(copyBtn, Colors.MiscButton, Colors.Accent)
    
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(hwidText)
        Library:ShowToast("HWID copied to clipboard!", "ToastSuccess", 2)
    end)
    
    local serverFrame = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 60),
        BackgroundColor3 = Colors.ProfileCard,
        Parent = Elements.MiscPanel,
        Create("UICorner", {CornerRadius = UDim.new(0, 8)})
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 5),
        Text = "📊 SERVER INFO",
        TextColor3 = Colors.TextHeader,
        Font = Fonts.Bold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = serverFrame
    })
    
    local serverInfoLabel = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 30),
        Text = "Players: " .. #Players:GetPlayers(),
        TextColor3 = Colors.TextDim,
        Font = Fonts.Medium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = serverFrame
    })

    -- Dragging functionality for ShowBtn
    local isDragging = false
    local dragStart, startPos
    
    table.insert(Library.Connections, Elements.ShowBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = Elements.ShowBtn.Position
            
            local endConnection
            endConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                    endConnection:Disconnect()
                end
            end)
        end
    end))

    table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Elements.ShowBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    -- Auto-resize scrolling frames
    task.spawn(function()
        while Library and Library.Elements and Library.Elements.ScreenGui and Library.Elements.ScreenGui.Parent do
            task.wait(0.2)
            if Elements.FarmingPanel:FindFirstChild("ListLayout") then
                Elements.FarmingPanel.CanvasSize = UDim2.new(0, 0, 0, Elements.FarmingPanel.ListLayout.AbsoluteContentSize.Y + 20)
            end
            if Elements.MiscPanel:FindFirstChild("ListLayout") then
                Elements.MiscPanel.CanvasSize = UDim2.new(0, 0, 0, Elements.MiscPanel.ListLayout.AbsoluteContentSize.Y + 20)
            end
        end
    end)
    
    task.wait(1)
    Library:ShowToast("Welcome to ANHub Premium! - " .. currentGameName, "ToastSuccess", 3)
end

-- Start Library
Library:Init()

return Library