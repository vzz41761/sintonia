-- cobble hills UI (Safe Mode)
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Config = getgenv().CobbleConfig
if not Config then return end

local Theme = { Bg = Color3.fromRGB(16, 18, 25), Sidebar = Color3.fromRGB(22, 24, 33), Surface = Color3.fromRGB(30, 33, 45), Text = Color3.fromRGB(240, 242, 250), Muted = Color3.fromRGB(120, 126, 145), Accent = Color3.fromRGB(90, 140, 255), Off = Color3.fromRGB(40, 44, 58), Danger = Color3.fromRGB(255, 80, 80) }
local function Tween(i, p, t) TweenService:Create(i, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad), p):Play() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "CobbleMaster"; Gui.ResetOnSpawn = false; Gui.IgnoreGuiInset = true
local ok, hui = pcall(function() return gethui and gethui() end)
Gui.Parent = (ok and hui) or game:GetService("CoreGui")
getgenv().Cobble_UI_Loaded = Gui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(500, 420)
Main.Position = UDim2.new(0.5, -250, 0.5, -210)
Main.BackgroundColor3 = Theme.Bg; Main.BorderSizePixel = 0; Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,50); TitleBar.BackgroundTransparency = 1; TitleBar.Parent = Main
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1,-30,1,0); TitleText.Position = UDim2.fromOffset(20,0)
TitleText.BackgroundTransparency = 1; TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "COBBLE <font color='#5A8CFF'>SAFE</font>"
TitleText.RichText = true; TitleText.TextColor3 = Theme.Text; TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left; TitleText.Parent = TitleBar

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,130,1,-70); Sidebar.Position = UDim2.new(0,15,0,55)
Sidebar.BackgroundColor3 = Theme.Sidebar; Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,10)

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1,-20,1,-20); TabContainer.Position = UDim2.new(0,10,0,10)
TabContainer.BackgroundTransparency = 1; TabContainer.Parent = Sidebar
Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0,8)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-160,1,-70); Content.Position = UDim2.new(0,155,0,55)
Content.BackgroundColor3 = Theme.Sidebar; Content.Parent = Main
Instance.new("UICorner", Content).CornerRadius = UDim.new(0,10)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,-20,1,-20); Scroll.Position = UDim2.new(0,10,0,10)
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Theme.Accent; Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.Parent = Content
local ScrollLayout = Instance.new("UIListLayout", Scroll)
ScrollLayout.Padding = UDim.new(0,8)
ScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0,0,0, ScrollLayout.AbsoluteContentSize.Y + 10)
end)

local function CreateTab(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,36); b.BackgroundColor3 = Theme.Bg
    b.Font = Enum.Font.GothamMedium; b.Text = text
    b.TextColor3 = Theme.Muted; b.TextSize = 13; b.AutoButtonColor = false
    b.Parent = TabContainer; Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local function CreateSection(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,20); l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold; l.Text = text
    l.TextColor3 = Theme.Muted; l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = Scroll
end

local function CreateToggle(text, get, set)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,30); row.BackgroundTransparency = 1; row.Parent = Scroll
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-60,1,0); lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium; lbl.Text = text
    lbl.TextColor3 = Theme.Text; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row
    local track = Instance.new("Frame")
    track.AnchorPoint = Vector2.new(1,0.5); track.Position = UDim2.new(1,0,0.5,0)
    track.Size = UDim2.fromOffset(36,18); track.BackgroundColor3 = Theme.Off; track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(14,14); dot.Position = UDim2.fromOffset(2,2)
    dot.BackgroundColor3 = Theme.Muted; dot.Parent = track
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1,1); btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = row
    local function Refresh()
        if get() then
            Tween(track, {BackgroundColor3 = Theme.Accent})
            Tween(dot, {Position = UDim2.fromOffset(20,2), BackgroundColor3 = Color3.new(1,1,1)})
        else
            Tween(track, {BackgroundColor3 = Theme.Off})
            Tween(dot, {Position = UDim2.fromOffset(2,2), BackgroundColor3 = Theme.Muted})
        end
    end
    btn.MouseButton1Click:Connect(function() set(not get()); Refresh() end)
    Refresh()
end

