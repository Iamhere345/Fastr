# Making Commands

**This section assumes that you already have some knowledge of Luau**

Where you write commands is different depending on what version of Fastr you are using.

### Loader version
- navigate to the Fastr folder
- Find and open the `Commands` module

### Source version
- navigate to Fastr > Core > Commands
- create a new module (name it whatever you want)

## How to write commands

to make a command, you must add a table to the commands module script. command template:

```lua
Commands.(command name goes here) = {
	Name = "",
	Desc = "",
	Usage = "",
	PermissionLevel = 1,
	Modifyers = {},
	Aliases = {},
	Run = function(player,target,args,flags)
		
	end
}
```
- Name: This is the name of the command. Fastr's parser uses this.

- Desc: a description of the command. this is useful for readability and is used by the :cmds command.
- Usage: this is also good for readability and is also used in the :cmds command
- PermissionLevel: This is the minimum required rank to run the command.
- Modifyers: The modifyers that can be used on the command

- Aliases: these are not required, but they are (as the name suggests) aliases for your command. If you have a command called :kill and you have "stopliving" in the aliases table, entering :stopliving will be the same as entering :kill.

- Run: this is the actual function where you put your code. it has three arguments:
    - player: the player that called the command. this is an instance, not a string
    - target: the target player, which is nil if your command doesn't have a modifyer. this is an instance, not a string.
    - args: these are all of the arguments for the command. if you used modifyers for your command, your first modifyer should be that modfyer. if the modifyer is team then the second modifyer will be the name of the team
	- flags: a table of all flags that were given when the command was entered.

example command:

```lua
Commands.kill = {
	Name = "kill",
	Desc = "kills the target player",
	Usage = ":kill <player> [amount of times you want to kill them]",
	PermissionLevel = 1.5,
	Modifyers = {"all","me","random","randother","others","team"},
	Aliases = {},
	Run = function(player,target,args,flags)
		
		for _,target in ipairs(target) {
			if args["p"] then
				target.CanRespawn = false
			end

			if target.Character then
				target.Character:FindFirstChild("Humanoid"):TakeDamage(t.Character.Humanoid.MaxHealth)
			else
				target.CharacterAdded:Wait():WaitForChild("Humanoid"):TakeDamage(t.Character.Humanoid.MaxHealth)
			end
		}
		
	end
}
```
