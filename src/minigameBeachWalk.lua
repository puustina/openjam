local results = require "src.results"
local countdown = require "src.countdown"
local anim8 = require "lib.anim8"

local beachWalk = {
	name = "Beach Walk",
	description = "Collect seashells. Don't cross your own footsteps.",
	controls = "LEFT RIGHT",
	thumbnail = nil,
	-- game specific
	over = false,
	player = nil,
	seaShells = {},
	playerSpeed = 48,
	playerTurnSpeed = math.pi,
	seaShellCount = 7,
	shellR = 16,
	sand = love.graphics.newImage("assets/beachWalk/sand.png"),
	footImg = love.graphics.newImage("assets/beachWalk/foot.png"), 
	clamImg = love.graphics.newImage("assets/beachWalk/clam.png"),
	clamAnim = anim8.newAnimation(anim8.newGrid(32, 32, 4*32, 32)('1-4', 1, '3-2', 1), 0.3)
}

local bindings = {
	LEFT = function(beachWalk, dt)
		beachWalk.player.angle = (beachWalk.player.angle - beachWalk.playerTurnSpeed * dt)%(math.pi * 2)
	end,
	RIGHT = function(beachWalk, dt)
		beachWalk.player.angle = (beachWalk.player.angle + beachWalk.playerTurnSpeed * dt)%(math.pi * 2)
	end
}

function beachWalk:init()
	self.timer = Timer.new()
end

function beachWalk:entering()
	countdown:reset()
	countdown:start()
	self.over = false

	local r = 16
	self.player = {
		x = math.random(r, Game.original.w - r),
		y = math.random(r, Game.original.h - r),
		angle = math.random(0, 2 * math.pi),
		steps = {},
		r = r,
		dist = 0
	}
	self.player.steps[1] = { self.player.x, self.player.y, self.player.angle }

	local overlap = function(newShell, player, shells)
		for i, j in ipairs(shells) do
			if math.sqrt(math.pow(j.x - newShell.x, 2) + math.pow(j.y - newShell.y, 2)) < 2 * beachWalk.shellR then
				return true
			end
		end
		if math.sqrt(math.pow(player.x - newShell.x, 2) + math.pow(player.y - newShell.y, 2)) < (player.r + beachWalk.shellR) then
			return true
		end
		return false
	end

	self.seaShells = {}
	for i = 1, self.seaShellCount do
		repeat
			newShell = {
				x = math.random(self.shellR, Game.original.w - self.shellR),
				y = math.random(self.shellR, Game.original.h - self.shellR)
			}
		until not overlap(newShell, self.player, self.seaShells)
		self.seaShells[#self.seaShells + 1] = newShell
	end
end

function beachWalk:entered()
end

function beachWalk:update(dt)
	self.clamAnim:update(dt)
	if Game.paused then return end
	if not countdown:over() then
		countdown:update(dt)
		return
	end
	
	self.timer:update(dt)
	if self.over then return end

	for i, j in pairs(bindings) do
		if love.keyboard.isDown(Controls[i]) then j(self, dt) end
	end

	self.player.dist = self.player.dist + self.playerSpeed * dt
	local eps = 0.1
	if self.player.dist >= (2 * self.player.r + eps) then
		self.player.dist = self.player.dist - 2 * self.player.r
		
		local newX = self.player.x + (2 * (self.player.r + eps)) * math.cos(self.player.angle)
		local newY = self.player.y + (2 * (self.player.r + eps)) * math.sin(self.player.angle)

		self.player.steps[#self.player.steps + 1] = {
			newX, newY, self.player.angle
		}

		-- do we need to wrap?
		if newX < self.player.r then
			self.player.steps[#self.player.steps + 1] = {
				newX + Game.original.w, newY, self.player.angle, double = true
			}
		elseif newX > (Game.original.w - self.player.r) then
			self.player.steps[#self.player.steps + 1] = {
				newX - Game.original.w, newY, self.player.angle, double = true
			}
		end
		if newY < self.player.r then
			self.player.steps[#self.player.steps + 1] = {
				newX, newY + Game.original.h, self.player.angle, double = true
			}
		elseif newY > (Game.original.h - self.player.r) then
			self.player.steps[#self.player.steps + 1] = {
				newX, newY - Game.original.h, self.player.angle, double = true
			}
		end

		self.player.x = newX%Game.original.w
		self.player.y = newY%Game.original.h
		
		-- collisions
		local collides = function(x1, y1, r1, x2, y2, r2)
			return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2)) < (r1 + r2)
		end
		local killTable = false
		local d = 0
		if self.player.steps[#self.player.steps].double then d = -1 end
		local lS = self.player.steps[#self.player.steps]
		local llS = self.player.steps[#self.player.steps - 1]
		for i, j in ipairs(self.seaShells) do
			if collides(lS[1], lS[2], self.player.r,
			j.x, j.y, self.shellR) or (d == -1 and
			collides(llS[1], llS[2], self.player.r, j.x, j.y, self.shellR)) then
				j.kill = true
				killTable = true
			end
		end
		if killTable then
			for i = #self.seaShells, 1, -1 do
				if self.seaShells[i].kill then
					table.remove(self.seaShells, i)
				end
			end
		end
		if #self.seaShells == 0 then
			self.over = true
			Game.result = "WIN"
			self.timer:add(2, function() Venus.switch(results) end)
			return -- can't lose anymore
		end

		local r = self.player.r
		for i = 1, #self.player.steps - 1 + d do
			local s = self.player.steps[i]
			if collides(s[1], s[2], r, lS[1], lS[2], r) or
			(d == -1 and collides(s[1], s[2], r, llS[1], llS[2], r)) then
				self.over = true
				Game.result = "LOSE"
				self.timer:add(1, function() Venus.switch(results) end)
				return
			end
		end
	end
end

function beachWalk:draw()
	preDraw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.sand)

	local step = -1
	for i, j in ipairs(self.player.steps) do
		if j.double then step = -step end
		love.graphics.setColor(255, 255, 255, 100)
		love.graphics.draw(self.footImg, j[1], j[2], j[3] + math.pi/2, step == 1 and 1 or -1, 1, self.player.r, self.player.r)
		if i == #self.player.steps and not self.over then
			local newX = j[1] + 2 * self.player.r * math.cos(self.player.angle)
			local newY = j[2] + 2 * self.player.r * math.sin(self.player.angle)
			love.graphics.setColor(255, 255, 255, 35)
			love.graphics.draw(self.footImg, newX, newY, self.player.angle + math.pi/2, step == 1 and -1 or 1, 1, self.player.r, self.player.r)
			if j.double then
				local other = self.player.steps[#self.player.steps - 1]
				local newX = other[1] + 2 * self.player.r * math.cos(self.player.angle)
				local newY = other[2] + 2 * self.player.r * math.sin(self.player.angle)
				love.graphics.draw(self.footImg, newX, newY, self.player.angle + math.pi/2, step == 1 and -1 or 1, 1, self.player.r, self.player.r)
			end
		end
		step = -step
	end

	for i, j in ipairs(self.seaShells) do
		love.graphics.setColor(255, 255, 255)
		self.clamAnim:draw(self.clamImg, j.x, j.y, 0, 1, 1, self.shellR, self.shellR)
	end

	if not countdown:over() then countdown:draw() end
	postDraw()
end

return beachWalk
