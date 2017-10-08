local results = require "src.results"
local countdown = require "src.countdown"
local anim8 = require "lib.anim8"

local cavePainting = {
	name = "Cave Painting",
	description = "Tell the tale of your tribe.",
	controls = "UP DOWN LEFT RIGHT ACTION",
	thumbnail = nil,
	-- game specific
	PAINTINGS = {
		{ r = 16, c = { 100, 0, 0 }, img = love.graphics.newImage("assets/cavePainting/caveman.png") },
		{ r = 32, c = { 0, 100, 0 }, img = love.graphics.newImage("assets/cavePainting/fire.png") },
		{ r = 64, c = { 0, 0, 100 }, img = love.graphics.newImage("assets/cavePainting/mammoth.png") }
	},
	speedOrig = 200,
	over = false,
	timeLimitOrig = 10,
	images = {
		wall = love.graphics.newImage("assets/cavePainting/wall.png"),
		fail = love.graphics.newImage("assets/cavePainting/fail.png")
	}
}
cavePainting.PAINTINGS[1].anim = anim8.newAnimation(anim8.newGrid(32, 32, 4*32, 32)('1-4', 1, '3-2', 1), 0.2)
cavePainting.PAINTINGS[2].anim = anim8.newAnimation(anim8.newGrid(64, 64, 5*64, 64)('1-5', 1, '4-2', 1), 0.15)
cavePainting.PAINTINGS[3].anim = anim8.newAnimation(anim8.newGrid(128, 128, 5*128, 128)('1-5', 1, '4-2', 1), 0.3)

