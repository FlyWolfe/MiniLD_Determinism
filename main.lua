require ("platform")
require ("player")

local map = {} -- stores tiledata
local mapWidth, mapHeight -- width and height in tiles
 
local mapX, mapY -- view x,y in tiles. can be a fractional value like 3.25.
local tilesDisplayWidth, tilesDisplayHeight -- number of tiles to show
local zoomX, zoomY
 
local tileSize = 32 -- size of tiles in pixels
local tileQuads = {} -- parts of the tileset used for different tiles

function love.load()
  --initial graphics setup
  --love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
  love.window.setMode(650, 650) --set the window dimensions to 650 by 650
  
  
  setupMap()
  setupMapView()
  setupTileset()
  love.graphics.setFont(love.graphics.newFont(12))
  
  
  love.physics.setMeter(64) --the height of a meter our worlds will be 64px
  world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
 
  objects = {} -- table to hold all our physical objects
 
 
  --Create Platforms
  --objects.block1 = createPlatform(world, 200, 550, 50, 75, 5)
  --objects.block2 = createPlatform(world, 200, 400, 100, 50, 2)
  --objects.ground = createPlatform(world, love.graphics.getWidth() / 2, love.graphics.getHeight() - 25, love.graphics.getWidth(), 50, 10)
  
  objects.player = Player.create(world, 325, 325, 20, 20)
  
  
end
 
function love.update(dt)
  --world:update(dt) --this puts the world into motion
  --objects.player:update(dt)
  
  if love.keyboard.isDown("up")  then
    moveMap(0, -0.2 * tileSize * dt)
  end
  if love.keyboard.isDown("down")  then
    moveMap(0, 0.2 * tileSize * dt)
  end
  if love.keyboard.isDown("left")  then
    moveMap(-0.2 * tileSize * dt, 0)
  end
  if love.keyboard.isDown("right")  then
    moveMap(0.2 * tileSize * dt, 0)
  end
  
end
 
function love.draw()

  love.graphics.draw(tilesetBatch,
    math.floor(-zoomX*(mapX%1)*tileSize), math.floor(-zoomY*(mapY%1)*tileSize),
    0, zoomX, zoomY)
  love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)

  --love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
  --love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
 
  --love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
  love.graphics.polygon("fill", objects.player.body:getWorldPoints(objects.player.shape:getPoints()))
 
  --love.graphics.setColor(50, 50, 50) -- set the drawing color to grey for the blocks
  --love.graphics.polygon("fill", objects.block1.body:getWorldPoints(objects.block1.shape:getPoints()))
  --love.graphics.polygon("fill", objects.block2.body:getWorldPoints(objects.block2.shape:getPoints()))
  
end





--Tile Stuff
function setupMap()
  local count = 1
  for line in love.filesystem.lines("TestMap.tilemap") do
    local tempParse = string.explode(line, ",")
	map[count] = {}
	for i=1, #tempParse do
		map[count][i] = tonumber(tempParse[i])
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
  tilesDisplayWidth = math.floor(love.graphics.getWidth() / tileSize) + 2
  tilesDisplayHeight = math.floor(love.graphics.getHeight() / tileSize) + 2
 
  zoomX = 1
  zoomY = 1
end
 
function setupTileset()
  local tilesetImage = love.graphics.newImage( "Tileset.png" )
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
	
	print("yuppers")
	print(tostring(tileQuads))
	print(tostring(tileQuads[3]))
 
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
  oldMapX = mapX
  oldMapY = mapY
  mapX = math.max(math.min(mapX + dx, mapWidth - tilesDisplayWidth), 1)
  mapY = math.max(math.min(mapY + dy, mapHeight - tilesDisplayHeight), 1)
  -- only update if we actually moved
  if math.floor(mapX) ~= math.floor(oldMapX) or math.floor(mapY) ~= math.floor(oldMapY) then
    updateTilesetBatch()
  end
end