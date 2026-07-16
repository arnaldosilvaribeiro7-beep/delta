-- [[ SENSI HUB - INTEGRATED FRUIT TRACKER EDITION ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

-- Prevenir duplicações do Menu anterior
if PlayerGui:FindFirstChild("SensiHub_Landscape") then
    PlayerGui.SensiHub_Landscape:Destroy()
end

-- Estados Globais
_G.AutoFarmFruits = false
_G.AutoFarmMobs = false
_G.AutoChest = false
_G.FastAttack = false
_G.FruitESP = false

-- Criar Interface Paisagem (Horizontal e Profissional)
local SensiHub = Instance.new("ScreenGui")
SensiHub.Name = "SensiHub_Landscape"
SensiHub.Parent = PlayerGui
SensiHub.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 90)
MainFrame.Position = UDim2.new(0.5, -260, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(240, 244, 248) -- Branco Sólido
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = SensiHub

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(10, 80, 160) -- Azul Corporativo
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- Barra de Título Lateral
local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(0, 110, 1, 0)
TitleFrame.BackgroundColor3 = Color3.fromRGB(10, 80, 160)
TitleFrame.BorderSizePixel = 0
TitleFrame.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.6, 0)
Title.BackgroundTransparency = 1
Title.Text = "SENSI HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = TitleFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0.4, 0)
Subtitle.Position = UDim2.new(0, 0, 0.6, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Landscape Pro"
Subtitle.TextColor3 = Color3.fromRGB(200, 220, 255)
Subtitle.TextSize = 10
Subtitle.Font = Enum.Font.SourceSansItalic
Subtitle.Parent = TitleFrame

-- Container Horizontal de Botões
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -120, 1, 0)
Container.Position = UDim2.new(0, 120, 0, 0)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Container
Layout.FillDirection = Enum.FillDirection.Horizontal
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 6)
Layout.VerticalAlignment = Enum.VerticalAlignment.Center

-- Sistema de Arrasto Mobile por Toque
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Teleporte Seguro
local function SecureTeleport(targetCFrame)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = targetCFrame
    end
end

-- Equipar Estilo de Luta/Melee Automaticamente (Punhos)
local function EquipMelee()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer.Backpack
    if character and backpack then
        local tool = character:FindFirstChildOfClass("Tool")
        if not tool or (tool.ToolTip ~= "Melee" and tool.Name ~= "Combat") then
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") and (item.ToolTip == "Melee" or item.Name == "Combat") then
                    character.Humanoid:EquipTool(item)
                    break
                end
            end
        end
    end
end

-- Criador de Botões Profissionais
local function CreateButton(text, order, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 74, 0, 70)
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextColor3 = Color3.fromRGB(10, 80, 160)
    Button.TextSize = 10
    Button.Font = Enum.Font.SourceSansBold
    Button.Text = text .. "\n[OFF]"
    Button.BorderSizePixel = 0
    Button.TextWrapped = true
    Button.LayoutOrder = order
    Button.Parent = Container

    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(200, 210, 225)
    ButtonStroke.Thickness = 1
    ButtonStroke.Parent = Button

    local active = false
    Button.MouseButton1Click:Connect(function()
        active = not active
        if active then
            Button.BackgroundColor3 = Color3.fromRGB(10, 80, 160)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonStroke.Color = Color3.fromRGB(10, 80, 160)
            Button.Text = text .. "\n[ON]"
        else
            Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextColor3 = Color3.fromRGB(10, 80, 160)
            ButtonStroke.Color = Color3.fromRGB(200, 210, 225)
            Button.Text = text .. "\n[OFF]"
        end
        callback(active)
    end)
end

-- Tabela para rastrear e limpar os objetos de ESP
local activeBillboards = {}

-- =================================================================
-- 1. PEGAR TODAS AS FRUTAS (INTEGRADO COM SISTEMA ESP)
-- =================================================================
CreateButton("Pegar Frutas", 1, function(state)
    _G.AutoFarmFruits = state
    task.spawn(function()
        while _G.AutoFarmFruits do
            task.wait(0.5)
            
            -- 1º Passo: Varre o Workspace principal por frutas soltas
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("Tool") and (string.find(obj.Name, "Fruit") or string.find(obj.Name, "Fruta") or obj:FindFirstChild("Handle")) then
                    if obj:FindFirstChild("Handle") then
                        SecureTeleport(obj.Handle.CFrame)
                        task.wait(0.4)
                    end
                end
            end
            
            -- 2º Passo (Integração): Se o ESP estiver ativado, ele busca frutas que foram marcadas com a tag
            if _G.FruitESP then
                for _, billboard in pairs(activeBillboards) do
                    if billboard and billboard.Parent and billboard.Parent:IsA("Part") then
                        -- Teleporta diretamente para a parte onde o marcador de ESP está fixado
                        SecureTeleport(billboard.Parent.CFrame)
                        task.wait(0.4)
                    end
                end
            end
        end
    end)
end)

