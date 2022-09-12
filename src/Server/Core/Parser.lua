--[[

Parser:
	Author: github.com/Iamhere345
	License: MIT
	Description: Parses commands set to Fastr and compiles configuration data from settings.
	Command or alias validity check -> player rank check -> control character check and control char execution -> modifier or control arg check ->
	control arg execution | normal execution

]]

local Parser = {}
--this script parses commands and also compiles stuff from settings

--//instances
local Fastr = script.Parent.Parent
local CommandsFolder = Fastr:WaitForChild("Core").Commands
--//dependencies
local ArgLib = require(Fastr:WaitForChild("Lib"):WaitForChild("ArgLib")).new()
local MiscUtils = require(Fastr:WaitForChild("Utils").MiscUtils)
local UIUtils = require(Fastr:WaitForChild("Utils"):WaitForChild("UIUtils"))
local Settings = require(Fastr:WaitForChild("Settings"))
--//settings
local Ranks = Settings.Ranks
local GroupRanks = Settings.GroupRanks
local prefix = Settings.Prefix

task.wait(0.25)

local Commands = MiscUtils.CompileCommands(CommandsFolder)

print(ArgLib)

--Rank functions:
local function GetPermissionLevel(player) --gets a players permission level. it loops through the ranks table and if it finds the players userid or name as the first value it will return the second value. otherwise it will return 0
	for _, v in pairs(Ranks) do
		if v[1] == player.UserId or v[1] == player.Name then
			return v[2]
		end
	end
	return 0
end

local function CheckGroupPerms(player) --converts a players value in the group ranks table to a normal rank
	for _, v in pairs(GroupRanks) do
		if player:IsInGroup(v[1]) then
			if player:GetRankInGroup(v[1]) == v[2] and GetPermissionLevel(player) == 0 then
				table.insert(Ranks, { player.UserId, v[2] })
			end
		end
	end
end

local function GetDefaultRank(player) --changes all the rank of all players who don't have a rank to the default rank
	if GetPermissionLevel(player) == 0 then
		table.insert(Ranks, { player.UserId, Settings.DefaultRank })
	end
end

local function IsValidCommand(cmd) --checks if a command is in the commands table
	if Commands[string.lower(cmd)] then
		return true
	else
		return false
	end
end

local function IsValidAlias(cmd) --checks if the command the player has said is an alias of a command
	for _, command in pairs(Commands) do
		if command.Aliases then
			-- selene: allow(unused_variable)
			for i, a in ipairs(command.Aliases) do
				if a == cmd then
					return string.lower(command.Name)
				end
			end
		end
	end
	return nil
end

--control character functions:
local function PipeCommand(player, args1, args2) --these are both parsed tables
	--local targets = ArgLib:checkMod(args2[2])

	local cmd2 = args2[1]
	table.remove(args2, 1)

	print(args1)
	print(args2)

	cmd2 = Commands[cmd2]

	print(cmd2)

	local cmd2Ret = cmd2.Run(player, player, args2)

	table.insert(args1, cmd2Ret)

	print(args1)

	return args1
end

