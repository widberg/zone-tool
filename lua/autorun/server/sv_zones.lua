if ( CLIENT ) then return end

AddCSLuaFile()
AddCSLuaFile( "autorun/client/cl_zones.lua" )
AddCSLuaFile( "autorun/sh_zones.lua" )

include( "autorun/sh_zones.lua" )

util.AddNetworkString( "ZoneTableUpdate" )

--
-- Master Table
--

ZoneManager = ZoneManager or {}
ZoneManager.Zones = ZoneManager.Zones or {}

--
-- Utility Functions
--

local function affects( zone, ent )
	return ( ( zone.player && ent:IsPlayer() && not ent:IsAdmin() && not ent:IsBot() ) ||
		( zone.admin && ent:IsPlayer() && ent:IsAdmin() && not ent:IsSuperAdmin() ) ||
		( zone.superadmin && ent:IsPlayer() && ent:IsAdmin() && ent:IsSuperAdmin() ) ||
		( zone.bot && ent:IsPlayer() && ent:IsBot() ) ||
		( zone.npc && ent:IsNPC() ) ||
		( zone.ent && not ent:IsPlayer() && not ent:IsNPC() ) )
end

local function permission( ply )
	return ply:IsSuperAdmin() || ply:GetTool( "zone" ) ~= nil
end

--
-- Data Initialization
--

local path

-- Different zones for singleplayer and multiplayer games.
if ( game.SinglePlayer() ) then
	path = "prowolf/zones/" .. game.GetMap() .. ".txt"
else
	path = "prowolf/zones/" .. game.GetMap() .. "_server" .. ".txt"
end

hook.Add( "Initialize", "ProWolf's Zone Tool Data Intialization", function()
	if ( !file.IsDir( "prowolf/zones", "DATA" ) ) then
		file.CreateDir( "prowolf/zones" )

		print( "Creating a zones folder.." )
	end

	if ( !file.Exists( path, "DATA" ) ) then
		file.Write( path, "{}" )

		print( "Creating zone data file.." )
	end

	local data = util.JSONToTable( file.Read( path, "DATA" ) or "{}" )

	if ( data ) then
		ZoneManager.Zones = {}

		for identifier, zone in pairs( data ) do
			if ( identifier ~= nil ) then
				ZoneManager.Zones[ identifier or "Zone" ] = {
					id = identifier or "Zone",
					point1 = zone.point1 or Vector( 0, 0, 0 ),
					point2 = zone.point2 or Vector( 0, 0, 0 ),
					wireframe = tobool( zone.wireframe ) or false,
					player = tobool( zone.player ) or false,
					admin = tobool( zone.admin ) or false,
					superadmin = tobool( zone.superadmin ) or false,
					bot = tobool( zone.bot ) or false,
					npc = tobool( zone.npc ) or false,
					ent = tobool( zone.ent ) or false,
					removeprops = tobool( zone.removeprops ) or false,
					tick = tonumber( zone.tick ) or 1,
					amount = tonumber( zone.amount ) or 1,
					limit = tonumber( zone.limit ) or 0,
					type = tonumber( zone.type ) or TYPE_DAMAGE,
					shape = tonumber( zone.shape ) or SHAPE_BOX,
					r = tonumber( zone.r ) or 255,
					g = tonumber( zone.g ) or 255,
					b = tonumber( zone.b ) or 255,
					a = tonumber( zone.a ) or 255
				}
				
				local type = tonumber( zone.type ) or TYPE_DAMAGE
				if ( type == TYPE_DAMAGE || type == TYPE_HEAL ) then
					timer.Create( "ZoneTimer_" .. zone.id, tonumber( zone.tick ) or 1, 0, function()
						hook.Call( "ZoneTick", nil, zone.id )
					end )
				end
			end
		end
	end

	if ( table.Count( ZoneManager.Zones ) > 0 ) then
		print( "Zones loaded for map: " .. game.GetMap() .. "!" )
	end
end )

--
-- Zone saving
--

concommand.Add("zone_save", function( ply )
	if ( !permission( ply ) ) then ply:PrintMessage( HUD_PRINTCONSOLE, "You do not have permission to use this command!" ) return end

	file.Write( path, util.TableToJSON( ZoneManager.Zones ) )

	if ( table.Count( ZoneManager.Zones ) == 1 ) then
		print( "Successfully saved " .. table.Count( ZoneManager.Zones ) .. " zone!" )
	else
		print( "Successfully saved " .. table.Count( ZoneManager.Zones ) .. " zones!" )
	end
end )

--
-- Zone creation
--

