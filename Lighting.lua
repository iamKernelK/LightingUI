--[[
================================================================================
🔥 AXIS PREMIUM UI LIBRARY V3 (THE DEFINITIVE EDITION)
🎨 Theme: Frosted Dark Amber Glass & Premium Orange Gradient
🛠️ Optimized for PC & Android Mobile Gestures
================================================================================
]]

local AxisUI = {}
AxisUI.__index = AxisUI

-- ==========================================
-- ⚙️ Services & Constants
-- ==========================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 🎨 Theme Configuration (Premium Dark Orange)
-- ==========================================
local Theme = {
    MainBackground = Color3.fromRGB(12, 8, 5),
    MainTransparency = 0.25,
    SecondaryBackground = Color3.fromRGB(18, 12, 8),
    SectionBackground = Color3.fromRGB(22, 16, 12),
    ElementBackground = Color3.fromRGB(28, 20, 15),
    HoverElement = Color3.fromRGB(38, 28, 22),
    
    OrangePrimary = Color3.fromRGB(255, 135, 0),
    OrangeDark = Color3.fromRGB(180, 70, 0),
    OrangeLight = Color3.fromRGB(255, 175, 70),
    
    TextColor = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(165, 155, 145),
    StrokeColor = Color3.fromRGB(48, 38, 28),
    
    DropdownBg = Color3.fromRGB(14, 9, 6),
    DropdownItem = Color3.fromRGB(26, 19, 13),
    
    -- Icons
    ButtonIcon = "rbxassetid://10088146939",
    DropdownClosedIcon = "rbxassetid://115929304045144",
    DropdownOpenIcon = "rbxassetid://76267512291523",
    SearchIcon = "rbxassetid://15999597350",
    CloseIcon = "rbxassetid://4458805208",
    MinimizeIcon = "rbxassetid://78357418744409",
    TransparencyIcon = "rbxassetid://101356891567422",
    RemoveIcon = "rbxassetid://11293977686",
}

-- ==========================================
-- 🛠️ Core Utilities
-- ==========================================
local Utility = {}

function Utility:Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

function Utility:ApplyGradient(instance, colorSequence, rotation)
    return self:Create("UIGradient", {
        Color = colorSequence or ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.OrangeLight),
            ColorSequenceKeypoint.new(0.5, Theme.OrangePrimary),
            ColorSequenceKeypoint.new(1, Theme.OrangeDark)
        }),
        Rotation = rotation or 45,
        Parent = instance
    })
end

function Utility:MakeDraggable(dragPart, targetPart)
    local Dragging, DragInput, DragStart, StartPosition

    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = targetPart.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)

    dragPart.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
            TweenService:Create(targetPart, TweenInfo.new(0.1, Enum.EasingStyle.OutQuad), {Position = pos}):Play()
        end
    end)
end

function Utility:RippleEffect(button)
    local ripple = self:Create("Frame", {
        BackgroundColor3 = Theme.OrangePrimary,
        BackgroundTransparency = 0.6,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        Parent = button
    })
    self:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ripple})
    
    local targetSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
    local tween = TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, targetSize, 0, targetSize),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function() ripple:Destroy() end)
end

-- ==========================================
-- 🔔 Notification System
-- ==========================================
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(parentGui)
    local self = setmetatable({}, NotificationSystem)
    self.ParentGui = parentGui
    self.ActiveNotifications = {}
    self.NotificationHeight = 85
    self.NotificationSpacing = 10
    
    self.Container = Utility:Create("Frame", {
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, -320, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 1000,
        Parent = parentGui
    })
    
    return self
end

