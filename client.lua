local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

repeat wait() until Player.Character ~= nil
local Character = Player.Character

local Vehicle = script:WaitForChild("Vehicle").Value
local Real = Vehicle.REAL
local Chassis = Real.CHASSIS
local VehicleSeat = Real.SEAT

local FLA = Chassis.FLA
local FRA = Chassis.FRA
local RLA = Chassis.FLA
local RRA = Chassis.RRA

local FLCC = Chassis.FLCC
local FRCC = Chassis.FRCC
local RLCC = Chassis.FLCC
local RRCC = Chassis.RRCC

local FLSC = Chassis.FLSC
local FRSC = Chassis.FRSC
local RLSC = Chassis.FLSC
local RRSC = Chassis.RRSC

local STEER = 0
local THROTTLE = 0

Camera.CameraType = Enum.CameraType.Custom
Camera.CFrame = Chassis.CFrame
Camera.CameraSubject = Chassis

RunService.Heartbeat:Connect(function(dt)
	-- Steer:
	local maxSteerAngle = 30
	local steerGoal
	steerGoal = -VehicleSeat.SteerFloat * maxSteerAngle
	STEER = STEER + (steerGoal - STEER) * math.min((dt * VehicleSeat.TurnSpeed), 1)
	FLA.Orientation = Vector3.new(0, STEER + 180, 90)
	FRA.Orientation = Vector3.new(0, STEER + 180, 90)
	-- Trottle:
	local throttleGoal = 0
	throttleGoal = VehicleSeat.ThrottleFloat
	THROTTLE = THROTTLE + (throttleGoal - THROTTLE) * math.min((dt * VehicleSeat.TurnSpeed), 1)
	local torque = VehicleSeat.Torque
	local speed = VehicleSeat.MaxSpeed * THROTTLE
	FLCC.MotorMaxTorque = torque
	FRCC.MotorMaxTorque = torque
	RLCC.MotorMaxTorque = torque
	RRCC.MotorMaxTorque = torque
	FLCC.AngularVelocity = speed
	FRCC.AngularVelocity = -speed
	RLCC.AngularVelocity = speed
	RRCC.AngularVelocity = -speed
end)

UserInputService.InputBegan:Connect(function(Input, External)
	if not External then
		Vehicle.Server.Keybind:FireServer(Input.KeyCode)
	end
end)

while wait() do
	if not VehicleSeat or not Vehicle.Server.Player.Value then
		if Character then
			local Humanoid = Character:FindFirstChild("Humanoid")
			if Humanoid then
				Camera.CameraType = Enum.CameraType.Custom
				Camera.CameraSubject = Humanoid
			end
		end
		FLCC.MotorMaxTorque = 0
		FRCC.MotorMaxTorque = 0
		RLCC.MotorMaxTorque = 0
		RRCC.MotorMaxTorque = 0
		FLCC.AngularVelocity = 0
		FRCC.AngularVelocity = 0
		RLCC.AngularVelocity = 0
		RRCC.AngularVelocity = 0
		break
	end
end

script:Destroy()