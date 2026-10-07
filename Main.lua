--==================================================
-- DEBUG AIM + ESP + SKELETON + WEAPON ESP
-- OPTIMIZADO + KIO SCRIPT
-- PARA TU PROPIA EXPERIENCIA DE ROBLOX
-- LocalScript
-- StarterPlayer > StarterPlayerScripts
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- CONFIGURACIÓN
--==================================================

local AimEnabled = true
local ESPEnabled = true
local SkeletonEnabled = true
local IgnoreFriends = true
local TeamCheck = false
local WallCheck = false
local WeaponESPEnabled = true
local HologramEnabled = true
local FOVEnabled = true

local AimPart = "Head"
local FOV = 180
local Precision = 35
local MaxDistance = 500

local Friends = {}

local ESPUpdateInterval = 0.08

--==================================================
-- COLORES
--==================================================

local HologramColor = Color3.fromRGB(0, 200, 255)
local HologramOutline = Color3.fromRGB(150, 245, 255)
local FOVColor = Color3.fromRGB(255, 0, 0)
local SkeletonColor = Color3.fromRGB(0, 220, 255)

--==================================================
-- ARMAS
--==================================================

local Armas = {
	["M24"] = true,
	["RPG"] = true,
	["M249"] = true,
	["M16"] = true,
	["AK47"] = true,
	["MP5"] = true,
	["Hunting Rifle"] = true,
	["Remington"] = true,
	["M4"] = true,
	["Shotgun"] = true,
	["Pistol"] = true,
	["Energy Shot"] = true,
	["Draco"] = true
}

local Legendarias = {
	["RPG"] = true,
	["Remington"] = true,
	["AK47"] = true,
	["MP5"] = true
}

local Epicas = {
	["M24"] = true,
	["Energy Shot"] = true,
	["Draco"] = true
}

--==================================================
-- PATRONES
--==================================================

local WeaponPatterns = {
	["MP5"] = {
		"mp5_",
		"mp5"
	},

	["AK47"] = {
		"ak47",
		"ak-47",
		"ak 47"
	},

	["Draco"] = {
		"draco_",
		"draco"
	},

	["M24"] = {
		"m24_",
		"m24"
	},

	["RPG"] = {
		"rpg"
	},

	["M249"] = {
		"m249"
	},

	["M16"] = {
		"m16"
	},

	["Hunting Rifle"] = {
		"hunting rifle",
		"huntingrifle"
	},

	["Remington"] = {
		"remington"
	},

	["M4"] = {
		"m4"
	},

	["Shotgun"] = {
		"shotgun"
	},

	["Pistol"] = {
		"pistol"
	},

	["Energy Shot"] = {
		"energy shot",
		"energyshot"
	}
}

--==================================================
-- IDS
--==================================================

local WeaponIDs = {
	["747294"] = "MP5",
	["345038"] = "Draco",
	["36248"] = "AK47"
}

--==================================================
-- DATOS
--==================================================

local ESPData = {}
local WeaponESPs = {}
local CharacterConnections = {}

--==================================================
-- FRIENDS
--==================================================

local function IsFriend(player)

	if not player then
		return false
	end

	if player == LocalPlayer then
		return true
	end

	if Friends[string.lower(player.Name)] then
		return true
	end

	local success, result = pcall(function()
		return LocalPlayer:IsFriendsWith(player.UserId)
	end)

	return success and result
end

--==================================================
-- VALIDAR TARGET
--==================================================

local function ValidTarget(player)

	if not player then
		return false
	end

	if player == LocalPlayer then
		return false
	end

	if IgnoreFriends and IsFriend(player) then
		return false
	end

	if TeamCheck and player.Team == LocalPlayer.Team then
		return false
	end

	local character = player.Character

	if not character then
		return false
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return false
	end

	if humanoid.Health <= 0 then
		return false
	end

	return true
end

--==================================================
-- TARGET PART
--==================================================

local function GetTargetPart(character)

	if not character then
		return nil
	end

	local part =
		character:FindFirstChild(AimPart)

	if part and part:IsA("BasePart") then
		return part
	end

	local head =
		character:FindFirstChild("Head")

	if head and head:IsA("BasePart") then
		return head
	end

	local root =
		character:FindFirstChild("HumanoidRootPart")

	if root and root:IsA("BasePart") then
		return root
	end

	return nil
