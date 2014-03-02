local CATEGORY_NAME = "Utility"

-- Force MOTD on players. Useful for people that have important rules in their MOTD that should be read.
function ulx.fmotd ( calling_ply, target_ply )
	target_ply:ConCommand( "ulx motd" )
	ulx.fancyLogAdmin( calling_ply, "#A opened the MOTD on #T", target_ply )
end
local fmotd = ulx.command( CATEGORY_NAME, "ulx fmotd", ulx.fmotd, "!fmotd" )
fmotd:addParam{ type=ULib.cmds.PlayerArg }
fmotd:defaultAccess( ULib.ACCESS_ADMIN )
fmotd:help( "Forces the MOTD to be opened for the target." )

function ulx.reloadmap( calling_ply )
	map = game.GetMap()
	ulx.fancyLogAdmin( calling_ply, "#A reloaded the map" )
	game.ConsoleCommand( "changelevel " .. map ..  "\n" )
end
local reloadmap = ulx.command( CATEGORY_NAME, "ulx reloadmap", ulx.reloadmap, "!reloadmap" )
reloadmap:defaultAccess( ULib.ACCESS_ADMIN )
reloadmap:help( "Reloads the map you're currently on." )

-- Credit to Markusmoo.
-- This is technically the standard "ULX Kick" command, I don't take credit for anything else other than adding a silent function to it, but also the "print to admins" part.
function ulx.skick( calling_ply, target_ply, reason )
	if reason and reason ~= "" then
		ulx.fancyLogAdmin( calling_ply, true, "#A silently kicked #T (#s)", target_ply, reason )
	else
		reason = nil
		ulx.fancyLogAdmin( calling_ply, true, "#A silently kicked #T", target_ply )
	end
	ULib.kick( target_ply, reason, calling_ply )
end
local skick = ulx.command( CATEGORY_NAME, "ulx skick", ulx.skick, "!skick", true )
skick:addParam{ type=ULib.cmds.PlayerArg }
skick:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
skick:defaultAccess( ULib.ACCESS_ADMIN )
skick:help( "Silently kicks target." )