-- ==========================================================
-- AUTO SEA BEST V3.5 | BY WERBERT_OFC
-- RESTART INTELIGENTE + ÍCONE MÓVEL + UI COMPLETA
-- ==========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local islandFolder = Workspace:WaitForChild("Island")

-- === CONFIGURAÇÕES ===
local configs = {
    ligado = true,          -- Começa ligado
    autoHop = true,         -- Auto Hop ligado
    delayInicial = 25,      -- Tempo de espera (carregamento)
    posicaoInicial = Vector3.new(16619.78, -4.05, -6611.93),
    tempoScan = 10,         -- Tempo procurando
    scriptAtivo = true,     -- Controle mestre do script
    buscandoAgora = false   -- Controle para não duplicar a busca
}

-- === INTERFACE (UI) ===
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("SeaBestV6") then pGui.SeaBestV6:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SeaBestV6"
ScreenGui.Parent = pGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 1. PAINEL PRINCIPAL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -110, 0.4, -80)
MainFrame.Size = UDim2.new(0, 220, 0, 170)
MainFrame.Active = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Parent = MainFrame
Stroke.Color = Color3.fromRGB(0, 120, 255)
Stroke.Thickness = 2

-- Título
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Size = UDim2.new(1, -60, 0, 20)
Title.Font = Enum.Font.GothamBold
Title.Text = "Auto Sea Best V3\nby: werbert_ofc"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Botão Fechar (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
local CornerClose = Instance.new("UICorner")
CornerClose.CornerRadius = UDim.new(0, 4)
CornerClose.Parent = CloseBtn

-- Botão Minimizar (-)
local MiniBtn = Instance.new("TextButton")
MiniBtn.Parent = MainFrame
MiniBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MiniBtn.Position = UDim2.new(1, -50, 0, 5)
MiniBtn.Size = UDim2.new(0, 20, 0, 20)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.Text = "-"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.TextSize = 14
local CornerMini = Instance.new("UICorner")
CornerMini.CornerRadius = UDim.new(0, 4)
CornerMini.Parent = MiniBtn

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Aguardando..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 11

-- Container
local ToggleContainer = Instance.new("Frame")
ToggleContainer.Parent = MainFrame
ToggleContainer.BackgroundTransparency = 1
ToggleContainer.Position = UDim2.new(0, 10, 0, 70)
ToggleContainer.Size = UDim2.new(1, -20, 0, 90)

-- 2. ÍCONE MINIMIZADO (MÓVEL)
local IconFrame = Instance.new("TextButton")
IconFrame.Name = "MinimizedIcon"
IconFrame.Parent = ScreenGui
IconFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
IconFrame.BorderSizePixel = 0
IconFrame.Position = UDim2.new(0.9, 0, 0.2, 0)
IconFrame.Size = UDim2.new(0, 30, 0, 30) -- Aumentei um pouco pra facilitar o toque
IconFrame.Text = ""
IconFrame.Visible = false

local IconStroke = Instance.new("UIStroke")
IconStroke.Parent = IconFrame
IconStroke.Color = Color3.fromRGB(255, 255, 255)
IconStroke.Thickness = 2
local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 6)
IconCorner.Parent = IconFrame

-- Ícone visual dentro do botão
local IconLabel = Instance.new("TextLabel")
IconLabel.Parent = IconFrame
IconLabel.BackgroundTransparency = 1
IconLabel.Size = UDim2.new(1, 0, 1, 0)
IconLabel.Font = Enum.Font.GothamBold
IconLabel.Text = "SK"
IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IconLabel.TextSize = 10

-- === SISTEMA DE ARRASTAR (UNIVERSAL) ===
local function enableDrag(frame)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

enableDrag(MainFrame)
enableDrag(IconFrame) -- Agora o ícone também arrasta

-- === LÓGICA DO SCRIPT ===

-- Declaração antecipada das funções
local iniciarBusca -- Forward declaration

