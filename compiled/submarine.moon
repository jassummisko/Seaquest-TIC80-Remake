--
-- Bundle file
-- Code changes will be overwritten
--

-- title:   Seaquest
-- author:  Mishko Bozhinoski
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  moon
-- [TQ-Bundler: includes.globals]

sec = 60
t = 0
scr = {
	width: 240
	height: 136
}
types = {
	Misc: -1
	Player: 0
	Torpedo: 1
	Enemy: 2
	Score: 3
}
bn = {
	up: 0
	down: 1
	left: 2
	right: 3
	z: 4
}
guiSpr = {
	o2: 48
}
lanes = {
	40,
	60,
	80,
	100
}
modes = {
	oxygenRefill: 0
	play: 1
}

gameMode = modes.oxygenRefill
particles = {}
objs = {}

-- [/TQ-Bundler: includes.globals]

-- [TQ-Bundler: includes.utils]

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

-- [/TQ-Bundler: includes.utils]

-- [TQ-Bundler: includes.particles]

class Particle
	new: (x, y, dir, speed, col, life) =>
		@x = x
		@y = y
		@dir = dir
		@speed = speed
		@col = @col or col or 12
		@life = @life or life or 60
		@alive = true

	update: =>
		@speed = @life/10
		@x += math.cos(math.rad(@dir)) * @speed
		@y += math.sin(math.rad(@dir)) * @speed
		@life -= 1
		if @life <= 0
			delObj(particles, self)

	draw: =>
		rect(@x, @y, 1, 1, @col)

export splash = (x, y, strength, speed, col) ->
	for i=1, strength
		add(particles, Particle(x, y, rnd(0, 360), speed, col, rnd(0, 30)))

class Bubble
	type: types.Misc
	new: (x, y, xvel) =>
		@x = x
		@y = y
		@xvel = xvel
		@sprs = {316, 318, 317}
		@animSpeed = 6
		@frame = 0
		@alive = true

	update: =>
		@animate!
		if @frame > #@sprs
			@alive = false

	animate: =>
		if t%@animSpeed == 0 
			@frame +=1
			@x += @xvel
	
	draw: =>
		spr(@sprs[@frame], @x, @y, 11)


-- [/TQ-Bundler: includes.particles]

-- [TQ-Bundler: includes.human]

class Human
    type: types.Score
    spr: 350
    hitbox: {0, 0, 16, 8}
    w: 2
    h: 1
    new: (x, y, flip) =>
        @x = x
        @y = y
        @flip = flip
        @alive = true

    update: =>
        @move!

    draw: =>
        spr(@spr, @x, @y, 0, 1, @flip, 0, @w, @h)

    move: =>
        @x -= 1 - @flip*2

    collect: =>
        @alive = false

-- [/TQ-Bundler: includes.human]

-- [TQ-Bundler: includes.player]

class Torpedo
	type: types.Torpedo
	new: (x, y, dir) =>
		@x = x
		@y = y
		@dir = dir
		@spd = 5
		@spr = 332
		@offset = 10
		@hitbox = {0, 2, 8, 5}
		@alive = true

	update: =>
		@x += @dir * @spd
		@y = plr.y+@offset
		if @x < -8 or @x > scr.width
			@die!

	draw: =>
		spr(@spr, @x, @y, 0)

	die: =>
		@alive = false

