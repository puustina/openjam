local results = require "src.results"
local countdown = require "src.countdown"

local shitPants = {
	name = "Skidmarks",
	description = "Reach the toilet.",
	controls = "ACTION",
	thumbnail = nil,
	-- game specific
	over = false,
	pos = 0,
	speed = 10,
	goal = 100,
	hold = false,
	poopUrgeStart = 10,
	multi = 1.5,
	poopUrgeCur = 10,
	poopUrgeMax = 100,
	poopMeter = 0,
	poopMeterDir = 1,
	poopMeterSpeed = 50,
	fail = love.graphics.newImage("assets/skidMarks/fail.png"),
	win = love.graphics.newImage("assets/skidMarks/win.png")
}

function shitPants:init()
	self.timer = Timer.new()
end

function shitPants:entering()
	countdown:reset()
	countdown:start()
	self.pos = 0
	self.poopUrgeCur = self.poopUrgeStart
	self.poopMeter = 0
	self.poopMeterDir = 1
	self.over = false
	self.alpha = 0
end

function shitPants:entered()
end

function shitPants:update(dt)
	if Game.paused then return end
	if not countdown:over() then
		countdown:update(dt)
		return
	end
	self.timer:update(dt)
	if self.over then return end
	self.hold = love.keyboard.isDown(Controls["ACTION"])
	if not self.hold and self.poopMeter > (self.poopUrgeMax - self.poopUrgeCur) then
		self.over = true
		Game.result = "LOSE"
		self.timer:tween(0.25, self, { alpha = 255 }, "linear")
		self.timer:add(2, function() Venus.switch(results) end)
		return
	end
	if not self.hold then self.pos = self.pos + self.speed * dt end
	if self.pos >= self.goal then
		self.over = true
		Game.result = "WIN"
		self.timer:add(2, function() Venus.switch(results) end)
		return
	end

	self.poopMeter = self.poopMeter + self.poopMeterDir * self.poopMeterSpeed * dt
	if self.poopMeter > self.poopUrgeMax then
		self.poopUrgeCur = self.multi * self.poopUrgeCur
		if self.poopUrgeCur >= self.poopUrgeMax then
			self.over = true
			Game.result = "LOSE"
			self.timer:tween(0.25, self, { alpha = 255 }, "linear")
			self.timer:add(2, function() Venus.switch(results) end)
		end
		self.poopMeter = self.poopMeter - (self.poopMeter - self.poopUrgeMax)
		self.poopMeterDir = -self.poopMeterDir
	elseif self.poopMeter < 0 then
		self.poopMeter = -self.poopMeter
		self.poopMeterDir = -self.poopMeterDir
	end
end

function shitPants:draw()
	local tS = math.pow(self.pos/self.goal, 2)
	local scale = 0.5 + 1.5 * tS
	local wall = 0.8 + 0.2 * tS
	local floor = 1 - wall
	preDraw()
	-- wall
	love.graphics.setColor(212, 198, 81)
	love.graphics.rectangle("fill", 0, 0, Game.original.w, wall * Game.original.h)
	-- door
	local w = 80 * scale
	local h = 150 * scale
	if not self.over then
		love.graphics.setColor(237, 235, 219)
	elseif Game.result == "WIN" then
		love.graphics.setColor(1, 1, 1, 0)
		love.graphics.setBlendMode("multiply")
		love.graphics.rectangle("fill", Game.original.w/2 - w/2, wall * Game.original.h - h, w, h)
		love.graphics.setBlendMode("alpha")
		love.graphics.setColor(237, 235, 219)
		love.graphics.rectangle("fill", Game.original.w/2 - 1.5 * w, wall * Game.original.h - h, w, h)
		love.graphics.setColor(158, 188, 181)
	end
	love.graphics.rectangle("fill", Game.original.w/2 - w/2, wall * Game.original.h - h, w, h)
	-- handle
	if not self.over then
		love.graphics.setColor(82, 82, 82)
		love.graphics.rectangle("fill", Game.original.w/2 + w/4, wall * Game.original.h - h/2, 10 * scale, 5 * scale)
		-- sign
		love.graphics.setColor(10, 10, 10)
		love.graphics.setFont(Game.font14)
		love.graphics.print("WC", math.floor(Game.original.w/2), math.floor(wall * Game.original.h - 0.75 * h), 0, 
			scale, scale, Game.font14:getWidth("WC")/2, Game.font14:getHeight()/2)
	elseif Game.result == "WIN" then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.win)	
	end
	-- floor
	love.graphics.setColor(189, 184, 140)
	love.graphics.rectangle("fill", 0, wall * Game.original.h, Game.original.w, floor * Game.original.h)
	love.graphics.setColor(0, 200, 0)
	-- seams
	love.graphics.setColor(10, 10, 10)
	local offset = 0
	love.graphics.setLineWidth(1)
	local lines = 20 + (1 - scale) * 10
	for i = 0, lines/2 do
		local pos = Game.original.w/2 + i * (Game.original.w/lines)
		love.graphics.line(pos, Game.original.h * wall, pos + offset, Game.original.h)
		offset = 1.25 * offset + 10
	end
	offset = 10
	for i = -1, -lines/2, -1 do
		local pos = Game.original.w/2 + i * (Game.original.w/lines)
		love.graphics.line(pos, Game.original.h * wall, pos - offset, Game.original.h)
		offset = 1.25 * offset + 10
	end
	local limit = 10 * (1 - tS)
	for i = 1, limit do
		local y = Game.original.h * (wall + floor * math.pow(i/limit, 2))
		love.graphics.line(0, y, Game.original.w, y)
	end

	if Game.result == "LOSE" then
		love.graphics.setColor(255, 255, 255, self.alpha)
		love.graphics.draw(self.fail)
	end

	-- UI
	love.graphics.setColor(50, 50, 50)
	love.graphics.rectangle("fill", 0, Game.original.h - 10, Game.original.w * (1 - self.poopUrgeCur/self.poopUrgeMax), 10)
	love.graphics.setColor(200, 0, 0)
	if self.hold then
		love.graphics.setColor(0, 200, 0)
	end
	love.graphics.rectangle("fill", Game.original.w * (1 - self.poopUrgeCur/self.poopUrgeMax), 
		Game.original.h - 10, Game.original.w * (self.poopUrgeCur/self.poopUrgeMax), 10)
	love.graphics.setLineWidth(5)
	love.graphics.setColor(255, 255, 255)
	love.graphics.line(Game.original.w * (self.poopMeter/self.poopUrgeMax), Game.original.h - 10, Game.original.w * (self.poopMeter/self.poopUrgeMax), Game.original.h)
	if not countdown:over() then countdown:draw() end
	postDraw()
end

return shitPants