local function CreateSlider(text, minv, maxv, get, set, step)
    step = step or 1
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,0,0,44); holder.BackgroundTransparency = 1; holder.Parent = Scroll
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-50,0,16); lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium; lbl.Text = text
    lbl.TextColor3 = Theme.Text; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = holder
    local val = Instance.new("TextLabel")
    val.Size = UDim2.fromOffset(50,16); val.Position = UDim2.new(1,-50,0,0)
    val.BackgroundTransparency = 1; val.Font = Enum.Font.Gotham
    val.TextColor3 = Theme.Accent; val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Right; val.Parent = holder
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1,0,0,6); track.Position = UDim2.new(0,0,0,26)
    track.BackgroundColor3 = Theme.Off; track.Parent = holder
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0); fill.BackgroundColor3 = Theme.Accent; fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local handle = Instance.new("Frame")
    handle.Size = UDim2.fromOffset(14,14); handle.AnchorPoint = Vector2.new(0.5,0.5)
    handle.Position = UDim2.new(0,0,0.5,0); handle.BackgroundColor3 = Color3.new(1,1,1)
    handle.Parent = track; Instance.new("UICorner", handle).CornerRadius = UDim.new(1,0)
    local function Refresh()
        local v = tonumber(get()) or minv
        local a = math.clamp((v-minv)/(maxv-minv),0,1)
        fill.Size = UDim2.new(a,0,1,0); handle.Position = UDim2.new(a,0,0.5,0)
        if step >= 1 then val.Text = tostring(math.floor(v)) else val.Text = string.format("%.2f", v) end
    end
    local dragging = false
    local function SetFromX(x)
        local a = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local raw = minv + (maxv-minv) * a
        local q = math.floor(raw/step + 0.5) * step
        set(math.clamp(q, minv, maxv)); Refresh()
    end
    track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true; SetFromX(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then SetFromX(i.Position.X) end end)
    Refresh()
end

local Tabs = { Visuals=CreateTab("Visuals"), Aim=CreateTab("Aim"), Utils=CreateTab("Utils") }
local function ClearScroll()
    for _, v in ipairs(Scroll:GetChildren()) do
        if v:IsA("Frame") or v:IsA("TextButton") or v:IsA("TextLabel") then v:Destroy() end
    end
end

local function LoadTab(tabName)
    ClearScroll()
    for name, btn in pairs(Tabs) do btn.TextColor3 = (name == tabName) and Theme.Accent or Theme.Muted end
    if tabName == "Visuals" then
        CreateSection("JOGADORES")
        CreateToggle("ESP Habilitado", function() return Config.ESP.Enabled end, function(v) Config.ESP.Enabled = v end)
        CreateToggle("Jogadores", function() return Config.ESP.Players end, function(v) Config.ESP.Players = v end)
    elseif tabName == "Aim" then
        CreateSection("AIMBOT")
        CreateToggle("Habilitado", function() return Config.Aim.Enabled end, function(v) Config.Aim.Enabled = v end)
        CreateToggle("Mostrar FOV", function() return Config.Aim.ShowFOV end, function(v) Config.Aim.ShowFOV = v end)
        CreateSlider("FOV (px)", 20, 400, function() return Config.Aim.FOV end, function(v) Config.Aim.FOV = v end, 5)
        CreateSlider("Suavidade", 0.1, 1.0, function() return Config.Aim.Smooth end, function(v) Config.Aim.Smooth = v end, 0.05)
    elseif tabName == "Utils" then
        CreateSection("MOVIMENTO")
        CreateToggle("WalkSpeed", function() return Config.Movement.SpeedEnabled end, function(v) Config.Movement.SpeedEnabled = v end)
        CreateSlider("Velocidade", 16, 200, function() return Config.Movement.SpeedValue end, function(v) Config.Movement.SpeedValue = v end, 1)
        CreateSection("SESSÃO")
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,34); btn.BackgroundColor3 = Theme.Danger
        btn.Font = Enum.Font.GothamBold; btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 13; btn.Text = "UNLOAD"
        btn.AutoButtonColor = false; btn.Parent = Scroll; Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
        btn.MouseButton1Click:Connect(function() if getgenv().Cobble_RP_Unload then getgenv().Cobble_RP_Unload() end; Gui:Destroy() end)
    end
end

Tabs.Visuals.MouseButton1Click:Connect(function() LoadTab("Visuals") end)
Tabs.Aim.MouseButton1Click:Connect(function() LoadTab("Aim") end)
Tabs.Utils.MouseButton1Click:Connect(function() LoadTab("Utils") end)
LoadTab("Visuals")

local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart; Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputBegan:Connect(function(i, gpe) if gpe then return end; if i.KeyCode == Enum.KeyCode.RightShift then Gui.Enabled = not Gui.Enabled end end)
