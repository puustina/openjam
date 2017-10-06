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
	love.graphics.print("SPLASH!", 10, 10)
end

return splash
