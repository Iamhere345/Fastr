--[[

Core_Commands:
	Author github.com/Iamhere345
	License: MIT
	Description: The default commands that Fastr comes with that can be executed by players with high enough privleges.
	These commands are purely utilites, as we try to make sure that Fastr doesn't have any 'bloat' commands.

]]

--# selene: allow(unused_variable)
local Core_Commands = {}
--this script contains all of the core commands for Fastr. They can be disabled from the loader by changing coreCommandsEdits or in the script by setting them to nil just before the return statement.
local Fastr = script.Parent.Parent.Parent

local ArgLib = require(Fastr:WaitForChild("Lib"):WaitForChild("ArgLib"))
local ModLib: {}? = nil

local UIUtils = require(Fastr:WaitForChild("Utils"):WaitForChild("UIUtils"))

local Resources = Fastr.Resources
local remotes = game.ReplicatedStorage.Fastr_Remotes

task.spawn(function()
	ModLib = require(Fastr.Lib:WaitForChild("ModLib"))
end)

Core_Commands.cmds = {
	Name = "cmds",
	Desc = "brings up the Commands ui",
	Usage = ":cmds",
	PermissionLevel = 0,
	Aliases = {"Help","Commands"},
	Run = function(player,target,args,flags)
		remotes.OpenMenu:FireClient(player,"Commands")
	end,
}

Core_Commands.m = {
	Name = "m",
	Desc = "shows a message on the screen of every player in the game",
	Usage = ":m [duration] <message>",
	PermissionLevel = 1.5,
	Aliases = {"message"},
	Run = function(player,target,args,flags)

		local Duration = 5

		if args and #args > 1 or args and typeof(args[1]) == "string" then

			if tonumber(args[1]) then

				Duration = tostring(args[1])
				table.remove(args,1)

				local Message = table.concat(args," ")
				local filteredMessage = game:GetService("Chat"):FilterStringForBroadcast(Message, player) --do not change this, if you remove the filter i am NOT responsible for what happens

				remotes.ShowMessage:FireAllClients(filteredMessage,player.Name,Duration)
			else
				local Message = table.concat(args," ")
				local filteredMessage = game:GetService("Chat"):FilterStringForBroadcast(Message, player) --do not change this, if you remove the filter i am NOT responsible for what happens

				remotes.ShowMessage:FireAllClients(filteredMessage,player.Name,Duration)
			end
		else
			UIUtils.Notify(player,"Error","message not specified")
		end
	end,
}

Core_Commands.sm = {
	Name = "sm",
	Desc = "shows a message on the top of every players screen",
	Usage = ":sm [duration] <message>",
	PermissionLevel = 1,
	Aliases = {"smallmessage"},
	Run = function(player,target,args,flags)

		local Duration = 5

		if args and #args > 1 or args and typeof(args[1]) == "string" then

			if tonumber(args[1]) then

				Duration = tostring(args[1])
				table.remove(args,1)

				local Message = table.concat(args," ")
				local filteredMessage = game:GetService("Chat"):FilterStringForBroadcast(Message, player)

				remotes.ShowSmallMessage:FireAllClients(filteredMessage,player.Name,Duration)
			else

				local Message = table.concat(args," ")
				local filteredMessage = game:GetService("Chat"):FilterStringForBroadcast(Message, player)

				remotes.ShowSmallMessage:FireAllClients(filteredMessage,player.Name,Duration)
			end
		else
			UIUtils.Notify(player,"Error","message not specified")
		end
	end,
}

Core_Commands.whisper = {
	Name = "whisper",
	Desc = "sends a message to a certain player or group of players",
	Usage = ":whisper <player OR modifyer> <message>",
	PermissionLevel = 0,
	Modifyers = {"all","me","others","random","randother","team"},
	Aliases = {"tell"},
	Run = function(player,target,args,flags)

		table.remove(args,1)
		local msg = table.concat(args," ")

		UIUtils.Notify(target,nil,msg,"Message from "..player.Name,nil,7)

	end,
}

Core_Commands.splitteam = {
	Name = "splitteam",
	Desc = "splits one team into two",
	Usage = ":twoteams <team to split> <team1> <team2>",
	PermissionLevel = 1,
	Aliases = {"twoteams"},
	Run = function(player,target,args,flags)
		if args[3] then
			local splitTeam = args[1]
			local team1 = args[2]
			local team2 = args[3]

			if game.Teams:FindFirstChild(splitTeam) and game.Teams:FindFirstChild(team1) and game.Teams:FindFirstChild(team2) then
				splitTeam = game.Teams[splitTeam]
				team1 = game.Teams[team1]
				team2 = game.Teams[team2]

				local PlayersInSplitTeam = {}

				for i,v in pairs(game.Players:GetPlayers()) do
					if v.Team == splitTeam then
						table.insert(PlayersInSplitTeam,v)
					end
				end

				for i,v in pairs(PlayersInSplitTeam) do
					if i > #PlayersInSplitTeam / 2 then
						player.Team = team1
					else
						player.Team = team2
					end
				end

			else
				UIUtils.Notify(player,"Error","not a valid team")
			end

		else
			UIUtils.Notify(player,"Error","argument missing")
		end
	end,
}