function NotificationSystem:Notify(Options)
    local title = Options.Title or "Notification"
    local desc = Options.Description or ""
    local icon = Options.Icon or ""
    local duration = Options.Duration or 3

    for _, notif in ipairs(self.ActiveNotifications) do
        local newPos = notif.Instance.Position - UDim2.new(0, 0, 0, self.NotificationHeight + self.NotificationSpacing)
        TweenService:Create(notif.Instance, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = newPos}):Play()
    end

    local notifFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, self.NotificationHeight),
        Position = UDim2.new(1, 20, 0, 0),
        BackgroundColor3 = Theme.MainBackground,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 1001,
        Parent = self.Container
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = notifFrame})
    
    local notifStroke = Utility:Create("UIStroke", {
        Color = Theme.OrangePrimary,
        Thickness = 1.2,
        Parent = notifFrame
    })

    if icon and icon ~= "" then
        local iconImg = Utility:Create("ImageLabel", {
            Size = UDim2.new(0, 36, 0, 36),
            Position = UDim2.new(0, 12, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Image = icon,
            ZIndex = 1002,
            Parent = notifFrame
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = iconImg})
    end

    local titleLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, icon ~= "" and -65 or -24, 0, 20),
        Position = UDim2.new(0, icon ~= "" and 55 or 12, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.TextColor,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1002,
        Parent = notifFrame
    })

    local descLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, icon ~= "" and -65 or -24, 0, 35),
        Position = UDim2.new(0, icon ~= "" and 55 or 12, 0, 28),
        BackgroundTransparency = 1,
        Text = desc,
        TextColor3 = Theme.TextMuted,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 1002,
        Parent = notifFrame
    })

    local progressBar = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 3),
        Position = UDim2.new(0, 10, 1, -6),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.SecondaryBackground,
        ZIndex = 1002,
        Parent = notifFrame
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = progressBar})
    
    local progressFill = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.OrangePrimary,
        ZIndex = 1003,
        Parent = progressBar
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = progressFill})

    TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()

    table.insert(self.ActiveNotifications, 1, {Instance = notifFrame})

    task.delay(duration, function()
        for i, notif in ipairs(self.ActiveNotifications) do
            if notif.Instance == notifFrame then
                table.remove(self.ActiveNotifications, i)
                break
            end
        end
        TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0, notifFrame.Position.Y.Offset), BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        notifFrame:Destroy()
    end)
end

