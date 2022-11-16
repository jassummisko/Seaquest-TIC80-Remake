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