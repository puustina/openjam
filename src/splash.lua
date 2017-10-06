local splash = {}
local menu = require "src.menu"

function splash:init()
	self.timer = Timer.new()
	self.timer:add(.1, function() Venus.switch(menu) end)
end

function splash:update(dt)
	self.timer:update(dt)
end

function splash:draw()
	preDraw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("SPLASH!", 10, 10)
	postDraw()
end

return splash
