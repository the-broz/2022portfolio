

local inventory = {
	"AK47", --Primary
	"Beretta", --Secondary
	"Knife", -- Melee
	"N/A" -- Special
}

local inventorybinds = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four
}

repeat wait() until game:IsLoaded()

local gunModel = game.ReplicatedStorage.Weapons.Models.Ranged:WaitForChild(inventory[1])
local viewModel = game.ReplicatedStorage:WaitForChild("viewModel")
local switchingGuns = false
local AnimationsFolder = gunModel.GunComponents:WaitForChild("Animations")

local mainModule = require(game.ReplicatedStorage.Weapons.Modules.MainModule)
local springModule = require(game.ReplicatedStorage.Modules.SpringModule)

local lastCleanUp = os.time()
local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
local cleanUpMin = 120
local RecoilSpring = springModule.new()
local BobbleSpring = springModule.new()
local SwayingSpring = springModule.new()
local isHoldingMouse = false
local canFire = true
local curSlot = 1
local canSwitchSlots = true
local canReload = true
local sprintAnim = nil
local ammo = gunModel:GetAttribute("ammo")
local fireDelay = gunModel:GetAttribute("fireDelay")
local partCache = require(game.ReplicatedStorage.Weapons.Modules.PartCache)

viewModel.Parent = game.Workspace.Camera

mainModule.weldgun(gunModel)

game.ReplicatedStorage.Remotes.Framework.FireGun.OnClientEvent:Connect(function(plr,origin,direction,velocity)
	if plr == game.Players.LocalPlayer then return end
	mainModule.fireFromPoint(origin,direction,velocity)
end)

game:GetService("RunService").RenderStepped:Connect(function(dt)
	if switchingGuns then return end
	fireDelay = gunModel:GetAttribute("fireDelay")
	ammo = gunModel:GetAttribute("ammo")
	game.Players.LocalPlayer.PlayerGui:WaitForChild("GameUI").GunName.Text = gunModel.Name
	game.Players.LocalPlayer.PlayerGui:WaitForChild("GameUI").Ammo.RichText = true
	if canReload == true then
		game.Players.LocalPlayer.PlayerGui:WaitForChild("GameUI").Ammo.Text = '<font color="rgb(255,255,255)" size="20">'..ammo..'</font>/'..gunModel:GetAttribute("maxAmmo")..''
	else
		game.Players.LocalPlayer.PlayerGui:WaitForChild("GameUI").Ammo.Text = "RELOADING"
		end
	mainModule.update(viewModel,dt,RecoilSpring,BobbleSpring,SwayingSpring,gunModel)
end)

mainModule.equip(viewModel,gunModel,AnimationsFolder.Hold)

game:GetService("UserInputService").InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isHoldingMouse = true
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		if sprintAnim ~= nil then
			mainModule.stopSprint(viewModel,game.Players.LocalPlayer,sprintAnim)
		end
		mainModule.aim(true,viewModel,gunModel)
	elseif input.KeyCode == Enum.KeyCode.R and ammo ~= "-" then
		if canReload == true then
			if sprintAnim ~= nil then
				mainModule.stopSprint(viewModel,game.Players.LocalPlayer,sprintAnim)
			end
			canReload = false
			mainModule.reload(viewModel,gunModel.GunComponents.Animations.Reload,gunModel)
		gunModel:SetAttribute("ammo",gunModel:GetAttribute("maxAmmo")) 
			canReload = true
			end
	elseif input.KeyCode == Enum.KeyCode.Q then
		mainModule.rollRight()
	elseif input.KeyCode == Enum.KeyCode.E then
		mainModule.rollLeft()
	elseif input.KeyCode == inventorybinds[1] and curSlot ~= 1 and canSwitchSlots then
		if gunModel.Name == "Knife" then
			mainModule.unequip(viewModel,gunModel,"melee")
		else
			mainModule.unequip(viewModel,gunModel)
		end
		curSlot = 1
		switchingGuns = true
		local newModel = game.ReplicatedStorage.Weapons.Models.Ranged:FindFirstChild(inventory[curSlot])
		if newModel == nil then newModel = inventory[2] end
		print(newModel.Name..curSlot)
		if newModel:FindFirstChild("GunComponents"):FindFirstChild("Handle"):GetChildren()[1] == nil then
			mainModule.weldgun(newModel)
		end
		
		gunModel = newModel
		mainModule.equip(viewModel,newModel,newModel.GunComponents.Animations.Hold)
		switchingGuns = false
	elseif input.KeyCode == inventorybinds[2] and curSlot ~= 2 then
		if gunModel.Name == "Knife" then
			mainModule.unequip(viewModel,gunModel,"melee")
		else
			mainModule.unequip(viewModel,gunModel)
		end
		curSlot = 2
		switchingGuns = true
		local newModel = game.ReplicatedStorage.Weapons.Models.Ranged:FindFirstChild(inventory[curSlot])
		if newModel == nil then newModel = inventory[2] end
		print(newModel.Name..curSlot)
		if newModel:FindFirstChild("GunComponents"):FindFirstChild("Handle"):GetChildren()[1] == nil then
			mainModule.weldgun(newModel)
		end
		
		gunModel = newModel
		mainModule.equip(viewModel,newModel,newModel.GunComponents.Animations.Hold)
		switchingGuns = false
	elseif input.KeyCode == inventorybinds[3] and curSlot ~= 3 then
		if gunModel.Name == "Knife" then
			mainModule.unequip(viewModel,gunModel,"melee")
		else
			mainModule.unequip(viewModel,gunModel)
		end
		curSlot = 3
		switchingGuns = true
		local newModel = game.ReplicatedStorage.Weapons.Models.Melees:FindFirstChild(inventory[curSlot])
		if newModel == nil then newModel = inventory[2] end
		print(curSlot)
		if newModel:FindFirstChild("GunComponents"):FindFirstChild("Handle"):GetChildren()[1] == nil then
			mainModule.weldgun(newModel)
		end
		
		gunModel = newModel
		mainModule.equip(viewModel,newModel,newModel.GunComponents.Animations.Hold)
		switchingGuns = false
	elseif input.KeyCode == Enum.KeyCode.LeftShift then
		mainModule.aim(false,viewModel,gunModel)
		sprintAnim = mainModule.sprint(viewModel,gunModel.GunComponents.Animations.Sprint, game.Players.LocalPlayer)
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isHoldingMouse = false
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		mainModule.aim(false,viewModel,gunModel)
	elseif input.KeyCode == Enum.KeyCode.Q then
		mainModule.rollMid()
	elseif input.KeyCode == Enum.KeyCode.E then
		mainModule.rollMid()
	elseif input.KeyCode == Enum.KeyCode.LeftShift then
		mainModule.stopSprint(viewModel,game.Players.LocalPlayer,sprintAnim)
		sprintAnim = nil
	end
