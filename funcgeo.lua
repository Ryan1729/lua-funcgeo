-- Functional Geomerty Lua/LÖVE module
-- 
-- This implements the algebra of pictures described in the paper Functional Geometry by Peter Henderson
-- see here: http://eprints.soton.ac.uk/257577/1/funcgeo2.pdf
--
-- This MIT Open courseware video was also referenced during implementation.
-- http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-001-structure-and-interpretation-of-computer-programs-spring-2005/video-lectures/3a-henderson-escher-example/
--
-- As is, this is set up for use with LÖVE, but you can replace love.graphics.line
-- with the relevant function immediately below

local drawLine = love.graphics.line
local unpack = unpack

--for debugging
local print = print -- the new env will prevent you from seeing global variables

-- This next part is just so I don't have to type FG.foo internally
-- Found here: http://lua-users.org/wiki/ModulesTutorial
local FG = {}
if setfenv then
	setfenv(1, FG) -- for 5.1
else
	_ENV = FG -- for 5.2
end

-- Here's the interesting part


function draw (v1,v2)
	drawLine(v1[1],v1[2],v2[1],v2[2])
end

function makeVector (x,y)
	return {x,y}
end

function  addVectors(v1, v2)
	return {v1[1] + v2[1], v1[2] + v2[2]}
end

function scaleVector(k, v)
	return {k * v[1], k * v[2]}
end

function makeSegement (v1, v2)
	return {v1,v2}
end

function segStart(v)
	return v[1]
end

function segEnd(v)
	return v[2]
end

function makeRect (origin, horiz, vert)
	return {origin, horiz, vert}
end

function origin(rect)
	return rect[1]
end

function horiz(rect)
	return rect[2]
end

function vert(rect)
	return rect[3]
end

function makeSegList(...)
	return {...}
end

-- Takes a rectangle and returns a function 
-- for scaling points from the unit square onto the rectangle  
function coordMap(rect)
	return function (point) 
		--the problem is probably something called from here
			return addVectors( 
							addVectors( 
										scaleVector( point[1], horiz(rect)),
										scaleVector( point[2], vert(rect))
										),
							origin(rect)
							)
			end
end

-- Apply a function to each element of a table, in place
function forEach (funct,t)
	for i=1, #t do
		local r = funct(t[i]) 
		if(r) then
			t[i] = r
		end
	end
end


-- take a list of segments and returns a function 
-- which draws them onto any given rectangle
function makePic(segmentList)
	segmentList = segmentList or {}
	return  function (rect)
				local map = coordMap(rect)
				forEach (function (segment)
							draw(
									map(segStart(segment)),
									map(segEnd(segment))
								  )
							end,
							segmentList
						  )
			end
end

-- Just to give you a picture to play with, this function returns a 
-- function which draws a picture of a cube onto a given rectangle
-- the sidelength parameter is optional
function makeCubePic(sidelength)
	sidelength = sidelength or .625
	return makePic(makeSegList(makeSegement ({0,1 - sidelength}, {1 - sidelength,0}),
									makeSegement ({1 - sidelength,0}, {1,0}),  
									makeSegement ({1,0}, {sidelength,1 - sidelength}), 
									makeSegement ({1,0}, {1,sidelength}), 
								    makeSegement ({0,1 - sidelength}, {sidelength,1 - sidelength}),  
									makeSegement ({0,1 - sidelength}, {0,1}), 
									makeSegement ({0,1}, {sidelength,1}), 
									makeSegement ({sidelength,1}, {1,sidelength}), 
									makeSegement ({sidelength,1 - sidelength}, { sidelength,1})
								 )
					)
end

-- p1 left of p2
function beside(p1,p2,scale)
	local scale = scale or 0.5
	return function (rect)
				local midVector = scaleVector(scale,horiz(rect))
				p1(makeRect(origin(rect),midVector,vert(rect)))
				p2(makeRect(addVectors(origin(rect), midVector),scaleVector(1-scale,horiz(rect)),vert(rect)))
			end
