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
    if ( !file.IsDir( "zones", "DATA" ) ) then
        file.CreateDir( "zones" )

        print( "Creating a zones folder.." )
    end

    if ( !file.Exists( path, "DATA" ) ) then
        file.Write( path, "{}" )

        print( "Creating zone data file.." )
    end

    local data = util.JSONToTable( file.Read( path, "DATA" ) or "" )

    if ( data ) then
        ZoneManager.Zones = {}

        for k, v in pairs( data ) do
            if ( v.id ~= nil ) then
                ZoneManager.Zones[ v.id ] = {
                    id = v.id or "Zone",
                    point1 = v.point1 or Vector( 0, 0, 0 ),
                    point2 = v.point2 or Vector( 0, 0, 0 ),
					wireframe = tobool( data.wireframe ) or false,
                    player = tobool( v.player ) or false,
                    admin = tobool( v.admin ) or false,
                    npc = tobool( v.npc ) or false,
                    ent = tobool( v.ent ) or false,
                    removeprops = tobool( v.removeprops ) or false,
					tick = tonumber( data.tick ) or 1,
					amount = tonumber( data.amount ) or 1,
					limit = tonumber( data.limit ) or 0,
					type = tonumber( data.type ) or TYPE_DAMAGE,
					shape = tonumber( data.shape ) or SHAPE_BOX,
                    r = tonumber( v.r ) or 255,
                    g = tonumber( v.g ) or 255,
                    b = tonumber( v.b ) or 255,
                    a = tonumber( v.a ) or 255
                }
				
				local type = tonumber( data.type ) or TYPE_DAMAGE
				if ( type == TYPE_DAMAGE || type == TYPE_HEAL ) then
					timer.Create( "ZoneTimer_" .. v.id, tonumber( data.tick ) or 1, 0, function()
						hook.Call( "ZoneTick", nil, v.id )
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

function ZoneManager.SaveZones( ply )
    if ( !ply:IsSuperAdmin() ) then return ply:ChatPrint( "You do not have permission to use this command!" ) end
    if ( table.Count( ZoneManager.Zones ) <= 0 ) then return print( "There are no zones to save." ) end

	file.Write( path, util.TableToJSON( ZoneManager.Zones ) )

    if ( table.Count( ZoneManager.Zones ) > 1 ) then
        print( "Successfully saved " .. table.Count( ZoneManager.Zones ) .. " zones!" )
    else
        print( "Successfully saved " .. table.Count( ZoneManager.Zones ) .. " zone!" )
    end
end
concommand.Add("zone_save", ZoneManager.SaveZones)

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
        npc = tobool( data.npc ) or false,
        ent = tobool( data.ent ) or false,
        removeprops = tobool( data.removeprops ) or false,
		tick = tonumber( data.tick ) or 1,
		amount = tonumber( data.amount ) or 1,
		limit = tonumber( data.limit ) or 0,
		type = tonumber( data.type ) or TYPE_DAMAGE,
		shape = tonumber( data.shape ) or TYPE_HEAL,
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
    if ( !ply:IsSuperAdmin() ) then print( "You do not have permission to use this command!" ) return end
    if ( table.Count( ZoneManager.Zones ) <= 0 ) then print( "There are no zones." ) return end

    PrintTable( ZoneManager.Zones )
end )

--
-- Zone removal
--