end

--==================================================
-- WALL CHECK
--==================================================

local function CanSee(part)

	if not WallCheck then
		return true
	end

	local camera = workspace.CurrentCamera

	if not camera or not part then
		return false
	end

	local params = RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	local ignore = {}

	if LocalPlayer.Character then
		table.insert(
			ignore,
			LocalPlayer.Character
		)
	end

	-- CORREGIDO
	params.FilterDescendantsInstances = ignore

	local origin =
		camera.CFrame.Position

	local direction =
		part.Position - origin

	local result =
		workspace:Raycast(
			origin,
			direction,
			params
		)

	if not result then
		return true
	end

	return result.Instance:IsDescendantOf(
		part.Parent
	)
end

--==================================================
-- BUSCAR TARGET
--==================================================

local function GetClosestTarget()

	local camera = workspace.CurrentCamera

	if not camera then
		return nil, nil
	end

	local viewport =
		camera.ViewportSize

	local center =
		Vector2.new(
			viewport.X / 2,
			viewport.Y / 2
		)

	local closestPlayer = nil
	local closestPart = nil
	local closestDistance = FOV

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if ValidTarget(player) then

			local character =
				player.Character

			local part =
				GetTargetPart(character)

			if part then

				local distance3D =
					(
						camera.CFrame.Position -
						part.Position
					).Magnitude

				if distance3D <= MaxDistance then

					local screenPosition, visible =
						camera:WorldToViewportPoint(
							part.Position
						)

					if visible then

						local screenDistance =
							(
								Vector2.new(
									screenPosition.X,
									screenPosition.Y
								) -
								center
							).Magnitude

						if screenDistance <=
							closestDistance then

							if CanSee(part) then

								closestDistance =
									screenDistance

								closestPlayer =
									player

								closestPart =
									part
							end
						end
					end
				end
			end
		end
	end

	return closestPlayer, closestPart
end

--==================================================
-- GUI
--==================================================

local gui =
	Instance.new("ScreenGui")

gui.Name = "DebugAimESP"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 1000

gui.Parent =
	LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- BIENVENIDA
--==================================================

local WelcomeFrame =
	Instance.new("Frame")

WelcomeFrame.Name = "KioWelcome"
WelcomeFrame.Size = UDim2.fromScale(1, 1)
WelcomeFrame.Position = UDim2.fromScale(0, 0)
WelcomeFrame.BackgroundColor3 =
	Color3.fromRGB(0, 0, 0)
WelcomeFrame.BorderSizePixel = 0
WelcomeFrame.ZIndex = 10000
WelcomeFrame.Parent = gui

local WelcomeText =
	Instance.new("TextLabel")

WelcomeText.Name = "WelcomeText"

WelcomeText.AnchorPoint =
	Vector2.new(0.5, 0.5)

WelcomeText.Position =
	UDim2.fromScale(0.5, 0.5)

WelcomeText.Size =
	UDim2.new(0, 600, 0, 80)

WelcomeText.BackgroundTransparency = 1

WelcomeText.Text =
	"GRACIAS POR USAR KIO_SCRIPT🃏"

WelcomeText.TextColor3 =
	Color3.fromRGB(255, 0, 0)

WelcomeText.TextStrokeColor3 =
	Color3.fromRGB(60, 0, 0)

WelcomeText.TextStrokeTransparency = 0

WelcomeText.TextSize = 28
WelcomeText.Font = Enum.Font.SourceSansBold
WelcomeText.TextScaled = true
WelcomeText.ZIndex = 10001
WelcomeText.Parent = WelcomeFrame
WelcomeText.TextTransparency = 1

task.spawn(function()

	for i = 1, 10 do

		WelcomeText.TextTransparency =
			1 - (i / 10)

		task.wait(0.04)
	end

	task.wait(1.8)

	for i = 1, 10 do

		WelcomeText.TextTransparency =
			i / 10

		task.wait(0.04)
	end

	if WelcomeFrame then
		WelcomeFrame:Destroy()
	end
end)

--==================================================
-- AIM BUTTON
--==================================================

local AimButton =
	Instance.new("TextButton")

AimButton.Name = "AimButton"

AimButton.Size =
	UDim2.new(0, 90, 0, 35)

AimButton.Position =
	UDim2.new(1, -105, 0, 20)

