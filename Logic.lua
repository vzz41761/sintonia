-- cobble hills logic (Sintonia RP - Money Maker v3)
pcall(function() if setthreadidentity then setthreadidentity(8) end end)
if getgenv().Cobble_RP_Unload then pcall(getgenv().Cobble_RP_Unload) end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Config = getgenv().CobbleConfig or {}
Config.ESP = Config.ESP or { Enabled=true, Players=true, Jobs=true }
Config.Movement = Config.Movement or { SpeedEnabled=false, SpeedValue=50 }
Config.Aim = Config.Aim or { Enabled=false, Key=Enum.KeyCode.E, FOV=120, Smooth=0.55, ShowFOV=true }
Config.Farm = Config.Farm or { ActiveJob = nil }
getgenv().CobbleConfig = Config

local connections = {}
local alive = true
local function track(c) connections[#connections+1] = c; return c end

-- ==========================================
-- TELEPORTE SUAVE (GLIDE) E VOO
-- ==========================================
getgenv().Cobble_GlideTo = function(targetPos)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    print("[cobble] Voando até o destino...")
    local startPos = hrp.Position
    local distance = (startPos - targetPos).Magnitude
    local speed = 150 
    local timeToTravel = distance / speed
    local t = 0
    
    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        local alpha = math.clamp(t / timeToTravel, 0, 1)
        hrp.CFrame = CFrame.new(startPos:Lerp(targetPos, alpha))
        if alpha >= 1 then conn:Disconnect() end
    end)
end

getgenv().Cobble_GoToMercado = function()
    local mercado = Workspace:FindFirstChild("Mercadinho") or Workspace:FindFirstChild("Prefeitura")
    if mercado then
        local part = mercado:FindFirstChildWhichIsA("BasePart") or mercado.PrimaryPart
        if part then getgenv().Cobble_GlideTo(part.Position + Vector3.new(0,5,0)) end
    else
        print("[cobble] Mercadinho não encontrado no mapa atual.")
    end
end

-- ==========================================
-- SCANNER DE PROMPTS (LOGS)
-- ==========================================
getgenv().Cobble_DumpPrompts = function()
    print("=== PROMPTS NUM RAIO DE 100M ===")
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local part = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
            if part and (part.Position - root.Position).Magnitude < 100 then
                print("-> " .. obj.Parent.Name .. " | Action: '" .. obj.ActionText .. "' | Object: '" .. obj.ObjectText .. "'")
            end
        end
    end
end

-- ==========================================
-- CACHE DE EMPREGOS
-- ==========================================
getgenv().Cobble_Jobs = {}
task.spawn(function()
    while alive do
        local temp = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local parent = obj.Parent
                local action = obj.ActionText:lower()
                local objectText = obj.ObjectText:lower()
                local parentName = parent.Name:lower()
                local combined = action .. " " .. objectText .. " " .. parentName
                
                if combined:find("lixo") or combined:find("carga") or combined:find("entrega") or combined:find("trabalho") then
                    local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart")
                    if part then
                        temp[obj] = { Name = obj.ObjectText ~= "" and obj.ObjectText or parent.Name, Pos = part.Position, Obj = obj }
                    end
                end
            end
        end
        getgenv().Cobble_Jobs = temp
        task.wait(3)
    end
end)

-- ==========================================
-- AUTO FARM (CORRIGIDO)
-- ==========================================
getgenv().Cobble_StartFarm = function(jobType)
    if Config.Farm.ActiveJob then print("[cobble] Já tem um farm rodando. Pare o outro primeiro."); return end
    Config.Farm.ActiveJob = jobType
    print("[cobble] Iniciando Auto " .. jobType)
    
    task.spawn(function()
        while Config.Farm.ActiveJob == jobType and alive do
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(1); continue end
            
            local closest, minDist = nil, 500
            local targetKeyword = jobType == "Lixeiro" and "lixo" or "carga"
            
            for obj, info in pairs(getgenv().Cobble_Jobs) do
                if info.Name:lower():find(targetKeyword) then
                    local d = (hrp.Position - info.Pos).Magnitude
                    if d < minDist then minDist = d; closest = info end
                end
            end
            
            if closest then
                if minDist > 8 then
                    getgenv().Cobble_GlideTo(closest.Pos + Vector3.new(0, 3, 0))
                    task.wait((minDist / 150) + 0.5)
                else
                    pcall(function() fireproximityprompt(closest.Obj) end)
                    print("[cobble] Coletou: " .. closest.Name)
                    task.wait(2)
                end
            else
                task.wait(2)
            end
        end
    end)
end

getgenv().Cobble_StopFarm = function()
    Config.Farm.ActiveJob = nil
    print("[cobble] Farm parado.")
end

