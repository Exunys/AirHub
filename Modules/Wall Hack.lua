--[[

	Wall Hack Module [AirHub] by Exunys © CC0 1.0 Universal (2023)

	https://github.com/Exunys

]]

--// Cache

local next, tostring, pcall, getgenv, setmetatable, mathfloor, mathabs, wait = next, tostring, pcall, getgenv, setmetatable, math.floor, math.abs, task.wait
local WorldToViewportPoint, Vector2new, Vector3new, Vector3zero, CFramenew, Drawingnew, Color3fromRGB = nil, Vector2.new, Vector3.new, Vector3.zero, CFrame.new, Drawing.new, Color3.fromRGB

--// Launching checks

if not getgenv().AirHub or getgenv().AirHub.WallHack then return end

--// Services

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Variables

local ServiceConnections = {}

--// Environment

getgenv().AirHub.WallHack = {
	Settings = {
		Enabled = true,
		TeamCheck = false,
		AliveCheck = true
	},

	Visuals = {
		ESPSettings = {
			Enabled = true,
			TextColor = Color3fromRGB(255, 255, 255),
			TextSize = 14,
			Outline = true,
			OutlineColor = Color3fromRGB(0, 0, 0),
			TextTransparency = 0.7,
			TextFont = Drawing.Fonts.UI, -- UI, System, Plex, Monospace
			Offset = 20,
			DisplayDistance = true,
			DisplayHealth = true,
			DisplayName = true
		},

		TracersSettings = {
			Enabled = true,
			Type = 1, -- 1 - Bottom; 2 - Center; 3 - Mouse
			Transparency = 0.7,
			Thickness = 1,
			Color = Color3fromRGB(255, 255, 255)
		},

		BoxSettings = {
			Enabled = true,
			Type = 1; -- 1 - 3D; 2 - 2D;
			Color = Color3fromRGB(255, 255, 255),
			Transparency = 0.7,
			Thickness = 1,
			Filled = false, -- For 2D
			Increase = 1 -- For 3D
		},

		HeadDotSettings = {
			Enabled = true,
			Color = Color3fromRGB(255, 255, 255),
			Transparency = 0.5,
			Thickness = 1,
			Filled = false,
			Sides = 30
		},

		HealthBarSettings = {
			Enabled = false,
			Transparency = 0.8,
			Size = 2,
			Offset = 10,
			OutlineColor = Color3fromRGB(0, 0, 0),
			Blue = 50,
			Type = 3 -- 1 - Top; 2 - Bottom; 3 - Left; 4 - Right
		}
	},

	Crosshair = {
		Settings = {
			Enabled = false,
			Type = 1, -- 1 - Mouse; 2 - Center
			Size = 12,
			Thickness = 1,
			Color = Color3fromRGB(0, 255, 0),
			Transparency = 1,
			GapSize = 5,
			CenterDot = false,
			CenterDotColor = Color3fromRGB(0, 255, 0),
			CenterDotSize = 1,
			CenterDotTransparency = 1,
			CenterDotFilled = true,
			CenterDotThickness = 1
		},

		Parts = {
			LeftLine = Drawingnew("Line"),
			RightLine = Drawingnew("Line"),
			TopLine = Drawingnew("Line"),
			BottomLine = Drawingnew("Line"),
			CenterDot = Drawingnew("Circle")
		}
	},

	WrappedPlayers = {}
}

local Environment = getgenv().AirHub.WallHack

--// Core Functions

WorldToViewportPoint = function(...)
	return Camera.WorldToViewportPoint(Camera, ...)
end

local function GetPlayerTable(Player)
	for _, v in next, Environment.WrappedPlayers do
		if v.Name == Player.Name then
			return v
		end
	end
end

local function InitChecks(Player)
	local PlayerTable = GetPlayerTable(Player)

	PlayerTable.Connections.UpdateChecks = RunService.RenderStepped:Connect(function()
		if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
			if Environment.Settings.AliveCheck then
				PlayerTable.Checks.Alive = Player.Character:FindFirstChildOfClass("Humanoid").Health > 0
			else
				PlayerTable.Checks.Alive = true
			end

			if Environment.Settings.TeamCheck then
				PlayerTable.Checks.Team = Player.TeamColor ~= LocalPlayer.TeamColor
			else
				PlayerTable.Checks.Team = true
			end
		else
			PlayerTable.Checks.Alive = false
			PlayerTable.Checks.Team = false
		end
	end)