Core_Commands.createteam = {
	Name = "createteam",
	Desc = "creates a team",
	Usage = ":createteam <team name (no spaces)> [BrickColor]",
	PermissionLevel = 1,
	Aliases = {},
	Run = function(player,target,args,flags)
		
		if args[1] then
			local team = Instance.new("Team",game.Teams)

			local TeamName = game:GetService("Chat"):FilterStringForBroadcast(args[1],player)

			team.Name = TeamName

			if args[2] then

				table.remove(args,1)

				local Brick_Colour = table.concat(args," ")
				team.TeamColor = BrickColor.new(Brick_Colour)

			else
				team.TeamColor = BrickColor.Random()
			end
			
			print(team.Name)
			
			return team.Name
			
		else
			UIUtils.Notify(player,"Error","argument missing")
		end
	end,
}

Core_Commands.team = {
	Name = "Team",
	Desc = "changes a players team",
	Usage = ":team <player OR modifyer>",
	Modifyers = {"all","me","others","random","randother"},
	PermissionLevel = 1,
	Aliases = {"changeteam"},
	Run = function(player,target,args,flags)
		target.Team = game.Teams:FindFirstChild(args[2])
	end,
}

Core_Commands.tp = {
	Name = "tp",
	Desc = "teleports a player to another player",
	Usage = ":tp <player1> <player2>",
	PermissionLevel = 0.5,
	Modifyers = {"all","me","others","random","randother","team"},
	Aliases = {"teleport"},
	Run = function(player,target,args,flags) --please remember that target is args[1], which means you cannot do :tp <player> all
		target.Character.Humanoid:ChangeState(Enum.HumanoidStateType.None)

		local targets = ArgLib:checkMod(player,args[2],args)

		if targets then
			for _,t in pairs(targets) do
				target.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame + player.Character.HumanoidRootPart.CFrame.LookVector * 2
			end
		elseif ArgLib:getPlayerTarget(player,args[2]) then
			target.Character.HumanoidRootPart.CFrame = ArgLib:getPlayerTarget(player,args[2])[1].Character.HumanoidRootPart.CFrame + player.Character.HumanoidRootPart.CFrame.LookVector * 2
		end
	end,
}

Core_Commands.bring = {
	Name = "bring",
	Desc = "brings a player to you",
	Usage = ":bring <player OR modifyer>",
	PermissionLevel = 1,
	Modifyers = {"all","me","others","random","randother","team"},
	Aliases = {},
	Run = function(player,target,args,flags)
		target.Character.Humanoid:ChangeState(Enum.HumanoidStateType.None)
		target.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + player.Character.HumanoidRootPart.CFrame.LookVector * 2
	end,
}

Core_Commands.to = {
	Name = "To",
	Desc = "teleports you to a player",
	Usage = ":to <player OR modifyer>",
	PermissionLevel = 1,
	Modifyers = {"all","me","others","random","randother","team"},
	Aliases = {},
	Run = function(player,target,args,flags)
		target.Character.Humanoid:ChangeState(Enum.HumanoidStateType.None)
		player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + target.Character.HumanoidRootPart.CFrame.LookVector * 2
	end,
}

Core_Commands.fly = {
	Name = "fly",
	Desc = "allows you to fly",
	Usage = ":fly <player OR modifyer>",
	PermissionLevel = 1,
	Modifyers = {"all","me","others","random","randother","team"},
	Aliases = {},
	Run = function(player,target,args,flags)
		
		local noclip_enabled
		
		if table.find(flags,"n") then
			noclip_enabled = true
		else
			noclip_enabled = false
		end
		
		remotes.Fly:FireClient(target,noclip_enabled)
	end,
}

Core_Commands.ban = {
	Name = "Ban",
	Desc = "bans a player for x amount of days",
	Usage = ":ban <player> [days]",
	PermissionLevel = 2,
	Modifyers = {"all","me","others","random","randother","team"},
	Run = function(player,target,args,flags)
		print(target.Name)
		
		if not tonumber(args[2]) then
			UIUtils.Notify(player,"Error","not a valid amount of time")
			return
		end
		
		if not ModLib then
			UIUtils.Notify(player,"Error","Fastr's moderation system hasn't loaded in yet. Please try again soon")
			return
		end

		local days: number
		
		if table.find(flags,"P") then
			days = 99e9 
		else 
			days = tonumber(args[2]) 
		end
		
		for i = 0,1,1 do 
			table.remove(args,1) 
		end
		
		local note
		
		if args[1] then
			note = table.concat(args," ")
			note = game:GetService("Chat"):FilterStringAsync(note,player,target)
		else
			note = "no note provided"
		end
		
		ModLib:banPlr(target, days, player, note)
	end,
}