AimButton.BackgroundColor3 =
	Color3.fromRGB(25, 25, 25)

AimButton.TextColor3 =
	Color3.new(1, 1, 1)

AimButton.TextSize = 14
AimButton.Text = "AIM: ON"
AimButton.Parent = gui

--==================================================
-- MENU
--==================================================

local MenuButton =
	Instance.new("TextButton")

MenuButton.Size =
	UDim2.new(0, 45, 0, 40)

MenuButton.Position =
	UDim2.new(0, 15, 0, 20)

MenuButton.BackgroundColor3 =
	Color3.fromRGB(25, 25, 25)

MenuButton.TextColor3 =
	Color3.new(1, 1, 1)

MenuButton.Text = "☰"
MenuButton.TextSize = 22
MenuButton.Parent = gui

local Menu =
	Instance.new("Frame")

Menu.Size =
	UDim2.new(0, 290, 0, 470)

Menu.Position =
	UDim2.new(0.5, -145, 0.5, -235)

Menu.BackgroundColor3 =
	Color3.fromRGB(20, 20, 20)

Menu.Visible = false
Menu.Parent = gui

--==================================================
-- CREAR BOTÓN
--==================================================

local function Button(text, y)

	local button =
		Instance.new("TextButton")

	button.Size =
		UDim2.new(0, 260, 0, 35)

	button.Position =
		UDim2.new(0, 15, 0, y)

	button.BackgroundColor3 =
		Color3.fromRGB(40, 40, 40)

	button.TextColor3 =
		Color3.new(1, 1, 1)

	button.TextSize = 14
	button.Text = text
	button.Parent = Menu

	return button
end

--==================================================
-- AIM
--==================================================

local AimToggle =
	Button("AIM: ON", 15)

local function UpdateAimButtons()

	local text =
		AimEnabled
		and "AIM: ON"
		or "AIM: OFF"

	AimButton.Text = text
	AimToggle.Text = text
end

local function ToggleAim()

	AimEnabled =
		not AimEnabled

	UpdateAimButtons()
end

AimButton.MouseButton1Click:Connect(
	ToggleAim
)

AimToggle.MouseButton1Click:Connect(
	ToggleAim
)

--==================================================
-- TARGET
--==================================================

local TargetButton =
	Button("TARGET: HEAD", 55)

TargetButton.MouseButton1Click:Connect(
	function()

		if AimPart == "Head" then

			AimPart =
				"HumanoidRootPart"

			TargetButton.Text =
				"TARGET: BODY"

		else

			AimPart =
				"Head"

			TargetButton.Text =
				"TARGET: HEAD"
		end
	end
)

--==================================================
-- ESP
--==================================================

local ESPButton =
	Button("ESP: ON", 95)

ESPButton.MouseButton1Click:Connect(
	function()

		ESPEnabled =
			not ESPEnabled

		ESPButton.Text =
			ESPEnabled
			and "ESP: ON"
			or "ESP: OFF"
	end
)

--==================================================
-- SKELETON
--==================================================

local SkeletonButton =
	Button("SKELETON: ON", 135)

SkeletonButton.MouseButton1Click:Connect(
	function()

		SkeletonEnabled =
			not SkeletonEnabled

		SkeletonButton.Text =
			SkeletonEnabled
			and "SKELETON: ON"
			or "SKELETON: OFF"
	end
)

--==================================================
-- WEAPON ESP
--==================================================

local WeaponESPButton =
	Button("WEAPON ESP: ON", 175)

--==================================================
-- FOV
--==================================================

local FOVButton =
	Button("FOV: 180", 215)

local FOVToggle =
	Button("FOV CIRCLE: ON", 255)

local PrecisionButton =
	Button("PRECISION: 35%", 295)

local FriendButton =
	Button("FRIENDS: IGNORE", 335)

--==================================================
-- FRIEND BOX
--==================================================

local FriendBox =
	Instance.new("TextBox")

FriendBox.Size =
	UDim2.new(0, 170, 0, 35)

FriendBox.Position =
	UDim2.new(0, 15, 0, 375)

FriendBox.BackgroundColor3 =
	Color3.fromRGB(35, 35, 35)

FriendBox.TextColor3 =
	Color3.new(1, 1, 1)

FriendBox.PlaceholderText =
	"Username"

FriendBox.Text = ""
FriendBox.TextSize = 14
FriendBox.Parent = Menu

