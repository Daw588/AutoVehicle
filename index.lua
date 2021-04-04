
plugin:Activate(false)

local Settings = {
	Name = "AutoVehicle",
	Author = "Daw588",
	License = "Copyright",
	Usage = "Not made yet",
	Version = "1.0.0",
	Generation = "1st Generation"
}

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local Toolbar = plugin:CreateToolbar(Settings.Name)
local StateButton = Toolbar:CreateButton(Settings.Name, "AutoVehicle allows you to make car just by few clicks", "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=5840697166")

local Widget = plugin:CreateDockWidgetPluginGui(Settings.Name, DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
	false,   -- Widget will be initially enabled
	false,  -- Don't override the previous enabled state
	475,    -- Default width of the floating window
	271,    -- Default height of the floating window
	475,    -- Minimum width of the floating window
	271     -- Minimum height of the floating window
))
Widget.Title = Settings.Name

StateButton.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled
end)

local function loadScreen(name)
	local Screen = script.Screens[name]:Clone()
	Screen.Size = UDim2.fromScale(1, 1)
	Screen.Position = UDim2.fromScale(0.5, 0.5)
	Screen.Visible = false
	Screen.Parent = Widget
	return Screen
end

local MainScreen = loadScreen("Main")
MainScreen.Visible = true

MainScreen.SelectionLabel.Text = "No Selection Found"
Selection.SelectionChanged:Connect(function()
	local Selections = Selection:Get()
	if #Selections > 0 then
		if #Selections > 1 then
			MainScreen.SelectionLabel.Text = "Multiple Selections Found"
		else
			MainScreen.SelectionLabel.Text = Selections[1].Name
		end
	else
		MainScreen.SelectionLabel.Text = "No Selection Found"
	end
end)

