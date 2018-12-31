A tool which allows you to easily create zones that affect health.

This addon is a heavily modified version of [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1547155435]Ced's Safezones[/url]. All credit for base code goes to Ced.

[b]Features:[/b]

* Easy to use
* 4 Zone types: Damage, Heal, Safe, and Useless
* 2 Zone shapes: Box and Sphere
* 4 Groups: Players, Admins, NPCs, and Entities
* Customizable appearance: color, transparency, and wireframe/filled rendering
* User defined tick interval, amount to affect health, health limit, groups to affect, and optionaly clear the zone of props
* Undo functionality
* Saving of zones
* Optimized for Garry's Mod 13

[b]Zone Types:[/b]

* [b]Damage[/b] - Damages the selected groups by the set amount once per the set tick interval. The entity will stop being damaged once its health is less than or equal to "Min Health".
* [b]Heal[/b] - Heals the selected groups by the set amount once per the set tick interval. The entity will stop being healed once its health is greater than or equal to "Max Health".
* [b]Safe[/b] - Protects the selected groups from damage.
* [b]Useless[/b] - Will be rendered and remove props if selected, but does not affect health.

[b]Zone Shapes:[/b]

* [b]Box[/b] - A rectangular prism defined by 2 opposite vertices
* [b]Sphere[/b] - A sphere defined by its center and a point on the surface

[b]Groups:[/b]

* [b]Players[/b] - Players that are not admins
* [b]Admins[/b] - Players that are admins
* [b]NPCs[/b] - NPCs
* [b]Entities[/b] - Entities that are not players or NPCs

[b]Commands:[/b]

* [b]zone_list[/b] - Shows a list of all the zones.
* [b]zone_remove[/b] - Removes a given zone by its identifier.
* [b]zone_save[/b] - Saves all the current zones.

I am open to feature requests. If you find any bugs please report them in the comments below.