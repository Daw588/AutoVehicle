local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Vehicle = script.Parent
local Configuration = Vehicle.Configuration
local Fake = Vehicle.FAKE
local Real = Vehicle.REAL
local Chassis = Real.CHASSIS
local VehicleSeat = Real.SEAT

local Sound = Instance.new("Sound", Chassis)

local function WeightOf(Model)
	local weight = 0
	for _, v in pairs(Model:GetDescendants()) do
		if v:IsA("BasePart") then
			weight += v:GetMass()
		end
	end
	return weight
end

local Wheels = {Real.FL, Real.FR, Real.RL, Real.RR}
local Headlights = {}
local Taillights = {}

for _, Wheel in pairs(Wheels) do
	Wheel.CustomPhysicalProperties = PhysicalProperties.new(
		0.7, -- density (0.7)
		10, -- friction (0.3)
		0.5, -- elasticity (0.5)
		100, -- friction weight (1)
		1 -- elasticity weight (1)
	)
end

for _, v in pairs(Fake:GetDescendants()) do
	if v:IsA("BasePart") then
		if v.Name == "HEADLIGHTS" then
			local Light = Instance.new("PointLight", v)
			Light.Name = "PL"
			Light.Enabled = false
			Light.Brightness = 1
			Light.Color = v.Color
			Light.Range = 32
			Light.Shadows = true
			table.insert(Headlights, {instance = v, material = v.Material})
		end
		if v.Name == "TAILLIGHTS" then
			local Light = Instance.new("PointLight", v)
			Light.Name = "PL"
			Light.Enabled = false
			Light.Brightness = 1
			Light.Color = v.Color
			Light.Range = 8
			Light.Shadows = true
			table.insert(Taillights, {instance = v, material = v.Material})
		end
	end
end

if Configuration.AutoTorque.Value then
	VehicleSeat.Torque = WeightOf(Vehicle) ^ 1.75
end

VehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
	if VehicleSeat.Occupant then
		local Player = Players:FindFirstChild(VehicleSeat.Occupant.Parent.Name)
		if Player then
			local PlayerGui = Player:FindFirstChild("PlayerGui")
			if PlayerGui then
				VehicleSeat:SetNetworkOwner(Player)
				script.Player.Value = Player
				local Client = script.Client:Clone()
				Client.Vehicle.Value = Vehicle
				Client.Parent = PlayerGui
				Client.Disabled = false
				if #(Fake:GetChildren()) > 0 then
					local Character = Player.Character
					if Character then
						for _, v in pairs(Character:GetDescendants()) do
							if v ~= Character.PrimaryPart and v.Name ~= "HumanoidRootPart" then
								if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
									v.Transparency = 1
									if string.lower(v.Name) == "face" then
										v.Parent = script
									end
									if v:IsA("BasePart") then
										v.CanCollide = false
									end
								end	
							end
						end
					end
				end
				if Sound.SoundId ~= "" then
					Sound:Play()
				end
			end
		end
	else
		VehicleSeat:SetNetworkOwnershipAuto()
		local Player = script.Player.Value
		if Player then
			if #(Fake:GetChildren()) > 0 then
				local Character = Player.Character
				if Character then
					for _, v in pairs(Character:GetDescendants()) do
						if v ~= Character.PrimaryPart and v.Name ~= "HumanoidRootPart" then
							if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
								v.Transparency = 0
								if v.Name == "Head" then
									local face = script:FindFirstChild("face")
									if face then
										face.Transparency = 0
										face.Parent = v
									end
								end
								if v:IsA("BasePart") then
									v.CanCollide = true
								end
							end
						end
					end
				end
			end
			script.Player.Value = nil
		end
		if Sound.SoundId ~= "" then
			Sound:Pause()
		end
	end
end)

VehicleSeat:GetPropertyChangedSignal("Throttle"):Connect(function()
	for _, v in pairs(Taillights) do
		v.instance.PL.Enabled = not (VehicleSeat.Throttle > 0)
		if v.instance.PL.Enabled then
			v.instance.Material = Enum.Material.Neon
		else
			v.instance.Material = v.material
		end
	end
end)

if Configuration.EngineSoundId.Value then
	Sound.Volume = 1
	Sound.SoundId = "rbxassetid://".. Configuration.EngineSoundId.Value
	Sound.Looped = true
	RunService.Heartbeat:Connect(function()
		Sound.Pitch = 1 + (Chassis.Velocity.Magnitude / VehicleSeat.MaxSpeed) / 4
	end)
end

script.Keybind.OnServerEvent:Connect(function(Player, KeyCode)
	if KeyCode == Enum.KeyCode.L then
		for _, v in pairs(Headlights) do
			v.instance.PL.Enabled = not v.instance.PL.Enabled
			if v.instance.PL.Enabled then
				v.instance.Material = Enum.Material.Neon
			else
				v.instance.Material = v.material
			end
		end
	end
end)