-- cobble hills logic (Sintonia RP v3 - Armas e Carros)
pcall(function() if setthreadidentity then setthreadidentity(8) end end)
if getgenv().Cobble_RP_Unload then pcall(getgenv().Cobble_RP_Unload) end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

if not Drawing then warn("[cobble] sem Drawing API"); return end

-- ==========================================
-- CONFIG
-- ==========================================
local defaults = {
    ESP = { Enabled=true, Players=true, Cars=true, Prompts=true },
    Movement = { SpeedEnabled=false, SpeedValue=50, FlyEnabled=false, NoclipEnabled=false, InvisEnabled=false },
    Farm = { AutoTrash=false, AutoCargo=false, Radius=15 },
    Aim = { Enabled=false, Key=Enum.KeyCode.E, FOV=120, Smooth=0.55, ShowFOV=true },
}
local Config = getgenv().CobbleConfig or {}
local function merge(dst, src) for k,v in pairs(src) do if type(v) == "table" and type(dst[k]) == "table" then merge(dst[k], v) elseif dst[k] == nil then dst[k] = v end end end
for s,tbl in pairs(defaults) do Config[s] = Config[s] or {}; merge(Config[s], tbl) end
getgenv().CobbleConfig = Config

local connections = {}
local alive = true
local function track(c) connections[#connections+1] = c; return c end

-- ==========================================
-- BYPASS DO ANTI-CHEAT
-- ==========================================
task.spawn(function()
    local filtergc = getgenv().filtergc
    local getupvalues = debug and debug.getupvalues
    if not (filtergc and getupvalues) then return end
    local ok, funcs = pcall(filtergc, "function", {Constants = {"FireServer", "bor", "clock"}}, false)
    if ok and type(funcs) == "table" then
        for _, fn in ipairs(funcs) do
            local src = debug.info(fn, "s")
            if type(src) == "string" and src:sub(-9) == ".ClientAC" then
                local upvals = getupvalues(fn)
                local teleportTable = upvals[4]
                local target = upvals[1]
                if type(target) == "table" and type(teleportTable) == "table" and rawget(target, "Teleporte") == 1 then
                    for k in pairs(target) do teleportTable[k] = math.huge end
                    print("[cobble] ✅ Anti-Cheat bypassado.")
                end
            end
        end
    end
end)

-- ==========================================
-- CACHES
-- ==========================================
local CachedPlayers, CachedCars, CachedPrompts = {}, {}, {}

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

task.spawn(function()
    while alive do
        local temp = {}
        local folder = Workspace:FindFirstChild("CarrosSpawnados")
        if folder then
            for _, car in ipairs(folder:GetChildren()) do
                local seat = car:FindFirstChild("DriveSeat", true) or car:FindFirstChildWhichIsA("VehicleSeat", true)
                if seat then temp[car] = { Name=car.Name, Pos=seat.Position } end
            end
        end
        CachedCars = temp
        task.wait(2)
    end
end)

task.spawn(function()
    while alive do
        local temp = {}
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Enabled then
                local pName = d.Parent and d.Parent.Name or "?"
                if pName:lower():find("lixo") or pName:lower():find("carga") or pName:lower():find("entrega") then
                    if d.Parent and d.Parent:IsA("BasePart") then
                        temp[d] = { Name=pName, Pos=d.Parent.Position, Color=Color3.fromRGB(100, 255, 100) }
                    end
                end
            end
        end
        CachedPrompts = temp
        task.wait(1.5)
    end
end)

-- ==========================================
-- AIMBOT (CÂMERA)
-- ==========================================
local aimHeld, aimTarget = false, nil
local curYaw, curPitch = 0, 0

local function isAimInput(input)
    local b = Config.Aim.Key
    if typeof(b) ~= "EnumItem" then return false end
    if b.EnumType == Enum.KeyCode then return input.KeyCode == b end
    return input.UserInputType == b
end

local function pickTarget()
    if aimTarget then
        local ok = aimTarget.Char.Parent and aimTarget.Hum.Health > 0
        if ok then return aimTarget end
        aimTarget = nil
    end
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

-- ==========================================
-- SPAWNER E PUXAR ARMA
-- ==========================================
getgenv().Cobble_SpawnWeapon = function(weaponName)
    local found = nil
    for _, d in ipairs(RS:GetDescendants()) do
        if d:IsA("Tool") and d.Name == weaponName then found = d; break end
    end
    if not found then print("[cobble] Arma não encontrada: " .. weaponName); return end
    local clone = found:Clone()
    local bp = LP:FindFirstChild("Backpack")
    if bp then clone.Parent = bp; print("[cobble] Arma equipada (Local): " .. weaponName) end
end

getgenv().Cobble_SpawnCar = function(carName)
    -- Tenta achar a pasta nova de carros no ReplicatedStorage
    local stuff = RS:FindFirstChild("Stuff")
    local concessionaria = stuff and stuff:FindFirstChild("Concessionaria")
    local remote = concessionaria and concessionaria:FindFirstChild("Remote")
    local spawner = remote and remote:FindFirstChild("CarrosSpawner")
    
    if spawner then
        pcall(function() 
            if spawner:IsA("RemoteEvent") then
                spawner:FireServer(carName) 
            else
                spawner:InvokeServer(carName)
            end
        end)
        print("[cobble] Tentando spawnar via Remote: " .. carName)
    else
        print("[cobble] Remote de spawn não encontrado.")
    end
end

-- ==========================================
-- DRAWINGS (ESP + FOV)
-- ==========================================
local playerDraw, carDraw, promptDraw = {}, {}, {}
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1; fovCircle.Filled = false; fovCircle.NumSides = 60
fovCircle.Color = Color3.fromRGB(157, 105, 255); fovCircle.Transparency = 0.55; fovCircle.Visible = false

local function destroyCache(cache) for _,d in pairs(cache) do pcall(function() d:Remove() end) end end

local function updateESP()
    local camPos = Camera.CFrame.Position
    
    local activeP = {}
    if Config.ESP.Enabled and Config.ESP.Players then
        for plr, data in pairs(CachedPlayers) do
            activeP[plr] = true
            local o = playerDraw[plr]
            if not o then
                o = { box=Drawing.new("Square"), name=Drawing.new("Text"), dist=Drawing.new("Text") }
                o.box.Thickness = 1; o.box.Filled = false; o.box.Color = Color3.fromRGB(157, 105, 255)
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
    for plr, o in pairs(playerDraw) do if not activeP[plr] then o.box:Remove(); o.name:Remove(); o.dist:Remove(); playerDraw[plr] = nil end end
    
    local activeC = {}
    if Config.ESP.Enabled and Config.ESP.Cars then
        for model, info in pairs(CachedCars) do
            local dist = (camPos - info.Pos).Magnitude
            if dist < 300 then
                activeC[model] = true
                local d = carDraw[model]
                if not d then d = Drawing.new("Text"); d.Center=true; d.Outline=true; d.Size=12; d.Color=Color3.fromRGB(150,200,255); carDraw[model] = d end
                local sp, on = Camera:WorldToViewportPoint(info.Pos)
                if sp.Z > 0 and on then d.Text = info.Name .. " [" .. math.floor(dist) .. "m]"; d.Position = Vector2.new(sp.X, sp.Y); d.Visible = true else d.Visible = false end
            end
        end
    end
    for m, d in pairs(carDraw) do if not activeC[m] then d:Remove(); carDraw[m] = nil end end

    local activePr = {}
    if Config.ESP.Enabled and Config.ESP.Prompts then
        for prompt, info in pairs(CachedPrompts) do
            local dist = (camPos - info.Pos).Magnitude
            if dist < 150 then
                activePr[prompt] = true
                local d = promptDraw[prompt]
                if not d then d = Drawing.new("Text"); d.Center=true; d.Outline=true; d.Size=12; d.Color = info.Color; promptDraw[prompt] = d end
                local sp, on = Camera:WorldToViewportPoint(info.Pos)
                if sp.Z > 0 and on then d.Text = info.Name .. " [" .. math.floor(dist) .. "m]"; d.Position = Vector2.new(sp.X, sp.Y); d.Visible = true else d.Visible = false end
            end
        end
    end
    for p, d in pairs(promptDraw) do if not activePr[p] then d:Remove(); promptDraw[p] = nil end end

    if Config.Aim.Enabled and Config.Aim.ShowFOV and aimHeld then
        fovCircle.Position = Camera.ViewportSize * 0.5; fovCircle.Radius = Config.Aim.FOV; fovCircle.Visible = true
    else fovCircle.Visible = false end
end
track(RunService.RenderStepped:Connect(updateESP))

-- ==========================================
-- AUTO FARM (LEGIT)
-- ==========================================
local lastFarm = 0
track(RunService.Heartbeat:Connect(function()
    if not (Config.Farm.AutoTrash or Config.Farm.AutoCargo) then return end
    if tick() - lastFarm < 0.5 then return end
    lastFarm = tick()
    
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    for prompt, info in pairs(CachedPrompts) do
        local dist = (root.Position - info.Pos).Magnitude
        if dist <= Config.Farm.Radius then
            local isTrash = info.Name:lower():find("lixo")
            local isCargo = info.Name:lower():find("carga") or info.Name:lower():find("entrega")
            if (Config.Farm.AutoTrash and isTrash) or (Config.Farm.AutoCargo and isCargo) then
                pcall(function() fireproximityprompt(prompt) end)
            end
        end
    end
end))

-- ==========================================
-- MOVIMENTAÇÃO
-- ==========================================
local flyBV, flyConn = nil, nil
track(RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if hum then hum.WalkSpeed = Config.Movement.SpeedEnabled and Config.Movement.SpeedValue or 16 end
    
    if Config.Movement.NoclipEnabled and char then
        for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end
    
    if Config.Movement.FlyEnabled and not flyBV and root then
        hum.PlatformStand = true
        flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(1e5,1e5,1e5); flyBV.Velocity = Vector3.zero; flyBV.Parent = root
        flyConn = RunService.RenderStepped:Connect(function()
            local camCF = Camera.CFrame
            local moveDir = Vector3.zero
            local UIS = game:GetService("UserInputService")
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
            flyBV.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * 100 or Vector3.zero
        end)
    elseif not Config.Movement.FlyEnabled and flyBV then
        hum.PlatformStand = false; flyBV:Destroy(); flyBV = nil
        if flyConn then flyConn:Disconnect(); flyConn = nil end
    end
end))

getgenv().Cobble_RP_Unload = function()
    alive = false
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    destroyCache(playerDraw); destroyCache(carDraw); destroyCache(promptDraw)
    if flyConn then flyConn:Disconnect() end
    if flyBV then flyBV:Destroy() end
    if getgenv().Cobble_UI_Loaded then getgenv().Cobble_UI_Loaded:Destroy() end
    print("[cobble] Script Unloaded.")
end
