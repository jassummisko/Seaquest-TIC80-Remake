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