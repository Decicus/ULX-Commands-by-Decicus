-- The V2.0 rewrite of the TTT commands that are included in my "Decicus' ULX Commands" addon.
-- Let's make it better.

local CATEGORY_NAME = "TTT"

function ulx.slapnr( calling_ply, target_ply, damage )

	local currentSlap = tonumber( target_ply:GetPData( "ulx_slapnextround" ) ) or 0
	
	if damage == 0 then
		
		target_ply:RemovePData( "ulx_slapnextround" )
		message = "#A removed the SlapNR of #T."
		
	else
	
		if damage == currentSlap then
		
			ULib.tsayError( calling_ply, calling_ply:Nick() .. " is already being slapped for that amount of damage." )
			
		else
		
			target_ply:SetPData( "ulx_slapnextround", damage )
			message = "#A is slapping #T for " .. damage .. " damage next round."
			
		end
		
	end
	
	ulx.fancyLogAdmin( calling_ply, message, target_ply )
		
end
local slapnr = ulx.command( CATEGORY_NAME, "ulx slapnr", ulx.slapnr, "!slapnr" )
slapnr:addParam{ type=ULib.cmds.PlayerArg, hint="Player to target" }
slapnr:addParam{ type=ULib.cmds.NumArg, min=0, max=99, hint="Slap damage", ULib.cmds.round }
slapnr:defaultAccess( ULib.ACCESS_ADMIN )
slapnr:help( "Allows you to slap a target in the next TTT round." )
slapnr:setOpposite( "ulx rslapnr", { _, _, 0 }, "!rslapnr" )

-- Well, that was a lot cleaner, wasn't it?
-- Let's create the functions for slapping and notifying.

function NotifyPlayerSlap( ply )

	local slapDamage = tonumber( ply:GetPData( "ulx_slapnextround" ) ) or 0
	
	if slapDamage > 0 then
	
		ULib.tsayColor( ply, true, Color( 255, 0, 0 ), "Slap Next Round: ", Color( 0, 255, 0 ), ply:Nick(), Color( 255, 255, 255 ), ", you are being slapped for ", Color( 255, 0, 0 ), slapDamage, Color( 255, 255, 255 ), " damage next round you play." )
		
	end	

end
hook.Add( "PlayerInitialSpawn", "NotifyPlayerSlap", NotifyPlayerSlap )
hook.Add( "PlayerSpawn", "NotifyPlayerSlapOnSpawn", NotifyPlayerSlap )

function SlapPlayers()

	for _, ply in ipairs( player.GetAll() ) do
		
		local slapDamage = tonumber( ply:GetPData( "ulx_slapnextround" ) ) or 0
	
		if ply:Alive() and slapDamage > 0 then
			
			ULib.slap( ply, slapDamage )
			ULib.tsay( ply, "You have been slapped for " .. slapDamage .. " damage this round." )
			ULib.tsay( nil, ply:Nick() .. " has been slapped for " .. slapDamage .. " damage this round." )
			ply:RemovePData( "ulx_slapnextround" ) -- Make sure to remove it so it doesn't slap every single round after that.
			
		end
	
	end

end
hook.Add( "TTTBeginRound", "SlapPlayers", SlapPlayers )

function ulx.toggledamagelog( calling_ply )

	local logEnabled = tonumber( calling_ply:GetPData( "ulx_toggle_damagelog" ) ) or 0
	
	if logEnabled == 0 then
	
		calling_ply:SetPData( "ulx_toggledamagelog", 1 )
		ULib.tsayColor( calling_ply, Color( 0, 255, 0 ), "ToggleDamagelog: You have enabled your automatic damagelog." )
		ulx.logString( "Toggle Damagelog: " .. calling_ply:Nick() .. "(" .. calling_ply:SteamID() .. ") has enabled their automatic damagelog.", true )
		
	else
	
		calling_ply:SetPData( "ulx_toggledamagelog", 0 )
		ULib.tsayColor( calling_ply, Color( 255, 0, 0 ), "ToggleDamagelog: You have disabled your automatic damagelog." )
		ulx.logString( "Toggle Damagelog: " .. calling_ply:Nick() .. "(" .. calling_ply:SteamID() .. ") has disabled their automatic damagelog.", true )
		
	end

end
local tdamagelog = ulx.command( CATEGORY_NAME, "ulx toggledamagelog", ulx.toggledamagelog, "!toggledamagelog" )
tdamagelog:defaultAccess( ULib.ACCESS_ALL )
tdamagelog:help( "Allows you toggle on/off an automatic damagelog that prints to your console after every round." )

function ToggleDamagelogPrint()

	for _, ply in ipairs( player.GetAll() ) do
	
		local logEnabled = tonumber( ply:GetPData( "ulx_toggledamagelog" ) ) or 0
		
		if logEnabled ~= 0 then
		
			ply:ConCommand( "ttt_print_damagelog" )
			
		end
	
	end

end
hook.Add( "TTTEndRound", "ToggleDamagelogPrint", ToggleDamagelogPrint )

function ulx.afkme( calling_ply, should_unafk )

	if not should_unafk then
	
		calling_ply:ConCommand( "ttt_spectator_mode 1" )
		ulx.logString( calling_ply:Nick() .. " forced themself into spectator." )
		ULib.tsay( calling_ply, "You're now in spectator mode." )
		
	else
	
		calling_ply:ConCommand( "ttt_spectator_mode 0" )
		ulx.logString( calling_ply:Nick() .. " forced themself out of spectator." )
		ULib.tsay( calling_ply, "You're now out of spectator mode." )
	
	end

end
local afkme = ulx.command( CATEGORY_NAME, "ulx afkme", ulx.afkme, "!afkme" )
afkme:addParam{ type=ULib.cmds.BoolArg, invisible=true }
afkme:defaultAccess( ULib.ACCESS_ALL )
afkme:help( "Puts your into spectator. Use 'ulx unafkme' (console) or '!afkme' (chat) if you want to get out of spectator. " )
afkme:setOpposite( "ulx unafkme", { _, true }, "!unafkme" )

function ulx.damagelog( calling_ply )
	
	-- I haven't done anything here except for small modifications so it actually works.
	-- Original code taken from admin.lua inside Trouble in Terrorist Town's gamemode folder.
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

-- Code below is for "ULX SlayNR" notifications.
function SlayNRDisconnect( ply )

	local slays = tonumber( ply:GetPData( "slaynr_slays" ) ) or 0
	
	if slays > 0 then
	
		for _, p in ipairs( player.GetAll() ) do
	
			if p:IsAdmin() then
						
				ULib.tsayColor( p, true, Color( 255, 255, 255 ), "The player ", Color( 255, 0, 0 ), ply:Nick(), Color( 255, 255, 255 ), " (", ply:SteamID(), ") left the server with ", Color( 255, 0, 0 ), tostring( slays ), Color( 255, 255, 255 ), " slay(s) left." )
			
			end
	
		end
		
	end
	
end
hook.Add( "PlayerDisconnected", "SlayNRDisconnect", SlayNRDisconnect )