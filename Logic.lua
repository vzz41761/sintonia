-- cobble hills logic (Sintonia RP - SAFE MODE)
pcall(function() if setthreadidentity then setthreadidentity(8) end end)
if getgenv().Cobble_RP_Unload then pcall(getgenv().Cobble_RP_Unload) end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

if not Drawing then warn("[cobble] sem Drawing API"); return end

-- CONFIG
local defaults = {
    ESP = { Enabled=true, Players=true },
    Movement = { SpeedEnabled=false, SpeedValue=50 },
    Aim = { Enabled=false, Key=Enum.KeyCode.E, FOV=120, Smooth=0.55, ShowFOV=true },
}
local Config = getgenv().CobbleConfig or {}
local function merge(dst, src) for k,v in pairs(src) do if type(v) == "table" and type(dst[k]) == "table" then merge(dst[k], v) elseif dst[k] == nil then dst[k] = v end end end
for s,tbl in pairs(defaults) do Config[s] = Config[s] or {}; merge(Config[s], tbl) end
getgenv().CobbleConfig = Config

local connections = {}
local alive = true
local function track(c) connections[#connections+1] = c; return c end

-- CACHE (Jogadores)
local CachedPlayers = {}
task.spawn(function()
    while alive do
        local temp = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    temp[plr] = { Char=plr.Character, Hum=hum, Root=root, Head=plr.Character:FindFirstChild("Head") }
                end
            end
        end
        CachedPlayers = temp
        task.wait(0.5)
    end
end)

-- AIMBOT
local aimHeld, aimTarget = false, nil
local function isAimInput(input)
    local b = Config.Aim.Key
    if typeof(b) ~= "EnumItem" then return false end
    if b.EnumType == Enum.KeyCode then return input.KeyCode == b end
    return input.UserInputType == b
end
local function pickTarget()
    if aimTarget and aimTarget.Char.Parent and aimTarget.Hum.Health > 0 then return aimTarget end
    aimTarget = nil
    local center = Camera.ViewportSize * 0.5
    local best, bestD = nil, Config.Aim.FOV
    for _, d in pairs(CachedPlayers) do
        if d.Hum.Health > 0 and d.Head then
            local sp, on = Camera:WorldToViewportPoint(d.Head.Position)
            if sp.Z > 0 and on then
                local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                if dist < bestD then bestD = dist; best = d end
            end
        end
    end
    aimTarget = best
    return best
end

track(UserInputService.InputBegan:Connect(function(i, gpe) if not gpe and isAimInput(i) then aimHeld = true; aimTarget = nil end end))
track(UserInputService.InputEnded:Connect(function(i) if isAimInput(i) then aimHeld = false; aimTarget = nil end end))

RunService:BindToRenderStep("cobble_aim", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if not Config.Aim.Enabled or not aimHeld then return end
    local t = pickTarget()
    if not t then return end
    local want = CFrame.lookAt(Camera.CFrame.Position, t.Head.Position)
    local s = math.clamp(Config.Aim.Smooth, 0.01, 1)
    Camera.CFrame = Camera.CFrame:Lerp(want, 1 - (1 - s) ^ (dt * 60))
end)

-- ESP
local playerDraw = {}
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1; fovCircle.Filled = false; fovCircle.NumSides = 60
fovCircle.Color = Color3.fromRGB(157, 105, 255); fovCircle.Transparency = 0.55; fovCircle.Visible = false

track(RunService.RenderStepped:Connect(function()
    local camPos = Camera.CFrame.Position
    local activeP = {}
    if Config.ESP.Enabled and Config.ESP.Players then
        for plr, data in pairs(CachedPlayers) do
            activeP[plr] = true
            local o = playerDraw[plr]
            if not o then
                o = { box=Drawing.new("Square"), name=Drawing.new("Text"), dist=Drawing.new("Text") }
                o.box.Thickness = 1; o.box.Filled = false; o.box.Color = Color3.fromRGB(255,60,60)
                o.name.Center=true; o.name.Outline=true; o.name.Size=13; o.name.Color=Color3.new(1,1,1)
                o.dist.Center=true; o.dist.Outline=true; o.dist.Size=12; o.dist.Color=Color3.fromRGB(200,205,220)
                playerDraw[plr] = o
            end
            local sp, on = Camera:WorldToViewportPoint(data.Root.Position + Vector3.new(0,3,0))
            local spBot, onBot = Camera:WorldToViewportPoint(data.Root.Position - Vector3.new(0,3,0))
            if sp.Z > 0 and on and onBot then
                local h = spBot.Y - sp.Y; local w = h * 0.6
                o.box.Position = Vector2.new(sp.X - w/2, sp.Y); o.box.Size = Vector2.new(w, h); o.box.Visible = true
                o.name.Text = plr.Name; o.name.Position = Vector2.new(sp.X, sp.Y - 16); o.name.Visible = true
                o.dist.Text = math.floor((camPos - data.Root.Position).Magnitude) .. "m"; o.dist.Position = Vector2.new(sp.X, spBot.Y + 4); o.dist.Visible = true
            else
                o.box.Visible=false; o.name.Visible=false; o.dist.Visible=false
            end
        end
    end
    for plr, o in pairs(playerDraw) do 
        if not activeP[plr] then 
            o.box:Remove(); o.name:Remove(); o.dist:Remove(); playerDraw[plr] = nil 
        end 
    end
    
    if Config.Aim.Enabled and Config.Aim.ShowFOV and aimHeld then
        fovCircle.Position = Camera.ViewportSize * 0.5; fovCircle.Radius = Config.Aim.FOV; fovCircle.Visible = true
    else fovCircle.Visible = false end
end))

-- MOVIMENTAÇÃO
track(RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Config.Movement.SpeedEnabled and Config.Movement.SpeedValue or 16 end
end))

getgenv().Cobble_RP_Unload = function()
    alive = false
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    for _, o in pairs(playerDraw) do pcall(function() o.box:Remove(); o.name:Remove(); o.dist:Remove() end) end
    pcall(function() fovCircle:Remove() end)
    if getgenv().Cobble_UI_Loaded then getgenv().Cobble_UI_Loaded:Destroy() end
    print("[cobble] Script Unloaded.")
end
