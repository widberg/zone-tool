include( "autorun/sh_zones.lua" )

local Zones = Zones or {}

net.Receive( "ZoneTableUpdate", function()
	Zones = net.ReadTable()
end )

local zone_material = Material( "zt/zone" )

hook.Add( "PostDrawTranslucentRenderables", "ProWolf's Zone Tool Draw Zones", function()
	for _, zone in pairs( Zones ) do
		if ( zone == nil ) then return end

		local col = Color( zone.r, zone.g, zone.b, zone.a )
		
		render.SetMaterial(zone_material)
		
		if ( zone.shape == SHAPE_BOX ) then
			if ( zone.wireframe ) then
				render.DrawWireframeBox( Vector( 0, 0, 0 ), Angle( 0, 0, 0 ), zone.point1, zone.point2, col, true )
			else
				render.DrawBox( Vector( 0, 0, 0 ), Angle( 0, 0, 0 ), zone.point2, zone.point1, col, true )
			end
		elseif ( zone.shape == SHAPE_SPHERE) then
			local radius = zone.point1:Distance( zone.point2 )
			local detail = math.Clamp( radius/10, 15, 50 )
			if ( zone.wireframe ) then
				render.DrawWireframeSphere( zone.point1, radius, detail, detail, col, true )
			else
				render.DrawSphere( zone.point1, radius, detail, detail, col, true )
			end
		end
	end
end )