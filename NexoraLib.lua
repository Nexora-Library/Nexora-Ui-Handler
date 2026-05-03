local NexoraLib = {}
NexoraLib.__index = NexoraLib

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

NexoraLib.Theme = {
    BgBase = Color3.fromRGB(13, 13, 15),
    BgSurface = Color3.fromRGB(18, 18, 22),
    BgPanel = Color3.fromRGB(22, 22, 28),
    BgElement = Color3.fromRGB(28, 28, 36),
    BgHover = Color3.fromRGB(34, 34, 44),
    Border = Color3.fromRGB(42, 42, 54),
    BorderFocus = Color3.fromRGB(62, 62, 82),
    Accent = Color3.fromRGB(124, 106, 247),
    AccentDim = Color3.fromRGB(90, 79, 212),
    AccentDark = Color3.fromRGB(30, 26, 60),
    TextPrimary = Color3.fromRGB(232, 232, 240),
    TextSecondary = Color3.fromRGB(152, 152, 176),
    TextMuted = Color3.fromRGB(85, 85, 106),
    Success = Color3.fromRGB(74, 247, 154),
    Warning = Color3.fromRGB(247, 196, 74),
    Danger = Color3.fromRGB(247, 106, 106),
    Font = Enum.Font.GothamMedium,
    FontLight = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMono = Enum.Font.Code,
    CornerRadius = UDim.new(0, 8),
    CornerSm = UDim.new(0, 5),
    CornerLg = UDim.new(0, 12),
}

local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function New(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function Corner(radius)
    return New("UICorner", { CornerRadius = radius or NexoraLib.Theme.CornerRadius })
end

local function Stroke(color, thickness)
    return New("UIStroke", {
        Color = color or NexoraLib.Theme.Border,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function Padding(top, right, bottom, left)
    return New("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft = UDim.new(0, left or 0),
    })
end

local function ListLayout(dir, align, spacing)
    return New("UIListLayout", {
        FillDirection = dir or Enum.FillDirection.Vertical,
        HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, spacing or 0),
    })
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local NotifHolder

local function EnsureNotifHolder()
    if NotifHolder and NotifHolder.Parent then return end
    local sg = New("ScreenGui", {
        Name = "test",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
    })
    NotifHolder = New("Frame", {
        Name = "test",
        Size = UDim2.new(0, 280, 1, 0),
        Position = UDim2.new(1, -290, 0, 0),
        BackgroundTransparency = 1,
        Parent = sg,
    }, {
        ListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, 8),
        Padding(12, 0, 0, 0),
    })
    NotifHolder.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

function NexoraLib:Notify(opts)
    opts = opts or {}
    EnsureNotifHolder()
    local T = self.Theme

    local icons = { info = "ℹ", success = "✓", warning = "⚠", error = "✕" }
    local colors = {
        info = T.Accent,
        success = T.Success,
        warning = T.Warning,
        error = T.Danger,
    }
    local kind = opts.Type or "info"
    local icon = icons[kind] or icons.info
    local color = colors[kind] or colors.info
    local dur = opts.Duration or 4

    local card = New("Frame", {
        Name = "test",
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = T.BgPanel,
        ClipsDescendants = true,
        Parent = NotifHolder,
    }, { Corner(T.CornerSm), Stroke(T.Border) })

    New("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = card,
    }, { New("UICorner", { CornerRadius = UDim.new(0,2) }) })

    New("TextLabel", {
        Size = UDim2.new(0, 32, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = icon,
        TextColor3 = color,
        Font = T.FontBold,
        TextSize = 16,
        Parent = card,
    })

    local txtBlock = New("Frame", {
        Size = UDim2.new(1, -46, 1, 0),
        Position = UDim2.new(0, 42, 0, 0),
        BackgroundTransparency = 1,
        Parent = card,
    }, { ListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 2),
         Padding(10, 0, 0, 0) })

    New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = opts.Title or "test",
        TextColor3 = T.TextPrimary,
        Font = T.FontBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = txtBlock,
    })
    New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = opts.Content or "",
        TextColor3 = T.TextSecondary,
        Font = T.FontLight,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = txtBlock,
    })

    local bar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = card,
    })

    card.Position = UDim2.new(0, 20, 0, 0)
    card.BackgroundTransparency = 1
    Tween(card, { Position = UDim2.new(0,0,0,0), BackgroundTransparency = 0 }, 0.25)
    Tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, dur, Enum.EasingStyle.Linear)

    task.delay(dur, function()
        Tween(card, { Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1 }, 0.25)
        task.wait(0.3)
        card:Destroy()
    end)
