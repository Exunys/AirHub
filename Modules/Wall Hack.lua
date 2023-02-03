--[[

	Wall Hack Module [AirHub] by Exunys © CC0 1.0 Universal (2023)

	https://github.com/Exunys

]]

--// Cache

local next, tostring, pcall, getgenv, setmetatable, mathfloor, mathabs, wait = next, tostring, pcall, getgenv, setmetatable, math.floor, math.abs, task.wait
local WorldToViewportPoint, Vector2new, Vector3new, CFramenew, Drawingnew, Color3fromRGB = nil, Vector2.new, Vector3.new, CFrame.new, Drawing.new, Color3.fromRGB

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
		Enabled = false,
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

		ChamsSettings = {
			Enabled = false, -- WIP, keep false
			Color = Color3fromRGB(255, 255, 255),
			Transparency = 0.5,
			Thickness = 0,
			Filled = true,
			EntireBody = false -- Keep false to prevent lag
		},

		HeadDotSettings = {
			Enabled = true,
			Color = Color3fromRGB(255, 255, 255),
			Transparency = 0.5,
			Thickness = 1,
			Filled = true,
			Sides = 30
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

local function AssignRigType(Player)
	local PlayerTable = GetPlayerTable(Player)

	repeat wait(0) until Player.Character

	if Player.Character:FindFirstChild("Torso") and not Player.Character:FindFirstChild("LowerTorso") then
		PlayerTable.RigType = "R6"
	elseif Player.Character:FindFirstChild("LowerTorso") and not Player.Character:FindFirstChild("Torso") then
		PlayerTable.RigType = "R15"
	else
		repeat AssignRigType(Player) until PlayerTable.RigType
	end
end

--// Visuals

local Visuals = {
	AddChams = function(Player)
		local PlayerTable = GetPlayerTable(Player)

		if PlayerTable.RigType == "R15" then
			if not Environment.Visuals.ChamsSettings.EntireBody then
				PlayerTable.Chams = {
					Head = {},
					UpperTorso = {},
					LeftLowerArm = {}, LeftUpperArm = {},
					RightLowerArm = {}, RightUpperArm = {},
					LeftLowerLeg = {}, LeftUpperLeg = {},
					RightLowerLeg = {}, RightUpperLeg = {}
				}
			else
				PlayerTable.Chams = {
					Head = {},
					UpperTorso = {}, LowerTorso = {},
					LeftLowerArm = {}, LeftUpperArm = {}, LeftHand = {},
					RightLowerArm = {}, RightUpperArm = {}, RightHand = {},
					LeftLowerLeg = {}, LeftUpperLeg = {}, LeftFoot = {},
					RightLowerLeg = {}, RightUpperLeg = {}, RightFoot = {}
				}
			end
		elseif PlayerTable.RigType == "R6" then
			PlayerTable.Chams = {
				Head = {},
				Torso = {},
				["Left Arm"] = {},
				["Right Arm"] = {},
				["Left Leg"] = {},
				["Right Leg"] = {}
			}
		end

		for _, v in next, PlayerTable.Chams do
			v["Quad"] = Drawingnew("Quad")

			for i = 2, 6 do
				v["Quad"..tostring(i)] = Drawingnew("Quad")
			end
		end

		local function UpdateCham(Part, Cham)
			local CorFrame, PartSize = Part.CFrame, Part.Size / 2

			--// Quad 1 - Front

			Cham.Quad.Transparency = Environment.Visuals.ChamsSettings.Transparency
			Cham.Quad.Color = Environment.Visuals.ChamsSettings.Color
			Cham.Quad.Thickness = Environment.Visuals.ChamsSettings.Thickness
			Cham.Quad.Filled = Environment.Visuals.ChamsSettings.Filled
			Cham.Quad.Visible = Environment.Visuals.ChamsSettings.Enabled

			local PosTopLeft = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X,  PartSize.Y, PartSize.Z).Position)
			local PosTopRight = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X,  PartSize.Y, PartSize.Z).Position)
			local PosBottomLeft = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, -PartSize.Y, PartSize.Z).Position)
			local PosBottomRight = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, -PartSize.Y, PartSize.Z).Position)

			Cham.Quad.PointA = Vector2new(PosTopLeft.X, PosTopLeft.Y)
			Cham.Quad.PointB = Vector2new(PosBottomLeft.X, PosBottomLeft.Y)
			Cham.Quad.PointC = Vector2new(PosBottomRight.X, PosBottomRight.Y)
			Cham.Quad.PointD = Vector2new(PosTopRight.X, PosTopRight.Y)

			--// Quad 2 - Back

			Cham.Quad2.Transparency = Environment.Visuals.ChamsSettings.Transparency
			Cham.Quad2.Color = Environment.Visuals.ChamsSettings.Color
			Cham.Quad2.Thickness = Environment.Visuals.ChamsSettings.Thickness
			Cham.Quad2.Filled = Environment.Visuals.ChamsSettings.Filled
			Cham.Quad2.Visible = Environment.Visuals.ChamsSettings.Enabled

			local PosTopLeft2 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X,  PartSize.Y, -PartSize.Z).Position)
			local PosTopRight2 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X,  PartSize.Y, -PartSize.Z).Position)
			local PosBottomLeft2 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, -PartSize.Y, -PartSize.Z).Position)
			local PosBottomRight2 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, -PartSize.Y, -PartSize.Z).Position)

			Cham.Quad2.PointA = Vector2new(PosTopLeft2.X, PosTopLeft2.Y)
			Cham.Quad2.PointB = Vector2new(PosBottomLeft2.X, PosBottomLeft2.Y)
			Cham.Quad2.PointC = Vector2new(PosBottomRight2.X, PosBottomRight2.Y)
			Cham.Quad2.PointD = Vector2new(PosTopRight2.X, PosTopRight2.Y)

			--// Quad 3 - Top

			Cham.Quad3.Transparency = Environment.Visuals.ChamsSettings.Transparency
			Cham.Quad3.Color = Environment.Visuals.ChamsSettings.Color
			Cham.Quad3.Thickness = Environment.Visuals.ChamsSettings.Thickness
			Cham.Quad3.Filled = Environment.Visuals.ChamsSettings.Filled
			Cham.Quad3.Visible = Environment.Visuals.ChamsSettings.Enabled

			local PosTopLeft3 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X,  PartSize.Y, PartSize.Z).Position)
			local PosTopRight3 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, PartSize.Y, PartSize.Z).Position)
			local PosBottomLeft3 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, PartSize.Y, -PartSize.Z).Position)
			local PosBottomRight3 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, PartSize.Y, -PartSize.Z).Position)

			Cham.Quad3.PointA = Vector2new(PosTopLeft3.X, PosTopLeft3.Y)
			Cham.Quad3.PointB = Vector2new(PosBottomLeft3.X, PosBottomLeft3.Y)
			Cham.Quad3.PointC = Vector2new(PosBottomRight3.X, PosBottomRight3.Y)
			Cham.Quad3.PointD = Vector2new(PosTopRight3.X, PosTopRight3.Y)

			--// Quad 4 - Bottom

			Cham.Quad4.Transparency = Environment.Visuals.ChamsSettings.Transparency
			Cham.Quad4.Color = Environment.Visuals.ChamsSettings.Color
			Cham.Quad4.Thickness = Environment.Visuals.ChamsSettings.Thickness
			Cham.Quad4.Filled = Environment.Visuals.ChamsSettings.Filled
			Cham.Quad4.Visible = Environment.Visuals.ChamsSettings.Enabled

			local PosTopLeft4 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X,  -PartSize.Y, PartSize.Z).Position)
			local PosTopRight4 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, -PartSize.Y, PartSize.Z).Position)
			local PosBottomLeft4 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, -PartSize.Y, -PartSize.Z).Position)
			local PosBottomRight4 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, -PartSize.Y, -PartSize.Z).Position)

			Cham.Quad4.PointA = Vector2new(PosTopLeft4.X, PosTopLeft4.Y)
			Cham.Quad4.PointB = Vector2new(PosBottomLeft4.X, PosBottomLeft4.Y)
			Cham.Quad4.PointC = Vector2new(PosBottomRight4.X, PosBottomRight4.Y)
			Cham.Quad4.PointD = Vector2new(PosTopRight4.X, PosTopRight4.Y)

			--// Quad 5 - Right

			Cham.Quad5.Transparency = Environment.Visuals.ChamsSettings.Transparency
			Cham.Quad5.Color = Environment.Visuals.ChamsSettings.Color
			Cham.Quad5.Thickness = Environment.Visuals.ChamsSettings.Thickness
			Cham.Quad5.Filled = Environment.Visuals.ChamsSettings.Filled
			Cham.Quad5.Visible = Environment.Visuals.ChamsSettings.Enabled

			local PosTopLeft5 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X,  PartSize.Y, PartSize.Z).Position)
			local PosTopRight5 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, PartSize.Y, -PartSize.Z).Position)
			local PosBottomLeft5 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, -PartSize.Y, PartSize.Z).Position)
			local PosBottomRight5 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, -PartSize.Y, -PartSize.Z).Position)

			Cham.Quad5.PointA = Vector2new(PosTopLeft5.X, PosTopLeft5.Y)
			Cham.Quad5.PointB = Vector2new(PosBottomLeft5.X, PosBottomLeft5.Y)
			Cham.Quad5.PointC = Vector2new(PosBottomRight5.X, PosBottomRight5.Y)
			Cham.Quad5.PointD = Vector2new(PosTopRight5.X, PosTopRight5.Y)

			--// Quad 6 - Left

			Cham.Quad6.Transparency = Environment.Visuals.ChamsSettings.Transparency
			Cham.Quad6.Color = Environment.Visuals.ChamsSettings.Color
			Cham.Quad6.Thickness = Environment.Visuals.ChamsSettings.Thickness
			Cham.Quad6.Filled = Environment.Visuals.ChamsSettings.Filled
			Cham.Quad6.Visible = Environment.Visuals.ChamsSettings.Enabled

			local PosTopLeft6 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X,  PartSize.Y, PartSize.Z).Position)
			local PosTopRight6 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, PartSize.Y, -PartSize.Z).Position)
			local PosBottomLeft6 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, -PartSize.Y, PartSize.Z).Position)
			local PosBottomRight6 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, -PartSize.Y, -PartSize.Z).Position)

			Cham.Quad6.PointA = Vector2new(PosTopLeft6.X, PosTopLeft6.Y)
			Cham.Quad6.PointB = Vector2new(PosBottomLeft6.X, PosBottomLeft6.Y)
			Cham.Quad6.PointC = Vector2new(PosBottomRight6.X, PosBottomRight6.Y)
			Cham.Quad6.PointD = Vector2new(PosTopRight6.X, PosTopRight6.Y)
		end

		PlayerTable.Connections.Chams = RunService.RenderStepped:Connect(function()
			if Environment.Visuals.ChamsSettings.Enabled then
				for i, v in next, PlayerTable.Chams do
					UpdateCham(Player.Character:FindFirstChild(i), v)
				end
			end
		end)
	end,

	AddESP = function(Player)
		local PlayerTable = GetPlayerTable(Player)

		PlayerTable.ESP = Drawingnew("Text")

		PlayerTable.Connections.ESP = RunService.RenderStepped:Connect(function()
			if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Head") and Environment.Settings.Enabled then
				local Vector, OnScreen = WorldToViewportPoint(Player.Character.Head.Position)

				PlayerTable.ESP.Visible = Environment.Visuals.ESPSettings.Enabled

				if OnScreen and Environment.Visuals.ESPSettings.Enabled then
					local Checks = {}

					--Checks.Alive = Environment.Settings.AliveCheck and Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 or true
					--Checks.Team = Environment.Settings.TeamCheck and Player.TeamColor ~= LocalPlayer.TeamColor or true

					--[[
					if Environment.Settings.AliveCheck then
						Checks.Alive = Player.Character:FindFirstChildOfClass("Humanoid").Health > 0
					else
						Checks.Alive = true
					end
					]]

					
					if Environment.Settings.TeamCheck then
						Checks.Team = Player.TeamColor ~= LocalPlayer.TeamColor
					else
						Checks.Team = true
					end
					

					Checks.Alive = Environment.Settings.AliveCheck and Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 or true
					--Checks.Team = Environment.Settings.TeamCheck and Player.TeamColor ~= LocalPlayer.TeamColor or true

					PlayerTable.ESP.Visible = Checks.Alive and Checks.Team and true or false

					if PlayerTable.ESP.Visible then
						PlayerTable.ESP.Center = true
						PlayerTable.ESP.Size = Environment.Visuals.ESPSettings.TextSize
						PlayerTable.ESP.Outline = Environment.Visuals.ESPSettings.Outline
						PlayerTable.ESP.OutlineColor = Environment.Visuals.ESPSettings.OutlineColor
						PlayerTable.ESP.Color = Environment.Visuals.ESPSettings.TextColor
						PlayerTable.ESP.Transparency = Environment.Visuals.ESPSettings.TextTransparency
						PlayerTable.ESP.Font = Environment.Visuals.ESPSettings.TextFont

						PlayerTable.ESP.Position = Vector2new(Vector.X, Vector.Y - 25)

						local Parts, Content = {
							Health = "("..tostring(Player.Character.Humanoid.Health)..")",
							Distance = "["..tostring(mathfloor((Player.Character.HumanoidRootPart.Position - (LocalPlayer.Character.HumanoidRootPart.Position or Vector3new(0, 0, 0))).Magnitude)).."]",
							Name = Player.DisplayName == Player.Name and Player.Name or Player.DisplayName.." {"..Player.Name.."}"
						}, ""

						if Environment.Visuals.ESPSettings.DisplayName then
							Content = Parts.Name..Content
						end

						if Environment.Visuals.ESPSettings.DisplayHealth then
							Content = Parts.Health..(Environment.Visuals.ESPSettings.DisplayName and " " or "")..Content
						end

						if Environment.Visuals.ESPSettings.DisplayDistance then
							Content = Content.." "..Parts.Distance
						end

						PlayerTable.ESP.Text = Content
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
				local Vector, OnScreen = WorldToViewportPoint(HRPCFrame * CFramenew(0, -HRPSize.Y, 0).Position)

				if OnScreen and Environment.Visuals.TracersSettings.Enabled then
					if Environment.Visuals.TracersSettings.Enabled then
						local Checks = {}

						Checks.Alive = Environment.Settings.AliveCheck and Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 or true
						Checks.Team = Environment.Settings.TeamCheck and Player.TeamColor ~= LocalPlayer.TeamColor or true

						PlayerTable.Tracer.Visible = Checks.Alive and Checks.Team and true or false

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

				local HRPCFrame, HRPSize = Player.Character.HumanoidRootPart.CFrame, Player.Character.HumanoidRootPart.Size * Environment.Visuals.BoxSettings.Increase

				local TopLeftPosition = WorldToViewportPoint(HRPCFrame * CFramenew(HRPSize.X,  HRPSize.Y, 0).Position)
				local TopRightPosition = WorldToViewportPoint(HRPCFrame * CFramenew(-HRPSize.X,  HRPSize.Y, 0).Position)
				local BottomLeftPosition = WorldToViewportPoint(HRPCFrame * CFramenew(HRPSize.X, -HRPSize.Y, 0).Position)
				local BottomRightPosition = WorldToViewportPoint(HRPCFrame * CFramenew(-HRPSize.X, -HRPSize.Y, 0).Position)

				local HeadOffset = WorldToViewportPoint(Player.Character.Head.Position + Vector3new(0, 0.5, 0))
				local LegsOffset = WorldToViewportPoint(Player.Character.HumanoidRootPart.Position - Vector3new(0, 3, 0))

				Visibility(Environment.Visuals.BoxSettings.Enabled)

				if OnScreen and Environment.Visuals.BoxSettings.Enabled then
					local Checks = {}

					Checks.Alive = Environment.Settings.AliveCheck and Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 or true
					Checks.Team = Environment.Settings.TeamCheck and Player.TeamColor ~= LocalPlayer.TeamColor or true

					if Checks.Alive and Checks.Team then
						Visibility(true)
					else
						Visibility2(false)
					end

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
						local Checks = {}

						Checks.Alive = Environment.Settings.AliveCheck and Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 or true
						Checks.Team = Environment.Settings.TeamCheck and Player.TeamColor ~= LocalPlayer.TeamColor or true

						PlayerTable.HeadDot.Visible = Checks.Alive and Checks.Team and true or false

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
		local Table, Value = nil, {Name = Player.Name, RigType = nil, Connections = {}, ESP = nil, Tracer = nil, HeadDot = nil, Box = {Square = nil, TopLeftLine = nil, TopRightLine = nil, BottomLeftLine = nil, BottomRightLine = nil}, Chams = {}}

		for _, v in next, Environment.WrappedPlayers do
			if v[1] == Player.Name then
				Table = v
			end
		end

		if not Table then
			Environment.WrappedPlayers[#Environment.WrappedPlayers + 1] = Value
			AssignRigType(Player)

			Visuals.AddESP(Player)
			Visuals.AddTracer(Player)
			Visuals.AddBox(Player)
			Visuals.AddHeadDot(Player)
			Visuals.AddChams(Player)
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

		wait(10)
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

	Load = nil; GetPlayerTable = nil; AssignRigType = nil; Visuals = nil; Wrap = nil; UnWrap = nil
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

		ChamsSettings = {
			Enabled = false,
			Color = Color3fromRGB(255, 255, 255),
			Transparency = 0.5,
			Thickness = 0,
			Filled = true,
			EntireBody = false -- Keep false to prevent lag
		},

		HeadDotSettings = {
			Enabled = true,
			Color = Color3fromRGB(255, 255, 255),
			Transparency = 0.5,
			Thickness = 1,
			Filled = true,
			Sides = 30
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