class Submarine
	type: types.Player
	new: =>
		@x = scr.width/2 - 16
		@y = 8
		@w = 4
		@h = 3
		@xvel = 0
		@yvel = 0
		@tick = 0
		@flip = 0
		@spd = 2
		@animSpeed = 3
		@hitbox = {1, 7, 28, 12}
		@sprs = {256, 260, 264, 268, 
				304, 308, 312, 308,
				304, 268, 264, 260}
		@frame = 1

		--Oxygen mechanic
		@oxygen = 1
		@maxOxygen = 33 *sec
		@refillSpeed = 12

		--Rescue mechanic
		@rescued = 0
		@maxRescued = 6

		@alive = true
 
	update: =>
		@tick+=1
		@control!
		@oxygenControl!
		@collision!
		@move!
		@animate!
			
	draw: =>
		spr(@sprs[@frame], @x, @y, 11, 1, @flip, 0, @w, @h)

	control: =>
		if gameMode == modes.play
			if btn bn.up
				@yvel = -@spd
			elseif btn bn.down
				@yvel = @spd
			else
				@yvel = 0

			if btn bn.left
				@xvel = -2
				@flip = 0
			elseif btn bn.right
				@xvel = 2
				@flip = 1
			else
				@xvel = 0

			if btn bn.z
				@attack!

	move: =>
		@y = min(max(@y+@yvel, 8), scr.height-8*@h)
		@x = min(max(@x+@xvel, 0), scr.width-8*@w)

	sound: =>
		if t%((@animSpeed*#@sprs/2)) == 0
			sfx(0)

	animate: =>
		if gameMode == modes.play
			if t%(@animSpeed) == 0
				@frame = ((@frame)%#@sprs)+1
			if t%((@animSpeed*#@sprs/2)) == 0
				@spawnBub!
			@sound!

	attack: =>
		unless containsType(objs, types.Torpedo)
			sfx(1, 10, 80, 1)
			if @flip == 1
				add(objs, Torpedo(@x+8*@w, @y+10, 1))
			elseif @flip == 0
				add(objs, Torpedo(@x-8, @y+10, -1))

	spawnBub: =>
		y = @y + rnd(2, 8*@h-8)
		if @flip == 1
			x = @x
			add(particles, Bubble(x-8, y, -6))
		elseif @flip == 0
			x = @x+8*@w
			add(particles, Bubble(x, y, 6))

	oxygenControl: =>
		
		if gameMode == modes.play
			if @y > 10
				@oxygen-=1
			if @maxOxygen - @oxygen > 50 and @y <= 10
				gameMode = modes.oxygenRefill

		elseif gameMode == modes.oxygenRefill
			unless @oxygen >= @maxOxygen
				@oxygen += @refillSpeed
				sfx(2, flr(@oxygen / 200), 2, 3)
			else
				gameMode = modes.play 

		if @oxygen <= 0
			@die!

	collision: =>
		for obj in *objs
			if collide(obj, self)
				if obj.type == types.Enemy
					@die!
					obj\die!

				if obj.type == types.Score and @rescued < @maxRescued
					obj\collect!
					@rescued += 1


	die: =>
		@alive = false
		splashX = @x+16
		splashY = @y+12
		splashStr = 10
		splashSpd = 4
		splash(splashX, splashY, splashStr+5, splashSpd, 15)
		splash(splashX, splashY, splashStr, splashSpd, 14)
		splash(splashX, splashY, splashStr-5, splashSpd, 13)

-- [/TQ-Bundler: includes.player]

-- [TQ-Bundler: includes.enemies]

class Enemy
	type: types.Enemy
	w: 1
	h: 1
	transparency: 0
	new: (x, y, flip) =>
		@x = x
		@y = y
		@flip = flip
		@tick = 0
		@alive = true

	update: =>
		if gameMode == modes.play
			@tick += 1
			@move!
			@collision!
			@edge!

	move: =>
		--add per enemy

	draw: =>
		spr(@spr, @x, @y, @transparency, 1, @flip, 0, @w, @h)
	
	collision: =>
		for obj in *objs
			if obj.type == types.Torpedo
				if collide(obj, self)
					@die!
					obj\die!
	
	die: =>
		@alive = false

	edge: =>
		if (@x < -24) and @flip == 0
			@alive = false
		if (@x > scr.width+16) and @flip == 1
			@alive = false

class Fishie extends Enemy
	spr: 348
	hitbox: {0, 2, 16, 6}
	spd: 1
	w: 2
	h: 1
	new: (...) =>
		super ...

		@ycenter = @y
		@bobRange = 8
		@bobFrame = 0
		@bobSpeed = 3

	move: =>
		@bob!
		if @flip == 0 then @x -= @spd else @x += @spd

	bob: =>
		@bobFrame += @bobSpeed
		@y = @ycenter + sin(rad(@bobFrame))*@bobRange

	die: =>
		super!
		splash(@x+4, @y+4, 10, 4, 7)

class SmallTorpedos extends Enemy
	spr: 333
	hitbox: {1, 1, 5, 5}
	spd: 2

	new: (...) =>
		super ...
	
	move: =>
		if @flip == 0 then @x -= @spd else @x += @spd

	die: =>
		super!
		splash(@x+4, @y+4, 10, 4, 2)

class PatrolSub extends Enemy
	sprs: {352, 354}
	spr: 352
	hitbox: {0, 6, 16, 6}
	w: 2
	h: 2
	spd: 1
	transparency: 11
	new: (...) =>
		super ...
		@cooldown = 0
		@animframe = 1
		@animspeed = 4
		
	update: =>
		super!
		if gameMode == modes.play
			@attack!
		@animate!

	animate: =>
		if @tick % @animspeed == 0
			@animframe = (@animframe % #@sprs)+1
		@spr = @sprs[@animframe]

	attack: =>
		@cooldown = max(@cooldown-1, 0)
		if @tick % 30 == 0
			if (rnd! > 0.5) and (@cooldown == 0)
				spawn(SmallTorpedos(@x+(@flip*6), @y+6, @flip))
				@cooldown = 120

	move: =>
		if @flip == 0 then @x -= @spd else @x += @spd

	draw: =>
		super!
		
	die: =>
		super!
		splash(@x+4, @y+4, 50, 4, 2)

class SurfacePatrol extends Enemy
	spr: 356
	hitbox: {1, 7, 14, 5}
	w: 2
	h: 2
	spd: 0.5
	transparency: 11
	new: (...) =>
		super ...

	update: =>
		@tick += 1
		@move!
		@collision!
		@edge!

	move: =>
		@x -= @spd

	die: =>
		super!
		splash(@x+8, @y+8, 100, 4, 2)

-- [/TQ-Bundler: includes.enemies]


export BOOT=->
	export plr = Submarine!
	spawn plr 
	spawn SurfacePatrol(scr.width+8, 8, 0)
	spawn Fishie(-16, 60, 1)
	spawn Fishie(scr.width+8, 80, 0)
	spawn PatrolSub(scr.width+8, 100, 0)
	spawn Human(40, 40, 0)

export TIC=->
	cls 0
	t += 1
	_UPDATE!
	_DRAW!

export _UPDATE=->

	removeObjs(objs)
	removeObjs(particles)

	updateAll(objs)
	updateAll(particles)

export _DRAW=->

	map!

	drawAll(particles)
	drawAll(objs)

	drawUI!