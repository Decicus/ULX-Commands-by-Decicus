local CATEGORY_NAME  = "TTT" --Make a category group in ULX.
local gamemode_error = "This gamemode is not Trouble in Terrorist Town." --Taken from Bender and Skillz' TTT module. - Credit to both of them.

--SlapNR function.
--[Start]----------------------------------------------------------------------------
--Command inspired by Bender and Skillz' "SlayNR".
--I wanted to make a "slapnr", due to how we actually have people that only damage a bit, and our staff members seem to forget to punish some people when we have a full server.
function ulx.slapnr ( calling_ply, target_ply, dmg_num )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) --Taken from Bender and Skillz' TTT module. Checks if the gamemode is actually TTT.
	else
		local slap_dmg = tonumber(target_ply:GetPData("slapnr_dmg")) or 0 --Shortcut to the PData. PData stores the damage needed to be done next round.
		if dmg_num < 0 then
			ULib.tsayError(calling_ply, "Damage can't be negative.", true) --Damage can't be less than 0.
		elseif dmg_num > 99 then
			ULib.tsayError(calling_ply, "You can't slap with more than 99!", true) --Damage can't be more than 99, as that will kill the person. This isn't a "slay next round".
		elseif dmg_num == 0 then
			target_ply:RemovePData("slapnr_dmg") --If the damage is 0, it will remove the PData. 0 = No slap.
			slapnr_msg = ("#A removed the slapnr of #T.")
		else
			if dmg_num ~= slap_dmg then
				target_ply:SetPData("slapnr_dmg", dmg_num)	--This sets a new slap damage, overrides a previous one if existant.
				slapnr_msg = ("#A is slapping #T for "..dmg_num.." damage next round.")
			elseif dmg_num == slap_dmg then
				ULib.tsayError(calling_ply, "This amount of damage is already set to the target!", true) --Example: If the target already has a slapnr on them, if someone tries to do it again with the same amount of damage, they'll get notified.
			else
				target_ply:SetPData("slapnr_dmg", dmg_num) --This sets the slap damage.
				slapnr_msg = ("#A is slapping #T for "..dmg_num.." damage next round.")
			end
		end
		ulx.fancyLogAdmin( calling_ply, slapnr_msg, target_ply )
	end
end
--ULX Command things here.
local slapnr = ulx.command( CATEGORY_NAME, "ulx slapnr", ulx.slapnr, "!slapnr" )
slapnr:addParam{ type=ULib.cmds.PlayerArg }
slapnr:addParam{ type=ULib.cmds.NumArg, min=0, default=50, max=99, hint="damage", ULib.cmds.round }
slapnr:defaultAccess( ULib.ACCESS_ADMIN )
slapnr:help( "Slaps a target next round." )
slapnr:setOpposite( "ulx rslapnr", {_, _, 0}, "!rslapnr" )

--Helper functions for SlapNR
function SlapNRHelper ()
	for _, v in ipairs (player.GetAll()) do
		local slap_dmg = tonumber(v:GetPData("slapnr_dmg")) or 0 --Shortcut again!
		if v:Alive() and slap_dmg > 0 then --Checks if alive and that the damage is more than 0.
			ULib.slap(v, slap_dmg) --Utilises ULib.slap to actually take care of the slapping.
			ULib.tsayColor( nil, Color( 255, 0, 0 ), v:Nick(), Color( 255, 255, 255 ), " got slapped for " .. tostring( slap_dmg ) .. " damage." )
			v:RemovePData("slapnr_dmg") --Remove the slap damage, or else it will repeat itself every round.
		end
	end
end
hook.Add("TTTBeginRound", "SlapNRHelper", SlapNRHelper) --Slap happens when the round starts.

function InformSlapNR (ply)
	local slap_dmg = tonumber(ply:GetPData("slapnr_dmg")) or 0 --Do I need to write 'shortcut' on all of these?
	if ply:Alive() and slap_dmg > 0 then --Again checks if the player is alive and then checks if their "slap_dmg" is more than 0.
		ULib.tsayColor( nil, Color( 255, 0, 0 ), ply:Nick(), Color( 255, 255, 255 ), " is being slapped for " .. tostring(slap_dmg) .. " damage." )
	end
end
hook.Add("PlayerSpawn", "InformSlapNR", InformSlapNR) --Informs everyone when they spawn in.
--[End]------------------------------------------------------------------------------

--Slaynr leave notifier
--[Start]----------------------------------------------------------------------------
function SlayNRLeaveInform (ply)
	local slays_left = tonumber(ply:GetPData("slaynr_slays")) or 0 --Taken from Bender and Skillz' TTT module. Shortcut to their "slaynr" PData.
	if slays_left > 0 then --Slays left need to be more than 0. Or else this will print to everyone that leaves.
		for _, a in ipairs (player.GetAll()) do
			if a:IsAdmin() then --Checks if there's an admin on.
				ULib.tsayColor(a, true, Color(255, 255, 255), "The player ", Color(255, 0, 0), ply:Nick(), Color(255, 255, 255), " (", Color(255, 0, 0), ply:SteamID(), Color(255, 255, 255), ") left the server with ", Color(255, 0, 0), tostring(slays_left), Color(255, 255, 255), " slay(s) left.") 
				--Prints to admins that someone with slays left leaves. I like colors.
			end
		end
	end