end

--// Visuals

local Visuals = {
	AddESP = function(Player)
		local PlayerTable = GetPlayerTable(Player)

		PlayerTable.ESP = Drawingnew("Text")

		PlayerTable.Connections.ESP = RunService.RenderStepped:Connect(function()
			if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Head") and Environment.Settings.Enabled then
				local Vector, OnScreen = WorldToViewportPoint(Player.Character.Head.Position)

				PlayerTable.ESP.Visible = Environment.Visuals.ESPSettings.Enabled

				if OnScreen and Environment.Visuals.ESPSettings.Enabled then
					PlayerTable.ESP.Visible = PlayerTable.Checks.Alive and PlayerTable.Checks.Team and true or false

					if PlayerTable.ESP.Visible then
						PlayerTable.ESP.Center = true
						PlayerTable.ESP.Size = Environment.Visuals.ESPSettings.TextSize
						PlayerTable.ESP.Outline = Environment.Visuals.ESPSettings.Outline
						PlayerTable.ESP.OutlineColor = Environment.Visuals.ESPSettings.OutlineColor
						PlayerTable.ESP.Color = Environment.Visuals.ESPSettings.TextColor
						PlayerTable.ESP.Transparency = Environment.Visuals.ESPSettings.TextTransparency
						PlayerTable.ESP.Font = Environment.Visuals.ESPSettings.TextFont

						PlayerTable.ESP.Position = Vector2new(Vector.X, Vector.Y - Environment.Visuals.ESPSettings.Offset)

						local Parts, Content, Tool = {
							Health = "("..tostring(mathfloor(Player.Character.Humanoid.Health))..")",
							Distance = "["..tostring(mathfloor((Player.Character.HumanoidRootPart.Position or Vector3zero - (LocalPlayer.Character.HumanoidRootPart.Position or Vector3zero)).Magnitude)).."]",
							Name = Player.DisplayName == Player.Name and Player.Name or Player.DisplayName.." {"..Player.Name.."}"
						}, "", Player.Character:FindFirstChildOfClass("Tool")

						if Environment.Visuals.ESPSettings.DisplayName then
							Content = Parts.Name..Content
						end

						if Environment.Visuals.ESPSettings.DisplayHealth then
							Content = Parts.Health..(Environment.Visuals.ESPSettings.DisplayName and " " or "")..Content
						end

						if Environment.Visuals.ESPSettings.DisplayDistance then
							Content = Content.." "..Parts.Distance
						end

						PlayerTable.ESP.Text = (Tool and "["..Tool.Name.."]\n" or "")..Content
					end
				else
					PlayerTable.ESP.Visible = false
				end
			else
				PlayerTable.ESP.Visible = false
			end
		end)
	end,

	AddTracer = function(Player)
		local PlayerTable = GetPlayerTable(Player)

		PlayerTable.Tracer = Drawingnew("Line")

		PlayerTable.Connections.Tracer = RunService.RenderStepped:Connect(function()
			if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and Environment.Settings.Enabled then
				local HRPCFrame, HRPSize = Player.Character.HumanoidRootPart.CFrame, Player.Character.HumanoidRootPart.Size
				local Vector, OnScreen = WorldToViewportPoint(HRPCFrame * CFramenew(0, -HRPSize.Y - 0.5, 0).Position)

				if OnScreen and Environment.Visuals.TracersSettings.Enabled then
					if Environment.Visuals.TracersSettings.Enabled then
						PlayerTable.Tracer.Visible = PlayerTable.Checks.Alive and PlayerTable.Checks.Team and true or false

						if PlayerTable.Tracer.Visible then
							PlayerTable.Tracer.Thickness = Environment.Visuals.TracersSettings.Thickness
							PlayerTable.Tracer.Color = Environment.Visuals.TracersSettings.Color
							PlayerTable.Tracer.Transparency = Environment.Visuals.TracersSettings.Transparency

							PlayerTable.Tracer.To = Vector2new(Vector.X, Vector.Y)

							if Environment.Visuals.TracersSettings.Type == 1 then
								PlayerTable.Tracer.From = Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
							elseif Environment.Visuals.TracersSettings.Type == 2 then
								PlayerTable.Tracer.From = Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
							elseif Environment.Visuals.TracersSettings.Type == 3 then
								PlayerTable.Tracer.From = Vector2new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
							else
								PlayerTable.Tracer.From = Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
							end
						end
					end
				else
					PlayerTable.Tracer.Visible = false
				end
			else
				PlayerTable.Tracer.Visible = false
			end
		end)
	end,

	AddBox = function(Player)
		local PlayerTable = GetPlayerTable(Player)

		PlayerTable.Box.Square = Drawingnew("Square")

		PlayerTable.Box.TopLeftLine = Drawingnew("Line")
		PlayerTable.Box.TopLeftLine = Drawingnew("Line")
		PlayerTable.Box.TopRightLine = Drawingnew("Line")
		PlayerTable.Box.BottomLeftLine = Drawingnew("Line")
		PlayerTable.Box.BottomRightLine = Drawingnew("Line")

		local function Visibility(Bool)
			if Environment.Visuals.BoxSettings.Type == 1 then
				PlayerTable.Box.Square.Visible = not Bool

				PlayerTable.Box.TopLeftLine.Visible = Bool
				PlayerTable.Box.TopRightLine.Visible = Bool
				PlayerTable.Box.BottomLeftLine.Visible = Bool
				PlayerTable.Box.BottomRightLine.Visible = Bool
			elseif Environment.Visuals.BoxSettings.Type == 2 then
				PlayerTable.Box.Square.Visible = Bool

				PlayerTable.Box.TopLeftLine.Visible = not Bool
				PlayerTable.Box.TopRightLine.Visible = not Bool
				PlayerTable.Box.BottomLeftLine.Visible = not Bool
				PlayerTable.Box.BottomRightLine.Visible = not Bool
			end
		end

		local function Visibility2(Bool)
			PlayerTable.Box.Square.Visible = Bool

			PlayerTable.Box.TopLeftLine.Visible = Bool
			PlayerTable.Box.TopRightLine.Visible = Bool
			PlayerTable.Box.BottomLeftLine.Visible = Bool
			PlayerTable.Box.BottomRightLine.Visible = Bool
		end

		PlayerTable.Connections.Box = RunService.RenderStepped:Connect(function()
			if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Head") and Environment.Settings.Enabled then
				local Vector, OnScreen = WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)

				Visibility(Environment.Visuals.BoxSettings.Enabled)

				if OnScreen and Environment.Visuals.BoxSettings.Enabled then
					if PlayerTable.Checks.Alive and PlayerTable.Checks.Team then
						Visibility(true)
					else
						Visibility2(false)
					end

					local HRPCFrame, HRPSize = Player.Character.HumanoidRootPart.CFrame, Player.Character.HumanoidRootPart.Size * Environment.Visuals.BoxSettings.Increase

					local HeadOffset = WorldToViewportPoint(Player.Character.Head.Position + Vector3new(0, 0.5, 0))
					local LegsOffset = WorldToViewportPoint(Player.Character.HumanoidRootPart.Position - Vector3new(0, 3, 0))

					local TopLeftPosition = WorldToViewportPoint(HRPCFrame * CFramenew(HRPSize.X, HRPSize.Y, 0).Position)
					local TopRightPosition = WorldToViewportPoint(HRPCFrame * CFramenew(-HRPSize.X, HRPSize.Y, 0).Position)
					local BottomLeftPosition = WorldToViewportPoint(HRPCFrame * CFramenew(HRPSize.X, -HRPSize.Y - 0.5, 0).Position)
					local BottomRightPosition = WorldToViewportPoint(HRPCFrame * CFramenew(-HRPSize.X, -HRPSize.Y - 0.5, 0).Position)

					if PlayerTable.Box.Square.Visible and not PlayerTable.Box.TopLeftLine.Visible and not PlayerTable.Box.TopRightLine.Visible and not PlayerTable.Box.BottomLeftLine.Visible and not PlayerTable.Box.BottomRightLine.Visible then
						PlayerTable.Box.Square.Thickness = Environment.Visuals.BoxSettings.Thickness
						PlayerTable.Box.Square.Color = Environment.Visuals.BoxSettings.Color
						PlayerTable.Box.Square.Transparency = Environment.Visuals.BoxSettings.Transparency
						PlayerTable.Box.Square.Filled = Environment.Visuals.BoxSettings.Filled

						PlayerTable.Box.Square.Size = Vector2new(2000 / Vector.Z, HeadOffset.Y - LegsOffset.Y)
						PlayerTable.Box.Square.Position = Vector2new(Vector.X - PlayerTable.Box.Square.Size.X / 2, Vector.Y - PlayerTable.Box.Square.Size.Y / 2)
					elseif not PlayerTable.Box.Square.Visible and PlayerTable.Box.TopLeftLine.Visible and PlayerTable.Box.TopRightLine.Visible and PlayerTable.Box.BottomLeftLine.Visible and PlayerTable.Box.BottomRightLine.Visible then
						PlayerTable.Box.TopLeftLine.Thickness = Environment.Visuals.BoxSettings.Thickness
						PlayerTable.Box.TopLeftLine.Transparency = Environment.Visuals.BoxSettings.Transparency
						PlayerTable.Box.TopLeftLine.Color = Environment.Visuals.BoxSettings.Color

						PlayerTable.Box.TopRightLine.Thickness = Environment.Visuals.BoxSettings.Thickness
						PlayerTable.Box.TopRightLine.Transparency = Environment.Visuals.BoxSettings.Transparency
						PlayerTable.Box.TopRightLine.Color = Environment.Visuals.BoxSettings.Color

						PlayerTable.Box.BottomLeftLine.Thickness = Environment.Visuals.BoxSettings.Thickness
						PlayerTable.Box.BottomLeftLine.Transparency = Environment.Visuals.BoxSettings.Transparency
						PlayerTable.Box.BottomLeftLine.Color = Environment.Visuals.BoxSettings.Color

						PlayerTable.Box.BottomRightLine.Thickness = Environment.Visuals.BoxSettings.Thickness
						PlayerTable.Box.BottomRightLine.Transparency = Environment.Visuals.BoxSettings.Transparency
						PlayerTable.Box.BottomRightLine.Color = Environment.Visuals.BoxSettings.Color

						PlayerTable.Box.TopLeftLine.From = Vector2new(TopLeftPosition.X, TopLeftPosition.Y)
						PlayerTable.Box.TopLeftLine.To = Vector2new(TopRightPosition.X, TopRightPosition.Y)

						PlayerTable.Box.TopRightLine.From = Vector2new(TopRightPosition.X, TopRightPosition.Y)
						PlayerTable.Box.TopRightLine.To = Vector2new(BottomRightPosition.X, BottomRightPosition.Y)

						PlayerTable.Box.BottomLeftLine.From = Vector2new(BottomLeftPosition.X, BottomLeftPosition.Y)
						PlayerTable.Box.BottomLeftLine.To = Vector2new(TopLeftPosition.X, TopLeftPosition.Y)

						PlayerTable.Box.BottomRightLine.From = Vector2new(BottomRightPosition.X, BottomRightPosition.Y)
						PlayerTable.Box.BottomRightLine.To = Vector2new(BottomLeftPosition.X, BottomLeftPosition.Y)
					end
				else
					Visibility2(false)
				end
			else
				Visibility2(false)
			end
		end)
	end,

	AddHeadDot = function(Player)
		local PlayerTable = GetPlayerTable(Player)

		PlayerTable.HeadDot = Drawingnew("Circle")

		PlayerTable.Connections.HeadDot = RunService.RenderStepped:Connect(function()
			if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChild("Head") and Environment.Settings.Enabled then
				local Vector, OnScreen = WorldToViewportPoint(Player.Character.Head.Position)

				PlayerTable.HeadDot.Visible = Environment.Visuals.HeadDotSettings.Enabled

				if OnScreen and Environment.Visuals.HeadDotSettings.Enabled then
					if Environment.Visuals.HeadDotSettings.Enabled then
						PlayerTable.HeadDot.Visible = PlayerTable.Checks.Alive and PlayerTable.Checks.Team and true or false

						if PlayerTable.HeadDot.Visible then
							PlayerTable.HeadDot.Thickness = Environment.Visuals.HeadDotSettings.Thickness
							PlayerTable.HeadDot.Color = Environment.Visuals.HeadDotSettings.Color
							PlayerTable.HeadDot.Transparency = Environment.Visuals.HeadDotSettings.Transparency
							PlayerTable.HeadDot.NumSides = Environment.Visuals.HeadDotSettings.Sides
							PlayerTable.HeadDot.Filled = Environment.Visuals.HeadDotSettings.Filled
							PlayerTable.HeadDot.Position = Vector2new(Vector.X, Vector.Y)

							local Top, Bottom = WorldToViewportPoint((Player.Character.Head.CFrame * CFramenew(0, Player.Character.Head.Size.Y / 2, 0)).Position), WorldToViewportPoint((Player.Character.Head.CFrame * CFramenew(0, -Player.Character.Head.Size.Y / 2, 0)).Position)
							PlayerTable.HeadDot.Radius = mathabs((Top - Bottom).Y) - 3
						end
					end
				else
					PlayerTable.HeadDot.Visible = false
				end
			else
				PlayerTable.HeadDot.Visible = false
			end
		end)
	end,

	AddHealthBar = function(Player)
		local PlayerTable = GetPlayerTable(Player)

		PlayerTable.HealthBar.Main = Drawingnew("Square")
		PlayerTable.HealthBar.Outline = Drawingnew("Square")

		PlayerTable.Connections.HealthBar = RunService.RenderStepped:Connect(function()
			if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and Environment.Settings.Enabled then
				local Vector, OnScreen = WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)

				local LeftPosition = WorldToViewportPoint(Player.Character.HumanoidRootPart.CFrame * CFramenew(Player.Character.HumanoidRootPart.Size.X, Player.Character.HumanoidRootPart.Size.Y / 2, 0).Position)
				local RightPosition = WorldToViewportPoint(Player.Character.HumanoidRootPart.CFrame * CFramenew(-Player.Character.HumanoidRootPart.Size.X, Player.Character.HumanoidRootPart.Size.Y / 2, 0).Position)

				PlayerTable.HealthBar.Main.Visible = Environment.Visuals.HealthBarSettings.Enabled
				PlayerTable.HealthBar.Outline.Visible = Environment.Visuals.HealthBarSettings.Enabled

				if OnScreen and Environment.Visuals.HealthBarSettings.Enabled then
					if Environment.Visuals.HealthBarSettings.Enabled then
						local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")

						PlayerTable.HealthBar.Main.Visible = PlayerTable.Checks.Alive and PlayerTable.Checks.Team and true or false
						PlayerTable.HealthBar.Outline.Visible = PlayerTable.HealthBar.Main.Visible

						if PlayerTable.HealthBar.Main.Visible then
							PlayerTable.HealthBar.Main.Thickness = 1
							PlayerTable.HealthBar.Main.Color = Color3fromRGB(255 - mathfloor(Humanoid.Health / 100 * 255), mathfloor(Humanoid.Health / 100 * 255), Environment.Visuals.HealthBarSettings.Blue)
							PlayerTable.HealthBar.Main.Transparency = Environment.Visuals.HealthBarSettings.Transparency
							PlayerTable.HealthBar.Main.Filled = true
							PlayerTable.HealthBar.Main.ZIndex = 2

							PlayerTable.HealthBar.Outline.Thickness = 3
							PlayerTable.HealthBar.Outline.Color = Environment.Visuals.HealthBarSettings.OutlineColor
							PlayerTable.HealthBar.Outline.Transparency = Environment.Visuals.HealthBarSettings.Transparency
							PlayerTable.HealthBar.Outline.Filled = false
							PlayerTable.HealthBar.Main.ZIndex = 1

							if Environment.Visuals.HealthBarSettings.Type == 1 then
								PlayerTable.HealthBar.Outline.Size = Vector2new(2000 / Vector.Z, Environment.Visuals.HealthBarSettings.Size)
								PlayerTable.HealthBar.Main.Size = Vector2new(PlayerTable.HealthBar.Outline.Size.X * (Humanoid.Health / 100), PlayerTable.HealthBar.Outline.Size.Y)
								PlayerTable.HealthBar.Main.Position = Vector2new(Vector.X - PlayerTable.HealthBar.Outline.Size.X / 2, Vector.Y - PlayerTable.HealthBar.Outline.Size.X / 2 - Environment.Visuals.HealthBarSettings.Offset)
							elseif Environment.Visuals.HealthBarSettings.Type == 2 then
								PlayerTable.HealthBar.Outline.Size = Vector2new(2000 / Vector.Z, Environment.Visuals.HealthBarSettings.Size)
								PlayerTable.HealthBar.Main.Size = Vector2new(PlayerTable.HealthBar.Outline.Size.X * (Humanoid.Health / 100), PlayerTable.HealthBar.Outline.Size.Y)
								PlayerTable.HealthBar.Main.Position = Vector2new(Vector.X - PlayerTable.HealthBar.Outline.Size.X / 2, Vector.Y + PlayerTable.HealthBar.Outline.Size.X / 2 + Environment.Visuals.HealthBarSettings.Offset)
							elseif Environment.Visuals.HealthBarSettings.Type == 3 then
								PlayerTable.HealthBar.Outline.Size = Vector2new(Environment.Visuals.HealthBarSettings.Size, 2500 / Vector.Z)
								PlayerTable.HealthBar.Main.Size = Vector2new(PlayerTable.HealthBar.Outline.Size.X, PlayerTable.HealthBar.Outline.Size.Y * (Humanoid.Health / 100))
								PlayerTable.HealthBar.Main.Position = Vector2new(LeftPosition.X - Environment.Visuals.HealthBarSettings.Offset, Vector.Y - PlayerTable.HealthBar.Outline.Size.Y / 2)
							elseif Environment.Visuals.HealthBarSettings.Type == 4 then
								PlayerTable.HealthBar.Outline.Size = Vector2new(Environment.Visuals.HealthBarSettings.Size, 2500 / Vector.Z)
								PlayerTable.HealthBar.Main.Size = Vector2new(PlayerTable.HealthBar.Outline.Size.X, PlayerTable.HealthBar.Outline.Size.Y * (Humanoid.Health / 100))
								PlayerTable.HealthBar.Main.Position = Vector2new(RightPosition.X + Environment.Visuals.HealthBarSettings.Offset, Vector.Y - PlayerTable.HealthBar.Outline.Size.Y / 2)
							end

							PlayerTable.HealthBar.Outline.Position = PlayerTable.HealthBar.Main.Position
						end
					end
				else
					PlayerTable.HealthBar.Main.Visible = false
					PlayerTable.HealthBar.Outline.Visible = false
				end
			else
				PlayerTable.HealthBar.Main.Visible = false
				PlayerTable.HealthBar.Outline.Visible = false
			end
		end)
	end,

	AddCrosshair = function()
		local AxisX, AxisY = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2

		ServiceConnections.AxisConnection = RunService.RenderStepped:Connect(function()
			if Environment.Crosshair.Settings.Enabled then
				if Environment.Crosshair.Settings.Type == 1 then
					AxisX, AxisY = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y
				elseif Environment.Crosshair.Settings.Type == 2 then
					AxisX, AxisY = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
				else
					Environment.Crosshair.Settings.Type = 1
				end
			end
		end)

		ServiceConnections.CrosshairConnection = RunService.RenderStepped:Connect(function()
			if Environment.Crosshair.Settings.Enabled then

				--// Left Line

				Environment.Crosshair.Parts.LeftLine.Visible = Environment.Crosshair.Settings.Enabled and Environment.Settings.Enabled
				Environment.Crosshair.Parts.LeftLine.Color = Environment.Crosshair.Settings.Color
				Environment.Crosshair.Parts.LeftLine.Thickness = Environment.Crosshair.Settings.Thickness
				Environment.Crosshair.Parts.LeftLine.Transparency = Environment.Crosshair.Settings.Transparency

				Environment.Crosshair.Parts.LeftLine.From = Vector2new(AxisX + Environment.Crosshair.Settings.GapSize, AxisY)
				Environment.Crosshair.Parts.LeftLine.To = Vector2new(AxisX + Environment.Crosshair.Settings.Size + Environment.Crosshair.Settings.GapSize, AxisY)

				--// Right Line

				Environment.Crosshair.Parts.RightLine.Visible = Environment.Settings.Enabled
				Environment.Crosshair.Parts.RightLine.Color = Environment.Crosshair.Settings.Color
				Environment.Crosshair.Parts.RightLine.Thickness = Environment.Crosshair.Settings.Thickness
				Environment.Crosshair.Parts.RightLine.Transparency = Environment.Crosshair.Settings.Transparency

				Environment.Crosshair.Parts.RightLine.From = Vector2new(AxisX - Environment.Crosshair.Settings.GapSize, AxisY)
				Environment.Crosshair.Parts.RightLine.To = Vector2new(AxisX - Environment.Crosshair.Settings.Size - Environment.Crosshair.Settings.GapSize, AxisY)

				--// Top Line

				Environment.Crosshair.Parts.TopLine.Visible = Environment.Settings.Enabled
				Environment.Crosshair.Parts.TopLine.Color = Environment.Crosshair.Settings.Color
				Environment.Crosshair.Parts.TopLine.Thickness = Environment.Crosshair.Settings.Thickness
				Environment.Crosshair.Parts.TopLine.Transparency = Environment.Crosshair.Settings.Transparency

				Environment.Crosshair.Parts.TopLine.From = Vector2new(AxisX, AxisY + Environment.Crosshair.Settings.GapSize)
				Environment.Crosshair.Parts.TopLine.To = Vector2new(AxisX, AxisY + Environment.Crosshair.Settings.Size + Environment.Crosshair.Settings.GapSize)

				--// Bottom Line

				Environment.Crosshair.Parts.BottomLine.Visible = Environment.Settings.Enabled
				Environment.Crosshair.Parts.BottomLine.Color = Environment.Crosshair.Settings.Color
				Environment.Crosshair.Parts.BottomLine.Thickness = Environment.Crosshair.Settings.Thickness
				Environment.Crosshair.Parts.BottomLine.Transparency = Environment.Crosshair.Settings.Transparency

				Environment.Crosshair.Parts.BottomLine.From = Vector2new(AxisX, AxisY - Environment.Crosshair.Settings.GapSize)
				Environment.Crosshair.Parts.BottomLine.To = Vector2new(AxisX, AxisY - Environment.Crosshair.Settings.Size - Environment.Crosshair.Settings.GapSize)

				--// Center Dot

				Environment.Crosshair.Parts.CenterDot.Visible = Environment.Settings.Enabled and Environment.Crosshair.Settings.CenterDot
				Environment.Crosshair.Parts.CenterDot.Color = Environment.Crosshair.Settings.CenterDotColor
				Environment.Crosshair.Parts.CenterDot.Radius = Environment.Crosshair.Settings.CenterDotSize
				Environment.Crosshair.Parts.CenterDot.Transparency = Environment.Crosshair.Settings.CenterDotTransparency
				Environment.Crosshair.Parts.CenterDot.Filled = Environment.Crosshair.Settings.CenterDotFilled
				Environment.Crosshair.Parts.CenterDot.Thickness = Environment.Crosshair.Settings.CenterDotThickness

				Environment.Crosshair.Parts.CenterDot.Position = Vector2new(AxisX, AxisY)
			else
				Environment.Crosshair.Parts.LeftLine.Visible = false
				Environment.Crosshair.Parts.RightLine.Visible = false
				Environment.Crosshair.Parts.TopLine.Visible = false
				Environment.Crosshair.Parts.BottomLine.Visible = false
				Environment.Crosshair.Parts.CenterDot.Visible = false
			end
		end)
	end
}