Core_Commands.unban = {
	Name = "unban",
	Desc = "unbans a player",
	Usage = ":unban <players full name>",
	PermissionLevel = 2,
	Modfyers = {},
	Run = function(player,target,args,flags)

		if not ModLib then
			UIUtils.Notify(player,"Error","Fastr's moderation system hasn't loaded in yet. Please try again soon")
			return
		end

		if args[1] then

			if game.Players:GetUserIdFromNameAsync(args[1]) then
				ModLib.unbanPlr(player,game.Players:GetUserIdFromNameAsync(args[1]))
			else
				UIUtils.Notify("Error","Not a valid player")
			end
		else
			UIUtils.Notify(player,"Error","argument not specified, see cmds for more info on how to use this command")
		end
	end,
}

Core_Commands.kick = {
	Name = "kick",
	Desc = "kicks a player from the server",
	Usage = ":kick <player> [message]",
	PermissionLevel = 1.5,
	Modifyers = {"all","me","others","random","randother","team"},
	Run = function(player,target,args,flags)
		
		if target then
			target:Kick(args[2])
		else
			UIUtils.Notify(player,"Error","Not a valid player")
		end
		
	end,
}

Core_Commands.kill = {
	Name = "kill",
	Desc = "kills a player",
	Usage = ":kill <player>",
	PermissionLevel = 1,
	Modifyers = {"all","me","others","random","randother","team"},
	Aliases = {},
	Run = function(player,target,args,flags)
		if target.Character then
			target.Character:WaitForChild("Humanoid"):TakeDamage(100)
		else
			target.CharacterAdded:Wait()
			target.Character:WaitForChild("Humanoid"):TakeDamage(100)
		end
	end
}

Core_Commands.btools = {
	Name = "btools",
	Desc = "gives a player building tools by F3X (credit to F3X for making Building Tools By F3X)",
	Usage = ":btools <player OR Modifyer>",
	PermissionLevel = 1.5,
	RepeatCeiling = 10,
	Modifyers = {"all","me","others","random","randother","team"},
	Aliases = {},
	Run = function(player,target,args,flags)
		local f3x = Resources.Btools:Clone()
		f3x.Parent = target.Backpack
	end
}

Core_Commands.menu = {
	Name = "Menu",
	Desc = "opens Fastr's menu",
	Usage = ":menu",
	PermissionLevel = 1,
	Aliases = {"openmenu","showmenu"},
	Run = function(player,target,args,flags)
		remotes.OpenMenu:FireClient(player,"Help")
	end,
}

Core_Commands.countdown = {
	Name = "Countdown",
	Desc = "shows a countdown on the top of every players screen",
	Usage = ":countdown <time>",
	PermissionLevel = 1.5,
	Run = function(player,target,args,flags)
		if tonumber(args[1]) then
			remotes.ShowCountdown:FireAllClients(args[1])
		else
			UIUtils.Notify(player,"Error","Not a number")
		end
	end,
}

Core_Commands.freeze = {
	Name = "Freeze",
	Desc = "Stops a player from moving",
	Usage = ":freeze <player OR modifyer> [duration]",
	PermissionLevel = 1.5,
	Modifyers = {"all"},
	Aliases = {"anchor","stopmovement"},
	Run = function(player,target,args,flags)

		local char = target.Character or target.Character:Wait()

		local function Anchor()
			
			for _,p in pairs(char:GetChildren()) do
				if p:IsA("BasePart") then
					p.Anchored = true
				end
			end
			
			if args[2] and tonumber(args[2]) then
				
				local i = 0 
				
				repeat
					task.wait(1)
					i += 1
				until i == tonumber(args[2])
				
				if not char then --the player might have reset after the duration is over
					task.wait() --there is a chance that the duration could finish right as the player resets, causing a race condition
				end
				
			end
			
		end
		
		
		Anchor()
		
		char.Humanoid.Died:Connect(function() -- >:)
			char = target.Character:Wait()
			Anchor()
		end)
		
	end,
}

Core_Commands.unfreeze = {
	Name = "unfreeze",
	Desc = "unfreezes a frozen player",
	Usage = ":unfreeze <player>",
	PermissionLevel = 1.5,
	Modifyers = {"all"},
	Run = function(player,target,args,flags)
		if target.Character or target.CharacterAdded:Wait() then
			
			local char = target.Character
			
			for _,p in pairs(char:GetChildren()) do
				if p:IsA("BasePart") then
					p.Anchored = false
				end
			end
			
		end
	end,
}

return Core_Commands
