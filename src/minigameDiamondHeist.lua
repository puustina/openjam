local results = require "src.results"

local diamondHeist = {
	name = "Diamond Heist",
	description = "Avoid glass. Grab diamond.",
	controls = "UP DOWN LEFT RIGHT",
	thumbnail = nil,
	-- game specific
	hasControl = false
}

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
		if (minigame.hand.y + minigame.hand.radius > love.graphics.getHeight()) then
			minigame.hand.y = love.graphics.getHeight() - minigame.hand.radius
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
		if (minigame.hand.x + minigame.hand.radius > love.graphics.getWidth()) then
			minigame.hand.x = love.graphics.getWidth() - minigame.hand.radius
		end
	end
}

function diamondHeist:init()
	self.holeRadius = 50
end

function diamondHeist:entering()
	self.hasControl = false
	self.nextRing = 1

	local sW, sH = love.graphics.getDimensions()
	self.hand = {
		x = sW/2,
		y = sH/2,
		z = 0,
		radius = 0.75 * self.holeRadius,
		speed = 100,
		zSpeed = 2
	}

	self.glassPanes = {}
	for i = 1, 10 do
		self.glassPanes[#self.glassPanes + 1] = {
			x = math.random(self.holeRadius, sW - self.holeRadius),
			y = math.random(self.holeRadius, sH - self.holeRadius),
			z = 10 + i * 5
		}
	end
end

function diamondHeist:entered()
	self.hasControl = true
end

function diamondHeist:update(dt)	
	self.hand.z = self.hand.z + self.hand.zSpeed * dt

	for i, j in pairs(bindings) do
		if (love.keyboard.isDown(Controls[i])) then
			j(self, dt)
		end
	end

	if ((self.nextRing <= #self.glassPanes) and 
	(self.glassPanes[self.nextRing].z < self.hand.z)) then
		local maxDistanceFromCenter = self.holeRadius - self.hand.radius
		local pane = self.glassPanes[self.nextRing]
		if (math.sqrt(math.pow(self.hand.x - pane.x, 2) + 
		math.pow(self.hand.y - pane.y, 2)) > maxDistanceFromCenter) then
			Game.result = "LOSE"
			Venus.switch(results)
		end

		self.nextRing = self.nextRing + 1
		if (self.nextRing > #self.glassPanes) then
			Game.result = "WIN"
			Venus.switch(results)
		end
	end
end

function diamondHeist:draw()
	love.graphics.setColor(0, 100, 0)
	for i, j in ipairs(self.glassPanes) do
		if (j.z - self.hand.z > -1) then
			if (i == #self.glassPanes) then love.graphics.setColor(0, 0, 100) end
			local scale = 1/(j.z - self.hand.z + 1)
			love.graphics.circle("line", j.x, j.y, scale * self.holeRadius)
		end
	end

	love.graphics.setColor(100, 0, 0, 150)
	love.graphics.circle("fill", self.hand.x, self.hand.y, self.hand.radius)
end

return diamondHeist