--==================================================
-- ADD FRIEND
--==================================================

local AddFriend =
	Instance.new("TextButton")

AddFriend.Size =
	UDim2.new(0, 70, 0, 35)

AddFriend.Position =
	UDim2.new(0, 195, 0, 375)

AddFriend.BackgroundColor3 =
	Color3.fromRGB(35, 100, 45)

AddFriend.TextColor3 =
	Color3.new(1, 1, 1)

AddFriend.Text = "ADD"
AddFriend.Parent = Menu

AddFriend.MouseButton1Click:Connect(
	function()

		local name =
			FriendBox.Text
			:gsub("^%s+", "")
			:gsub("%s+$", "")

		if name ~= "" then

			Friends[
				string.lower(name)
			] = true

			FriendBox.Text = ""
		end
	end
)

--==================================================
-- REMOVE FRIEND
--==================================================

local RemoveFriend =
	Instance.new("TextButton")

RemoveFriend.Size =
	UDim2.new(0, 125, 0, 35)

RemoveFriend.Position =
	UDim2.new(0, 15, 0, 420)

RemoveFriend.BackgroundColor3 =
	Color3.fromRGB(110, 35, 35)

RemoveFriend.TextColor3 =
	Color3.new(1, 1, 1)

RemoveFriend.Text =
	"REMOVE FRIEND"

RemoveFriend.Parent = Menu

RemoveFriend.MouseButton1Click:Connect(
	function()

		local name =
			FriendBox.Text
			:gsub("^%s+", "")
			:gsub("%s+$", "")

		if name ~= "" then

			Friends[
				string.lower(name)
			] = nil

			FriendBox.Text = ""
		end
	end
)

--==================================================
-- FOV CIRCLE
--==================================================

local FOVCircle =
	Instance.new("Frame")

FOVCircle.Name = "FOVCircle"

FOVCircle.AnchorPoint =
	Vector2.new(0.5, 0.5)

FOVCircle.Position =
	UDim2.new(0.5, 0, 0.5, 0)

FOVCircle.Size =
	UDim2.new(
		0,
		FOV * 2,
		0,
		FOV * 2
	)

FOVCircle.BackgroundTransparency = 1
FOVCircle.ZIndex = 500
FOVCircle.Parent = gui

local Corner =
	Instance.new("UICorner")

Corner.CornerRadius =
	UDim.new(1, 0)

Corner.Parent = FOVCircle

local Stroke =
	Instance.new("UIStroke")

Stroke.Thickness = 2
Stroke.Color = FOVColor
Stroke.Parent = FOVCircle

--==================================================
-- AIM SYSTEM
--==================================================

RunService.RenderStepped:Connect(
	function()

		if not AimEnabled then
			return
		end

		local camera =
			workspace.CurrentCamera

		if not camera then
			return
		end

		local player, part =
			GetClosestTarget()

		if not player or not part then
			return
		end

		local targetCFrame =
			CFrame.lookAt(
				camera.CFrame.Position,
				part.Position
			)

		local alpha =
			math.clamp(
				Precision / 100,
				0.01,
				1
			)

		camera.CFrame =
			camera.CFrame:Lerp(
				targetCFrame,
				alpha
			)
	end
)

--==================================================
-- REMOVE ESP
--==================================================

local function RemoveESP(player)

	local data =
		ESPData[player]

	if not data then
		return
	end

	if data.Highlight then
		data.Highlight:Destroy()
	end

	if data.NameGui then
		data.NameGui:Destroy()
	end

	for _, beam in ipairs(
		data.Beams or {}
	) do

		if beam then
			beam:Destroy()
		end
	end

	for _, attachment in ipairs(
		data.Attachments or {}
	) do

		if attachment then
			attachment:Destroy()
		end
	end

	ESPData[player] = nil
end

--==================================================
-- CREATE ESP
--==================================================