concommand.Add( "zone_remove", function( ply, cmd, args )
    if ( !ply:IsSuperAdmin() ) then print( "You do not have permission to use this command!" ) return end

    if ( isstring( args[ 1 ] ) ) && ( ZoneManager.Zones[ args[ 1 ] ] ~= nil ) then
		local zone = ZoneManager.Zones[ args[ 1 ] ]
		ZoneManager.Zones[ args[ 1 ] ] = nil
		
		if ( zone.type == TYPE_DAMAGE || zone.type == TYPE_HEAL ) then
			timer.Remove( "ZoneTimer_" .. args[ 1 ] )
		end
		
		if ( args[ 2 ] == nil ) then
			undo.Create( "ZoneRemove" )
				undo.AddFunction( function( tab, zone )
					ZoneManager.CreateZone( zone.id, {
						id = zone.id,
						point1 = zone.point1,
						point2 = zone.point2,
						wireframe = zone.wireframe,
						player = zone.player,
						admin = zone.admin,
						npc = zone.npc,
						ent = zone.ent,
						removeprops = zone.removeprops,
						tick = zone.tick,
						amount = zone.amount,
						limit = zone.limit,
						type = zone.type,
						shape = zone.shape,
						r = zone.r,
						g = zone.g,
						b = zone.b,
						a = zone.a
					} )
				end, zone )
				undo.SetPlayer( ply )
			undo.Finish()
		end
        print( "Successfully removed the zone with an identifier of: " .. args[ 1 ] )
    else
        print( "That isn't a valid zone identifier." )
    end 
end )

--
-- Safezone protection
--

hook.Add( "EntityTakeDamage", "ProWolf's Zone Tool Entity Take Damage", function( ent, info )
    for k, v in pairs( ZoneManager.Zones ) do
		if ( v.type == TYPE_SAFE ) then
			local zone
			if ( v.shape == SHAPE_BOX ) then
				zone = ents.FindInBox( v.point1, v.point2 )
			elseif ( v.shape == SHAPE_SPHERE ) then
				zone = ents.FindInSphere( v.point1, v.point1:Distance(v.point2) )
			end
			if ( table.HasValue( zone, ent ) ) &&
			(( v.player && ent:IsPlayer() && not ent:IsAdmin() ) ||
			( v.admin && ent:IsPlayer() && ent:IsAdmin() ) ||
			( v.npc && ent:IsNPC() ) ||
			( v.ent && not ent:IsPlayer() && not ent:IsNPC() ) ) then
				info:SetDamage(0)
			end
		end
    end
end )

--
-- Zone update
--

hook.Add( "ZoneTick", "ProWolf's Zone Tool Zone Tick", function( id )
	if ZoneManager.Zones[ id ] ~= nil then
		v = ZoneManager.Zones[ id ]
        local zone
		if ( v.shape == SHAPE_BOX ) then
			zone = ents.FindInBox( v.point1, v.point2 )
		elseif ( v.shape == SHAPE_SPHERE ) then
			zone = ents.FindInSphere( v.point1, v.point1:Distance(v.point2) )
		end
		for k, ent in pairs(zone) do
			if ( v.player && ent:IsPlayer() && not ent:IsAdmin() ) ||
			( v.admin && ent:IsPlayer() && ent:IsAdmin() ) ||
			( v.npc && ent:IsNPC() ) ||
			( v.ent && not ent:IsPlayer() && not ent:IsNPC() ) then
				if ( v.type == TYPE_DAMAGE ) then
					if ( v.limit == 0 ) then
						ent:TakeDamage( v.amount, nil, nil )
					else
						ent:TakeDamage( math.Clamp( ent:Health() - v.limit, 0, v.amount ), nil, nil )
					end
				elseif ( v.type == TYPE_HEAL ) then
					if ( v.limit == 0 ) then
						ent:SetHealth( ent:Health() + v.amount )
					elseif ( ent:Health() < v.limit ) then
						ent:SetHealth( math.min( ent:Health() + v.amount, v.limit ) )
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

    for k, v in pairs( ZoneManager.Zones ) do
        local zone
		if ( v.shape == SHAPE_BOX ) then
			zone = ents.FindInBox( v.point1, v.point2 )
		elseif ( v.shape == SHAPE_SPHERE ) then
			zone = ents.FindInSphere( v.point1, v.point1:Distance(v.point2) )
		end
		
        if ( v.removeprops ) then
            for k, x in pairs( zone ) do
                if ( x:GetClass() == "prop_physics" ) then
                    x:Remove()
                end
            end
        end
    end
end )