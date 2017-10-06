local results = require "src.results"
local countdown = require "src.countdown"
local anim8 = require "lib.anim8"

local diamondHeist = {
	name = "Diamond Heist",
	description = "Avoid glass. Grab diamond.",
	controls = "UP DOWN LEFT RIGHT",
	thumbnail = nil,
	-- game specific
	hasControl = false,
	diamondPic = love.graphics.newImage("assets/diamondHeist/diamond.png")
}
diamondHeist.diamondAnim = anim8.newAnimation(anim8.newGrid(160, 160, 7*160, 160)('1-7', 1), 0.1) 

local bindings = {
	UP = function(minigame, dt)
		if not minigame.hasControl then return end
		minigame.hand.y = minigame.hand.y - minigame.hand.speed * dt
		if (minigame.hand.y - minigame.hand.radius < 0) then
			minigame.hand.y = minigame.hand.radius
		end
	end,
	DOWN = function(minigame, dt)
		if not minigame.hasControl then return end
		minigame.hand.y = minigame.hand.y + minigame.hand.speed * dt
		if (minigame.hand.y + minigame.hand.radius > Game.original.h) then
			minigame.hand.y = Game.original.h - minigame.hand.radius
		end
	end,
	LEFT = function(minigame, dt)
		if not minigame.hasControl then return end
		minigame.hand.x = minigame.hand.x - minigame.hand.speed * dt
		if (minigame.hand.x - minigame.hand.radius < 0) then
			minigame.hand.x = minigame.hand.radius
		end
	end,
	RIGHT = function(minigame, dt)
		if not minigame.hasControl then return end
		minigame.hand.x = minigame.hand.x + minigame.hand.speed * dt
		if (minigame.hand.x + minigame.hand.radius > Game.original.w) then
			minigame.hand.x = Game.original.w - minigame.hand.radius
		end
	end
}

function diamondHeist:init()
	self.holeRadius = 90
end

function diamondHeist:entering()
	countdown:reset()
	countdown:start()
	self.hasControl = false
	self.over = false
	self.nextRing = 1

	self.hand = {
		x = Game.original.w/2,
		y = Game.original.h/2,
		z = 0,
		radius = 64,
		speed = 100,
		zSpeed = 3,
		img = love.graphics.newImage("assets/diamondHeist/hand.png"),
		anim = anim8.newAnimation(anim8.newGrid(128, 128, 4*128, 128)('1-4', 1), 0.2)
	}

	self.glassPanes = {}
	for i = 1, 5 do
		self.glassPanes[#self.glassPanes + 1] = {
			x = math.random(self.holeRadius, Game.original.w - self.holeRadius),
			y = math.random(self.holeRadius, Game.original.h - self.holeRadius),
			z = 7 + i * 6
		}
	end
end

function diamondHeist:entered()
end

function diamondHeist:update(dt)	
	self.diamondAnim:update(dt)
	self.hand.anim:update(dt)
	if Game.paused or self.over then return end
	if not countdown:over() then
		countdown:update(dt)
		return
	else
		self.hasControl = true
	end
	self.hand.z = self.hand.z + self.hand.zSpeed * dt

	for i, j in pairs(bindings) do
		if (love.keyboard.isDown(Controls[i])) then
			j(self, dt)
		end
	end

	if ((self.nextRing <= #self.glassPanes) and 
	(self.glassPanes[self.nextRing].z < self.hand.z)) then
		local maxDistanceFromCenter = self.holeRadius - self.hand.radius
		if (self.nextRing == #self.glassPanes) then maxDistanceFromCenter = self.holeRadius end
		local pane = self.glassPanes[self.nextRing]
		if (math.sqrt(math.pow(self.hand.x - pane.x, 2) + 
		math.pow(self.hand.y - pane.y, 2)) > maxDistanceFromCenter) then
			Game.result = "LOSE"
			self.hand.z = pane.z - 0.01
			self.over = true
			Venus.switch(results)
		end

		self.nextRing = self.nextRing + 1
		if (self.nextRing > #self.glassPanes and not self.over) then
			Game.result = "WIN"
			self.hand.z = pane.z - 0.01
			self.over = true
			Venus.switch(results)
		end
	end
end

function diamondHeist:draw()
	preDraw()
	love.graphics.setBackgroundColor(222, 222, 222)
	local diamond = self.glassPanes[#self.glassPanes]
	local scale = 1/(diamond.z - self.hand.z + 1)
	if true then
		love.graphics.setColor(100, 100, 100)
		for x = diamond.x + 50 * scale, Game.original.w, 50 * scale do
			love.graphics.line(x, 0, x, Game.original.h)
		end
		for x = diamond.x, 0, -50 * scale do
			love.graphics.line(x, 0, x, Game.original.h)
		end
		for y = diamond.y + 50 * scale, Game.original.h, 50 * scale do
			love.graphics.line(0, y, Game.original.w, y)
		end
		for y = diamond.y, 0, -50 * scale do
			love.graphics.line(0, y, Game.original.w, y)
		end
	end
	for i = #self.glassPanes, 1, -1 do
		local j = self.glassPanes[i]
		if (j.z > self.hand.z) then
			local scale = 1/(j.z - self.hand.z + 1)
			if (i == #self.glassPanes) then 
				love.graphics.setColor(255, 255, 255)
				self.diamondAnim:draw(self.diamondPic, j.x, j.y, 0, scale, scale, 80, 80)
			else
				if (i == self.nextRing) then
					love.graphics.setColor(225, 225, 225, 150)
					love.graphics.rectangle("fill", 0, 0, Game.original.w, Game.original.h)
					love.graphics.setColor(100, 100, 100, 255)
					love.graphics.setBlendMode("add")
					love.graphics.circle("fill", j.x, j.y, scale * self.holeRadius)
				end
				love.graphics.setBlendMode("alpha")
				love.graphics.setColor(0, 0, 0)
				love.graphics.circle("line", j.x, j.y, scale * self.holeRadius)
			end
		end
	end

	love.graphics.setColor(255, 255, 255, 200)
	self.hand.anim:draw(self.hand.img, self.hand.x, self.hand.y, 0, 1, 1, self.hand.radius, self.hand.radius)
	if not countdown:over() then countdown:draw() end
	postDraw()
end

return diamondHeist
