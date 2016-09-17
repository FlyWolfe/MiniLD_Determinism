require ("platform")
require ("player")

local map = {} -- stores tiledata
local mapWidth, mapHeight -- width and height in tiles
 
local mapX, mapY -- view x,y in tiles. can be a fractional value like 3.25.
local prevMapX, prevMapY
local tilesDisplayWidth, tilesDisplayHeight -- number of tiles to show
local zoomX, zoomY
 
local tileSize = 32 -- size of tiles in pixels
local tileQuads = {} -- parts of the tileset used for different tiles


--Ghost Stuff
ghostX = {}
ghostY = {}
ghostVelX = {}
ghostVelY = {}

testCount = 0

function love.load()
	--initial graphics setup
	love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
	love.window.setMode(650, 650) --set the window dimensions to 650 by 650
	
	settings = {}
	--frameRate in fps
	settings.frameRate = 60
	settings.deltaTime = 1 / settings.frameRate
	settings.nextFrame = love.timer.getTime()
	
	require ("playLevel")
	load("gameMap.tilemap", "Tileset.png")
end

 
function love.update(dt)
	--some data upkeep for keeping a constant frame rate
	settings.nextFrame = settings.nextFrame + settings.deltaTime
end
 
function love.draw()
	love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
	--pulled from https://love2d.org/wiki/love.timer.sleep
	-- the idea is if not enough time has passed for the next frame, then sleep until we're ready for it
	local curTime = love.timer.getTime()
	if settings.nextFrame <= curTime then
		settings.nextFrame = curTime
	else
		love.timer.sleep(settings.nextFrame - curTime)
	end
end