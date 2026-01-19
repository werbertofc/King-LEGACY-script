-- ==========================================================
-- AUTO SEA BEST V3 | BY WERBERT_OFC
-- UI MODERNA + MINIMIZAR + AUTO-START
-- ==========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local islandFolder = Workspace:WaitForChild("Island")

-- === CONFIGURAÇÕES GERAIS ===
local configs = {
    ligado = true,          -- Auto Sea King (Começa ativo)
    autoHop = true,         -- Auto Hop (Começa ativo)
    delayInicial = 25,      -- Tempo de espera inicial
    posicaoInicial = Vector3.new(16619.78, -4.05, -6611.93),
    tempoScan = 10,         -- Tempo procurando antes de trocar de server
    running = true          -- Variável para controlar se o script está rodando
}

-- === CRIAÇÃO DA INTERFACE (UI) ===
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("SeaBestV3") then pGui.SeaBestV3:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SeaBestV3"
ScreenGui.Parent = pGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 1. PAINEL PRINCIPAL (MENU)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -100, 0.4, -75) -- Centro da tela
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Active = true -- Importante para não bugar o clique

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

-- Status Label (Contagem)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Iniciando..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 11

-- Container dos Botões
local ToggleContainer = Instance.new("Frame")
ToggleContainer.Parent = MainFrame
ToggleContainer.BackgroundTransparency = 1
ToggleContainer.Position = UDim2.new(0, 10, 0, 70)
ToggleContainer.Size = UDim2.new(1, -20, 0, 80)

-- Função para Criar Botão Toggle
local function createToggle(name, text, defaultState, yPos, callback)
    local Btn = Instance.new("TextButton")
    Btn.Name = name
    Btn.Parent = ToggleContainer
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
        local newState = not ((Btn.BackgroundColor3.G * 255) > 100)
        Btn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(60, 60, 60)
        Btn.Text = text .. ": " .. (newState and "ON" or "OFF")
        callback(newState)
    end)
    
    return Btn
end

local ToggleSK = createToggle("SKToggle", "Auto Sea Best", configs.ligado, 0, function(state) configs.ligado = state end)
local ToggleHop = createToggle("HopToggle", "Auto Server Hop", configs.autoHop, 40, function(state) configs.autoHop = state end)

-- 2. ÍCONE MINIMIZADO (20x20 PRETO)
local IconFrame = Instance.new("TextButton")
IconFrame.Name = "MinimizedIcon"
IconFrame.Parent = ScreenGui
IconFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
IconFrame.BorderSizePixel = 0
IconFrame.Position = UDim2.new(0.9, 0, 0.2, 0)
IconFrame.Size = UDim2.new(0, 20, 0, 20)
IconFrame.Text = ""
IconFrame.Visible = false
IconFrame.AutoButtonColor = false

local IconStroke = Instance.new("UIStroke")
IconStroke.Parent = IconFrame
IconStroke.Color = Color3.fromRGB(255, 255, 255)
IconStroke.Thickness = 1

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 4)
IconCorner.Parent = IconFrame

-- === SISTEMA DE ARRASTAR (DRAG) ===
local function makeDraggable(guiObject)
    local dragging, dragStart, startPos
    
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
        end
    end)
    
    guiObject.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(MainFrame)
makeDraggable(IconFrame)

-- === AÇÕES DOS BOTÕES DA JANELA ===

-- Minimizar
MiniBtn.Activated:Connect(function()
    MainFrame.Visible = false
    IconFrame.Visible = true
end)

-- Restaurar (Clicar no ícone preto)
IconFrame.Activated:Connect(function()
    IconFrame.Visible = false
    MainFrame.Visible = true
end)

-- Fechar (Destruir Script)
CloseBtn.Activated:Connect(function()
    configs.running = false
    ScreenGui:Destroy()
    print("Script encerrado pelo usuário.")
end)

-- === LÓGICA DO SCRIPT ===

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

local function loopPrincipal()
    -- 1. Delay Inicial (25s)
    for i = configs.delayInicial, 1, -1 do
        if not configs.running then return end
        StatusLabel.Text = "Status: Aguardando Carregamento (" .. i .. "s)"
        task.wait(1)
    end
    
    if not configs.running or not configs.ligado then
        StatusLabel.Text = "Status: Pausado (Aguardando Ativação)"
    end

    -- 2. Teleporte Inicial (Base)
    if configs.ligado and configs.running then
        StatusLabel.Text = "Status: Indo para Posição de Busca..."
        teleportar(CFrame.new(configs.posicaoInicial), false)
        task.wait(2)
    end

    -- 3. Loop de Busca
    local tempoPassado = 0
    while configs.running and tempoPassado < configs.tempoScan do
        if not configs.ligado then
            StatusLabel.Text = "Status: Busca Pausada"
            task.wait(1)
        else
            StatusLabel.Text = "Status: Procurando Ilha (" .. (configs.tempoScan - tempoPassado) .. "s)"
            
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
                
                -- Desativa o Auto Sea Best para evitar loops
                configs.ligado = false
                ToggleSK.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                ToggleSK.Text = "Auto Sea Best: OFF"
                return -- Sai da função pois achou
            end
            
            tempoPassado = tempoPassado + 1
            task.wait(1)
        end
    end

    -- 4. Auto Hop (Se não achou)
    if configs.running and configs.autoHop and configs.ligado then
        trocarDeServidor()
    elseif configs.running then
        StatusLabel.Text = "Status: Tempo esgotado (Hop Desativado)"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
end

-- Inicia o processo em uma thread separada
task.spawn(loopPrincipal)
