local results = require "src.results"
local countdown = require "src.countdown"

local cavePainting = {
	name = "Cave Painting",
	description = "Tell the tale of your tribe.",
	controls = "UP DOWN LEFT RIGHT ACTION",
	thumbnail = nil,
	-- game specific
	PAINTINGS = {
		{ r = 10, c = { 100, 0, 0 }},
		{ r = 20, c = { 0, 100, 0 }},
		{ r = 50, c = { 0, 0, 100 }}
	},
	speed = 200,
	hasControl = false,
	timeLimit = 10
}

local bindings = {
	UP = function(minigame, dt)
		if not minigame.hasControl then return end
		if (minigame.curPainting.index > #minigame.paintings) then return end 
		local r = minigame.PAINTINGS[minigame.paintings[minigame.curPainting.index] ].r
		minigame.curPainting.y = minigame.curPainting.y - minigame.speed * dt
		if (minigame.curPainting.y - r < 0) then
			minigame.curPainting.y = r
		end
	end,
	DOWN = function(minigame, dt)
		if not minigame.hasControl then return end
		if (minigame.curPainting.index > #minigame.paintings) then return end 
		local r = minigame.PAINTINGS[minigame.paintings[minigame.curPainting.index] ].r
		minigame.curPainting.y = minigame.curPainting.y + minigame.speed * dt
		if (minigame.curPainting.y + r > Game.original.h) then
			minigame.curPainting.y = Game.original.h - r
		end
	end,
	LEFT = function(minigame, dt)
		if not minigame.hasControl then return end
		if (minigame.curPainting.index > #minigame.paintings) then return end 
		local r = minigame.PAINTINGS[minigame.paintings[minigame.curPainting.index] ].r
		minigame.curPainting.x = minigame.curPainting.x - minigame.speed * dt
		if (minigame.curPainting.x - r < 0) then
			minigame.curPainting.x = r
		end
	end,
	RIGHT = function(minigame, dt)
		if not minigame.hasControl then return end
		if (minigame.curPainting.index > #minigame.paintings) then return end 
		local r = minigame.PAINTINGS[minigame.paintings[minigame.curPainting.index] ].r
		minigame.curPainting.x = minigame.curPainting.x + minigame.speed * dt
		if (minigame.curPainting.x + r > Game.original.w) then
			minigame.curPainting.x = Game.original.w - r
		end
	end,
	ACTION = function(minigame)
		if not minigame.hasControl then return end
		if (minigame.curPainting.index > #minigame.paintings) then return end 

		minigame.paintWall[#minigame.paintWall + 1] = {
			x = minigame.curPainting.x,
			y = minigame.curPainting.y,
			index = minigame.paintings[minigame.curPainting.index]
		}

		minigame.curPainting.index = minigame.curPainting.index + 1
	end
}

function cavePainting:init()
	self.timer = Timer.new()
end

function cavePainting:entering()
	countdown:reset()
	countdown:start()
	self.timeLeft = self.timeLimit

	-- Painting queue
	self.paintings = {
		1, 1, 2, 3, 1, 3
	}
	self.curPainting = {
		index = 1,
		x = Game.original.w/2,
		y = Game.original.h/2
	}

	-- Paint the wall based on the queue
	self.wall = {}
	for i, j in ipairs(self.paintings) do
		local r = self.PAINTINGS[j].r
		self.wall[#self.wall + 1] = {
			index = j,
			x = math.random(r, Game.original.w - r),
			y = math.random(r, Game.original.h - r)
		}
	end
	self.paintWall = {}
end

function cavePainting:entered()
end

function cavePainting:keypressed(key, scancode, isRepeat)
	if Game.paused or not countdown:over() then return end
	if (key == Controls["ACTION"] and not isRepeat) then
		bindings["ACTION"](self)
	end
end

function cavePainting:update(dt)
	if Game.paused then return end
	if not countdown:over() then
		countdown:update(dt)
		return
	else
		self.hasControl = true
	end
	if self.hasControl then
		self.timeLeft = self.timeLeft - dt

		if (self.timeLeft < 0 and Game.result == "") then 
			Game.result = "LOSE"
			Venus.switch(results)
		end
	end

	for i, j in pairs(bindings) do
		if (i ~= "ACTION" and love.keyboard.isDown(Controls[i])) then
			j(self, dt)
		end
	end

	self.timer:update(dt)
end

function cavePainting:draw()
	preDraw()
	love.graphics.setBackgroundColor(0, 0, 0)
	for i, j in pairs(self.wall) do
		local color = self.PAINTINGS[j.index].c
		color[#color + 1] = 100
		love.graphics.setColor(color)
		love.graphics.circle("line", j.x, j.y, self.PAINTINGS[j.index].r)
	end

	for i, j in pairs(self.paintWall) do
		love.graphics.setColor(self.PAINTINGS[j.index].c)
		love.graphics.circle("fill", j.x, j.y, self.PAINTINGS[j.index].r)
	end

	if (self.curPainting.index <= #self.paintings) then
		love.graphics.setColor(self.PAINTINGS[self.paintings[self.curPainting.index] ].c)
		love.graphics.circle("fill", self.curPainting.x, self.curPainting.y, self.PAINTINGS[self.paintings[self.curPainting.index] ].r)
	end

	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", 0, Game.original.h - 10, Game.original.w * (self.timeLeft/self.timeLimit), 10) 
	if not countdown:over() then countdown:draw() end
	postDraw()
end

return cavePainting