-- =================================================================
-- 2. AUTO FARM MOBS (ESQUIVA DE 1 SEGUNDO E ATAQUE CORRIGIDO)
-- =================================================================
CreateButton("Farm Mobs", 2, function(state)
    _G.AutoFarmMobs = state
    task.spawn(function()
        local currentTarget = nil
        local lastShift = os.time()
        local shiftDirection = true

        -- Loop dedicado ao clique físico do soco
        task.spawn(function()
            while _G.AutoFarmMobs do
                if _G.FastAttack then
                    task.wait(0.05)
                else
                    task.wait(0.15)
                end
                
                if currentTarget and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health > 0 then
                    EquipMelee()
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(0, 0))
                end
            end
        end)

        -- Loop de detecção e movimentação com esquiva a cada 1s
        while _G.AutoFarmMobs do
            task.wait(0.05)
            
            if not currentTarget or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
                currentTarget = nil
                local enemies = Workspace:FindFirstChild("Enemies") or Workspace
                for _, enemy in pairs(enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                        currentTarget = enemy
                        break
                    end
                end
            end

            if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
                if os.time() - lastShift >= 1 then
                    shiftDirection = not shiftDirection
                    lastShift = os.time()
                end

                local positionOffset = shiftDirection and 3.5 or -3.5
                SecureTeleport(currentTarget.HumanoidRootPart.CFrame * CFrame.new(0, 1.5, positionOffset))
            end
        end
    end)
end)

-- =================================================================
-- 3. ATAQUE RÁPIDO (FAST ATTACK)
-- =================================================================
CreateButton("Fast Attack", 3, function(state)
    _G.FastAttack = state
end)

-- =================================================================
-- 4. ESP FRUTAS (RASTRADOR VISUAL + ALVO PARA COLETA)
-- =================================================================
CreateButton("Fruit ESP", 4, function(state)
    _G.FruitESP = state
    if not state then
        -- Limpa marcadores se for desligado
        for _, billboard in pairs(activeBillboards) do
            if billboard then billboard:Destroy() end
        end
        activeBillboards = {}
    else
        task.spawn(function()
            while _G.FruitESP do
                task.wait(1)
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj:IsA("Tool") and (string.find(obj.Name, "Fruit") or string.find(obj.Name, "Fruta")) and obj:FindFirstChild("Handle") then
                        if not obj.Handle:FindFirstChild("FruitESP_Tag") then
                            local BillboardGui = Instance.new("BillboardGui")
                            BillboardGui.Name = "FruitESP_Tag"
                            BillboardGui.AlwaysOnTop = true
                            BillboardGui.Size = UDim2.new(0, 100, 0, 30)
                            BillboardGui.Adornee = obj.Handle
                            BillboardGui.Parent = obj.Handle

                            local TextLabel = Instance.new("TextLabel")
                            TextLabel.Size = UDim2.new(1, 0, 1, 0)
                            TextLabel.BackgroundTransparency = 1
                            TextLabel.TextColor3 = Color3.fromRGB(10, 80, 160) -- Texto Azul Escuro Profissional
                            TextLabel.TextSize = 10
                            TextLabel.Font = Enum.Font.SourceSansBold
                            TextLabel.Text = "[🍒 " .. obj.Name .. "]"
                            TextLabel.Parent = BillboardGui

                            table.insert(activeBillboards, BillboardGui)
                        end
                    end
                end
            end
        end)
    end
end)

-- =================================================================
-- 5. AUTO FARM CHESTS (PEGA TODOS OS BAÚS DO MAPA)
-- =================================================================
CreateButton("Farm Baús", 5, function(state)
    _G.AutoChest = state
    task.spawn(function()
        while _G.AutoChest do
            task.wait(0.5)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Part") and (string.find(obj.Name, "Chest") or string.find(obj.Name, "Chest1") or string.find(obj.Name, "Chest2") or string.find(obj.Name, "Chest3")) then
                    SecureTeleport(obj.CFrame + Vector3.new(0, 2, 0))
                    task.wait(0.4)
                end
            end
        end
    end)
end)
