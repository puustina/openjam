local splash = {
	love = love.graphics.newImage("assets/love-logo.png"),
	piskel = love.graphics.newImage("assets/logo_transparent_small_compact.png"),
	gimp = love.graphics.newImage("assets/wilber-big.png")
}
local menu = require "src.menu"

function splash:init()
	self.timer = Timer.new()
	self.timer:add(5, function() Venus.switch(menu) end)
end

function splash:keypressed(key, scancode, isRepeat)
	if Game.paused then return end
	self.timer:clear()
	Venus.switch(menu)
end

function splash:update(dt)
	if Game.paused then return end
	self.timer:update(dt)
end

function splash:draw()
	preDraw()
	love.graphics.setBackgroundColor(170, 170, 170)
	love.graphics.setColor(255, 255, 255)
	local s = math.min(Game.original.w/self.love:getWidth(), Game.original.h/self.love:getHeight())
	love.graphics.draw(self.love, Game.original.w/2, Game.original.h/2 - 40, 0, s, s, self.love:getWidth()/2, self.love:getHeight()/2)
	love.graphics.draw(self.piskel, 40, Game.original.h/2 + s * (self.love:getHeight()/2) - 10)
	love.graphics.draw(self.gimp, 250, Game.original.h/2 + s * (self.love:getHeight()/2) - 30, 0, 0.4, 0.4)
	postDraw()
end

return splash