--// Functions

local function Wrap(Player)
	if not GetPlayerTable(Player) then
		local Table, Value = nil, {Name = Player.Name, Checks = {Alive = true, Team = true}, Connections = {}, ESP = nil, Tracer = nil, HeadDot = nil, HealthBar = {Main = nil, Outline = nil}, Box = {Square = nil, TopLeftLine = nil, TopRightLine = nil, BottomLeftLine = nil, BottomRightLine = nil}, Chams = {}}

		for _, v in next, Environment.WrappedPlayers do
			if v[1] == Player.Name then
				Table = v
			end
		end

		if not Table then
			Environment.WrappedPlayers[#Environment.WrappedPlayers + 1] = Value
			InitChecks(Player)

			Visuals.AddESP(Player)
			Visuals.AddTracer(Player)
			Visuals.AddBox(Player)
			Visuals.AddHeadDot(Player)
			Visuals.AddHealthBar(Player)
		end
	end
end

local function UnWrap(Player)
	local Table, Index = nil, nil

	for i, v in next, Environment.WrappedPlayers do
		if v.Name == Player.Name then
			Table, Index = v, i
		end
	end

	if Table then
		for _, v in next, Table.Connections do
			v:Disconnect()
		end

		pcall(function()
			Table.ESP:Remove()
			Table.Tracer:Remove()
			Table.HeadDot:Remove()
			Table.HealthBar.Main:Remove()
			Table.HealthBar.Outline:Remove()
		end)

		for _, v in next, Table.Box do
			if type(v.Remove) == "function" then
				v:Remove()
			end
		end

		for _, v in next, Table.Chams do
			for _, v2 in next, v do
				if type(v2.Remove) == "function" then
					v2:Remove()
				end
			end
		end

		Environment.WrappedPlayers[Index] = nil
	end
end

local function Load()
	Visuals.AddCrosshair()

	ServiceConnections.PlayerAddedConnection = Players.PlayerAdded:Connect(Wrap)
	ServiceConnections.PlayerRemovingConnection = Players.PlayerRemoving:Connect(UnWrap)

	ServiceConnections.ReWrapPlayers = RunService.RenderStepped:Connect(function()
		for _, v in next, Players:GetPlayers() do
			if v ~= LocalPlayer then
				Wrap(v)
			end
		end

		wait(60)
	end)
end

--// Functions

Environment.Functions = {}

function Environment.Functions:Exit()
	for _, v in next, ServiceConnections do
		v:Disconnect()
	end

	for _, v in next, Environment.Crosshair.Parts do
		v:Remove()
	end

	for _, v in next, Players:GetPlayers() do
		if v ~= LocalPlayer then
			UnWrap(v)
		end
	end

	getgenv().AirHub.WallHack.Functions = nil
	getgenv().AirHub.WallHack = nil

	Load = nil; GetPlayerTable = nil; InitChecks = nil; Visuals = nil; Wrap = nil; UnWrap = nil
end

function Environment.Functions:Restart()
	for _, v in next, Players:GetPlayers() do
		if v ~= LocalPlayer then
			UnWrap(v)
		end
	end

	for _, v in next, ServiceConnections do
		v:Disconnect()
	end

	Load()
end

function Environment.Functions:ResetSettings()
	Environment.Visuals = {
		ESPSettings = {
			Enabled = true,
			TextColor = Color3fromRGB(255, 255, 255),
			TextSize = 14,
			Center = true,
			Outline = true,
			OutlineColor = Color3fromRGB(0, 0, 0),
			TextTransparency = 0.7,
			TextFont = Drawing.Fonts.UI, -- UI, System, Plex, Monospace
			DisplayDistance = true,
			DisplayHealth = true,
			DisplayName = true
		},

		TracersSettings = {
			Enabled = true,
			Type = 1, -- 1 - Bottom; 2 - Center; 3 - Mouse
			Transparency = 0.7,
			Thickness = 1,
			Color = Color3fromRGB(255, 255, 255)
		},

		BoxSettings = {
			Enabled = true,
			Type = 1; -- 1 - 3D; 2 - 2D;
			Color = Color3fromRGB(255, 255, 255),
			Transparency = 0.7,
			Thickness = 1,
			Filled = false, -- For 2D
			Increase = 1
		},

		HeadDotSettings = {
			Enabled = true,
			Color = Color3fromRGB(255, 255, 255),
			Transparency = 0.5,
			Thickness = 1,
			Filled = true,
			Sides = 30
		},

		HealthBarSettings = {
			Enabled = false,
			Transparency = 0.8,
			Size = 2,
			Offset = 10,
			OutlineColor = Color3fromRGB(0, 0, 0),
			Blue = 50,
			Type = 3 -- 1 - Top; 2 - Bottom; 3 - Left; 4 - Right
		}
	}

	Environment.Crosshair.Settings = {
		Enabled = false,
		Type = 1, -- 1 - Mouse; 2 - Center
		Size = 12,
		Thickness = 1,
		Color = Color3fromRGB(0, 255, 0),
		Transparency = 1,
		GapSize = 5,
		CenterDot = false,
		CenterDotColor = Color3fromRGB(0, 255, 0),
		CenterDotSize = 1,
		CenterDotTransparency = 1,
		CenterDotFilled = true,
		CenterDotThickness = 1
	}

	Environment.Settings = {
		Enabled = false,
		TeamCheck = false,
		AliveCheck = true
	}
end

setmetatable(Environment.Functions, {
	__newindex = warn
})

--// Main

Load()
