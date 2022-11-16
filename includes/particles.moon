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
