include( "autorun/sh_zones.lua" )

local Zones = Zones or {}

net.Receive( "ZoneTableUpdate", function()
	Zones = net.ReadTable()
end )

local zone_material = Material("zt/zone")

hook.Add( "PostDrawTranslucentRenderables", "ProWolf's Zone Tool Draw Zones", function()
	for k, v in pairs( Zones ) do
		if ( v == nil ) then return end

		local col = Color( v.r, v.g, v.b, v.a )
		
		render.SetMaterial(zone_material)
		
		if ( v.shape == SHAPE_BOX) then
			if ( v.wireframe ) then
				render.DrawWireframeBox( Vector( 0, 0, 0), Angle( 0, 0, 0 ), v.point1, v.point2, col, true )
			else
				render.DrawBox( Vector( 0, 0, 0), Angle( 0, 0, 0 ), v.point2, v.point1, col, true )
			end
		elseif ( v.shape == SHAPE_SPHERE) then
			local radius = v.point1:Distance(v.point2)
			local detail = math.Clamp(radius/10, 15, 50)
			if ( v.wireframe ) then
				render.DrawWireframeSphere( v.point1, radius, detail, detail, col, true )
			else
				render.DrawSphere( v.point1, radius, detail, detail, col, true )
			end
		end
	end
end )