local function CreateESP(player)

	if player == LocalPlayer then
		return
	end

	local character =
		player.Character

	if not character then
		return
	end

	local root =
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not root then
		return
	end

	RemoveESP(player)

	local data = {
		Beams = {},
		Attachments = {}
	}

	ESPData[player] = data

	local highlight =
		Instance.new("Highlight")

	highlight.Name =
		"BlueHologram"

	highlight.FillColor =
		HologramColor

	highlight.OutlineColor =
		HologramOutline

	highlight.FillTransparency = 0.35
	highlight.OutlineTransparency = 0

	highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Enabled =
		ESPEnabled and HologramEnabled

	highlight.Adornee =
		character

	highlight.Parent =
		character

	data.Highlight =
		highlight

	local billboard =
		Instance.new("BillboardGui")

	billboard.Name =
		"PlayerESP"

	billboard.Size =
		UDim2.new(0, 180, 0, 35)

	billboard.StudsOffset =
		Vector3.new(0, 3, 0)

	billboard.AlwaysOnTop = true

	billboard.Parent =
		root

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.fromScale(1, 1)

	label.BackgroundTransparency = 1

	label.TextColor3 =
		HologramOutline

	label.TextStrokeColor3 =
		Color3.fromRGB(0, 40, 60)

	label.TextStrokeTransparency = 0

	label.TextSize = 13

	label.Font =
		Enum.Font.SourceSans

	label.Text =
		player.Name

	label.Parent =
		billboard

	data.NameGui =
		billboard

	data.NameLabel =
		label

	local connections = {

		{"Head", "UpperTorso"},

		{"UpperTorso", "LowerTorso"},

		{"UpperTorso", "LeftUpperArm"},

		{"LeftUpperArm", "LeftLowerArm"},

		{"LeftLowerArm", "LeftHand"},

		{"UpperTorso", "RightUpperArm"},

		{"RightUpperArm", "RightLowerArm"},

		{"RightLowerArm", "RightHand"},

		{"LowerTorso", "LeftUpperLeg"},

		{"LeftUpperLeg", "LeftLowerLeg"},

		{"LeftLowerLeg", "LeftFoot"},

		{"LowerTorso", "RightUpperLeg"},

		{"RightUpperLeg", "RightLowerLeg"},

		{"RightLowerLeg", "RightFoot"}
	}

	for _, pair in ipairs(
		connections
	) do

		local part1 =
			character:FindFirstChild(pair[1])

		local part2 =
			character:FindFirstChild(pair[2])

		if part1 and part2 then

			local a1 =
				Instance.new("Attachment")

			a1.Parent =
				part1

			local a2 =
				Instance.new("Attachment")

			a2.Parent =
				part2

			local beam =
				Instance.new("Beam")

			beam.Attachment0 =
				a1

			beam.Attachment1 =
				a2

			beam.Width0 = 0.05
			beam.Width1 = 0.05
			beam.FaceCamera = true

			beam.Color =
				ColorSequence.new(
					SkeletonColor
				)

			beam.LightEmission = 1

			beam.Parent =
				part1

			table.insert(
				data.Attachments,
				a1
			)

			table.insert(
				data.Attachments,
				a2
			)

			table.insert(
				data.Beams,
				beam
			)
		end
	end
end

--==================================================
-- WEAPON PART
--==================================================

local function ObtenerWeaponPart(objeto)

	if not objeto then
		return nil
	end

	if objeto:IsA("BasePart") then
		return objeto
	end

	local handle =
		objeto:FindFirstChild(
			"Handle",
			true
		)

	if handle and
		handle:IsA("BasePart") then

		return handle
	end

	return objeto:FindFirstChildWhichIsA(
		"BasePart",
		true
	)
end

--==================================================
-- DETECTAR ARMA
--==================================================

local function DetectarArma(objeto)

	if not objeto then
		return nil
	end

	local nombre =
		string.lower(
			objeto.Name or ""
		)

	local idWeapon =
		WeaponIDs[objeto.Name]

	if idWeapon then
		return idWeapon
	end

	for weaponName, patterns in pairs(
		WeaponPatterns
	) do

		for _, pattern in ipairs(
			patterns
		) do

			if string.find(
				nombre,
				string.lower(pattern),
				1,
				true
			) then

				return weaponName
			end
		end
	end

	return nil
end

--==================================================
-- DETECTAR ARMA DENTRO DE OBJETO
--==================================================

local function DetectarArmaCompleta(objeto)

	if not objeto then
		return nil
	end

	local arma =
		DetectarArma(objeto)

	if arma then
		return arma
	end

	for _, child in ipairs(
		objeto:GetDescendants()
	) do

		arma =
			DetectarArma(child)

		if arma then
			return arma
		end
	end

	return nil
end

--==================================================
-- COLOR DE ARMAS
--==================================================

