local curLetter = 1
local canType = true
local vaildKeys = {" Enum.KeyCode.A", "Enum.KeyCode.B", "Enum.KeyCode.C"," Enum.KeyCode.D"," Enum.KeyCode.E", "Enum.KeyCode.F", "Enum.KeyCode.G","Enum.KeyCode.H", "Enum.KeyCode.I", "Enum.KeyCode.J", "Enum.KeyCode.K", "Enum.KeyCode.L", "Enum.KeyCode.N", "Enum.KeyCode.M", "Enum.KeyCode.O", "Enum.KeyCode.P", "Enum.KeyCode.R"," Enum.KeyCode.S", "Enum.KeyCode.T", "Enum.KeyCode.U", "Enum.KeyCode.V"," Enum.KeyCode.W", "Enum.KeyCode.X", "Enum.KeyCode.Y", "Enum.KeyCode.Z"}
local currentRow = 1
local colors = 
	{
		absent = Color3.new(0.541176, 0.541176, 0.541176),
		present = Color3.new(1, 0.921569, 0.470588),
		correct = Color3.new(0.486275, 1, 0.396078)
	}
local sounds =
	{
		absent = "rbxassetid://6022989753",
		present = "rbxassetid://7146792142",
		correct = "rbxassetid://6436188054"
	}
local letterStrings = {"","","","",""}
local results = {}
game:GetService("ReplicatedStorage").HTTPFailure.OnClientEvent:Connect(function(problem)
	script.Parent.Whoops.Visible = true
	canType = false
	script.Parent.Whoops.err.Text = problem
end)
game:GetService("ReplicatedStorage").HTTPFound.OnClientEvent:Connect(function()
	script.Parent.Whoops.Visible = false
	canType = true
end)
game:GetService('ReplicatedStorage').forceWin.OnClientEvent:Connect(function()
	print("win forced by server")
	script.Parent.WinScreen.subtitle.Text = "You've already beaten today's Wordle!"
	canType = false
	script.Parent.Win:Play()
	local animator = require(script.Parent.WinScreen.Animator)
	animator.Win:Play()
end)
game:GetService("ReplicatedStorage").forceLose.OnClientEvent:Connect(function()
	script.Parent.Lose:Play()
	script.Parent.WinScreen.title.Text= "Nice Try!"
	script.Parent.WinScreen.subtitle.Text = "You gave it your best!"
	local animator = require(script.Parent.WinScreen.Animator)
	animator.Win:Play()
end)
game:GetService("ReplicatedStorage").returnResults.OnClientEvent:Connect(function(tableOfResults,row)
	results = {}
	for i,v in pairs(tableOfResults) do
		print(v.result)
		
		results[i] = v.result
		script.Parent.Background.Game:FindFirstChild("Row"..row.."Letter"..i).BackgroundColor3 = colors[v.result]
		script.Parent.SFX.SoundId =  sounds[v.result]
		script.Parent.SFX:Play()
		task.wait(.75)
	end
	local good = true
	for i2,v2 in pairs(results) do
		if v2 ~= 'correct' then
			good = false
		end
	end
	if good then
		script.Parent.Win:Play()
		local animator = require(script.Parent.WinScreen.Animator)
		animator.Win:Play()
	end
	if not good and currentRow == 7 then
		script.Parent.Lose:Play()
		script.Parent.WinScreen.title.Text= "Nice Try!"
		script.Parent.WinScreen.subtitle.Text = "You gave it your best!"
		local animator = require(script.Parent.WinScreen.Animator)
		animator.Win:Play()
	end
	canType = true
end)
game:GetService("UserInputService").InputBegan:Connect(function(key,processed)
	if canType then
	if processed then
		print("Server processed this key.")
	else
		print("Server did not process this key.")
	end
		if key.KeyCode == Enum.KeyCode.Return then
			if letterStrings[5] ~= "" then
				game.ReplicatedStorage:FindFirstChild("submitGuess"):FireServer(letterStrings,currentRow)
				canType = false
			currentRow += 1
			curLetter = 1
			letterStrings = {"","","","",""}
			return
			end
			
	end
	if key.KeyCode == Enum.KeyCode.Backspace then
		if curLetter ~= 1 then
			letterStrings[curLetter-1] = ""
				script.Parent.Delete:Play()
			curLetter-=1
			script.Parent.Background.Game:FindFirstChild("Row"..currentRow.."Letter"..curLetter):FindFirstChild("Input").Text =""
			return
		end
	end
	if curLetter == 6 then
		print("not passed")
			return
		end
	if table.find(vaildKeys,tostring(key.KeyCode)) then
			script.Parent.Key:Play()
			letterStrings[curLetter] = key.KeyCode.Name
		script.Parent.Background.Game:FindFirstChild("Row"..currentRow.."Letter"..curLetter):FindFirstChild("Input").Text = key.KeyCode.Name
		curLetter += 1
		end
		end
end)
local function toHMS(s)
	return string.format("%02i:%02i:%02i", s/60^2, s/60%60, s%60)
end
repeat wait() until game.ReplicatedStorage.Players:FindFirstChild(game.Players.LocalPlayer.Name)
while true do
	local day = math.floor((os.time()) / (60 * 60 * 24)) 
	local t = (math.floor(os.time()))
	local daypass = t % 86400 
	local timeleft = 86400 - daypass 
	local timeleftstring = toHMS(timeleft)
	script.Parent.WinScreen.timer.Text = timeleftstring
	script.Parent.WinScreen.correct.Text ="Correct Words: "..game.ReplicatedStorage.Players:FindFirstChild(game.Players.LocalPlayer.Name):GetAttribute("wins")
	script.Parent.WinScreen.played.Text = "Total Games Played: "..game.ReplicatedStorage.Players:FindFirstChild(game.Players.LocalPlayer.Name):GetAttribute("totalGames")
	script.Parent.WinScreen.acc.Text = "Streak: "..game.ReplicatedStorage.Players:FindFirstChild(game.Players.LocalPlayer.Name):GetAttribute("streak")
	for i3,v3 in pairs(script.Parent.Background.Game:GetChildren()) do
		if v3:IsA("Frame") then
			if v3.Name == "Row"..currentRow.."Letter"..curLetter then
				v3.BackgroundColor3 = Color3.fromRGB(204, 204, 204)
			else
				if v3.BackgroundColor3 == Color3.fromRGB(204, 204, 204) then
					v3.BackgroundColor3 = Color3.fromRGB(120,120,120)
				end
			end
		end
	end
	task.wait(0.1)
end