end

function NexoraLib:CreateWindow(opts)
    opts = opts or {}
    local T = self.Theme

    local ScreenGui = New("ScreenGui", {
        Name = "test",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
    })

    local Main = New("Frame", {
        Name = "test",
        Size = UDim2.new(0, 580, 0, 420),
        Position = UDim2.new(0.5, -290, 0.5, -210),
        BackgroundColor3 = T.BgSurface,
        ClipsDescendants = false,
        Parent = ScreenGui,
    }, { Corner(T.CornerLg), Stroke(T.Border) })

    New("ImageLabel", {
        Name = "test",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49,49,450,450),
        ZIndex = 0,
        Parent = Main,
    })

    local TitleBar = New("Frame", {
        Name = "test",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = T.BgPanel,
        ZIndex = 2,
        Parent = Main,
    }, { Corner(T.CornerLg), Stroke(T.Border) })

    New("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = T.BgPanel,
        BorderSizePixel = 0,
        Parent = TitleBar,
    })

    local Logo = New("Frame", {
        Name = "test",
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 10, 0.5, -11),
        BackgroundColor3 = T.Accent,
        Parent = TitleBar,
    }, { Corner(UDim.new(0,5)) })

    New("TextLabel", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = string.sub(opts.Title or "test", 1, 1),
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = T.FontBold,
        TextSize = 12,
        Parent = Logo,
    })

    New("TextLabel", {
        Name = "test",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 38, 0, 0),
        BackgroundTransparency = 1,
        Text = (opts.Title or "test"),
        TextColor3 = T.TextPrimary,
        Font = T.FontBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar,
    })

    if opts.Subtitle then
        New("TextLabel", {
            Name = "test",
            Size = UDim2.new(0, 50, 0, 16),
            Position = UDim2.new(0, 38 + 110, 0.5, -8),
            BackgroundColor3 = T.AccentDark,
            Text = opts.Subtitle,
            TextColor3 = T.Accent,
            Font = T.FontMono,
            TextSize = 9,
            Parent = TitleBar,
        }, { Corner(UDim.new(0,3)), Stroke(Color3.fromRGB(80,65,180)) })
    end

    local CtrlFrame = New("Frame", {
        Name = "test",
        Size = UDim2.new(0, 60, 0, 12),
        Position = UDim2.new(1, -70, 0.5, -6),
        BackgroundTransparency = 1,
        Parent = TitleBar,
    }, { ListLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, 6) })

    local function WinBtn(color, callback)
        local btn = New("TextButton", {
            Size = UDim2.new(0, 12, 0, 12),
            BackgroundColor3 = color,
            Text = "",
            Parent = CtrlFrame,
        }, { Corner(UDim.new(0.5, 0)) })
        btn.MouseButton1Click:Connect(callback or function() end)
        btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency=0.3}, 0.1) end)
        btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency=0}, 0.1) end)
        return btn
    end

    local minimized = false
    local ContentHolder

    WinBtn(T.Danger, function()
        Tween(Main, {Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0), BackgroundTransparency=1}, 0.2)
        task.wait(0.22)
        ScreenGui:Destroy()
    end)
    WinBtn(T.Warning, function()
        minimized = not minimized
        if minimized then
            Tween(Main, {Size=UDim2.new(0,580,0,38)}, 0.2, Enum.EasingStyle.Back)
        else
            Tween(Main, {Size=UDim2.new(0,580,0,420)}, 0.2, Enum.EasingStyle.Back)
        end
    end)
    WinBtn(T.Success, function() end)

    MakeDraggable(Main, TitleBar)

    local TabBar = New("Frame", {
        Name = "test",
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundColor3 = T.BgPanel,
        ClipsDescendants = true,
        Parent = Main,
    }, {
        Stroke(T.Border),
        ListLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 0),
        Padding(0, 10, 0, 10),
    })

    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        BorderSizePixel = 0,
        Parent = TabBar,
    })

    ContentHolder = New("Frame", {
        Name = "test",
        Size = UDim2.new(1, 0, 1, -70),
        Position = UDim2.new(0, 0, 0, 70),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = Main,
    })

    local StatusBar = New("Frame", {
        Name = "test",
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 1, -22),
        BackgroundColor3 = T.BgPanel,
        Parent = Main,
    }, { Stroke(T.Border) })

    New("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = T.BgPanel,
        BorderSizePixel = 0,
        Parent = StatusBar,
    })

    local StatusDot = New("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 10, 0.5, -3),
        BackgroundColor3 = T.Success,
        Parent = StatusBar,
    }, { Corner(UDim.new(0.5,0)) })

    task.spawn(function()
        while StatusDot and StatusDot.Parent do
            Tween(StatusDot, {BackgroundTransparency=0.6}, 0.8, Enum.EasingStyle.Sine)
            task.wait(0.8)
            Tween(StatusDot, {BackgroundTransparency=0}, 0.8, Enum.EasingStyle.Sine)
            task.wait(0.8)
        end
    end)

    New("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 22, 0, 0),
        BackgroundTransparency = 1,
        Text = "test  ·  " .. (opts.Title or "test"),
        TextColor3 = T.TextMuted,
        Font = T.FontMono,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = StatusBar,
    })

    New("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(1, -210, 0, 0),
        BackgroundTransparency = 1,
        Text = "test",
        TextColor3 = T.TextMuted,
        Font = T.FontMono,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = StatusBar,
    })

    local Window = { Theme = T, Tabs = {}, ActiveTab = nil }

    function Window:AddTab(tabOpts)
        tabOpts = tabOpts or {}
        local tabName = tabOpts.Name or "test"

        local TabBtn = New("TextButton", {
            Name = tabName,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = "",
            Parent = TabBar,
        })

        local TabInner = New("Frame", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Parent = TabBtn,
        }, {
            Padding(0, 14, 0, 14),
            ListLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 5),
        })

        local TabLabel = New("TextLabel", {
            Size = UDim2.new(0,0,1,0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = T.TextMuted,
            Font = T.Font,
            TextSize = 12,
            Parent = TabInner,
        })

        local Underline = New("Frame", {
            Name = "test",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = TabBtn,
        })

        local TabContent = New("ScrollingFrame", {
            Name = tabName .. "test",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.Border,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentHolder,
        }, {
            ListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 8),
            Padding(10, 10, 10, 10),
        })

        local function Activate()
            for _, t in pairs(Window.Tabs) do
                Tween(t.Label, {TextColor3 = T.TextMuted}, 0.15)
                Tween(t.Underline, {BackgroundTransparency = 1}, 0.15)
                t.Content.Visible = false
            end
            Tween(TabLabel, {TextColor3 = T.Accent}, 0.15)
            Tween(Underline, {BackgroundTransparency = 0}, 0.15)
            TabContent.Visible = true
            Window.ActiveTab = tabName
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        TabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= tabName then
                Tween(TabLabel, {TextColor3 = T.TextSecondary}, 0.1)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= tabName then
                Tween(TabLabel, {TextColor3 = T.TextMuted}, 0.1)
            end
        end)

        local tabObj = {
            Name = tabName,
            Button = TabBtn,
            Label = TabLabel,
            Underline = Underline,
            Content = TabContent,
        }
        table.insert(Window.Tabs, tabObj)

        if #Window.Tabs == 1 then
            Activate()
        end

        local Tab = { Theme = T, Content = TabContent }

        function Tab:AddSection(secOpts)
            secOpts = secOpts or {}
            local secName = secOpts.Name or "test"

            local SectionFrame = New("Frame", {
                Name = secName,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = T.BgPanel,
                Parent = TabContent,
            }, { Corner(T.CornerRadius), Stroke(T.Border) })

            local SectionHeader = New("Frame", {
                Name = "test",
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Parent = SectionFrame,
            })

            New("Frame", {
                Size = UDim2.new(0, 2, 0, 12),
                Position = UDim2.new(0, 10, 0.5, -6),
                BackgroundColor3 = T.Accent,
                BorderSizePixel = 0,
                Parent = SectionHeader,
            }, { Corner(UDim.new(0,1)) })

            New("TextLabel", {
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 18, 0, 0),
                BackgroundTransparency = 1,
                Text = string.upper(secName),
                TextColor3 = T.TextSecondary,
                Font = T.FontBold,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                LetterSpacing = 2,
                Parent = SectionHeader,
            })

            New("Frame", {
                Size = UDim2.new(1, -20, 0, 1),
                Position = UDim2.new(0, 10, 0, 28),
                BackgroundColor3 = T.Border,
                BorderSizePixel = 0,
                Parent = SectionFrame,
            })

            local SectionBody = New("Frame", {
                Name = "test",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 29),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = SectionFrame,
            }, {
                ListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 0),
                Padding(4, 0, 6, 0),
            })

            local Section = { Theme = T, Body = SectionBody }

            local function MakeRow()
                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1,
                    Parent = SectionBody,
                })
                row.MouseEnter:Connect(function()
                    Tween(row, {BackgroundColor3=T.BgHover, BackgroundTransparency=0.7}, 0.1)
                end)
                row.MouseLeave:Connect(function()
                    Tween(row, {BackgroundTransparency=1}, 0.1)
                end)
                return row
            end

            function Section:AddToggle(opts)
                opts = opts or {}
                local value = opts.Default or false
                local row = MakeRow()

                New("TextLabel", {
                    Size = UDim2.new(1, -56, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Name or "test",
                    TextColor3 = T.TextPrimary,
                    Font = T.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })

                local Track = New("Frame", {
                    Size = UDim2.new(0, 34, 0, 18),
                    Position = UDim2.new(1, -46, 0.5, -9),
                    BackgroundColor3 = T.BgElement,
                    Parent = row,
                }, { Corner(UDim.new(0,9)), Stroke(T.Border) })

                local Knob = New("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, 2, 0.5, -6),
                    BackgroundColor3 = T.TextMuted,
                    Parent = Track,
                }, { Corner(UDim.new(0.5,0)) })

                local function SetToggle(v)
                    value = v
                    if v then
                        Tween(Track, {BackgroundColor3=T.AccentDark}, 0.15)
                        Tween(Knob, {Position=UDim2.new(0,20,0.5,-6), BackgroundColor3=T.Accent}, 0.15)
                        Track.UIStroke.Color = T.Accent
                    else
                        Tween(Track, {BackgroundColor3=T.BgElement}, 0.15)
                        Tween(Knob, {Position=UDim2.new(0,2,0.5,-6), BackgroundColor3=T.TextMuted}, 0.15)
                        Track.UIStroke.Color = T.Border
                    end
                    if opts.Callback then opts.Callback(value) end
                end

                SetToggle(value)

                local ToggleBtn = New("TextButton", {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = row,
                })
                ToggleBtn.MouseButton1Click:Connect(function()
                    SetToggle(not value)
                end)

                return {
                    Set = SetToggle,
                    Get = function() return value end,
                }
            end

            function Section:AddSlider(opts)
                opts = opts or {}
                local min = opts.Min or 0
                local max = opts.Max or 100
                local value = opts.Default or min
                local suffix = opts.Suffix or ""

                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    Parent = SectionBody,
                })
                row.MouseEnter:Connect(function()
                    Tween(row, {BackgroundColor3=T.BgHover, BackgroundTransparency=0.7}, 0.1)
                end)
                row.MouseLeave:Connect(function()
                    Tween(row, {BackgroundTransparency=1}, 0.1)
                end)

                local TopRow = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Parent = row,
                })
                New("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Name or "test",
                    TextColor3 = T.TextPrimary,
                    Font = T.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TopRow,
                })
                local ValLabel = New("TextLabel", {
                    Size = UDim2.new(0, 50, 1, 0),
                    Position = UDim2.new(1, -62, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value) .. suffix,
                    TextColor3 = T.Accent,
                    Font = T.FontMono,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = TopRow,
                })

                local TrackBg = New("Frame", {
                    Size = UDim2.new(1, -24, 0, 3),
                    Position = UDim2.new(0, 12, 0, 28),
                    BackgroundColor3 = T.BgElement,
                    Parent = row,
                }, { Corner(UDim.new(0,2)) })

                local Fill = New("Frame", {
                    Size = UDim2.new((value-min)/(max-min), 0, 1, 0),
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel = 0,
                    Parent = TrackBg,
                }, { Corner(UDim.new(0,2)) })

                local Knob = New("Frame", {
                    Size = UDim2.new(0,13,0,13),
                    Position = UDim2.new((value-min)/(max-min),0,0.5,-6),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    BackgroundColor3 = T.Accent,
                    Parent = TrackBg,
                }, { Corner(UDim.new(0.5,0)) })

                local function SetSlider(v)
                    v = math.clamp(math.round(v), min, max)
                    value = v
                    local pct = (v - min) / (max - min)
                    Tween(Fill, {Size=UDim2.new(pct,0,1,0)}, 0.05)
                    Tween(Knob, {Position=UDim2.new(pct,0,0.5,-6)}, 0.05)
                    ValLabel.Text = tostring(v) .. suffix
                    if opts.Callback then opts.Callback(v) end
                end

                local draggingSlider = false
                local SliderBtn = New("TextButton", {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = TrackBg,
                })
                SliderBtn.MouseButton1Down:Connect(function()
                    draggingSlider = true
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)
                RunService.RenderStepped:Connect(function()
                    if draggingSlider then
                        local rel = Mouse.X - TrackBg.AbsolutePosition.X
                        local pct = math.clamp(rel / TrackBg.AbsoluteSize.X, 0, 1)
                        SetSlider(min + (max - min) * pct)
                    end
                end)

                SetSlider(value)

                return {
                    Set = SetSlider,
                    Get = function() return value end,
                }
            end

            function Section:AddDropdown(opts)
                opts = opts or {}
                local options = opts.Options or {}
                local value = opts.Default or (options[1] or "")
                local open = false

                local Wrapper = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1,
                    ZIndex = 5,
                    Parent = SectionBody,
                })

                New("TextLabel", {
                    Size = UDim2.new(0.45, -12, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Name or "test",
                    TextColor3 = T.TextPrimary,
                    Font = T.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = Wrapper,
                })

                local DdFrame = New("Frame", {
                    Size = UDim2.new(0.55, -12, 0, 22),
                    Position = UDim2.new(0.45, 0, 0.5, -11),
                    BackgroundColor3 = T.BgElement,
                    ZIndex = 5,
                    Parent = Wrapper,
                }, { Corner(T.CornerSm), Stroke(T.Border) })

                local CurrentLabel = New("TextLabel", {
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = value,
                    TextColor3 = T.TextPrimary,
                    Font = T.Font,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                    Parent = DdFrame,
                })

                local Arrow = New("TextLabel", {
                    Size = UDim2.new(0, 16, 1, 0),
                    Position = UDim2.new(1, -18, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▾",
                    TextColor3 = T.TextMuted,
                    Font = T.FontBold,
                    TextSize = 12,
                    ZIndex = 6,
                    Parent = DdFrame,
                })

                local Menu = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 4),
                    BackgroundColor3 = T.BgPanel,
                    ClipsDescendants = true,
                    ZIndex = 20,
                    Visible = false,
                    Parent = DdFrame,
                }, { Corner(T.CornerSm), Stroke(T.Border) })

                local MenuList = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    ZIndex = 20,
                    Parent = Menu,
                }, { ListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 0) })

                local function BuildMenu()
                    for _, child in pairs(MenuList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local Item = New("TextButton", {
                            Size = UDim2.new(1, 0, 0, 24),
                            BackgroundTransparency = 1,
                            Text = opt,
                            TextColor3 = opt == value and T.Accent or T.TextSecondary,
                            Font = T.Font,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 21,
                            Parent = MenuList,
                        }, { Padding(0,0,0,8) })
                        Item.MouseEnter:Connect(function()
                            Tween(Item, {BackgroundTransparency=0.7, BackgroundColor3=T.BgHover}, 0.1)
                        end)
                        Item.MouseLeave:Connect(function()
                            Tween(Item, {BackgroundTransparency=1}, 0.1)
                        end)
                        Item.MouseButton1Click:Connect(function()
                            value = opt
                            CurrentLabel.Text = opt
                            BuildMenu()
                            open = false
                            Tween(Arrow, {Rotation=0}, 0.15)
                            Tween(Menu, {Size=UDim2.new(1,0,0,0)}, 0.15)
                            task.wait(0.15)
                            Menu.Visible = false
                            if opts.Callback then opts.Callback(value) end
                        end)
                    end
                end

                BuildMenu()

                local DdBtn = New("TextButton", {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 7,
                    Parent = DdFrame,
                })
                DdBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        Menu.Visible = true
                        local targetH = math.min(#options * 24, 120)
                        Tween(Arrow, {Rotation=180}, 0.15)
                        Tween(Menu, {Size=UDim2.new(1,0,0,targetH)}, 0.15)
                    else
                        Tween(Arrow, {Rotation=0}, 0.15)
                        Tween(Menu, {Size=UDim2.new(1,0,0,0)}, 0.15)
                        task.wait(0.15)
                        Menu.Visible = false
                    end
                end)

                return {
                    Set = function(v)
                        value = v
                        CurrentLabel.Text = v
                        BuildMenu()
                        if opts.Callback then opts.Callback(v) end
                    end,
                    Get = function() return value end,
                    Refresh = function(newOptions)
                        options = newOptions
                        BuildMenu()
                    end,
                }
            end

            function Section:AddTextbox(opts)
                opts = opts or {}
                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1,
                    Parent = SectionBody,
                })

                New("TextLabel", {
                    Size = UDim2.new(0.4, -12, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Name or "test",
                    TextColor3 = T.TextPrimary,
                    Font = T.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })

                local Box = New("TextBox", {
                    Size = UDim2.new(0.6, -12, 0, 22),
                    Position = UDim2.new(0.4, 0, 0.5, -11),
                    BackgroundColor3 = T.BgElement,
                    Text = opts.Default or "",
                    PlaceholderText = opts.Placeholder or "...",
                    TextColor3 = T.TextPrimary,
                    PlaceholderColor3 = T.TextMuted,
                    Font = T.Font,
                    TextSize = 11,
                    ClearTextOnFocus = opts.ClearOnFocus ~= false,
                    Parent = row,
                }, { Corner(T.CornerSm), Stroke(T.Border) })

                Box.Focused:Connect(function()
                    Tween(Box.UIStroke, {Color=T.Accent}, 0.15)
                end)
                Box.FocusLost:Connect(function(enter)
                    Tween(Box.UIStroke, {Color=T.Border}, 0.15)
                    if opts.Callback then opts.Callback(Box.Text, enter) end
                end)

                return {
                    Get = function() return Box.Text end,
                    Set = function(v) Box.Text = v end,
                }
            end

            function Section:AddButton(opts)
                opts = opts or {}
                local row = MakeRow()

                local Btn = New("TextButton", {
                    Size = UDim2.new(1, -24, 0, 22),
                    Position = UDim2.new(0, 12, 0.5, -11),
                    BackgroundColor3 = opts.Style == "danger" and Color3.fromRGB(60,20,20)
                                    or opts.Style == "ghost" and T.BgElement
                                    or T.AccentDark,
                    Text = opts.Name or "test",
                    TextColor3 = opts.Style == "danger" and T.Danger
                                    or opts.Style == "ghost" and T.TextSecondary
                                    or T.Accent,
                    Font = T.Font,
                    TextSize = 12,
                    Parent = row,
                }, {
                    Corner(T.CornerSm),
                    Stroke(opts.Style == "danger" and Color3.fromRGB(120,40,40)
                        or opts.Style == "ghost" and T.Border
                        or Color3.fromRGB(80,65,180)),
                })

                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, {Size=UDim2.new(1,-28,0,20)}, 0.07)
                    task.wait(0.07)
                    Tween(Btn, {Size=UDim2.new(1,-24,0,22)}, 0.1)
                    if opts.Callback then opts.Callback() end
                end)
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {BackgroundTransparency=0.3}, 0.1)
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {BackgroundTransparency=0}, 0.1)
                end)

                return Btn
            end

            function Section:AddColorPicker(opts)
                opts = opts or {}
                local color = opts.Default or Color3.fromRGB(124,106,247)
                local hue, sat, val = Color3.toHSV(color)

                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1,
                    Parent = SectionBody,
                })

                New("TextLabel", {
                    Size = UDim2.new(1, -56, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Name or "test",
                    TextColor3 = T.TextPrimary,
                    Font = T.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })

                local Swatch = New("Frame", {
                    Size = UDim2.new(0, 28, 0, 18),
                    Position = UDim2.new(1, -40, 0.5, -9),
                    BackgroundColor3 = color,
                    Parent = row,
                }, { Corner(T.CornerSm), Stroke(T.Border) })

                local PickerFrame = New("Frame", {
                    Size = UDim2.new(0, 180, 0, 170),
                    Position = UDim2.new(1, -190, 1, 4),
                    BackgroundColor3 = T.BgPanel,
                    Visible = false,
                    ZIndex = 30,
                    Parent = row,
                }, { Corner(T.CornerRadius), Stroke(T.Border) })

                Padding(8,8,8,8)

                local HueBar = New("Frame", {
                    Size = UDim2.new(1,-16,0,10),
                    Position = UDim2.new(0,8,0,8),
                    ZIndex = 31,
                    Parent = PickerFrame,
                }, { Corner(UDim.new(0,3)) })

                local HueGrad = New("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167,1,1)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333,1,1)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667,1,1)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833,1,1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1)),
                    }),
                    Parent = HueBar,
                })

                local HueKnob = New("Frame", {
                    Size = UDim2.new(0,4,1,0),
                    Position = UDim2.new(hue,0,0,0),
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    ZIndex = 32,
                    Parent = HueBar,
                }, { Corner(UDim.new(0,2)) })

                local SVFrame = New("Frame", {
                    Size = UDim2.new(1,-16,0,100),
                    Position = UDim2.new(0,8,0,24),
                    ZIndex = 31,
                    Parent = PickerFrame,
                }, { Corner(UDim.new(0,4)) })

                local SVColor = New("UIGradient", {
                    Color = ColorSequence.new(Color3.fromHSV(hue,1,1), Color3.fromRGB(255,255,255)),
                    Parent = SVFrame,
                })
                local SVDark = New("Frame", {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundColor3 = Color3.fromRGB(0,0,0),
                    BackgroundTransparency = 1-val,
                    ZIndex = 32,
                    Parent = SVFrame,
                }, { Corner(UDim.new(0,4)) })

                local SVGradY = New("UIGradient", {
                    Color = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(255,255,255)),
                    Rotation = 90,
                    Parent = SVDark,
                })

                local SVKnob = New("Frame", {
                    Size = UDim2.new(0,10,0,10),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    Position = UDim2.new(sat, 0, 1-val, 0),
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    ZIndex = 33,
                    Parent = SVFrame,
                }, { Corner(UDim.new(0.5,0)) })

                local function ToHex(c)
                    return string.format("#%02X%02X%02X",
                        math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
                end

                local HexLabel = New("TextBox", {
                    Size = UDim2.new(1,-16,0,20),
                    Position = UDim2.new(0,8,0,130),
                    BackgroundColor3 = T.BgElement,
                    Text = ToHex(color),
                    TextColor3 = T.TextPrimary,
                    Font = T.FontMono,
                    TextSize = 11,
                    ZIndex = 31,
                    Parent = PickerFrame,
                }, { Corner(T.CornerSm), Stroke(T.Border) })

                local function UpdateColor()
                    color = Color3.fromHSV(hue, sat, val)
                    Swatch.BackgroundColor3 = color
                    SVColor.Color = ColorSequence.new(Color3.fromHSV(hue,1,1), Color3.fromRGB(255,255,255))
                    HueKnob.Position = UDim2.new(hue, 0, 0, 0)
                    SVKnob.Position = UDim2.new(sat, 0, 1-val, 0)
                    SVDark.BackgroundTransparency = 1 - val
                    HexLabel.Text = ToHex(color)
                    if opts.Callback then opts.Callback(color) end
                end

                local dragHue = false
                local HueBtn = New("TextButton", {
                    Size = UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=33, Parent=HueBar
                })
                HueBtn.MouseButton1Down:Connect(function() dragHue = true end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragHue = false end
                end)
                RunService.RenderStepped:Connect(function()
                    if dragHue then
                        hue = math.clamp((Mouse.X - HueBar.AbsolutePosition.X)/HueBar.AbsoluteSize.X,0,1)
                        UpdateColor()
                    end
                end)

                local dragSV = false
                local SVBtn = New("TextButton", {
                    Size = UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=34, Parent=SVFrame
                })
                SVBtn.MouseButton1Down:Connect(function() dragSV = true end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragSV = false end
                end)
                RunService.RenderStepped:Connect(function()
                    if dragSV then
                        sat = math.clamp((Mouse.X - SVFrame.AbsolutePosition.X)/SVFrame.AbsoluteSize.X,0,1)
                        val = 1 - math.clamp((Mouse.Y - SVFrame.AbsolutePosition.Y)/SVFrame.AbsoluteSize.Y,0,1)
                        UpdateColor()
                    end
                end)

                local pickerOpen = false
                local SwatchBtn = New("TextButton", {
                    Size = UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=5, Parent=Swatch
                })
                SwatchBtn.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    PickerFrame.Visible = pickerOpen
                end)

                return {
                    Get = function() return color end,
                    Set = function(c)
                        color = c
                        hue, sat, val = Color3.toHSV(c)
                        Swatch.BackgroundColor3 = c
                        UpdateColor()
                    end,
                }
            end

            function Section:AddKeybind(opts)
                opts = opts or {}
                local key = opts.Default or Enum.KeyCode.Unknown
                local listening = false

                local row = MakeRow()

                New("TextLabel", {
                    Size = UDim2.new(1, -80, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Name or "test",
                    TextColor3 = T.TextPrimary,
                    Font = T.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })

                local KeyBtn = New("TextButton", {
                    Size = UDim2.new(0, 60, 0, 20),
                    Position = UDim2.new(1, -72, 0.5, -10),
                    BackgroundColor3 = T.BgElement,
                    Text = key.Name or "test",
                    TextColor3 = T.TextSecondary,
                    Font = T.FontMono,
                    TextSize = 10,
                    Parent = row,
                }, { Corner(T.CornerSm), Stroke(T.Border) })

                KeyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    KeyBtn.Text = "..."
                    Tween(KeyBtn.UIStroke, {Color=T.Accent}, 0.15)
                end)

                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                        key = inp.KeyCode
                        listening = false
                        KeyBtn.Text = key.Name
                        Tween(KeyBtn.UIStroke, {Color=T.Border}, 0.15)
                        if opts.Callback then opts.Callback(key) end
                    end
                end)

                return {
                    Get = function() return key end,
                    Set = function(k) key = k; KeyBtn.Text = k.Name end,
                }
            end

            function Section:AddLabel(opts)
                opts = opts or {}
                local lbl = New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    Text = opts.Text or "",
                    TextColor3 = opts.Color or T.TextMuted,
                    Font = opts.Bold and T.FontBold or T.FontLight,
                    TextSize = opts.Size or 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = SectionBody,
                }, { Padding(0,12,0,12) })
                return {
                    Set = function(v) lbl.Text = v end,
                }
            end

            function Section:AddSeparator()
                New("Frame", {
                    Size = UDim2.new(1, -24, 0, 1),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundColor3 = T.Border,
                    BorderSizePixel = 0,
                    Parent = SectionBody,
                })
            end

            return Section
        end

        return Tab
    end

    function Window:Notify(opts)
        NexoraLib:Notify(opts)
    end

    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightAlt
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if inp.KeyCode == toggleKey then
            Main.Visible = not Main.Visible
        end
    end)

    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.BackgroundTransparency = 1
    Tween(Main, {Size=UDim2.new(0,580,0,420), BackgroundTransparency=0}, 0.25, Enum.EasingStyle.Back)

    return Window
end

return NexoraLib