end

-- p1 above p2
function above(p1,p2,scale)
	local scale = scale or 0.5
	return function (rect)
				local midVector = scaleVector(scale,vert(rect))
				p1(makeRect(origin(rect),horiz(rect),midVector))
				p2(makeRect(addVectors(origin(rect), midVector),horiz(rect),scaleVector(1-scale,vert(rect))))
			end
end

-- This returns a pic rotated 90 degrees ccw
function rot90(p)
	return function (rect)
				p(makeRect(
							addVectors(
									origin(rect),
									vert(rect)
									  ),
							scaleVector(-1,vert(rect)),
							horiz(rect)
							)
				)
			end
end

function flipH (p)
	return function (rect)
			p(makeRect(
						addVectors(
									horiz(rect),
									origin(rect)
								  ),
						scaleVector(-1,horiz(rect)),
						vert(rect)
						)
			)
			end
end

function flipV (p)
	return function (rect)
			p(makeRect(
						addVectors(
									vert(rect),
									origin(rect)
								  ),
						horiz(rect),
						scaleVector(-1,vert(rect))
						)
			)
			end
end

function fourPics (p1,p2,p3,p4)
	return  
				above( 
						beside(p1,p2,0.5),
						beside(p3,p4,0.5),
						0.5
					  )
			
end

function cycle (p)
	return fourPics(p,rot90(rot90(rot90(p))),rot90(p),rot90(rot90(p)))
end

function ninePics (p1,p2,p3,
				   p4,p5,p6,
				   p7,p8,p9)
	local third = 1/3
	return  
				above( 
						beside(p1,beside(p2,p3),third),
						above(
								beside(p4,beside(p5,p6),third),
								beside(p7,beside(p8,p9),third)
							),
						third
					  )
			
end

-- nSquaredPics is left as an exercise to the reader

-- as is cycleN where cycle above would be cycleN(2,p)

function rightPush (p, iterations, scale)
	local iterations = iterations or 2
	local scale = scale or 0.5
	if iterations <= 0 then
		return p
	else
		return beside(p, 
					  rightPush (p, iterations - 1, scale),
					  scale
					  )
	end
end

function leftPush (p, iterations, scale)
	local iterations = iterations or 2
	local scale = scale or 0.5
	if iterations <= 0 then
		return p
	else
		return beside(leftPush (p, iterations - 1, scale),
					  p, 
					  scale
					  )
	end
end

function upPush (p, iterations, scale)
	local scale = scale or 0.5
	if iterations <= 0 then
		return p
	else
		return above(upPush (p, iterations - 1, scale), 
					  p,
					  scale
					  )
	end
end

function downPush (p, iterations, scale)
	local iterations = iterations or 2
	local scale = scale or 0.5
	if iterations <= 0 then
		return p
	else
		return above(p, 
					  downPush (p, iterations - 1, scale),
					  scale
					  )
	end
end

function rightUpPush (p, iterations, scale)
	local iterations = iterations or 2
	local scale = scale or 0.5
	if iterations <= 0 then
		return p
	else
		return rightPush(upPush (p, iterations - 1, scale), 
					  iterations - 1,
					  scale
					  )
	end
end



-- Returns a function that applys a given function n times.
function repeated (funct, n)
	local n = n or 1
	return function (...) 
				for i = 1,n do
					funct(...)
				end
			end
end

-- Takes a function and parameters for the function and returns 
-- a function which calls the function with the first two parameters swapped
-- and returns the result
function swapFirstTwoParams (func) 
	return function (...)
		local a = {...} 
		a[1],a[2] = a[2],a[1] 
		return func(unpack(a)) 
	end
end

