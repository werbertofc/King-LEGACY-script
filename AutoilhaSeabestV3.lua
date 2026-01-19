-- ==========================================================
-- KING LEGACY: SEA KING TRACKER PRO (v4.2)
-- SISTEMA: FULL AUTO (SK & HOP ATIVOS POR PADRÃO)
-- ==========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local islandFolder = Workspace:WaitForChild("Island")

-- === CONFIGURAÇÕES (AMBOS ATIVOS POR PADRÃO) ===
local ligado = true 
local autoHopAtivo = true 
local posicaoInicial = Vector3.new(16619.78, -4.05, -6611.93)
local tempoDeEspera = 10 -- Tempo de scan antes do Hop

-- === INTERFACE (GUI) ===
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("SK_System") then pGui.SK_System:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SK_System"
ScreenGui.Parent = pGui
ScreenGui.ResetOnSpawn = false

-- Botão de Busca (SK) - Inicia em AZUL (ON)
local MainButton = Instance.new("TextButton")
MainButton.Name = "SKButton"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
MainButton.Position = UDim2.new(0.1, 0, 0.4, 0)
MainButton.Size = UDim2.new(0, 50, 0, 50)
MainButton.Text = "SK: ON"
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.Font = Enum.Font.GothamBold
MainButton.TextSize = 10

local Corner1 = Instance.new("UICorner")
Corner1.CornerRadius = UDim.new(0, 10)
Corner1.Parent = MainButton

-- Botão de Auto Hop (HOP) - Inicia em VERDE (ON)
local HopButton = Instance.new("TextButton")
HopButton.Name = "HopButton"
HopButton.Parent = ScreenGui
HopButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
HopButton.Position = UDim2.new(0.1, 0, 0.52, 0)
HopButton.Size = UDim2.new(0, 50, 0, 50)
HopButton.Text = "HOP: ON"
HopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HopButton.Font = Enum.Font.GothamBold
HopButton.TextSize = 10

local Corner2 = Instance.new("UICorner")
Corner2.CornerRadius = UDim.new(0, 10)
Corner2.Parent = HopButton

-- === FUNÇÃO SERVER HOP ===
local function trocarDeServidor()
    if not autoHopAtivo then return end
    print("❌ Ilha não encontrada. Buscando novo servidor...")
    
    local sfUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(sfUrl))
    end)

    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
                break
            end
        end
    else
        TeleportService:Teleport(game.PlaceId, player)
    end
end

-- === FUNÇÃO DE TELEPORTE ===
local function teleportar(cframeAlvo, forcarRender)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if forcarRender then
            player:RequestStreamAroundAsync(cframeAlvo.Position)
            task.wait(0.5)
        end
        hrp.CFrame = cframeAlvo
    end
end

-- === LÓGICA PRINCIPAL ===
local function iniciarProcesso()
    if not ligado then return end

    -- Teleporta para o ponto de espera do log
    teleportar(CFrame.new(posicaoInicial), false)
    
    local tempoPassado = 0
    local ilhaEncontrada = false

    print("⏳ Iniciando monitoramento automático...")
    
    while tempoPassado < tempoDeEspera do
        if not ligado then return end 

        -- Busca a ilha
        local target = islandFolder:FindFirstChild("SeaKing Island")
        if not target then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "SeaKing Island" then target = obj break end
            end
        end

        if target then
            ilhaEncontrada = true
            teleportar(target:GetPivot() + Vector3.new(0, 50, 0), true)
            ligado = false
            MainButton.Text = "SK: OFF"
            MainButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            return 
        end

        task.wait(1)
        tempoPassado = tempoPassado + 1
    end

    -- Se acabar o tempo e o HOP estiver ligado (padrão), troca de server
    if not ilhaEncontrada and autoHopAtivo and ligado then
        trocarDeServidor()
    end
end

-- === SISTEMA DE ARRASTAR ===
local function habilitarArrastar(botao)
    local dragging, dragStart, startPos
    botao.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = botao.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            botao.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    botao.InputEnded:Connect(function() dragging = false end)
end

habilitarArrastar(MainButton)
habilitarArrastar(HopButton)

-- === CONTROLES MANUAIS ===
MainButton.Activated:Connect(function()
    ligado = not ligado
    MainButton.Text = ligado and "SK: ON" or "SK: OFF"
    MainButton.BackgroundColor3 = ligado and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(200, 0, 0)
    if ligado then iniciarProcesso() end
end)

HopButton.Activated:Connect(function()
    autoHopAtivo = not autoHopAtivo
    HopButton.Text = autoHopAtivo and "HOP: ON" or "HOP: OFF"
    HopButton.BackgroundColor3 = autoHopAtivo and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
end)

-- Execução automática imediata
task.spawn(iniciarProcesso)
