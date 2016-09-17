require ("platform")
require ("player")
require ("camera")

local map = {} -- stores tiledata
mapWidth, mapHeight = 0,0 -- width and height in tiles
 
local mapX, mapY -- view x,y in tiles. can be a fractional value like 3.25.
local prevMapX, prevMapY
local tilesDisplayWidth, tilesDisplayHeight -- number of tiles to show
local zoomX, zoomY
 
tileSize = 32 -- size of tiles in pixels
local tileQuads = {} -- parts of the tileset used for different tiles

local file
local image
objectBodies = {}

function load(fileName, imageName)

	--Set file names
	file = fileName
	image = imageName

	--initial graphics setup
	--love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
	--love.window.setMode(650, 650) --set the window dimensions to 650 by 650
	setupMap()
	setupMapView()
	setupTileset()
	love.graphics.setFont(love.graphics.newFont(12))
  
	--initial graphics setup
	love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
	--love.window.setMode(650, 650) --set the window dimensions to 650 by 650
	
	settings = {}
	--frameRate in fps
	settings.frameRate = 60
	settings.deltaTime = 1 / settings.frameRate
	settings.nextFrame = love.timer.getTime()

	love.physics.setMeter(64) --the height of a meter our worlds will be 64px
	world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

	objects = {} -- table to hold all our physical objects
	objects.platforms = {} --table to hold all platforms

	--Create Platforms
	addPhysicsObjects()
	--table.insert(objects.platforms, createPlatform(world, love.graphics.getWidth() / 2, love.graphics.getHeight() - 25, love.graphics.getWidth(), 50, 10, BASIC_PLATFORM))
	--table.insert(objects.platforms, createPlatform(world, 200, 550, 50, 75, 5, DISAPPEARING_PLATFORM))
	--table.insert(objects.platforms, createPlatform(world, 200, 400, 100, 50, 2, DISAPPEARING_PLATFORM))

	objects.player = Player.create(world, 325, 325, 20, 20)
	objects.ghost = Ghost.create({}, {}, {}, 20, 20, "ghost.png")
	
	love.update, love.draw = update, draw
  
  
end


function addPhysicsObjects()
	for x=1, #map do
		for y=1, #map[x] do
			if map[x][y] > 1 then
				if map[x][y] == 4 then
					local newPlat = createPlatform(world, (x-1)*(tileSize)+tileSize/2, (y-1)*(tileSize)+tileSize/2, tileSize, tileSize, 5, GOAL_PLATFORM)
					table.insert(objects.platforms, newPlat)
					objectBodies[newPlat.body] = newPlat
				else
					local newPlat = createPlatform(world, (x-1)*(tileSize)+tileSize/2, (y-1)*(tileSize)+tileSize/2, tileSize, tileSize, 5, BASIC_PLATFORM)
					table.insert(objects.platforms, newPlat)
					objectBodies[newPlat.body] = newPlat
				end
			end
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "p" then
		objects.player:endRecording()
		objects.ghost:setPlaybackData(objects.player.recordedPoints, objects.player.recordedVelocity, {})
		objects.ghost:beginPlayback()
	elseif key == "r" then
		objects.player:beginRecording()
	elseif key == "escape" then
		os.exit(0)
	end
end
 
function update(dt)
	--some data upkeep for keeping a constant frame rate
	settings.nextFrame = settings.nextFrame + settings.deltaTime
	
  local prevX = objects.player.body:getX()
	local prevCamX = camera.x
	--local prevY = objects.player.body:getY()

	world:update(dt) --this puts the world into motion
	objects.player:update(dt)
	objects.ghost:update(dt)
	local colliders = objects.player:getGroundedBodies()

	for i = 1, #objects.platforms do--#objects.platforms, 1, -1 do
		--objects.platforms[i].body:setX(objects.platforms[i].body:getX()+ (prevMapX - mapX) * tileSize)
		--objects.platforms[i].body:setY(objects.platforms[i].body:getY()+ (prevMapY - mapY) * tileSize)
		objects.platforms[i]:update(dt)
		--if we are colliding with the current platform, then activate it
		for j = 1, #colliders, 1 do
			if colliders[j] == objects.platforms[i].fixture then
				objects.platforms[i]:activate()
			end
		end
		if objects.platforms[i].toDelete then
			table.remove(objects.platforms, i)
		end
	end
	
	camera:setPosition(camera.x + objects.player.body:getX() - prevX, camera.y)
	--camera.y = camera.y + objects.player.body:getY() - prevY
	--moveMap((objects.player.body:getX() - prevX) / tileSize, 0)
	moveMap((camera.x - prevCamX) / tileSize, 0)
	
	prevMapX = mapX
	prevMapY = mapY
