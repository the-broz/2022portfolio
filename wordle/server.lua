local DDS = game:GetService("DataStoreService")
local DS = DDS:GetDataStore("PlayerData-v1")
local apiString:string = "HIDDEN FOR PRIVACY"
local results = {}
local apiStringALT:string = "HIDDEN FOR PRIVACY"
local HTTPRequests = game:GetService("HttpService")
game.Players.PlayerAdded:Connect(function(plr)
	local plrStore = DS:GetAsync(plr.UserId)
	if not plrStore then
		DS:SetAsync(plr.UserId,{unixTimeBeat = 1,wordsBeat = 0,totalGamesPlayed=0,streak=0,win=false})
	else
		local playerTime = os.date("!*t",plrStore.unixTimeBeat)
		local gameTime = os.date("!*t",os.time())
		
		print(playerTime.yday,gameTime.yday)
		if playerTime.yday == gameTime.yday then
			if plrStore.win == true then
				game.ReplicatedStorage.forceWin:FireClient(plr)
			else
				game.ReplicatedStorage.forceLose:FireClient(plr)
			end
		else
			DS:SetAsync(plr.UserId,{unixTimeBeat = 1,wordsBeat = plrStore.wordsBeat,totalGamesPlayed=plrStore.totalGamesPlayed,streak=plrStore.streak,win=false})
		end
	end
	plrStore = DS:GetAsync(plr.UserId)
	local plrData = Instance.new("ObjectValue",game.ReplicatedStorage.Players)
	plrData.Name = plr.Name
	plrData.Value = plr
	plrData:SetAttribute("unixTimeBeat",plrStore.unixTimeBeat)
	plrData:SetAttribute("wins",plrStore.wordsBeat)
	plrData:SetAttribute("totalGames",plrStore.totalGamesPlayed)
	plrData:SetAttribute("streak",plrStore.streak)
end)
local function testServer()
	local amIGood, endResult = pcall(function()
		if not game:GetService("RunService"):IsStudio() then
			HTTPRequests:GetAsync(apiString,false)
		else
			HTTPRequests:GetAsync(apiStringALT,false)
		end
	end)
	return {amIGood,endResult}
end
local testSuccess, result = pcall(function()
	if not game:GetService("RunService"):IsStudio() then
		HTTPRequests:GetAsync(apiString,false)
	else
		HTTPRequests:GetAsync(apiStringALT,false)
		end
end)
if testSuccess then
	print("Successful Connection To Server!")
else
	game.ReplicatedStorage.HTTPFailure:FireAllClients("Finding Error")
end
game.ReplicatedStorage.submitGuess.OnServerEvent:Connect(function(plr,tableOfguess,row)
	local guessString:string = tableOfguess[1]..tableOfguess[2]..tableOfguess[3]..tableOfguess[4]..tableOfguess[5]
	local request = 
		{
			guess = guessString,
			size = "5"
		}
	local http = nil
	local JSONRequest = HTTPRequests:JSONEncode(request)
	local success , result = pcall(function()
		
		if not game:GetService("RunService"):IsStudio() then
			http = HTTPRequests:GetAsync(apiString,false,request)
		else
			http = HTTPRequests:GetAsync(apiStringALT,false,request)
		end
	end)
	repeat wait(2) until success ~= nil
	if success then
		local part1 = string.gsub(http,"%[","")
		local part2 = string.gsub(part1,"%]","")
		local part3a = string.split(part2,"},")[1].."}"
		local part3b = string.split(part2,"},")[2].."}"
		local part3c = string.split(part2,"},")[3].."}"
		local part3d = string.split(part2,"},")[4].."}"
		local part3e = string.split(part2,"},")[5]
		local part4a = string.gsub(part3a,"'",'"')
		local part4b = string.gsub(part3b,"'",'"')
		local part4c = string.gsub(part3c,"'",'"')
		local part4d = string.gsub(part3d,"'",'"')
		local part4e = string.gsub(part3e,"'",'"')
		local result1= HTTPRequests:JSONDecode(part4a)
		local result2= HTTPRequests:JSONDecode(part4b)
		local result3= HTTPRequests:JSONDecode(part4c)
		local result4= HTTPRequests:JSONDecode(part4d)
		local result5= HTTPRequests:JSONDecode(part4e)
		local tableOfResults = {result1,result2,result3,result4,result5}
		for i,v in pairs(tableOfResults) do
			results[i] = v.result
		end
		local good = true
		for i2,v2 in pairs(results) do
			if v2 ~= 'correct' then
				good = false
			end
		end
		if good then
			local pastData = DS:GetAsync(plr.UserId)
			DS:SetAsync(plr.UserId,{unixTimeBeat = os.time(),wordsBeat = pastData.wordsBeat +1,totalGamesPlayed = pastData.totalGamesPlayed +1,streak = pastData.streak + 1,win=true})
			local plrData = game.ReplicatedStorage:FindFirstChild("Players"):FindFirstChild(plr.Name)
			plrData.Name = plr.Name
			plrData.Value = plr
			plrData:SetAttribute("unixTimeBeat",os.time())
			plrData:SetAttribute("wins",plrData:GetAttribute("wins")+1)
			plrData:SetAttribute("totalGames",plrData:GetAttribute("totalGames")+1)
			plrData:SetAttribute("streak",plrData:GetAttribute("streak")+1)
		else
			local pastData = DS:GetAsync(plr.UserId)
			local plrData = game.ReplicatedStorage:FindFirstChild("Players"):FindFirstChild(plr.Name)
			DS:SetAsync(plr.UserId,{unixTimeBeat = os.time(),wordsBeat = pastData.wordsBeat,totalGamesPlayed = pastData.totalGamesPlayed +1,streak = 0,win=false})
			plrData:SetAttribute("unixTimeBeat",os.time())
			plrData:SetAttribute("totalGames",plrData:GetAttribute("totalGames")+1)
			plrData:SetAttribute("streak",0)
		end
		game.ReplicatedStorage.returnResults:FireClient(plr,{result1,result2,result3,result4,result5},row)
	else
	return	
	end
end)

while true do
	local test = testServer()
	if test[1] == true then
		print("Server Ping Sucess")
		game.ReplicatedStorage.HTTPFound:FireAllClients()
	else
		warn("Server Ping Failed. Warning Clients")
		game.ReplicatedStorage.HTTPFailure:FireAllClients(test[2])
	end
	task.wait(5)
end 
