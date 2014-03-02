local CATEGORY_NAME  = "TTT" --Make a category group in ULX.
local gamemode_error = "This gamemode is not Trouble in Terrorist Town." --Taken from Bender and Skillz' TTT module. - Credit to both of them.

--SlapNR function.
--[Start]----------------------------------------------------------------------------
--Command inspired by Bender and Skillz' "SlayNR".
--I wanted to make a "slapnr", due to how we actually have people that only damage a bit, and our staff members seem to forget to punish some people when we have a full server.
function ulx.slapnr ( calling_ply, target_ply, dmg_num )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) --Taken from Bender and Skillz' TTT module. Checks if the gamemode is actually TTT.
	else
		local slap_dmg = tonumber(target_ply:GetPData("slapnr_dmg")) or 0
		if dmg_num < 0 then
			ULib.tsayError(calling_ply, "Damage can't be negative.", true)
		elseif dmg_num > 99 then
			ULib.tsayError(calling_ply, "You can't slap with more than 99!", true)
		elseif dmg_num == 0 then
			target_ply:RemovePData("slapnr_dmg")
			slapnr_msg = ("#A removed the slapnr of #T.")
		else
			if dmg_num ~= slap_dmg then
				target_ply:SetPData("slapnr_dmg", dmg_num)
				slapnr_msg = ("#A is slapping #T for "..dmg_num.." damage next round.")
			elseif dmg_num == slap_dmg then
				ULib.tsayError(calling_ply, "This amount of damage is already set to the target!", true)
			else
				target_ply:SetPData("slapnr_dmg", dmg_num)
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
		local slap_dmg = tonumber(v:GetPData("slapnr_dmg")) or 0
		if v:Alive() and slap_dmg > 0 then
			ULib.slap(v, slap_dmg)
			ULib.tsayColor( nil, Color( 255, 0, 0 ), v:Nick(), Color( 255, 255, 255 ), " got slapped for " .. tostring( slap_dmg ) .. " damage." )
			v:RemovePData("slapnr_dmg")
		end
	end
end
hook.Add("TTTBeginRound", "SlapNRHelper", SlapNRHelper) --Slap happens when the round starts.

function InformSlapNR (ply)
	local slap_dmg = tonumber(ply:GetPData("slapnr_dmg")) or 0
	if ply:Alive() and slap_dmg > 0 then
		ULib.tsayColor( nil, Color( 255, 0, 0 ), ply:Nick(), Color( 255, 255, 255 ), " is being slapped for " .. tostring(slap_dmg) .. " damage." )
	end
end
hook.Add("PlayerSpawn", "InformSlapNR", InformSlapNR)
--[End]------------------------------------------------------------------------------

-- Toggle Auto-Damagelog on Round End.
--[Start]----------------------------------------------------------------------------
-- This is a TTT command, what it will do is to automatically print the damagelog to your console if you enable it.
function ulx.toggledamagelog( calling_ply )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true )
	else
		local togdmglog = tonumber(calling_ply:GetPData("autodmglog_data", 0))
		if togdmglog == 0 then
			ULib.tsayColor( calling_ply, true, Color(0, 255, 0), "You have enabled your automatic damagelog. It will print to your console when the round ends." ) --Prints to their chat that it's enabled (green text).
			calling_ply:SetPData("autodmglog_data", 1)
			ulx.logString( calling_ply:Nick() .. " has enabled their automatic damagelog.", true )
		else
			ULib.tsayColor( calling_ply, true, Color(255, 0, 0), "You have disabled your automatic damagelog. It will no longer print to your console when the round ends.")
			calling_ply:SetPData("autodmglog_data", 0)
			ulx.logString( calling_ply:Nick() .. " has disabled their automatic damagelog.", true )
		end
	end
end
local toggledamagelog = ulx.command( CATEGORY_NAME, "ulx toggledamagelog", ulx.toggledamagelog, "!toggledamagelog" )
toggledamagelog:defaultAccess( ULib.ACCESS_ALL )
toggledamagelog:help( "Enables/disables the damagelog." )

-- This is the function that actually prints the damagelog to the player's console.
function DamageLogPrintHelper()
	for k, v in ipairs (player.GetAll()) do
		local togdmglog = tonumber(v:GetPData("autodmglog_data", 0))
		if togdmglog == 1 then
			v:ConCommand("ttt_print_damagelog")
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