local function RepeatCmd(args, cmd)
	if args[#args - 1] == Settings.RepeatChar and tonumber(args[#args]) then
		return math.clamp(tonumber(args[#args]), 1, cmd["RepeatCeiling"]) or math.clamp(tonumber(args[#args]), 1, 250)
	end

	return nil
end

local function GetFlags(args: {string})
	local flags = {}

	for i, arg in args do
		if string.sub(arg, 0, 1) == "-" then
			print("match: "..arg)

			arg = arg:sub(1, arg:len())

			if arg:len() > 1 then
				for x = 0, string.len(arg), 1 do
					table.insert(flags, string.sub(arg, x, x))
					table.remove(args, i)
				end
			else
				table.insert(flags, arg)
				table.remove(args, i)
			end
			
		end
	end

	return args, flags
end

local function getQuotedArgs(args: {string}) --TODO allow multiple quoted args

	args = table.concat(args, " ")
 
	if string.find(args, '%b""') then
		
	 local startStr, endStr = string.find(args, '%b""')
 
	 local beforeQuote = string.sub(args, 0, startStr-2)
	 beforeQuote = string.split(beforeQuote, " ")
	 
	 local afterQuote = string.sub(args, endStr+2, -1) --the plus and minus two get rid of the quotation mark and space
	 afterQuote = string.split(afterQuote, " ")
 
	 table.insert(beforeQuote, string.match(args, '%b""'))
	 
	 for _,v in pairs(afterQuote) do
		 table.insert(beforeQuote, v)
	 end
 
	 args = beforeQuote
 
	 return args
 
	end
	 
	return string.split(args, " ")
 
 end

--misc functions

local function RunCmd(args, cmd, cmdFunction) --this is for repeat functionality
	local RptCmd_result = RepeatCmd(args, cmd)

	if RptCmd_result then
		table.remove(args, #args)
		table.remove(args, #args)

		for _ = 0, RptCmd_result, 1 do
			cmdFunction()
		end
	else
		cmdFunction()
	end
end

Parser.ParseCmd = function(player: Player, msg: string, UsingPrefix: boolean)
	CheckGroupPerms(player)
	GetDefaultRank(player)

	local rank = GetPermissionLevel(player)
	local CommandStr = string.split(msg, " ")[1]
	local args = string.split(msg, " ")
	local flags

	if string.sub(msg, 0, 1) == prefix and UsingPrefix == true then --check if the prefix was used
		CommandStr = string.split(CommandStr, ":")[2]
	elseif UsingPrefix == true then
		return
	end

	string.lower(CommandStr)
	table.remove(args, 1) --remove the command from the args table (because the command isn't an argument)

	args, flags = GetFlags(args) --seperate the flags from the args
	args = getQuotedArgs(args) --There can only be one quoted arg currently

	if IsValidCommand(CommandStr) or IsValidAlias(CommandStr) then --check if the command is valid
		if IsValidAlias(CommandStr) then
			CommandStr = IsValidAlias(CommandStr) --gets the command from the alias
		end

		local command = Commands[string.lower(CommandStr)]
		local Modifyers = command.Modifyers

		if command.PermissionLevel <= rank then

			do --checks for control characters
				if table.find(args, Settings.PipeChar) then --this means the user wants to pipe a command to another command
					--prep args for piping
					local argsCopy = MiscUtils.DeepCopy(args)

					argsCopy = table.concat(argsCopy, " ")

					argsCopy = string.split(argsCopy, Settings.PipeChar)

					local args1 = string.split(argsCopy[1], " ")
					local args2 = string.split(argsCopy[2], " ")

					if args2[1] == "" then --if the user used a space after typing the pipe char, there would be a space as an argument, which Fastr does not like
						table.remove(args2, 1)
					end

					if args1[#args1] == "" then
						table.remove(args1, #args1)
					end

					args = PipeCommand(player, args1, args2)
				end

				if table.find(args, Settings.AndChar) then --if the user has inputted multiple commands (:sm message + m  message + fly me)
					local argsCopy = MiscUtils.DeepCopy(args)

					argsCopy = table.concat(argsCopy, " ")
					argsCopy = string.split(argsCopy, Settings.AndChar)

					table.remove(argsCopy, 1)

					for i, s in ipairs(argsCopy) do
						if string.sub(s, 0, 1) == " " then
							argsCopy[i] = string.sub(s, 2, -1)
						end
						--[[
					if string.sub(s,string.len(s)-1,string.len(s)) == " " then
						print("EE")
						argsCopy[i] = string.sub(s,0,string.len(s)-1)
					end]]
						-- support for more than two commands at a time will come in the future
					end

					argsCopy = table.concat(argsCopy, "")

					Parser.ParseCmd(player, argsCopy, false)

					args = table.concat(args, " ")
					args = string.split(args, Settings.AndChar)

					table.remove(args, 2)

					args = args[1]
					args = string.split(args, " ")
				end
			end

			if Modifyers then

				if table.find(Modifyers, args[1]) then
					if ArgLib.controlArgs[string.lower(args[1])] and tostring(args[1]) ~= "getplayertarget" then --ArgLib:getPlayerTarget is special and cannot be accessed from the player just typing player
						local targets = ArgLib:checkMod(player, args[1], args)

						print("got target(s)")

						RunCmd(args, command, function()
							for _, target in targets do
								command.Run(player, target, args, flags)
							end
						end)
					end
				else --this will fire if the first argument (usually reserved for a mod) is not a valid mod.
					print("not valid mod")

					local Target = ArgLib:getPlayerTarget(player, args[1])

					if Target then
						RunCmd(args, command, function()
							command.Run(player, Target, args, flags)
						end)
					else
						RunCmd(args, command, function()
							command.Run(player, player, args, flags)
						end)
					end
				end
			else --if there are no modifyers, the mod argument will be the player that ran the command
				RunCmd(args, command, function()
					command.Run(player, player, args, flags)
				end)
			end
		else
			UIUtils.Notify(player, "Error", "you do not have permission to run this command")
		end
	end
end

return Parser
