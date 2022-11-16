-- title:   Seaquest
-- author:  Mishko Bozhinoski
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  moon
include "includes.globals"
include "includes.utils"
include "includes.particles"
include "includes.player"
include "includes.enemies"

export BOOT=->
	export plr = Submarine!
	spawn(plr)
	spawn(Fishie(-8, 60, 1))
	spawn(Fishie(scr.width, 90, 0))

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