-- ==========================================
-- 🪟 Window Construction
-- ==========================================
function AxisUI:CreateWindow(Options)
    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Transparency = Options.Transparency or Theme.MainTransparency,
        Size = Options.Size or UDim2.new(0, 750, 0, 480)
    }
    
    local TitleText = Options.Title or "Axis Premium"
    local DescText = Options.Description or "Ultimate UI Experience"
    local ThemeImage = Options.ThemeImage or "rbxassetid://103845371952278" 
    
    -- Safe ScreenGui Mounting
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "AxisUI_PremiumV3",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })

    local success, _ = pcall(function() ScreenGui.Parent = gethui() end)
    if not success then pcall(function() ScreenGui.Parent = CoreGui end) end
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    Window.ScreenGui = ScreenGui

    -- Main Frame
    local MainFrame = Utility:Create("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Theme.MainBackground,
        BackgroundTransparency = Window.Transparency,
        BorderSizePixel = 0,
        Active = true,
        Parent = ScreenGui
    })
    Window.MainFrame = MainFrame
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})

    local MainStroke = Utility:Create("UIStroke", {
        Color = Color3.new(1,1,1),
        Thickness = 1.5,
        Parent = MainFrame
    })
    local StrokeGrad = Utility:ApplyGradient(MainStroke)
    TweenService:Create(StrokeGrad, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360}):Play()

    -- Drop Shadow
    Utility:Create("ImageLabel", {
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.5,
        ZIndex = -1,
        Parent = MainFrame
    })

    -- ========================================================
    -- 👑 Professional TopBar Design
    -- ========================================================
    local TopBar = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 75),
        BackgroundTransparency = 1,
        ZIndex = 10,
        Parent = MainFrame
    })
    Utility:MakeDraggable(TopBar, MainFrame)

    local TitleLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 350, 0, 25),
        Position = UDim2.new(0, 25, 0, 16),
        BackgroundTransparency = 1,
        Text = TitleText,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })
    Utility:ApplyGradient(TitleLabel, nil, 0)

    local DescLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 350, 0, 20),
        Position = UDim2.new(0, 25, 0, 42),
        BackgroundTransparency = 1,
        Text = DescText,
        TextColor3 = Theme.TextMuted,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })

    -- Ordered TopBar Action Buttons Container
    local TopBarButtonsContainer = Utility:Create("Frame", {
        Size = UDim2.new(0, 220, 1, 0),
        Position = UDim2.new(1, -235, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = TopBar
    })
    
    local TopBarLayout = Utility:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 14),
        Parent = TopBarButtonsContainer
    })

    -- Function to dynamically add buttons to TopBar with LayoutOrder
    function Window:AddTopBarButton(BtnOptions)
        local iconId = BtnOptions.Icon or "rbxassetid://0"
        local callback = BtnOptions.Callback or function() end
        local name = BtnOptions.Name or "CustomBtn"
        local toggleCallback = BtnOptions.ToggleCallback
        local order = BtnOptions.LayoutOrder or 10

        local btn = Utility:Create("ImageButton", {
            Name = name,
            Size = UDim2.new(0, 20, 0, 20),
            BackgroundTransparency = 1,
            Image = iconId,
            LayoutOrder = order,
            ZIndex = 12,
            Parent = TopBarButtonsContainer
        })
        local btnGradient = Utility:ApplyGradient(btn)

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 23, 0, 23)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 20, 0, 20)}):Play()
        end)
        
        local isToggled = false
        btn.MouseButton1Click:Connect(function()
            Utility:RippleEffect(btn)
            if toggleCallback then
                isToggled = not isToggled
                toggleCallback(isToggled)
            else
                callback()
            end
        end)

        return {
            Instance = btn,
            SetIcon = function(self, newIcon) btn.Image = newIcon end,
            Destroy = function(self) btn:Destroy() end
        }
    end

    -- Setup Default TopBar Buttons using fixed orders
    Window:AddTopBarButton({
        Name = "Bright",
        Icon = Theme.TransparencyIcon,
        LayoutOrder = 1,
        ToggleCallback = function(isActive)
            Window.Transparency = isActive and 0.55 or Theme.MainTransparency
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = Window.Transparency}):Play()
        end
    })

    Window:AddTopBarButton({
        Name = "Minimize",
        Icon = Theme.MinimizeIcon,
        LayoutOrder = 2,
        Callback = function()
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
            task.wait(0.4)
            MainFrame.Visible = false
            _G.AxisFloatingBtn.Visible = true
            _G.AxisFloatingBtn.Size = UDim2.new(0,0,0,0)
            TweenService:Create(_G.AxisFloatingBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,50,0,50)}):Play()
        end
    })

    Window:AddTopBarButton({
        Name = "Remove",
        Icon = Theme.RemoveIcon,
        LayoutOrder = 3,
        Callback = function()
            ScreenGui:Destroy()
        end
    })

    Window:AddTopBarButton({
        Name = "Close",
        Icon = Theme.CloseIcon,
        LayoutOrder = 4,
        Callback = function()
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
            task.wait(0.4)
            ScreenGui:Destroy()
        end
    })

    -- Restore Floating Button
    if _G.AxisFloatingBtn then _G.AxisFloatingBtn:Destroy() end
    
    local FloatingBtn = Utility:Create("ImageButton", {
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.1, 0, 0.1, 0),
        BackgroundColor3 = Theme.MainBackground,
        BackgroundTransparency = 0.2,
        Visible = false,
        ZIndex = 5000,
        Parent = ScreenGui
    })
    _G.AxisFloatingBtn = FloatingBtn
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = FloatingBtn})
    local floatStroke = Utility:Create("UIStroke", {Color = Color3.new(1,1,1), Thickness = 1.5, Parent = FloatingBtn})
    Utility:ApplyGradient(floatStroke)
    
    Utility:Create("ImageLabel", {
        Size = UDim2.new(1, -14, 1, -14),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = ThemeImage,
        Parent = FloatingBtn
    })
    Utility:MakeDraggable(FloatingBtn, FloatingBtn)

    FloatingBtn.MouseButton1Click:Connect(function()
        TweenService:Create(FloatingBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.3)
        FloatingBtn.Visible = false
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.OutExponential), {Size = Window.Size}):Play()
    end)

    -- Layout Dividers
    Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 75),
        BackgroundColor3 = Theme.StrokeColor,
        BorderSizePixel = 0,
        Parent = MainFrame
    })

    Utility:Create("Frame", {
        Size = UDim2.new(0, 1, 1, -75),
        Position = UDim2.new(0, 180, 0, 75),
        BackgroundColor3 = Theme.StrokeColor,
        BorderSizePixel = 0,
        Parent = MainFrame
    })

    -- Sidebar Container
    local Sidebar = Utility:Create("ScrollingFrame", {
        Size = UDim2.new(0, 180, 1, -75),
        Position = UDim2.new(0, 0, 0, 75),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = MainFrame
    })
    Utility:Create("UIListLayout", {Padding = UDim.new(0, 8), Parent = Sidebar})
    Utility:Create("UIPadding", {PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = Sidebar})

    -- Content Frame Area
    local ContentArea = Utility:Create("Frame", {
        Size = UDim2.new(1, -181, 1, -75),
        Position = UDim2.new(0, 181, 0, 75),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.OutExponential), {Size = Window.Size}):Play()

    Window.Notifications = NotificationSystem.new(ScreenGui)
    function Window:Notify(Options) self.Notifications:Notify(Options) end

    -- ==========================================
    -- 📑 Tab System
    -- ==========================================
    function Window:CreateTab(TabOptions)
        local TabName = TabOptions.Name or "New Tab"
        local TabIcon = TabOptions.Icon or "rbxassetid://103845371952278"
        
        local Tab = {Elements = {}, Name = TabName}
        local isFirst = (#Sidebar:GetChildren() == 2) 

        local TabBtn = Utility:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = isFirst and Theme.ElementBackground or Theme.MainBackground,
            BackgroundTransparency = isFirst and 0 or 1,
            Text = "",
            AutoButtonColor = false,
            Parent = Sidebar
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})
        
        local TabStroke = Utility:Create("UIStroke", {
            Color = Theme.OrangePrimary,
            Transparency = isFirst and 0 or 1,
            Parent = TabBtn
        })

        local IconImg = Utility:Create("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 12, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Image = TabIcon,
            ImageColor3 = isFirst and Theme.OrangePrimary or Theme.TextMuted,
            Parent = TabBtn
        })
        
        local TitleTxt = Utility:Create("TextLabel", {
            Size = UDim2.new(1, -45, 1, 0),
            Position = UDim2.new(0, 40, 0, 0),
            BackgroundTransparency = 1,
            Text = TabName,
            TextColor3 = isFirst and Theme.TextColor or Theme.TextMuted,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabBtn
        })

        local TabContainer = Utility:Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.OrangePrimary,
            Visible = isFirst,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = ContentArea
        })
        Utility:Create("UIListLayout", {Padding = UDim.new(0, 10), Parent = TabContainer})
        Utility:Create("UIPadding", {PaddingTop = UDim.new(0, 15), PaddingBottom = UDim.new(0, 30), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), Parent = TabContainer})

        if isFirst then Window.ActiveTab = TabBtn end

        TabBtn.MouseButton1Click:Connect(function()
            if Window.ActiveTab == TabBtn then return end
            
            for _, child in ipairs(ContentArea:GetChildren()) do
                if child:IsA("ScrollingFrame") then child.Visible = false end
            end
            for _, btn in ipairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(btn:FindFirstChild("UIStroke"), TweenInfo.new(0.2), {Transparency = 1}):Play()
                    btn:FindFirstChildOfClass("TextLabel").TextColor3 = Theme.TextMuted
                    btn:FindFirstChildOfClass("ImageLabel").ImageColor3 = Theme.TextMuted
                end
            end
            
            TabContainer.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBackground, BackgroundTransparency = 0}):Play()
            TweenService:Create(TabStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
            TitleTxt.TextColor3 = Theme.TextColor
            IconImg.ImageColor3 = Theme.OrangePrimary
            Window.ActiveTab = TabBtn
        end)

        local function GetParent(customParent) return customParent or TabContainer end

        -- 1. Section Element
        function Tab:CreateSection(SectionName)
            local SecFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.SectionBackground,
                BackgroundTransparency = 0.4,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = TabContainer
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SecFrame})
            Utility:Create("UIStroke", {Color = Theme.StrokeColor, Transparency = 0.4, Parent = SecFrame})

            Utility:Create("TextLabel", {
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 12, 0, 4),
                BackgroundTransparency = 1,
                Text = SectionName,
                TextColor3 = Theme.OrangePrimary,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SecFrame
            })
            
            local SecContent = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 34),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SecFrame
            })
            Utility:Create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = SecContent})
            Utility:Create("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = SecContent})

            return {Container = SecContent}
        end

        -- 2. Label Element
        function Tab:CreateLabel(Options, parentTarget)
            local target = GetParent(parentTarget)
            local LblFrame = Utility:Create("Frame", {Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Parent = target})
            local Txt = Utility:Create("TextLabel", {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = Options.Text or "Label Text",
                TextColor3 = Options.Color or Theme.TextColor,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = LblFrame
            })
            return {
                SetText = function(self, newTxt) Txt.Text = newTxt end,
                SetColor = function(self, newCol) Txt.TextColor3 = newCol end
            }
        end

        -- 3. Button Element
        function Tab:CreateButton(Options, parentTarget)
            local target = GetParent(parentTarget)
            local Callback = Options.Callback or function() end

            local BtnFrame = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0.2,
                Text = "",
                AutoButtonColor = false,
                ClipsDescendants = true,
                Parent = target
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = BtnFrame})
            Utility:Create("UIStroke", {Color = Theme.StrokeColor, Transparency = 0.4, Parent = BtnFrame})

            Utility:Create("ImageLabel", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 12, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Image = Theme.ButtonIcon,
                ImageColor3 = Theme.OrangePrimary,
                Parent = BtnFrame
            })

            local Lbl = Utility:Create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 40, 0, 0),
                BackgroundTransparency = 1,
                Text = Options.Name or "Button",
                TextColor3 = Theme.TextColor,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = BtnFrame
            })

            BtnFrame.MouseEnter:Connect(function() TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.HoverElement}):Play() end)
            BtnFrame.MouseLeave:Connect(function() TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBackground}):Play() end)
            BtnFrame.MouseButton1Click:Connect(function()
                Utility:RippleEffect(BtnFrame)
                Callback()
            end)
            return {SetText = function(self, newText) Lbl.Text = newText end}
        end

        -- 4. TextBox Element
        function Tab:CreateTextBox(Options, parentTarget)
            local target = GetParent(parentTarget)
            local Callback = Options.Callback or function() end

            local BoxFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0.2,
                Parent = target
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = BoxFrame})
            local MainStroke = Utility:Create("UIStroke", {Color = Theme.StrokeColor, Transparency = 0.4, Parent = BoxFrame})

            Utility:Create("TextLabel", {
                Size = UDim2.new(1, -140, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = Options.Name or "TextBox",
                TextColor3 = Theme.TextColor,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = BoxFrame
            })

            local InputBox = Utility:Create("TextBox", {
                Size = UDim2.new(0, 110, 0, 26),
                Position = UDim2.new(1, -12, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Color3.fromRGB(15, 12, 8),
                Text = Options.Default or "",
                PlaceholderText = Options.Placeholder or "Enter...",
                PlaceholderColor3 = Theme.TextMuted,
                TextColor3 = Theme.OrangePrimary,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                ClearTextOnFocus = Options.ClearOnFocus or false,
                Parent = BoxFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = InputBox})
            local InputStroke = Utility:Create("UIStroke", {Color = Theme.StrokeColor, Thickness = 1.2, Parent = InputBox})

            InputBox.Focused:Connect(function()
                TweenService:Create(InputStroke, TweenInfo.new(0.2), {Color = Theme.OrangePrimary}):Play()
            end)
            InputBox.FocusLost:Connect(function()
                TweenService:Create(InputStroke, TweenInfo.new(0.2), {Color = Theme.StrokeColor}):Play()
                Callback(InputBox.Text)
            end)
            return {
                SetText = function(self, text) InputBox.Text = text end,
                GetText = function(self) return InputBox.Text end
            }
        end

        -- 5. Toggle Element
        function Tab:CreateToggle(Options, parentTarget)
            local target = GetParent(parentTarget)
            local Callback = Options.Callback or function() end
            local State = Options.Default or false

            local TogFrame = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0.2,
                Text = "",
                AutoButtonColor = false,
                Parent = target
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TogFrame})
            Utility:Create("UIStroke", {Color = Theme.StrokeColor, Parent = TogFrame})

            Utility:Create("TextLabel", {
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = Options.Name or "Toggle",
                TextColor3 = Theme.TextColor,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TogFrame
            })

            local ToggleBg = Utility:Create("Frame", {
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -52, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = State and Theme.OrangePrimary or Theme.SecondaryBackground,
                Parent = TogFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBg})
            local ToggleStroke = Utility:Create("UIStroke", {Color = Theme.StrokeColor, Parent = ToggleBg})

            local ToggleCircle = Utility:Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = State and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.new(1,1,1),
                Parent = ToggleBg
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleCircle})

            local function UpdateVisuals()
                local targetBg = State and Theme.OrangePrimary or Theme.SecondaryBackground
                local targetPos = State and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                TweenService:Create(ToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = targetBg}):Play()
                TweenService:Create(ToggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
            end

            TogFrame.MouseButton1Click:Connect(function()
                State = not State
                UpdateVisuals()
                Callback(State)
            end)
            return {
                Set = function(self, v) State = v UpdateVisuals() Callback(State) end,
                Get = function(self) return State end
            }
        end

        -- 6. Slider Element (⭐ 100% Android & Mobile Fixed)
        function Tab:CreateSlider(Options, parentTarget)
            local target = GetParent(parentTarget)
            local Min = Options.Min or 0
            local Max = Options.Max or 100
            local Default = Options.Default or Min
            local Callback = Options.Callback or function() end

            local SliFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 56),
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0.2,
                Parent = target
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SliFrame})
            Utility:Create("UIStroke", {Color = Theme.StrokeColor, Parent = SliFrame})

            Utility:Create("TextLabel", {
                Size = UDim2.new(1, -100, 0, 20),
                Position = UDim2.new(0, 14, 0, 6),
                BackgroundTransparency = 1,
                Text = Options.Name or "Slider",
                TextColor3 = Theme.TextColor,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SliFrame
            })

            local ValBox = Utility:Create("TextBox", {
                Size = UDim2.new(0, 45, 0, 20),
                Position = UDim2.new(1, -58, 0, 6),
                BackgroundColor3 = Theme.SecondaryBackground,
                Text = tostring(Default),
                TextColor3 = Theme.OrangePrimary,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                Parent = SliFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ValBox})

            local Track = Utility:Create("TextButton", {
                Size = UDim2.new(1, -28, 0, 6),
                Position = UDim2.new(0, 14, 0, 38),
                BackgroundColor3 = Theme.SecondaryBackground,
                Text = "",
                AutoButtonColor = false,
                Parent = SliFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Track})

            local Fill = Utility:Create("Frame", {
                Size = UDim2.new(math.clamp((Default-Min)/(Max-Min), 0, 1), 0, 1, 0),
                BackgroundColor3 = Theme.OrangePrimary,
                Parent = Track
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})

            local Thumb = Utility:Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -7, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.new(1,1,1),
                Parent = Fill
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Thumb})

            local Dragging = false

            local function UpdateSlider(pct)
                local val = math.floor(Min + (pct * (Max - Min)))
                Fill.Size = UDim2.new(pct, 0, 1, 0)
                ValBox.Text = tostring(val)
                Callback(val)
            end

            local function ProcessInput(inputObj)
                local absoluteX = Track.AbsolutePosition.X
                local absoluteWidth = Track.AbsoluteSize.X
                local pct = math.clamp((inputObj.Position.X - absoluteX) / absoluteWidth, 0, 1)
                UpdateSlider(pct)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    ProcessInput(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    ProcessInput(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)

            return {
                SetValue = function(self, val)
                    UpdateSlider(math.clamp((val - Min) / (Max - Min), 0, 1))
                end
            }
        end

        -- 7. Progress Bar Element
        function Tab:CreateProgressBar(Options, parentTarget)
            local target = GetParent(parentTarget)
            local MaxVal = Options.Max or 100
            local CurrentVal = Options.Default or 0

            local ProgFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 48),
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0.2,
                Parent = target
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ProgFrame})

            local Title = Utility:Create("TextLabel", {
                Size = UDim2.new(1, -100, 0, 20),
                Position = UDim2.new(0, 14, 0, 6),
                BackgroundTransparency = 1,
                Text = Options.Name or "Progress",
                TextColor3 = Theme.TextColor,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ProgFrame
            })

            local ValDisplay = Utility:Create("TextLabel", {
                Size = UDim2.new(0, 60, 0, 20),
                Position = UDim2.new(1, -74, 0, 6),
                BackgroundTransparency = 1,
                Text = CurrentVal.."/"..MaxVal,
                TextColor3 = Theme.OrangePrimary,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = ProgFrame
            })

            local Track = Utility:Create("Frame", {
                Size = UDim2.new(1, -28, 0, 6),
                Position = UDim2.new(0, 14, 0, 32),
                BackgroundColor3 = Theme.SecondaryBackground,
                Parent = ProgFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Track})

            local Fill = Utility:Create("Frame", {
                Size = UDim2.new(math.clamp(CurrentVal/MaxVal, 0, 1), 0, 1, 0),
                BackgroundColor3 = Theme.OrangePrimary,
                Parent = Track
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})

            return {
                Update = function(self, newVal)
                    CurrentVal = math.clamp(newVal, 0, MaxVal)
                    ValDisplay.Text = CurrentVal.."/"..MaxVal
                    TweenService:Create(Fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(CurrentVal/MaxVal, 0, 1, 0)}):Play()
                end
            }
        end

        -- 8. Keybind Element
        function Tab:CreateKeybind(Options, parentTarget)
            local target = GetParent(parentTarget)
            local Callback = Options.Callback or function() end
            local CurrentKey = Options.Default or Enum.KeyCode.Unknown

            local KeyFrame = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0.2,
                Text = "",
                AutoButtonColor = false,
                Parent = target
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = KeyFrame})

            Utility:Create("TextLabel", {
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = Options.Name or "Keybind",
                TextColor3 = Theme.TextColor,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = KeyFrame
            })

            local KeyDisplay = Utility:Create("TextLabel", {
                Size = UDim2.new(0, 60, 0, 24),
                Position = UDim2.new(1, -74, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Theme.SecondaryBackground,
                Text = CurrentKey ~= Enum.KeyCode.Unknown and CurrentKey.Name or "None",
                TextColor3 = Theme.OrangePrimary,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                Parent = KeyFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KeyDisplay})

            local Listening = false
            KeyFrame.MouseButton1Click:Connect(function()
                if Listening then return end
                Listening = true
                KeyDisplay.Text = "..."
                
                local conn
                conn = UserInputService.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        CurrentKey = input.KeyCode
                        KeyDisplay.Text = CurrentKey.Name
                        Listening = false
                        conn:Disconnect()
                        Callback(CurrentKey)
                    end
                end)
            end)
            return {}
        end

        -- 9. Advanced Dropdown Element (SpeedHub Premium Style)
        function Tab:CreateDropdown(Options, parentTarget)
            local target = GetParent(parentTarget)
            local DropList = Options.Options or {}
            local MaxSelect = Options.Max or 1
            local Callback = Options.Callback or function() end
            local SelectedItems = {}

            local DropBtn = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.ElementBackground,
                BackgroundTransparency = 0.2,
                Text = "",
                AutoButtonColor = false,
                Parent = target
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DropBtn})

            Utility:Create("TextLabel", {
                Size = UDim2.new(0, 150, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = Options.Name or "Dropdown",
                TextColor3 = Theme.TextColor,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = DropBtn
            })

            local SelectedText = Utility:Create("TextLabel", {
                Size = UDim2.new(1, -200, 1, 0),
                Position = UDim2.new(0, 160, 0, 0),
                BackgroundTransparency = 1,
                Text = "None",
                TextColor3 = Theme.OrangePrimary,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = DropBtn
            })

            local Arrow = Utility:Create("ImageLabel", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -25, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Image = Theme.DropdownClosedIcon,
                ImageColor3 = Theme.TextMuted,
                Parent = DropBtn
            })

            local OverlayFrame = Utility:Create("Frame", {
                Size = UDim2.new(0, 0, 0, 200),
                BackgroundColor3 = Theme.DropdownBg,
                BackgroundTransparency = 0.1,
                Visible = false,
                ZIndex = 500,
                Parent = ScreenGui
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = OverlayFrame})
            Utility:Create("UIStroke", {Color = Theme.StrokeColor, Parent = OverlayFrame})

            local SearchWrapper = Utility:Create("Frame", {
                Size = UDim2.new(1, -20, 0, 28),
                Position = UDim2.new(0, 10, 0, 8),
                BackgroundColor3 = Theme.SecondaryBackground,
                ZIndex = 501,
                Parent = OverlayFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SearchWrapper})

            local SearchBox = Utility:Create("TextBox", {
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 25, 0, 0),
                BackgroundTransparency = 1,
                Text = "",
                PlaceholderText = "Search...",
                PlaceholderColor3 = Theme.TextMuted,
                TextColor3 = Theme.TextColor,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 502,
                Parent = SearchWrapper
            })

            local ItemScroll = Utility:Create("ScrollingFrame", {
                Size = UDim2.new(1, -10, 1, -48),
                Position = UDim2.new(0, 5, 0, 42),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.OrangePrimary,
                ZIndex = 501,
                Parent = OverlayFrame
            })
            Utility:Create("UIListLayout", {Padding = UDim.new(0, 4), Parent = ItemScroll})

            local isOpen = false
            local function RefreshList(filter)
                for _, c in ipairs(ItemScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                ItemScroll.CanvasSize = UDim2.new(0,0,0,0)
                ItemScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

                for _, item in ipairs(DropList) do
                    if not filter or filter == "" or string.find(string.lower(item), string.lower(filter)) then
                        local isSel = table.find(SelectedItems, item) ~= nil
                        local ibtn = Utility:Create("TextButton", {
                            Size = UDim2.new(1, -10, 0, 28),
                            BackgroundColor3 = isSel and Theme.HoverElement or Theme.DropdownItem,
                            Text = item,
                            TextColor3 = isSel and Theme.OrangePrimary or Theme.TextColor,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 12,
                            ZIndex = 502,
                            Parent = ItemScroll
                        })
                        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ibtn})

                        ibtn.MouseButton1Click:Connect(function()
                            if MaxSelect == 1 then
                                SelectedItems = {item}
                                isOpen = false
                                OverlayFrame.Visible = false
                                TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                            else
                                local idx = table.find(SelectedItems, item)
                                if idx then table.remove(SelectedItems, idx) else table.insert(SelectedItems, item) end
                            end
                            SelectedText.Text = #SelectedItems > 0 and table.concat(SelectedItems, ", ") or "None"
                            RefreshList(SearchBox.Text)
                            Callback(MaxSelect == 1 and SelectedItems[1] or SelectedItems)
                        end)
                    end
                end
            end

            SearchBox:GetPropertyChangedSignal("Text"):Connect(function() RefreshList(SearchBox.Text) end)

            DropBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    OverlayFrame.Position = UDim2.new(0, DropBtn.AbsolutePosition.X, 0, DropBtn.AbsolutePosition.Y + DropBtn.AbsoluteSize.Y + 4)
                    OverlayFrame.Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, 180)
                    RefreshList()
                    OverlayFrame.Visible = true
                    TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
                else
                    OverlayFrame.Visible = false
                    TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                end
            end)
            return {}
        end

        return Tab
    end
    return Window
end

return AxisUI
