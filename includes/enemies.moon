class Enemy
	type: types.Enemy
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
		spr(@spr, @x, @y, 0, 1, @flip, 0)
	
	collision: =>
		for obj in *objs
			if obj.type == types.Torpedo
				if collide(obj, self)
					@die!
					obj\die!
	
	die: =>
		@alive = false

	edge: =>
		if @x < -16
			@alive = false
		if @x > scr.width+8
			@alive = false

class Fishie extends Enemy
	spr: 348
	hitbox: {0, 1, 8, 5}
	spd: 1
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