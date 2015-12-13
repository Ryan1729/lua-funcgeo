G = require("funcgeo")

function love.load()

	R = G.makeRect(G.makeVector (10,10), G.makeVector(500,0), G.makeVector(0,500))
	sideRect = G.makeRect(G.makeVector (510,10), G.makeVector(50,0), G.makeVector(0,50))
	Trap = G.makePic(G.makeSegList(G.makeSegement ({.200,.50}, {.400,.50}),
								  G.makeSegement ({.400,.50}, {.500,.300}),  
								  G.makeSegement ({.500,.300}, {.100,.300}), 
								  G.makeSegement ({.100,.300}, {.200,.50})
								 )
								  
					)
	--[[Pic = 	G.makePic(G.makeSegList(G.makeSegement ({0,.5}, {.5,0}),
									G.makeSegement ({.5,0}, {1,0}),  
									G.makeSegement ({1,0}, {.5,.5}), 
									G.makeSegement ({1,0}, {1,.5}), 
								    G.makeSegement ({0,.5}, {.5,.5}),  
									G.makeSegement ({0,.5}, {0,1}), 
									G.makeSegement ({0,1}, {.5,1}), 
									G.makeSegement ({.5,1}, {1,.5}), 
									G.makeSegement ({.5,.5}, {.5,1})
								 )
								  
					)			
			]]--
	square = G.makePic(
						G.makeSegList(G.makeSegement ({0, 0}, {1,0}),
								  G.makeSegement ({1,0}, {1,1}),  
								  G.makeSegement ({1,1}, {0,1}), 
								  G.makeSegement ({0,1}, {0,0})
								 )
						)
	cube = G.makeCubePic()
	Pic = G.fourPics(cube,G.rot90(cube),G.rot90(G.rot90(G.rot90(cube))),G.rot90(G.rot90(cube)))
	rotCube = G.rot90(cube)
	Pic2 = G.fourPics(cube,G.rot90(cube),G.rot90(G.rot90(G.rot90(cube))),G.rot90(G.rot90(cube)))
	Pic3 = G.beside(cube,rotCube,0.5)
	Pic4 = G.fourPics(cube,cube,cube,cube)
	love.graphics.setColor(0,0,255,255)
	
	counter = 0
	countUp = true
	bouncer = bouncerMaker(1/64, 0, 1)
	b2 = bouncerMaker(1/64,0,7)
end
local floor = math.floor
local modf = math.modf
function love.update(dt)
	
	Pic = G.makeCubePic(bouncer())
	Pic = G.fourPics(Pic,G.rot90(Pic),G.rot90(G.rot90(G.rot90(Pic))),G.rot90(G.rot90(Pic)))
	local i = b2() - 1
	if not (i <= 0) then

		Pic = G.fourPics(G.leftPush(Pic, modf(i)), G.upPush(Pic, modf(i)), G.downPush(Pic, modf(i)),G.rightPush(Pic, modf(i)))
		--for j = 0, floor(i/2) do
			Pic = G.fourPics(Pic,Pic,Pic,Pic)
		--end
	end

end

function love.draw()
	--[[
	cube(sideRect)
	cube(R)
	local r,g,b,a = love.graphics.getColor( )
	love.graphics.setColor(255,0,0,255)
	local newcube = G.rot90(cube)
	newcube(sideRect)
	newcube(R)
	love.graphics.setColor(r,g,b,a)
	]]--
	--rotPic(R)
	--Pic2(R)
	
	--Pic2 =G.fourPics(Pic,Pic,Pic,Pic)
	
	--Pic(sideRect)
	Pic(R)
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)

end

function love.keypressed(key)
	if  key == " " then
		counter = b2()
	end
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