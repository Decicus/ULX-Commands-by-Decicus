local CATEGORY_NAME = "Chat"

-- Permmute sort of inspired by Cobalt's "pgag".
function ulx.pmute( calling_ply, target_ply, should_unpmute )

	if should_unpmute then
	
		target_ply:RemovePData( "ULX_PermMute" )
		ulx.fancyLogAdmin( calling_ply, "#A unpermmuted #T.", target_ply )
		
	else
	
		target_ply:SetPData( "ULX_PermMute", "true" )
		ulx.fancyLogAdmin( calling_ply, "#A permmuted #T.", target_ply )
		
	end

end
local pmute = ulx.command( CATEGORY_NAME, "ulx pmute", ulx.pmute, "!pmute" )
pmute:addParam{ type=ULib.cmds.PlayerArg }
pmute:addParam{ type=ULib.cmds.BoolArg, invisible=true }
pmute:defaultAccess( ULib.ACCESS_ADMIN )
pmute:help( "Mutes the target permanently." )
pmute:setOpposite( "ulx unpmute", { _, _, true }, "!unpmute" )

function ulx.pmuteid( calling_ply, sid, should_unpmuteid )

	local sid = string.upper( sid )

	if not ULib.isValidSteamID( sid ) then
	
		ULib.tsayError( calling_ply, "Invalid Steam ID!" )
		
	else
	
		if should_unpmuteid then
		
			util.RemovePData( sid, "ULX_PermMute" )
			ulx.fancyLogAdmin( calling_ply, "#A unpermmuted the Steam ID: #s", sid )
		
		else
		
			util.SetPData( sid, "ULX_PermMute", "true" )
			ulx.fancyLogAdmin( calling_ply, "#A permmuted the Steam ID: #s", sid )
		
		end
	
	end

end
local pmuteid = ulx.command( CATEGORY_NAME, "ulx pmuteid", ulx.pmuteid, "!pmuteid" )
pmuteid:addParam{ type=ULib.cmds.StringArg, hint="Player Steam ID." }
pmuteid:addParam{ type=ULib.cmds.BoolArg, invisible=true }
pmuteid:defaultAccess( ULib.ACCESS_ADMIN )
pmuteid:help( "Mutes a player's Steam ID permanently." )
pmuteid:setOpposite( "ulx unpmuteid", { _, _, true }, "!unpmuteid" )

function CheckPMuted( ply, str, t )

	if ply:GetPData( "ULX_PermMute" ) == "true" then
	
		ULib.tsayError( ply, "You are permanently muted and cannot speak." )
		return ""
	
	end

end
hook.Add( "PlayerSay", "Check_Perm_Muted", CheckPMuted )