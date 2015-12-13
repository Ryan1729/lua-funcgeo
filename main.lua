G = require("funcgeo")

function love.load()

	R = G.makeRect(G.makeVector (0,0), G.makeVector(400,0), G.makeVector(0,400))
	sideRect = G.makeRect(G.makeVector (400,0), G.makeVector(400,0), G.makeVector(0,400))
	cornerRect = G.makeRect(G.makeVector (0,400), G.makeVector(200,0), G.makeVector(0,200))
	bottomRect = G.makeRect(G.makeVector (0,400), G.makeVector(800,0), G.makeVector(0,200))
	Trap = G.makePic(G.makeSegList(G.makeSegement ({.200,.50}, {.400,.50}),
								  G.makeSegement ({.400,.50}, {.500,.300}),  
								  G.makeSegement ({.500,.300}, {.100,.300}), 
								  G.makeSegement ({.100,.300}, {.200,.50})
								 )
								  
					)
	square = G.makePic(
						G.makeSegList(G.makeSegement ({0, 0}, {1,0}),
								  G.makeSegement ({1,0}, {1,1}),  
								  G.makeSegement ({1,1}, {0,1}), 
								  G.makeSegement ({0,1}, {0,0})
								 )
						)
	fishSeg = G.makeFishSegment()
	hypPart = G.rot45(G.flipH(G.rot90(G.rot90(fishSeg))))
	parts = G.beside(G.rot90(fishSeg), G.combine(fishSeg, hypPart, G.rot90(G.rot90(hypPart))))
	sq = G.makeSquareLimitPic (parts)
	
	fish = G.makeFishOutline (fishSeg)
	
	local p2 = G.flipH(G.rot45(fish))
	t = G.combine(fish, p2, G.rot90(G.rot90(G.rot90(p2))))
	
	bouncer = bouncerMaker(1/64, 0, 1)
	b2 = bouncerMaker(1/64,0,7)
end
local floor = math.floor
local modf = math.modf
function love.update(dt)
	
end

function love.draw()
	love.graphics.setLineStyle("smooth")
	love.graphics.setColor(0,0,255,255)
	fishSeg(R)
	sq(sideRect)
	t(cornerRect)
	
	love.graphics.setColor(255,0,0,128)
	love.graphics.setLineStyle("rough")
	parts(R)
	
	
	square(cornerRect)
	
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)

end

function love.keypressed(key)

end

function love.keyreleased(key)

end

function bouncerMaker(step, startOfInterval, endOfInterval)
	local startOfInterval = startOfInterval or 1
	local endOfInterval = endOfInterval or 10
	local step = step or 1
	local countUp = true
	local counter = startOfInterval
	return function ()
			if countUp then
				counter = counter + step
			else 
				counter = counter - step
			end
			if counter >= endOfInterval or counter <= startOfInterval then 
			countUp = not countUp
			end
			return counter
		end
end

