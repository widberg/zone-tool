local Zones = Zones or {}

net.Receive( "ZoneTableUpdate", function()
    Zones = net.ReadTable()
end )

hook.Add( "PostDrawTranslucentRenderables", "ProWolf's Zone Tool Draw Zones", function()
    for k, v in pairs( Zones ) do
        if ( v == nil ) then return end

        local col = Color( v.r, v.g, v.b, v.a )
        
		render.SetColorMaterial()
		
		if ( v.shape == 1) then
			if ( v.filled ) then
				render.DrawBox( Vector( 0, 0, 0), Angle( 0, 0, 0 ), v.point2, v.point1, col, true )
				render.DrawBox( Vector( 0, 0, 0), Angle( 0, 0, 0 ), v.point1, v.point2, col, true )
			else
				render.DrawWireframeBox( Vector( 0, 0, 0), Angle( 0, 0, 0 ), v.point2, v.point1, col, true )
			end
		elseif ( v.shape == 2) then
			if ( v.filled ) then
				render.DrawSphere( v.point1, v.point1:Distance(v.point2), 50, 50, col, true )
				render.DrawSphere( v.point1, -v.point1:Distance(v.point2), 50, 50, col, true )
			else
				render.DrawWireframeSphere( v.point1, v.point1:Distance(v.point2), 50, 50, col, true ) 
			end
		end
    end
end )