end
 
function draw()
	love.graphics.draw(tilesetBatch,
	math.floor(-zoomX*(mapX%1)*tileSize), math.floor(-zoomY*(mapY%1)*tileSize),
	0, zoomX, zoomY)
	love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
		camera:set()
	
	--love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
	local playerX, playerY, player
	
	love.graphics.polygon("fill", objects.player.body:getWorldPoints(objects.player.shape:getPoints()))
	
	if objects.ghost.doPlayback then
		objects.ghost:draw()
	end
	
	--pulled from https://love2d.org/wiki/love.timer.sleep
	-- the idea is if not enough time has passed for the next frame, then sleep until we're ready for it
	local curTime = love.timer.getTime()
	if settings.nextFrame <= curTime then
		settings.nextFrame = curTime
	else
		love.timer.sleep(settings.nextFrame - curTime)
	end
	updateTilesetBatch()
	camera:unset()
end





--Tile Stuff
function setupMap()
	local count = 1
	for line in love.filesystem.lines(file) do
		local tempParse = string.explode(line, ",")
		--map[count] = {}
		for i=1, #tempParse do
			if map[i] == nil then
				map[i] = {}
			end
			map[i][count] = tonumber(tempParse[i])
		end
		count = count + 1
	end
	
	--mapWidth = math.floor(love.graphics.getWidth() / tileSize) * 10
	--mapHeight = math.floor(love.graphics.getHeight() / tileSize) * 10
	mapWidth = #map
	mapHeight = #map[1]
end

function string.explode(str, div)
	assert(type(str) == "string" and type(div) == "string", "invalid arguments")
	local o = {}
	while true do
		local pos1,pos2 = str:find(div)
		if not pos1 then
			o[#o+1] = str
			break
		end
		o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
	end
	return o
end
 
function setupMapView()
	mapX = 1
	mapY = 1
	prevMapX = 1
	prevMapY = 1
	tilesDisplayWidth = math.floor(love.graphics.getWidth() / tileSize) + 2
	tilesDisplayHeight = math.floor(love.graphics.getHeight() / tileSize) + 2

	zoomX = 1
	zoomY = 1
end
 
function setupTileset()
	local tilesetImage = love.graphics.newImage(image)
	tilesetImage:setFilter("nearest", "linear") -- this "linear filter" removes some artifacts if we were to scale the tiles
	--tileSize = 32

	local tilesWide = tilesetImage:getWidth() / tileSize
	local tilesHigh = tilesetImage:getHeight() / tileSize

	for x=0, tilesWide - 1 do
		for y=0, tilesHigh - 1 do
			tileQuads[(x*tilesHigh)+y ] = love.graphics.newQuad( x * tileSize, y * tileSize, tileSize, tileSize,
				tilesetImage:getWidth(), tilesetImage:getHeight())
		end
	end
	tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, tilesDisplayWidth * tilesDisplayHeight)

	updateTilesetBatch()
end
 
function updateTilesetBatch()
	tilesetBatch:clear()
	for x=1, tilesDisplayWidth do
		for y=1, tilesDisplayHeight do
			local test = map[x+math.floor(mapX) - 1][y+math.floor(mapY) - 1]
			local test2 = tileQuads[test]
			tilesetBatch:add(test2, (x-1)*tileSize, (y-1)*tileSize)
		end
	end
	tilesetBatch:flush()
end
 
-- central function for moving the map
function moveMap(dx, dy)
	local oldMapX = mapX
	local oldMapY = mapY
	mapX = math.max(math.min(mapX + dx, mapWidth - tilesDisplayWidth), 1)
	mapY = math.max(math.min(mapY + dy, mapHeight - tilesDisplayHeight), 1)
	-- only update if we actually moved
	if math.floor(mapX) ~= math.floor(oldMapX) or math.floor(mapY) ~= math.floor(oldMapY) then
		updateTilesetBatch()
	end
end