end
hook.Add("PlayerDisconnected", "SlayNRLeaveInform", SlayNRLeaveInform)
--[End]------------------------------------------------------------------------------

--Toggle Auto-Damagelog on Round End.
--[Start]----------------------------------------------------------------------------
--This is a TTT command, what it will do is to automatically print the damagelog to your console if you enable it.
function ulx.toggledamagelog( calling_ply )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) --Taken from Bender and Skillz' TTT module. Checks if the gamemode is actually TTT.
	else
		local togdmglog = tonumber(calling_ply:GetPData("autodmglog_data", 0)) --Bender and/or Skillz, I love you for showing me this with your SlayNR command (PData).
		if togdmglog == 0 then --Checks if the person has disabled the damagelog or not used it before.
			ULib.tsayColor( calling_ply, true, Color(0, 255, 0), "You have enabled your automatic damagelog. It will print to your console when the round ends." ) --Prints to their chat that it's enabled (green text).
			calling_ply:SetPData("autodmglog_data", 1) --Sets the PData so my helper function prints the damagelog to their console.
			ulx.logString( calling_ply:Nick() .. " has enabled their automatic damagelog.", true )
		else --Basically if it's "1", it will set it to "0". In the end, it will disable the auto-damagelog.
			ULib.tsayColor( calling_ply, true, Color(255, 0, 0), "You have disabled your automatic damagelog. It will no longer print to your console when the round ends.") --Notifies the one who uses the command that it's disabled (red text).
			calling_ply:SetPData("autodmglog_data", 0) --Sets the PData to 0, this is the thing that actually disables it.
			ulx.logString( calling_ply:Nick() .. " has disabled their automatic damagelog.", true )
		end
	end
end
local toggledamagelog = ulx.command( CATEGORY_NAME, "ulx toggledamagelog", ulx.toggledamagelog, "!toggledamagelog" )
toggledamagelog:defaultAccess( ULib.ACCESS_ALL )
toggledamagelog:help( "Enables/disables the damagelog." )

--This is the function that actually prints the damagelog to the player's console.
function DamageLogPrintHelper()
	for k, v in ipairs (player.GetAll()) do
		local togdmglog = tonumber(v:GetPData("autodmglog_data", 0)) --Shortcut, like every other GetPData local thingymajigger.
		if togdmglog == 1 then --Checks if the toggledamagelog data is set to 1.
			v:ConCommand("ttt_print_damagelog") --If the "if" statement figures out it's set to "1", it will print the damagelog when the round ends.
		end
	end
end
hook.Add("TTTEndRound", "DamageLogPrintHelper", DamageLogPrintHelper)
--[End]------------------------------------------------------------------------------

--[Start - AFKMe]--------------------------------------------------------------------
function ulx.afkme( calling_ply, should_unafk )
	if not should_unafk then
		calling_ply:ConCommand("ttt_spectator_mode 1")
		ulx.logString( calling_ply:Nick() .. " forced themself to spectator." )
		ULib.tsay( calling_ply, "You're now set to spectator mode." )
	else
		calling_ply:ConCommand("ttt_spectator_mode 0")
		ulx.logString( calling_ply:Nick() .. " forced themself out of spectator." )
		ULib.tsay( calling_ply, "You're now out of spectator mode." )
	end
end
local afkme = ulx.command( CATEGORY_NAME, "ulx afkme", ulx.afkme, "!afkme" )
afkme:addParam{ type=ULib.cmds.BoolArg, invisible=true }
afkme:defaultAccess( ULib.ACCESS_ALL )
afkme:help( "Forces yourself to spectator" )
afkme:setOpposite( "ulx unafkme", {_, true}, "!unafkme" )
--[End - AFKMe]----------------------------------------------------------------------

--[Start - Damagelog]----------------------------------------------------------------
function ulx.damagelog ( calling_ply )
	--Everything below is pretty much taken from admin.lua of TTT.
	local pr = GetPrintFn( calling_ply )
	ServerLog(Format("%s printed the damagelog, using 'ulx damagelog'\n", IsValid( calling_ply ) and calling_ply:Nick() or "console"))
    pr("*** Damage log:\n")

    for k, txt in ipairs(GAMEMODE.DamageLog) do
		pr(txt)
    end

	pr("*** Damage log end.")
end
local damagelog = ulx.command( CATEGORY_NAME, "ulx damagelog", ulx.damagelog, "!damagelog" )
damagelog:defaultAccess( ULib.ACCESS_SUPERADMIN )
damagelog:help( "Prints the damagelog to the console." )

function GetPrintFn( ply )
   if IsValid( ply ) then
      return function(...)
                local t = ""
                for _, a in ipairs({...}) do
                   t = t .. "\t" .. a
                end
                ply:PrintMessage(HUD_PRINTCONSOLE, t)
             end
   else
      return print
   end
end
--[[
	Developer notes:
	95% of this code is taken from admin.lua in TTT.
	I only did a few modifications to it, so it works as a ULX command.
	I (Decicus) only take credit for the very, very few additions/changes to this.
--]]
--[End - Damagelog]------------------------------------------------------------------