local bindings = {
	UP = function(minigame, dt)
		local r = minigame.PAINTINGS[minigame.paintings[minigame.curPainting.index] ].r
		minigame.curPainting.y = minigame.curPainting.y - minigame.speed * dt
		if (minigame.curPainting.y - r < 10) then
			minigame.curPainting.y = r + 10
		end
	end,
	DOWN = function(minigame, dt)
		local r = minigame.PAINTINGS[minigame.paintings[minigame.curPainting.index] ].r
		minigame.curPainting.y = minigame.curPainting.y + minigame.speed * dt
		if (minigame.curPainting.y + r > Game.original.h - 10) then
			minigame.curPainting.y = Game.original.h - r - 10
		end
	end,
	LEFT = function(minigame, dt)
		local r = minigame.PAINTINGS[minigame.paintings[minigame.curPainting.index] ].r
		minigame.curPainting.x = minigame.curPainting.x - minigame.speed * dt
		if (minigame.curPainting.x - r < 0) then
			minigame.curPainting.x = r
		end
	end,
	RIGHT = function(minigame, dt)
		local r = minigame.PAINTINGS[minigame.paintings[minigame.curPainting.index] ].r
		minigame.curPainting.x = minigame.curPainting.x + minigame.speed * dt
		if (minigame.curPainting.x + r > Game.original.w) then
			minigame.curPainting.x = Game.original.w - r
		end
	end,
	ACTION = function(minigame)
		minigame.paintWall[#minigame.paintWall + 1] = {
			x = minigame.curPainting.x,
			y = minigame.curPainting.y,
			index = minigame.paintings[minigame.curPainting.index]
		}

		local p = minigame.paintWall[#minigame.paintWall]
		local minDist = math.huge
		local minIndex = nil
		for i, j in ipairs(minigame.wall) do
			local dist = math.sqrt(math.pow(p.x - j.x, 2) + math.pow(p.y - j.y, 2))
			if (p.index == j.index and dist < 2 * (minigame.PAINTINGS[p.index].r) and dist < minDist) then
				minIndex = i
				minDist = dist
			end
		end

		if minIndex then
			minigame.success = minigame.success + 1 - minDist/(2 * minigame.PAINTINGS[p.index].r)	
			table.remove(minigame.wall, minIndex)
		else
			minigame.success = minigame.success - 1
			for i, j in ipairs(minigame.wall) do
				if j.index == p.index then
					table.remove(minigame.wall, i)
					break
				end
			end
		end

		minigame.curPainting.index = minigame.curPainting.index + 1
		if #minigame.wall == 0 then
			minigame.over = true
			if minigame.success > 0 then
				Game.result = "WIN"
			else
				Game.result = "LOSE"
				minigame.timer:tween(2 * (1/Game.speed), minigame, { failPos = -Game.original.w }, "linear")
			end
			minigame.timer:add(2 * (1/Game.speed), function()
				Venus.switch(results)
			end)
		end
	end
}

function cavePainting:init()
	self.timer = Timer.new()
end

function cavePainting:entering()
	countdown:reset()
	countdown:start()
	self.speed = self.speedOrig
	self.timeLimit = self.timeLimitOrig - 1.5 * Game.speed
	self.timeLeft = self.timeLimit
	self.success = -2.5
	self.over = false
	self.failPos = Game.original.w

	-- Painting queue
	self.paintings = {}
	for i = 1, 5 do
		local rand = math.random()
		local index = 0
		if rand > 0.9 - 0.05 * Game.speed then
			index = 3
		elseif rand > 0.6 - 0.05 * Game.speed then
			index = 2
		else
			index = 1
		end
		self.paintings[#self.paintings + 1] = index
	end

	self.curPainting = {
		index = 1,
		x = Game.original.w/2,
		y = Game.original.h/2
	}

	-- Paint the wall based on the queue
	self.wall = {}
	for i, j in ipairs(self.paintings) do
		local r = self.PAINTINGS[j].r
		local w = Game.original.w
		local h = Game.original.h
		local angle = ((i - 1)/#self.paintings) * 2 * math.pi
		local minDist = r
		local maxDist = math.sqrt(math.pow(math.cos(angle)*(w/2), 2) + math.pow(math.sin(angle)*(h/2 - 10), 2)) - r
		local dist = math.random(minDist, maxDist)
		self.wall[#self.wall + 1] = {
			index = j,
			x = w/2 + math.cos(angle) * dist,
			y = h/2 + math.sin(angle) * dist
		}
	end
	self.paintWall = {}
end

function cavePainting:entered()
end

function cavePainting:keypressed(key, scancode, isRepeat)
	if Game.paused or not countdown:over() or self.over then return end
	if (key == Controls["ACTION"] and not isRepeat) then
		bindings["ACTION"](self)
	end
end

function cavePainting:update(dt)
	for i, j in ipairs(self.PAINTINGS) do
		j.anim:update(dt)
	end

	if Game.paused then return end
	if not countdown:over() then
		countdown:update(dt)
		return
	end
	if not self.over then
		self.timeLeft = self.timeLeft - dt

		if (self.timeLeft < 0 and Game.result == "") then 
			self.over = true
			Game.result = "LOSE"
			self.timer:tween(2 * (1/Game.speed), self, { failPos = -Game.original.w }, "linear")
			self.timer:add(2 * (1/Game.speed), function() Venus.switch(results) end)
		end

		for i, j in pairs(bindings) do
			if (i ~= "ACTION" and love.keyboard.isDown(Controls[i])) then
				j(self, dt)
			end
		end
	elseif Game.result == "WIN" then
		for i, j in pairs(self.paintWall) do
			if j.index == 1 or j.index == 3 then
				j.x = j.x + (50 * Game.speed + 10 * j.index) * dt
			end
		end
	end

	self.timer:update(dt)
end

function cavePainting:draw()
	preDraw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.images.wall, 0, 0)

	for i, j in pairs(self.wall) do
		love.graphics.setColor(255, 255, 255, 100)
		self.PAINTINGS[j.index].anim:draw(self.PAINTINGS[j.index].img, j.x, j.y, 0, 1, 1, self.PAINTINGS[j.index].r, self.PAINTINGS[j.index].r)
	end

	for i, j in pairs(self.paintWall) do
		love.graphics.setColor(255, 255, 255)
		self.PAINTINGS[j.index].anim:draw(self.PAINTINGS[j.index].img, j.x, j.y, 0, 1, 1, self.PAINTINGS[j.index].r, self.PAINTINGS[j.index].r)
	end

	if (self.curPainting.index <= #self.paintings) then
		local painting = self.PAINTINGS[self.paintings[self.curPainting.index] ]
		love.graphics.setColor(255, 255, 255, 200)
		painting.anim:draw(painting.img, self.curPainting.x, self.curPainting.y, 0, 1, 1, painting.r, painting.r)
	end

	if Game.result == "LOSE" then
		love.graphics.setColor(255, 255, 255, 200)
		love.graphics.draw(self.images.fail, self.failPos, 0)
	end
	love.graphics.setColor(50, 50, 50)
	love.graphics.rectangle("fill", 0, 0, Game.original.w, 10)
	love.graphics.rectangle("fill", 0, Game.original.h - 10, Game.original.w, 10)
	love.graphics.setColor(150, 150, 150)
	love.graphics.rectangle("fill", 0, Game.original.h - 10, Game.original.w * (self.timeLeft/self.timeLimit), 10) 
	if self.success < 0 then
		love.graphics.setColor(200, 0, 0, 150)
	else
		love.graphics.setColor(0, 200, 0, 150)
	end
	love.graphics.rectangle("fill", Game.original.w * 0.5, 0, Game.original.w * 0.5 * (self.success/5), 10)
	if not countdown:over() then countdown:draw() end
	postDraw()
end

return cavePainting