local function ObtenerWeaponColor(nombre)

	if Legendarias[nombre] then

		return Color3.fromRGB(
			255,
			215,
			0
		)

	elseif Epicas[nombre] then

		return Color3.fromRGB(
			180,
			70,
			255
		)
	end

	return Color3.fromRGB(
		255,
		255,
		255
	)
end

--==================================================
-- CREAR WEAPON ESP
--==================================================

local function CrearWeaponESP(
	objeto,
	nombreArma
)

	if not WeaponESPEnabled then
		return
	end

	if not objeto or not objeto.Parent then
		return
	end

	nombreArma =
		nombreArma
		or DetectarArmaCompleta(objeto)

	if not nombreArma then
		return
	end

	local parte =
		ObtenerWeaponPart(objeto)

	if not parte then
		return
	end

	-- Actualizar existente

	if WeaponESPs[objeto] then

		local record =
			WeaponESPs[objeto]

		local weaponGui =
			record.Gui

		if weaponGui then

			if weaponGui.Adornee ~= parte then
				weaponGui.Adornee =
					parte
			end

			return
		end
	end

	-- Crear nuevo

	local weaponGui =
		Instance.new("BillboardGui")

	weaponGui.Name =
		"WeaponESP"

	weaponGui.Adornee =
		parte

	weaponGui.Size =
		UDim2.new(
			0,
			150,
			0,
			30
		)

	weaponGui.StudsOffset =
		Vector3.new(
			0,
			3,
			0
		)

	weaponGui.AlwaysOnTop = true

	weaponGui.ZIndexBehavior =
		Enum.ZIndexBehavior.Sibling

	weaponGui.Parent =
		gui

	local texto =
		Instance.new("TextLabel")

	texto.Name =
		"WeaponName"

	texto.BackgroundTransparency = 1

	texto.Size =
		UDim2.fromScale(
			1,
			1
		)

	texto.Font =
		Enum.Font.SourceSans

	texto.TextSize = 15

	texto.TextScaled = false
	texto.TextWrapped = false

	texto.TextXAlignment =
		Enum.TextXAlignment.Center

	texto.TextYAlignment =
		Enum.TextYAlignment.Center

	texto.TextColor3 =
		ObtenerWeaponColor(
			nombreArma
		)

	texto.Text =
		nombreArma

	texto.TextStrokeColor3 =
		Color3.fromRGB(
			0,
			0,
			0
		)

	texto.TextStrokeTransparency =
		0.25

	texto.ZIndex = 1000

	texto.Parent =
		weaponGui

	if Legendarias[nombreArma] then

		local glow =
			Instance.new("UIStroke")

		glow.Name =
			"GoldGlow"

		glow.Thickness =
			0.5

		glow.Transparency =
			0.05

		glow.Color =
			Color3.fromRGB(
				255,
				190,
				0
			)

		glow.Parent =
			texto
	end

	WeaponESPs[objeto] = {
		Gui = weaponGui,
		WeaponName = nombreArma
	}
end

--==================================================
-- REMOVE WEAPON ESP
--==================================================

local function RemoveWeaponESP(objeto)

	local record =
		WeaponESPs[objeto]

	if record then

		local weaponGui =
			record.Gui

		if weaponGui then

			pcall(function()
				weaponGui:Destroy()
			end)
		end
	end

	WeaponESPs[objeto] =
		nil
end

--==================================================
-- OBTENER ARMA EQUIPADA
--==================================================

local function GetEquippedWeapons(player)

	local equipped = {}

	if not player then
		return equipped
	end

	local character =
		player.Character

	if not character then
		return equipped
	end

	-- SOLO OBJETOS DIRECTOS DEL CHARACTER
	-- No se escanea Workspace

	for _, objeto in ipairs(
		character:GetChildren()
	) do

		local esCandidato =
			objeto:IsA("Tool")
			or objeto:IsA("Model")
			or objeto:IsA("Folder")
			or objeto:IsA("BasePart")

		if esCandidato then

			local arma =
				DetectarArmaCompleta(objeto)

			if arma then

				equipped[objeto] =
					arma
			end
		end
	end

	return equipped
end

--==================================================
-- SINCRONIZAR WEAPON ESP
--==================================================