end)

game:GetService("RunService").Heartbeat:Connect(function(dt)
	if isHoldingMouse then
		if ammo == "-" and canFire then
			canFire = false
			mainModule.castMelee(gunModel,gunModel.GunComponents.Animations.Shoot, viewModel)
			wait(fireDelay)
			canFire = true
			return
		end
		if canFire and ammo > 0 and canReload == true and Character.Humanoid.Health ~= 0 then
			canFire = false
			if gunModel.GunComponents.Animations:FindFirstChild("Shoot") ~= nil then
				local Attack:AnimationTrack = viewModel.AnimationController:LoadAnimation(gunModel.GunComponents.Animations.Shoot)
				Attack:Play()
			end
			local newBullet = game.ReplicatedStorage.Weapons.Models.BulletModels:FindFirstChild(gunModel:GetAttribute("wepType")):Clone()
			newBullet.CFrame = gunModel.GunComponents.Ejection.CFrame
			newBullet.Parent = workspace.GroundRounds
			newBullet.Anchored = false
			newBullet.Velocity = Vector3.new(20,20,20)
			game:GetService("Debris"):AddItem(newBullet,3)
			if sprintAnim ~= nil then
				mainModule.stopSprint(viewModel,game.Players.LocalPlayer,sprintAnim)
				end
			gunModel:SetAttribute("ammo",ammo-1)
			RecoilSpring:shove(Vector3.new(1.5, math.random(-2,2), 10))
			
			coroutine.wrap(function()
				for i,v in pairs(gunModel.GunComponents.Barrel:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v:Emit()
					end
					wait(.025)
				end
				newBullet.CanCollide = true
				
				local fireSound = gunModel.GunComponents.Sounds.Fire:Clone()
				
				fireSound.Parent = game.Workspace
				fireSound.Parent = nil
				fireSound:Destroy()
			end)()
			
			coroutine.wrap(function()
				
			wait(0.2)
				RecoilSpring:shove(Vector3.new(-.8,math.random(-1,1),-10))
			end)()
			local thisparams = RaycastParams.new()
			thisparams.IgnoreWater = true
			thisparams.FilterType = Enum.RaycastFilterType.Blacklist
			thisparams.FilterDescendantsInstances = {viewModel,Character}
			mainModule.cast(gunModel, (mainModule.GetMouse(1000,thisparams)-gunModel.GunComponents.Barrel.Position).Unit, 400,thisparams)
			
			wait(fireDelay)
			canFire = true
		elseif ammo == 0 and canReload == true then
			canReload = false
			local reloadmodel = gunModel
			if sprintAnim ~= nil then
				mainModule.stopSprint(viewModel,game.Players.LocalPlayer,sprintAnim)
				end
			mainModule.reload(viewModel,gunModel.GunComponents.Animations.Reload,gunModel)
			if gunModel ~= reloadmodel then
				canReload = true
				return
			end
			reloadmodel:SetAttribute("ammo",gunModel:GetAttribute("maxAmmo")) 
			canReload = true
		end
	end
end)
