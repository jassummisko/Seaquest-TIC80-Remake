do --table functions
	export add = table.insert
	export pop = table.remove
	export delObj = (tab, element) ->
		for i=#tab, 1, -1
			if tab[i] == element
				pop(tab, i)
	export removeObjs = (tab) ->
		for i=#tab, 1, -1
			if tab[i].alive == false
				pop(tab, i)
	export containsType = (tab, typ) ->
		for i=#tab, 1, -1
			if tab[i].type == typ
				return true
		return false
do --math functions
	export max = math.max
	export min = math.min
	export sin = math.sin
	export rad = math.rad
	export cos = math.cos
	export rnd = math.random
	export abs = math.abs
	export flr = math.floor
	export ceil = math.ceil
do -- utilities
	export spawn = (obj) ->
		add(objs, obj)

	export collide = (o1, o2) ->
		hit = false

		w1 = o1.hitbox[3]
		w2 = o2.hitbox[3]
		h1 = o1.hitbox[4]
		h2 = o2.hitbox[4]
		x1 = o1.hitbox[1]+o1.x
		x2 = o2.hitbox[1]+o2.x
		y1 = o1.hitbox[2]+o1.y
		y2 = o2.hitbox[2]+o2.y

		xs = w1/2 + w2/2
		ys = h1/2 + h2/2
		xd = abs( (x1 + w1/2) - (x2 + w2/2) )
		yd = abs( (y1 + h1/2) - (y2 + h2/2) )

		if xd<xs and yd<ys then
			hit = true

		return hit

	export updateAll = (tab) -> (unless element == nil then element\update!) for element in *tab
	export drawAll = (tab) -> (unless element == nil then element\draw!) for element in *tab
    
    export drawUI = ->
        spr(guiSpr.o2, 64, 4)
        rect(74, 6, 92, 4, 14)
        rect(74, 6, 92 * (plr.oxygen / plr.maxOxygen), 4, 1)