function ZoneManager.CreateZone( identifier, data )
	if ( identifier == nil || not isstring( identifier ) || identifier == "" ) then
		error( "Failed creating a zone! Identifier isn't valid!" )

		return
	end

	if ( not isvector( data.point1 ) || not isvector( data.point2 ) ) then
		error( "Failed creating a zone! One of your points isn't valid!" )

		return
	end
	
	local zone = ZoneManager.Zones[ identifier ]
	
	ZoneManager.Zones[ identifier ] = {
		id = identifier,
		point1 = data.point1 or Vector( 0, 0, 0 ),
		point2 = data.point2 or Vector( 0, 0, 0 ),
		wireframe = tobool( data.wireframe ) or false,
		player = tobool( data.player ) or false,
		admin = tobool( data.admin ) or false,
		superadmin = tobool( data.superadmin ) or false,
		bot = tobool( data.bot ) or false,
		npc = tobool( data.npc ) or false,
		ent = tobool( data.ent ) or false,
		removeprops = tobool( data.removeprops ) or false,
		tick = tonumber( data.tick ) or 1,
		amount = tonumber( data.amount ) or 1,
		limit = tonumber( data.limit ) or 0,
		type = tonumber( data.type ) or TYPE_DAMAGE,
		shape = tonumber( data.shape ) or SHAPE_BOX,
		r = tonumber( data.r ) or 255,
		g = tonumber( data.g ) or 255,
		b = tonumber( data.b ) or 255,
		a = tonumber( data.a ) or 255
	}
	
	local type = tonumber( data.type ) or TYPE_DAMAGE
	if ( type == TYPE_DAMAGE || type == TYPE_HEAL ) then
		timer.Create( "ZoneTimer_" .. identifier, tonumber( data.tick ) or 1, 0, function()
			hook.Call( "ZoneTick", nil, identifier )
		end )
	elseif ( zone ~= nil && ( zone.type == TYPE_DAMAGE || zone.type == TYPE_HEAL) ) then
			timer.Remove( "ZoneTimer_" .. zone.id )
	end
end

--
-- Zone list
--

concommand.Add( "zone_list", function( ply, cmd, args )
	if ( !permission( ply ) ) then ply:PrintMessage( HUD_PRINTCONSOLE, "You do not have permission to use this command!" ) return end
	if ( table.Count( ZoneManager.Zones ) <= 0 ) then print( "There are no zones." ) return end

	PrintTable( ZoneManager.Zones )
end )

--
-- Zone removal
--

function ZoneManager.RemoveZone( identifier )
	local zone = ZoneManager.Zones[ identifier ]
	if ( isstring( identifier ) ) && ( zone ~= nil ) then
		ZoneManager.Zones[ identifier ] = nil
		
		if ( zone.type == TYPE_DAMAGE || zone.type == TYPE_HEAL ) then
			timer.Remove( "ZoneTimer_" .. identifier )
		end
		
		return true
	else
		print( "That isn't a valid zone identifier." )
		return false
	end
end

concommand.Add( "zone_remove", function( ply, cmd, args )
	if ( !permission( ply ) ) then ply:PrintMessage( HUD_PRINTCONSOLE, "You do not have permission to use this command!" ) return end
	local zone = ZoneManager.Zones[ args[ 1 ] ]
	if ( ZoneManager.RemoveZone( args[ 1 ] ) ) then
		undo.Create( "ZoneRemove" )
			undo.AddFunction( function( tab, zone )
				ZoneManager.CreateZone( zone.id, zone )
			end, zone )
			undo.SetPlayer( ply )
		undo.Finish()
		ply:PrintMessage( HUD_PRINTCENTER, "#zone.success.remove" )
	end
end )

--
-- Scalezone
--

hook.Add( "EntityTakeDamage", "ProWolf's Zone Tool Entity Take Damage", function( ent, dmginfo )
	for _, zone in pairs( ZoneManager.Zones ) do
		if ( zone.type == TYPE_SCALE ) then
			local entities
			if ( zone.shape == SHAPE_BOX ) then
				entities = ents.FindInBox( zone.point1, zone.point2 )
			elseif ( zone.shape == SHAPE_SPHERE ) then
				entities = ents.FindInSphere( zone.point1, zone.point1:Distance(zone.point2) )
			end
			if ( table.HasValue( entities, ent ) && affects( zone, ent ) ) then
				dmginfo:ScaleDamage( zone.amount )
			end
		end
	end
end )

--
-- Zone update
--

hook.Add( "ZoneTick", "ProWolf's Zone Tool Zone Tick", function( id )
	if ZoneManager.Zones[ id ] ~= nil then
		zone = ZoneManager.Zones[ id ]
		local entities
		if ( zone.shape == SHAPE_BOX ) then
			entities = ents.FindInBox( zone.point1, zone.point2 )
		elseif ( zone.shape == SHAPE_SPHERE ) then
			entities = ents.FindInSphere( zone.point1, zone.point1:Distance( zone.point2 ) )
		end
		for _, ent in pairs( entities ) do
			if ( affects( zone, ent ) ) then
				if ( zone.type == TYPE_DAMAGE ) then
					if ( zone.limit == 0 ) then
						ent:TakeDamage( zone.amount, nil, nil )
					else
						ent:TakeDamage( math.Clamp( ent:Health() - zone.limit, 0, zone.amount ), nil, nil )
					end
				elseif ( zone.type == TYPE_HEAL ) then
					if ( zone.limit == 0 ) then
						ent:SetHealth( ent:Health() + zone.amount )
					elseif ( ent:Health() < zone.limit ) then
						ent:SetHealth( math.min( ent:Health() + zone.amount, zone.limit ) )
					end
				end
			end
		end
	end
end )

--
-- Prop removal
--

hook.Add( "Think", "ProWolf's Zone Tool Prop Removal", function()
	-- Used to update the client's data.
	net.Start( "ZoneTableUpdate" )
		net.WriteTable( ZoneManager.Zones )
	net.Broadcast()

	for _, zone in pairs( ZoneManager.Zones ) do
		local entities
		if ( zone.shape == SHAPE_BOX ) then
			entities = ents.FindInBox( zone.point1, zone.point2 )
		elseif ( zone.shape == SHAPE_SPHERE ) then
			entities = ents.FindInSphere( zone.point1, zone.point1:Distance( zone.point2 ) )
		end
		
		if ( zone.removeprops ) then
			for _, ent in pairs( entities ) do
				if ( ent:GetClass() == "prop_physics" ) then
					ent:Remove()
				end
			end
		end
	end
end )