-- ==========================================
-- AIMBOT E ESP (Mantidos)
-- ==========================================
local aimHeld, aimTarget = false, nil
local CachedPlayers = {}
task.spawn(function()
    while alive do
        local temp = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local h = plr.Character:FindFirstChildOfClass("Humanoid")
                local r = plr.Character:FindFirstChild("HumanoidRootPart")
                if h and r and h.Health > 0 then temp[plr] = { Char=plr.Character, Hum=h, Root=r, Head=plr.Character:FindFirstChild("Head") } end
            end
        end
        CachedPlayers = temp
        task.wait(0.5)
    end
end)

local function isAimInput(input)
    local b = Config.Aim.Key
    if typeof(b) ~= "EnumItem" then return false end
    return b.EnumType == Enum.KeyCode and input.KeyCode == b or input.UserInputType == b
end
local function pickTarget()
    if aimTarget and aimTarget.Char.Parent and aimTarget.Hum.Health > 0 then return aimTarget end
    local center, best, bestD = Camera.ViewportSize * 0.5, nil, Config.Aim.FOV
    for _, d in pairs(CachedPlayers) do
        if d.Head then
            local sp, on = Camera:WorldToViewportPoint(d.Head.Position)
            if sp.Z > 0 and on and (Vector2.new(sp.X, sp.Y) - center).Magnitude < bestD then best = d end
        end
    end
    aimTarget = best
    return best
end

track(game:GetService("UserInputService").InputBegan:Connect(function(i, gpe) if not gpe and isAimInput(i) then aimHeld = true; aimTarget = nil end end))
track(game:GetService("UserInputService").InputEnded:Connect(function(i) if isAimInput(i) then aimHeld = false; aimTarget = nil end end))

RunService:BindToRenderStep("cobble_aim", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if not Config.Aim.Enabled or not aimHeld then return end
    local t = pickTarget()
    if t then
        local want = CFrame.lookAt(Camera.CFrame.Position, t.Head.Position)
        Camera.CFrame = Camera.CFrame:Lerp(want, 1 - (1 - math.clamp(Config.Aim.Smooth, 0.01, 1)) ^ (dt * 60))
    end
end)

local playerDraw, jobDraw = {}, {}
local function destroyCache(c) for _,d in pairs(c) do pcall(function() d:Remove() end) end end

track(RunService.RenderStepped:Connect(function()
    local camPos = Camera.CFrame.Position
    -- Players
    local activeP = {}
    if Config.ESP.Enabled and Config.ESP.Players then
        for plr, data in pairs(CachedPlayers) do
            activeP[plr] = true
            local o = playerDraw[plr]
            if not o then
                o = { box=Drawing.new("Square"), name=Drawing.new("Text") }
                o.box.Thickness = 1; o.box.Filled = false; o.box.Color = Color3.fromRGB(255,60,60)
                o.name.Center=true; o.name.Outline=true; o.name.Size=13; o.name.Color=Color3.new(1,1,1)
                playerDraw[plr] = o
            end
            local sp, on = Camera:WorldToViewportPoint(data.Root.Position + Vector3.new(0,3,0))
            local spBot, onBot = Camera:WorldToViewportPoint(data.Root.Position - Vector3.new(0,3,0))
            if sp.Z > 0 and on and onBot then
                local h = spBot.Y - sp.Y; local w = h * 0.6
                o.box.Position = Vector2.new(sp.X - w/2, sp.Y); o.box.Size = Vector2.new(w, h); o.box.Visible = true
                o.name.Text = plr.Name; o.name.Position = Vector2.new(sp.X, sp.Y - 16); o.name.Visible = true
            else o.box.Visible=false; o.name.Visible=false end
        end
    end
    for p, o in pairs(playerDraw) do if not activeP[p] then o.box:Remove(); o.name:Remove(); playerDraw[p] = nil end end
    
    -- Jobs
    local activeJ = {}
    if Config.ESP.Enabled and Config.ESP.Jobs then
        for obj, info in pairs(getgenv().Cobble_Jobs) do
            local dist = (camPos - info.Pos).Magnitude
            if dist < 500 then
                activeJ[obj] = true
                local d = jobDraw[obj]
                if not d then d = Drawing.new("Text"); d.Center=true; d.Outline=true; d.Size=13; d.Color=Color3.fromRGB(100, 255, 100); jobDraw[obj] = d end
                local sp, on = Camera:WorldToViewportPoint(info.Pos)
                if sp.Z > 0 and on then d.Text = "💼 " .. info.Name .. " [" .. math.floor(dist) .. "m]"; d.Position = Vector2.new(sp.X, sp.Y); d.Visible = true else d.Visible = false end
            end
        end
    end
    for j, d in pairs(jobDraw) do if not activeJ[j] then d:Remove(); jobDraw[j] = nil end end
end))

track(RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and not Config.Farm.ActiveJob then 
        hum.WalkSpeed = Config.Movement.SpeedEnabled and Config.Movement.SpeedValue or 16 
    end
end))

getgenv().Cobble_RP_Unload = function()
    alive = false; Config.Farm.ActiveJob = nil
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    destroyCache(playerDraw); destroyCache(jobDraw)
    if getgenv().Cobble_UI_Loaded then getgenv().Cobble_UI_Loaded:Destroy() end
end
