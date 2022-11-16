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
		if @x < -24
			@alive = false
		if @x > scr.width+16
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