local function createToggle(parent, text, defaultState, yPos, onClick)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(60, 60, 60)
    Btn.Position = UDim2.new(0, 0, 0, yPos)
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = text .. ": " .. (defaultState and "ON" or "OFF")
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    Btn.Activated:Connect(function()
        -- Lógica de Toggle visual
        local isGreen = (Btn.BackgroundColor3.G * 255) > 100
        local newState = not isGreen
        
        Btn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(60, 60, 60)
        Btn.Text = text .. ": " .. (newState and "ON" or "OFF")
        
        onClick(newState, Btn)
    end)
    return Btn
end

local function trocarDeServidor()
    if not configs.autoHop then return end
    StatusLabel.Text = "Status: Trocando de Servidor..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    local sfUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(sfUrl)) end)

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

local function teleportar(cframe, forceStream)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if forceStream then
            player:RequestStreamAroundAsync(cframe.Position)
            task.wait(0.5)
        end
        hrp.CFrame = cframe
    end
end

-- Lógica Principal de Busca
iniciarBusca = function()
    if configs.buscandoAgora then return end -- Evita duplicar
    configs.buscandoAgora = true
    
    task.spawn(function()
        -- 1. Delay Inicial
        for i = configs.delayInicial, 1, -1 do
            if not configs.scriptAtivo or not configs.ligado then 
                configs.buscandoAgora = false
                return 
            end
            StatusLabel.Text = "Status: Aguardando (" .. i .. "s)"
            task.wait(1)
        end
        
        -- 2. Ir para a Base
        StatusLabel.Text = "Status: Indo para Base..."
        teleportar(CFrame.new(configs.posicaoInicial), false)
        task.wait(2)
        
        -- 3. Loop de Escaneamento
        local tempo = 0
        while configs.scriptAtivo and configs.ligado and tempo < configs.tempoScan do
            StatusLabel.Text = "Status: Procurando (" .. (configs.tempoScan - tempo) .. "s)"
            
            local target = islandFolder:FindFirstChild("SeaKing Island")
            if not target then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "SeaKing Island" then target = obj break end
                end
            end
            
            if target then
                StatusLabel.Text = "Status: ILHA ENCONTRADA!"
                StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                teleportar(target:GetPivot() + Vector3.new(0, 50, 0), true)
                
                -- Desativa o botão visualmente e na config
                configs.ligado = false
                local skBtn = ToggleContainer:FindFirstChild("SKToggle")
                if skBtn then
                    skBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    skBtn.Text = "Auto Sea Best: OFF"
                end
                
                configs.buscandoAgora = false
                return -- SUCESSO!
            end
            
            tempo = tempo + 1
            task.wait(1)
        end
        
        -- 4. Auto Hop
        if configs.scriptAtivo and configs.ligado and configs.autoHop then
            trocarDeServidor()
        else
            StatusLabel.Text = "Status: Tempo Esgotado"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        end
        
        configs.buscandoAgora = false
    end)
end

-- Criar os Botões Toggle
local ToggleSK = createToggle(ToggleContainer, "Auto Sea Best", configs.ligado, 0, function(state, btn)
    configs.ligado = state
    if state then
        -- SE O USUÁRIO CLICAR PARA LIGAR, INICIA A BUSCA NOVAMENTE
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        iniciarBusca()
    else
        StatusLabel.Text = "Status: Pausado pelo Usuário"
    end
end)
ToggleSK.Name = "SKToggle"

local ToggleHop = createToggle(ToggleContainer, "Auto Server Hop", configs.autoHop, 40, function(state, btn)
    configs.autoHop = state
end)
ToggleHop.Name = "HopToggle"

-- === AÇÕES UI ===
MiniBtn.Activated:Connect(function()
    MainFrame.Visible = false
    IconFrame.Visible = true
end)

IconFrame.Activated:Connect(function() -- Clique curto abre
    if IconFrame.Visible then
        IconFrame.Visible = false
        MainFrame.Visible = true
    end
end)

CloseBtn.Activated:Connect(function()
    configs.scriptAtivo = false
    ScreenGui:Destroy()
end)

-- Início Automático
if configs.ligado then
    iniciarBusca()
end
