Button = {}
Button.__index = Button

function Button.create(text, callback)
	local obj = {}
	setmetatable(obj, Button)
	
	obj.selected = false
	obj.text = text
	obj.callback = callback
	
	return obj
end

