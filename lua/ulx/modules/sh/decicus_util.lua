-- Rewrite of my Utility commands.
-- The official V2.0 of "Decicus' ULX Commands".
-- Let's make this less messy.
-- Most of this code is just a small rewrite with spacing and minor modifications.

local CATEGORY_NAME = "Utility"

function ulx.fmotd( calling_ply, target_ply )

	target_ply:ConCommand( "ulx motd" )
	ulx.fancyLogAdmin( calling_ply, "#A force-opened the MOTD for #T.", target_ply )
	
end
local fmotd = ulx.command( CATEGORY_NAME, "ulx fmotd", ulx.fmotd, "!fmotd" )
fmotd:addParam{ type=ULib.cmds.PlayerArg }
fmotd:defaultAccess( ULib.ACCESS_ADMIN )
fmotd:help( "Opens the MOTD for the targeted player." )

function ulx.reloadmap( calling_ply )

	local map = game.GetMap()
	
	ULib.tsay( nil, calling_ply:Nick() .. " reloaded the map." )
	
	timer.Simple( 1.5, function()
	
		game.ConsoleCommand( "changelevel " .. map .. "\n" ) -- Add a timer so it doesn't change right away.
	
	end)

end
local reloadmap = ulx.command( CATEGORY_NAME, "ulx reloadmap", ulx.reloadmap, "!reloadmap" )
reloadmap:defaultAccess( ULib.ACCESS_ADMIN )
reloadmap:help( "Reloads/restarts the current map." )

function ulx.skick( calling_ply, target_ply, reason )

	if reason and reason ~= "" then
	
		ulx.fancyLogAdmin( calling_ply, true, "#A silently kicked #T (#s)", target_ply, reason )
		
	else
	
		ulx.fancyLogAdmin( calling_ply, true, "#A silently kicked #T (No reason)", target_ply )
	
	end
	
	ULib.kick( target_ply, reason, calling_ply )

end
local skick = ulx.command( CATEGORY_NAME, "ulx skick", ulx.skick, "!skick", true )
skick:addParam{ type=ULib.cmds.PlayerArg }
skick:addParam{ type=ULib.cmds.StringArg, hint="Reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
skick:defaultAccess( ULib.ACCESS_ADMIN )
skick:help( "Silently kicks the player." )