MainScreen.RigButton.MouseButton1Click:Connect(function()
	ChangeHistoryService:SetWaypoint("Before")
	for _, v in pairs(Selection:Get()) do
		if v:IsA("Model") then
			local RigData = v:FindFirstChild("RigData")
			local Rig = {}

			if RigData then
				for _, q in pairs(RigData:GetChildren()) do
					if q:IsA("ObjectValue") then
						(q.Value):Destroy()
						q:Destroy()
					end
				end
			else
				RigData = Instance.new("Folder", v)
				RigData.Name = "RigData"
			end

			local FAKE = v:FindFirstChild("FAKE")
			if not FAKE then warn('required "FAKE" instance is missing') return end

			local REAL = v:FindFirstChild("REAL")
			if not REAL then warn('required "REAL" instance is missing') return end

			local SEAT = REAL:FindFirstChild("SEAT")
			if not SEAT then warn('required "SEAT" instance is missing') return end

			local CHASSIS = REAL:FindFirstChild("CHASSIS")
			if not CHASSIS then warn('required "CHASSIS" instance is missing') return end

			local FL = REAL:FindFirstChild("FL")
			if not FL then warn('required "FL" instance is missing') return end

			local FR = REAL:FindFirstChild("FR")
			if not FR then warn('required "FR" instance is missing') return end

			local RL = REAL:FindFirstChild("RL")
			if not RL then warn('required "RL" instance is missing') return end

			local RR = REAL:FindFirstChild("RR")
			if not RR then warn('required "RR" instance is missing') return end

			SEAT.Disabled = false
			SEAT.HeadsUpDisplay = false
			SEAT.MaxSpeed = 25
			SEAT.Torque = 1000
			SEAT.TurnSpeed = 2
			SEAT.Massless = false

			local WHEELS = {FL, FR, RL, RR}

			local function WELD(P0, P1)
				local WC = Instance.new("WeldConstraint")
				table.insert(Rig, WC)
				WC.Name = P0.Name.. " -> ".. P1.Name
				WC.Part0 = P0
				WC.Part1 = P1
				WC.Parent = P0
			end

			local function NOCOLLIDE(P0, P1)
				local NCC = Instance.new("NoCollisionConstraint")
				table.insert(Rig, NCC)
				NCC.Name = P0.Name.. " -> ".. P1.Name
				NCC.Part0 = P0
				NCC.Part1 = P1
				NCC.Parent = P0
			end

			local FAKE_FL = FAKE:FindFirstChild("FL")
			local FAKE_FR = FAKE:FindFirstChild("FR")
			local FAKE_RL = FAKE:FindFirstChild("RL")
			local FAKE_RR = FAKE:FindFirstChild("RR")

			local FAKE_WHEELS = {FAKE_FL, FAKE_FR, FAKE_RL, FAKE_RR}

			for i, FAKE_WHEEL in pairs(FAKE_WHEELS) do
				if FAKE_WHEEL then
					if FAKE_WHEEL:IsA("BasePart") then
						FAKE_WHEEL.Size = WHEELS[i].Size
						FAKE_WHEEL.Position = WHEELS[i].Position
						WELD(FAKE_WHEEL, WHEELS[i])
						for _, RIM in pairs(FAKE_WHEEL:GetChildren()) do
							if RIM:IsA("BasePart") then
								--RIM.Size = FAKE_WHEEL.Size * 0.5
								RIM.Position = FAKE_WHEEL.Position
								WELD(RIM, FAKE_WHEEL)
							end
						end
					end
				end
			end

			for _, WHEEL in pairs(WHEELS) do
				local Attachment0 = Instance.new("Attachment", CHASSIS)
				table.insert(Rig, Attachment0)
				Attachment0.Name = WHEEL.Name.. "A"
				Attachment0.Position -= Vector3.new(0, CHASSIS.Size.Y / 2, 0)

				local Attachment1 = Instance.new("Attachment", WHEEL)
				table.insert(Rig, Attachment1)
				Attachment1.Orientation = Vector3.new(0, 0, 0)
				Attachment1.Position = Vector3.new(0, 0, 0)

				local CC = Instance.new("CylindricalConstraint")
				table.insert(Rig, CC)
				CC.Name = WHEEL.Name.. "CC"
				CC.AngularActuatorType = Enum.ActuatorType.Motor
				CC.Visible = false
				CC.Attachment0 = Attachment0
				CC.Attachment1 = Attachment1
				CC.Parent = CHASSIS

				if WHEEL.Name == "FL" or WHEEL.Name == "RL" then
					CC.InclinationAngle = -90
					Attachment1.Position += Vector3.new(WHEEL.Size.X / 2, 0, 0)
				end

				if WHEEL.Name == "FR" or WHEEL.Name == "RR" then
					CC.InclinationAngle = 90
					Attachment1.Position -= Vector3.new(WHEEL.Size.X / 2, 0, 0)
				end

				if WHEEL.Name == "FL" or WHEEL.Name == "RL" then
					Attachment0.Orientation = Vector3.new(0, 0, -90)
					Attachment1.Orientation = Vector3.new(-90, -180, 0)
				end

				if WHEEL.Name == "FR" or WHEEL.Name == "RR" then
					Attachment0.Orientation = Vector3.new(0, 0, -90)
					Attachment1.Orientation = Vector3.new(-90, 0, 0)
				end

				Attachment0.WorldPosition = Vector3.new(
					Attachment1.WorldPosition.X,
					Attachment0.WorldPosition.Y,
					Attachment1.WorldPosition.Z
				)

				local SC = Instance.new("SpringConstraint")
				table.insert(Rig, SC)
				SC.Name = WHEEL.Name.. "SC"
				SC.Damping = 500
				SC.Stiffness = 10000
				SC.FreeLength = math.abs(CHASSIS.Position.Y - WHEEL.Position.Y) * 1.25
				SC.Visible = false
				SC.Attachment0 = Attachment0
				SC.Attachment1 = Attachment1
				SC.Parent = CHASSIS
			end

			WELD(SEAT, CHASSIS)

			for _, q in pairs(REAL:GetDescendants()) do
				if q:IsA("BasePart") then
					q.Anchored = false
					q.CanCollide = true
					if #(FAKE:GetChildren()) > 0 then
						q.Transparency = 1
					end
				end
			end

			CHASSIS.CanCollide = false

			for _, f in pairs(FAKE:GetDescendants()) do
				if f:IsA("BasePart") then
					f.Anchored = false
					f.CanCollide = true
					f.Massless = true
					if f.Name ~= "FL" and f.Name ~= "FR" and f.Name ~= "RL" and f.Name ~= "RR" then
						if f.Parent.Name ~= "FL" and f.Parent.Name ~= "FR" and f.Parent.Name ~= "RL" and f.Parent.Name ~= "RR" then
							WELD(f, CHASSIS)
						end
					else
						f.CanCollide = false
					end
					for _, r in pairs(REAL:GetDescendants()) do
						if r:IsA("BasePart") then
							NOCOLLIDE(f, r)
						end
					end
				end
			end

			local PACKAGES = script.Packages
			for _, PACKAGE in pairs(PACKAGES:GetChildren()) do
				local _PACKAGE = PACKAGE:Clone()
				table.insert(Rig, _PACKAGE)
				_PACKAGE.Parent = v
				if _PACKAGE:IsA("Script") then
					_PACKAGE.Disabled = false
				end
			end

			for _, q in pairs(Rig) do
				local RigObject = Instance.new("ObjectValue", RigData)
				RigObject.Name = "[".. q.Name.. "]"
				RigObject.Value = q
			end

		end
	end
	ChangeHistoryService:SetWaypoint("After")
end)

MainScreen.RemoveRigButton.MouseButton1Click:Connect(function()
	for _, v in pairs(Selection:Get()) do
		local RigData = v:FindFirstChild("RigData")
		if RigData then
			for _, q in pairs(RigData:GetChildren()) do
				if q:IsA("ObjectValue") then
					(q.Value):Destroy()
					q:Destroy()
				end
			end
		end
		RigData:Destroy()
	end
end)