-- Takes a function that takes two pictures (and optionally a scale parameter)
-- and returns a function which takes a picture, a number of iterations (and again, an optional scale parameter)
-- which then returns a picture with the originally passed function applied to it  the number of iterations times.
function push (comb)
	return function (p, iterations, scale)
				local iterations = iterations or 2
				local scale = scale or 0.5
				if iterations <= 0 then
					return p
				else
				return comb(p, 
							push(comb)(p, iterations - 1, scale),
							scale
							)
				end
			end
	
end

-- Takes a number of functions and returns a function which applies
-- any parameters to all of the passed functions and 
-- returns the results separately, in the order the functions were passed in
function combine (...)
	local a = {...}
	return function (...)
				local t = {}
				for i=1, #a do
					t[i] = a[i](...)
				end
				return(unpack(t))
			end
end

-- This function takes a picture and returns a picture tiled to resemble
-- M.C Esher's Square Limit, as described in Henderson's 1982 paper.
function makeOldSquareLimitPic(p)

	local t = fourPics(p,p,p,p)
	local u = cycle(rot90(p))

	local empty = makePic()
	local side1 = fourPics(empty,empty,rot90(t),t)
	local side2 = fourPics(side1,side1,rot90(t),t)
	local corner1 = fourPics(empty,empty,empty,u)
	local corner2 = fourPics(corner1,side1,rot90(side1),u)
	local corner = ninePics(corner2,side2,side2,
						rot90(side2),u,rot90(cycle(p)),
						rot90(side2),rot90(cycle(p)),rot90(p))
	return cycle(corner)

end

-- rotates a picture 45 degrees and shrinks it such that two opposite 
-- corners of the picture are on two adjacent corners of the given rectangle
-- Applying this twice is NOT the same as applying rot90 any number of times.
function rot45(p)
	return function (rect)
			local aveVector = scaleVector(0.5, addVectors(horiz(rect),vert(rect)))
			p(makeRect(
						addVectors(
								origin(rect),
								aveVector	
								  ),
						aveVector,
						scaleVector(0.5, addVectors(scaleVector(-1,horiz(rect)),vert(rect)))
						)
			)
		end
end

function sideN (p, n)
	n = n or 2
	if n <= 0 then return function () end
	else
	local side = sideN (p, n - 1)
	return fourPics(side,side,rot90(p),p)
	end
end

function cornerN (p, n)
	n = n or 2
	if n <= 0 then return function () end
	else
	local side = sideN (p, n - 1)
	return fourPics(cornerN(p, n - 1),side,rot90(side),p)
	end
end

-- This function takes a picture and returns a picture tiled to resemble
-- M.C Esher's Square Limit, as described in Henderson's 2002 paper.
function makeSquareLimitPic (p, n)
	n = n or 2
	local p2 = flipH(rot45(p))
	local t = combine(p, p2, rot90(rot90(rot90(p2))))
	local u = combine(p2, rot90(p2), rot90(rot90(p2)), rot90(rot90(rot90(p2))))
	local side = sideN(t,n)
	local corner = cornerN(u,n)
	return ninePics(corner,side, rot90(rot90(rot90(corner))),
					rot90(side),u, rot90(rot90(rot90(side))),
					rot90(corner),rot90(rot90(side)),rot90(rot90(corner)))

end

-- Returns picture of an approximation of a segment of the outline of the fish in
-- M.C Esher's Square Limit, as described in Henderson's 2002 paper.
function makeFishSegment ()
	return makePic(makeSegList(makeSegement ({0,1}, {.2,.75}),
									makeSegement ({.2,.75}, {.6,.99}),  
									makeSegement ({.6,.99}, {.8,.95}), 
									makeSegement ({.8,.95}, {1,1})
								 )
					)
end

-- given the fish segment from above, this function returns a picture of the fish's outline,
-- essentially drawing a right triangle with 4 copies of the picture given 
function makeFishOutline (p)
	local hypPart = rot45(flipH(rot90(rot90(p))))
	return beside(rot90(p), combine(p, hypPart, rot90(rot90(hypPart))))
end


return FG

-- This module was created in 2014 by Ryan Wiedemann
