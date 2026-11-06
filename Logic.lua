-- cobble hills logic (Sintonia RP - Money Maker)
pcall(function() if setthreadidentity then setthreadidentity(8) end end)
if getgenv().Cobble_RP_Unload then pcall(getgenv().Cobble_RP_Unload) end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Config = getgenv().CobbleConfig or {}
Config.ESP = Config.ESP or { Enabled=true, Players=true, Jobs=true }
Config.Movement = Config.Movement or { SpeedEnabled=false, SpeedValue=50 }
Config.Aim = Config.Aim or { Enabled=false, Key=Enum.KeyCode.E, FOV=120, Smooth=0.55, ShowFOV=true }
Config.Farm = Config.Farm or { AutoLixeiro=false, AutoCarga=false }
getgenv().CobbleConfig = Config

local connections = {}
local alive = true
local function track(c) connections[#connections+1] = c; return c end

-- ==========================================
-- CACHE DE EMPREGOS E PROMPTS
-- ==========================================
local CachedJobs = {}
task.spawn(function()
    while alive do
        local temp = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local action = obj.ActionText:lower()
                local object = obj.ObjectText:lower()
                local parentName = obj.Parent.Name:lower()
                
                -- Detecta se é um ponto de emprego ou entrega
                if action:find("trabalhar") or action:find("emprego") or object:find("lixeiro") or object:find("carga") or parentName:find("entrega") then
                    local part = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                    if part then
                        temp[obj] = { Name = obj.ObjectText ~= "" and obj.ObjectText or obj.Parent.Name, Pos = part.Position, Prompt = obj }
                    end
                end
            end
        end
        CachedJobs = temp
        task.wait(2)
    end
end)

-- ==========================================
-- FUNÇÃO DE TELEPORTE SEGURO (GLIDE)
-- ==========================================
getgenv().Cobble_GlideTo = function(targetPos)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    print("[cobble] Deslizando até o destino...")
    local oldSpeed = hum.WalkSpeed
    hum.WalkSpeed = 200 -- Fica rápido mas não é um teleporte
    
    local distance = (char.HumanoidRootPart.Position - targetPos).Magnitude
    local timeToTravel = distance / 200
    
    hum:MoveTo(targetPos)
    task.wait(timeToTravel + 0.5) -- Espera chegar
    hum.WalkSpeed = oldSpeed -- Restaura a velocidade
    hum:MoveTo(char.HumanoidRootPart.Position) -- Para de andar
    print("[cobble] Chegou ao destino.")
end

-- ==========================================
-- AUTO FARM (LIXEIRO / CARGA) INTELIGENTE
-- ==========================================
local isFarming = false
getgenv().Cobble_StartFarm = function(jobType)
    if isFarming then return end
    isFarming = true
    
    task.spawn(function()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then isFarming = false; return end
        
        print("[cobble] Iniciando loop de farm: " .. jobType)
        
        while isFarming and alive do
            -- 1. Acha o prompt mais perto (coleta ou entrega)
            local closestPrompt, minDist = nil, 50
            for prompt, info in pairs(CachedJobs) do
                -- Se o farm for Lixeiro, procura lixo
                if jobType == "Lixeiro" and info.Name:lower():find("lixo") then
                    local d = (root.Position - info.Pos).Magnitude
                    if d < minDist then minDist = d; closestPrompt = prompt end
                -- Se o farm for Carga, procura carga
                elseif jobType == "Carga" and info.Name:lower():find("carga") then
                    local d = (root.Position - info.Pos).Magnitude
                    if d < minDist then minDist = d; closestPrompt = prompt end
                end
            end
            
            if closestPrompt then
                -- Vai até o item e pega
                if minDist > 10 then
                    -- Se tiver longe, desliza até lá
                    hum.WalkSpeed = 150
                    hum:MoveTo(CachedJobs[closestPrompt].Pos)
                    task.wait(1)
                else
                    -- Se tiver perto, para e pega
                    hum.WalkSpeed = 16
                    pcall(function() fireproximityprompt(closestPrompt) end)
                    print("[cobble] Coletado: " .. CachedJobs[closestPrompt].Name)
                    task.wait(1.5)
                end
            else
                -- Se não achou nada, espera um pouco e anda um pouco aleatoriamente
                hum.WalkSpeed = 16
                task.wait(2)
            end
        end
    end)
end

getgenv().Cobble_StopFarm = function()
    isFarming = false
    print("[cobble] Farm parado.")
end

-- ==========================================
-- AIMBOT E ESP (Mantidos do Safe Mode)
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

-- ESP Simples (Players e Jobs)
local playerDraw, jobDraw = {}, {}
local function destroyCache(c) for _,d in pairs(c) do pcall(function() d:Remove() end) end end

track(RunService.RenderStepped:Connect(function()
    local camPos = Camera.CFrame.Position
    
    -- Players ESP
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
            else
                o.box.Visible=false; o.name.Visible=false
            end
        end
    end
    for p, o in pairs(playerDraw) do if not activeP[p] then o.box:Remove(); o.name:Remove(); playerDraw[p] = nil end end
    
    -- Jobs ESP
    local activeJ = {}
    if Config.ESP.Enabled and Config.ESP.Jobs then
        for prompt, info in pairs(CachedJobs) do
            local dist = (camPos - info.Pos).Magnitude
            if dist < 300 then
                activeJ[prompt] = true
                local d = jobDraw[prompt]
                if not d then d = Drawing.new("Text"); d.Center=true; d.Outline=true; d.Size=13; d.Color=Color3.fromRGB(100, 255, 100); jobDraw[prompt] = d end
                local sp, on = Camera:WorldToViewportPoint(info.Pos)
                if sp.Z > 0 and on then d.Text = "💼 " .. info.Name .. " [" .. math.floor(dist) .. "m]"; d.Position = Vector2.new(sp.X, sp.Y); d.Visible = true else d.Visible = false end
            end
        end
    end
    for j, d in pairs(jobDraw) do if not activeJ[j] then d:Remove(); jobDraw[j] = nil end end
end))

-- MOVIMENTAÇÃO
track(RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    -- Não mexe no speed se estiver no meio do Glide/Farm
    if hum and not isFarming then 
        hum.WalkSpeed = Config.Movement.SpeedEnabled and Config.Movement.SpeedValue or 16 
    end
end))

getgenv().Cobble_RP_Unload = function()
    alive = false; isFarming = false
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    destroyCache(playerDraw); destroyCache(jobDraw)
    if getgenv().Cobble_UI_Loaded then getgenv().Cobble_UI_Loaded:Destroy() end
end
