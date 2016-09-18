Menu = {}
Menu.__index = Menu

function Menu.create(x, y, xPadding, yPadding, buttonList, bgImage, buttonInactiveImage, buttonActiveImage)
	local obj = {}
	setmetatable(obj, Menu)
	
	obj.active = false
	obj.buttons = buttonList
	obj.x = x
	obj.y = y
	obj.bgImage = love.graphics.newImage(bgImage)
	obj.buttonInactive = love.graphics.newImage(buttonInactiveImage)
	obj.buttonActive = love.graphics.newImage(buttonActiveImage)
	obj.xPadding = xPadding
	obj.yPadding = yPadding
	
	obj.buttons[1].active = true
	
	return obj
end

function Menu:moveDown()
	for i,b in pairs(self.buttons) do
		if b.active and i < #(self.buttons) then
			self.buttons[i].active = false
			self.buttons[i+1].active = true
			break
		end
	end
end

function Menu:moveUp()
	for i,b in pairs(self.buttons) do
		if b.active and i > 1 then
			self.buttons[i].active = false
			self.buttons[i-1].active = true
			break
		end
	end
end

function Menu:activate()
	for i, b in pairs(self.buttons) do
		if b.active then
			b.callback()
			self.active = false
		end
	end
end

function Menu:update(dt)
	if self.active then
		if love.keyboard.isDown("down") then
			self:moveDown()
		end
		if love.keyboard.isDown("up") then
			self:moveUp()
		end
		if love.keyboard.isDown("space") then
			self:activate()
		end
	end
end

function Menu:draw()
	if self.active then
		love.graphics.draw(self.bgImage, self.x, self.y)
		for i,b in pairs(self.buttons) do
			local x =  self.x + self.xPadding
			local y =  self.y + (self.yPadding * i)
			if b.active then
				love.graphics.draw(self.buttonActive, x, y)
			else 
				love.graphics.draw(self.buttonInactive, x, y)
			end
			love.graphics.print(b.text, x + (self.xPadding / 2), y + (self.yPadding / 4))
		end
	end
end