local function ScanPlayerWeapons(player)

	if not WeaponESPEnabled then
		return
	end

	if not player or
		player == LocalPlayer then

		return
	end

	local character =
		player.Character

	if not character then
		return
	end

	local equipped =
		GetEquippedWeapons(player)

	-- Crear / actualizar

	for objeto, nombreArma in pairs(
		equipped
	) do

		CrearWeaponESP(
			objeto,
			nombreArma
		)

		local record =
			WeaponESPs[objeto]

		if record and record.Gui then

			local parte =
				ObtenerWeaponPart(objeto)

			if parte then
				record.Gui.Adornee =
					parte
			end
		end
	end

	-- Eliminar cualquier arma que
	-- ya no esté equipada

	for objeto, _ in pairs(
		WeaponESPs
	) do

		local keep = false

		if objeto and
			objeto.Parent then

			if objeto:IsDescendantOf(
				character
			) then

				if equipped[objeto] then
					keep = true
				end
			end
		end

		if not keep then

			RemoveWeaponESP(
				objeto
			)
		end
	end
end

--==================================================
-- CONECTAR WEAPON ESP
--==================================================

local function ConnectWeaponDetection(
	player,
	character
)

	if player == LocalPlayer then
		return
	end

	if not character then
		return
	end

	ClearCharacterConnections(player)

	-- Sincronización inicial

	task.defer(function()

		task.wait(0.25)

		if character.Parent then

			ScanPlayerWeapons(
				player
			)
		end
	end)

	local addedConnection =
		character.ChildAdded:Connect(
			function()

				task.defer(function()

					if character.Parent then

						ScanPlayerWeapons(
							player
						)
					end
				end)
			end
		)

	local removedConnection =
		character.ChildRemoved:Connect(
			function(objeto)

				if WeaponESPs[objeto] then

					RemoveWeaponESP(
						objeto
					)
				end

				task.defer(function()

					if character.Parent then

						ScanPlayerWeapons(
							player
						)
					end
				end)
			end
		)

	CharacterConnections[player] =
		CharacterConnections[player]
		or {}

	table.insert(
		CharacterConnections[player],
		addedConnection
	)

	table.insert(
		CharacterConnections[player],
		removedConnection
	)
end

--==================================================
-- LIMPIAR CONEXIONES
--==================================================

function ClearCharacterConnections(player)

	local connections =
		CharacterConnections[player]

	if not connections then
		return
	end

	for _, connection in ipairs(
		connections
	) do

		if connection then
			connection:Disconnect()
		end
	end

	CharacterConnections[player] =
		nil
end

--==================================================
-- SINCRONIZACIÓN CONTINUA DE ARMAS
--==================================================

task.spawn(function()

	while true do

		task.wait(0.10)

		if WeaponESPEnabled then

			for _, player in ipairs(
				Players:GetPlayers()
			) do

				if player ~= LocalPlayer then

					ScanPlayerWeapons(
						player
					)
				end
			end
		end
	end
end)

--==================================================
-- WEAPON ESP BUTTON
--==================================================

WeaponESPButton.MouseButton1Click:Connect(
	function()

		WeaponESPEnabled =
			not WeaponESPEnabled

		WeaponESPButton.Text =
			WeaponESPEnabled
			and "WEAPON ESP: ON"
			or "WEAPON ESP: OFF"

		if not WeaponESPEnabled then

			for objeto, _ in pairs(
				WeaponESPs
			) do

				RemoveWeaponESP(
					objeto
				)
			end

		else

			for _, player in ipairs(
				Players:GetPlayers()
			) do

				if player ~= LocalPlayer then

					ScanPlayerWeapons(
						player
					)
				end
			end
		end
	end
)

--==================================================
-- FOV
--==================================================

FOVButton.MouseButton1Click:Connect(
	function()

		FOV += 25

		if FOV > 500 then
			FOV = 50
		end

		FOVButton.Text =
			"FOV: " .. FOV
	end
)

--==================================================
-- FOV TOGGLE
--==================================================

FOVToggle.MouseButton1Click:Connect(
	function()

		FOVEnabled =
			not FOVEnabled

		FOVToggle.Text =
			FOVEnabled
			and "FOV CIRCLE: ON"
			or "FOV CIRCLE: OFF"
	end
)

--==================================================
-- PRECISION
--==================================================

PrecisionButton.MouseButton1Click:Connect(
	function()

		Precision += 10

		if Precision > 100 then
			Precision = 10
		end

		PrecisionButton.Text =
			"PRECISION: "
			.. Precision
			.. "%"
	end
)

--==================================================
-- FRIENDS
--==================================================

FriendButton.MouseButton1Click:Connect(
	function()

		IgnoreFriends =
			not IgnoreFriends

		FriendButton.Text =
			IgnoreFriends
			and "FRIENDS: IGNORE"
			or "FRIENDS: TARGET"
	end
)

--==================================================
-- MENU
--==================================================

MenuButton.MouseButton1Click:Connect(
	function()

		Menu.Visible =
			not Menu.Visible
	end
)

--==================================================
-- ESP UPDATE
--==================================================

local ESPUpdateTimer = 0

RunService.RenderStepped:Connect(
	function(deltaTime)

		ESPUpdateTimer += deltaTime

		if ESPUpdateTimer <
			ESPUpdateInterval then

			return
		end

		ESPUpdateTimer = 0

		FOVCircle.Visible =
			FOVEnabled
			and AimEnabled

		FOVCircle.Size =
			UDim2.new(
				0,
				FOV * 2,
				0,
				FOV * 2
			)

		for player, data in pairs(
			ESPData
		) do

			if player and
				player.Parent then

				local show =
					ESPEnabled
					and not (
						IgnoreFriends
						and IsFriend(player)
					)

				if data.Highlight then

					data.Highlight.Enabled =
						show
						and HologramEnabled
				end

				if data.NameGui then

					data.NameGui.Enabled =
						show
				end

				for _, beam in ipairs(
					data.Beams or {}
				) do

					if beam then

						beam.Enabled =
							show
							and SkeletonEnabled
					end
				end
			end
		end
	end
)

--==================================================
-- PLAYER SETUP
--==================================================

local function SetupPlayer(player)

	if player == LocalPlayer then
		return
	end

	if player.Character then

		task.defer(
			function()

				CreateESP(player)

				ConnectWeaponDetection(
					player,
					player.Character
				)
			end
		)
	end

	player.CharacterAdded:Connect(
		function(character)

			ClearCharacterConnections(
				player
			)

			-- Limpiar armas antiguas
			for objeto, _ in pairs(
				WeaponESPs
			) do

				if objeto then

					local belongs = false

					pcall(function()

						if objeto:IsDescendantOf(
							character
						) then

							belongs = true
						end
					end)

					if belongs then

						RemoveWeaponESP(
							objeto
						)
					end
				end
			end

			task.wait(0.25)

			CreateESP(player)

			ConnectWeaponDetection(
				player,
				character
			)
		end
	)
end

--==================================================
-- PLAYERS EXISTENTES
--==================================================

for _, player in ipairs(
	Players:GetPlayers()
) do

	SetupPlayer(player)
end

--==================================================
-- PLAYER NUEVO
--==================================================

Players.PlayerAdded:Connect(
	SetupPlayer
)

--==================================================
-- PLAYER SALE
--==================================================

Players.PlayerRemoving:Connect(
	function(player)

		ClearCharacterConnections(
			player
		)

		RemoveESP(player)

		for objeto, _ in pairs(
			WeaponESPs
		) do

			local belongsToPlayer =
				false

			pcall(function()

				if player.Character and
					objeto and
					objeto:IsDescendantOf(
						player.Character
					) then

					belongsToPlayer =
						true
				end
			end)

			if belongsToPlayer then

				RemoveWeaponESP(
					objeto
				)
			end
		end
	end
)

--==================================================
-- Q = AIM
--==================================================

UserInputService.InputBegan:Connect(
	function(input, processed)

		if processed then
			return
		end

		if input.KeyCode ==
			Enum.KeyCode.Q then

			ToggleAim()
		end
	end
)

--==================================================
-- MENSAJES
--==================================================

print(
	"[KIO_SCRIPT] CARGADO CORRECTAMENTE"
)

print(
	"[WEAPON ESP] SEGUIMIENTO DINÁMICO ACTIVO"
)

print(
	"[WEAPON ESP] SOLO ARMAS EQUIPADAS"
)

print(
	"[OPTIMIZADO] SIN ESCANEO DE ARMAS POR FRAME"
)

print(
	"[FRIENDS] ACTIVO"
)

print(
	"[HOLOGRAMA] ACTIVO"
)
