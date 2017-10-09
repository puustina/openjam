-- Global variables:
require "controls"
require "lib.slam"

drawMinigameInfo = function(index, bg, fg)
	local mg = Game.minigames[Game.minigameNames[index] ]
	love.graphics.push()
	local wR = 0.6
	local hR = 0.5
	love.graphics.translate((1 - wR) * 0.5 * Game.original.w, (1 - hR) * 0.5 * Game.original.h)
	love.graphics.setColor(bg)
	love.graphics.rectangle("fill", 0, 0, wR * Game.original.w, hR * Game.original.h)
	love.graphics.setColor(fg)
	love.graphics.setFont(Game.font20)
	love.graphics.print(mg.name, 10, 10)
	love.graphics.setFont(Game.font14)
	love.graphics.print("Instructions:", 15, 50)
	love.graphics.print(mg.description, 25, 68)
	love.graphics.print("Controls:", 15, 100)
	love.graphics.print(mg.controls, 25, 118)
	love.graphics.pop()
end

Game = {
	paused = false,
	pauseEnd = false,
	mode = "",		-- game mode (FP|END|"")
	result = "",		-- minigame result (WIN|LOSE|"")
	maxLives = 3,
	curLives = 3,
	speed = 1,		-- speed/difficulty of minigames
	maxSpeed = 3,
	minSpeed = 0.5,
	multi = 1.1,
	minigamesWon = 0,
	minigameStreak = 0,
	scale = 1,
	volume = 1,
	original = {
		w = love.graphics.getWidth(),
		h = love.graphics.getHeight()
	},
	font14 = love.graphics.newFont(14),
	font20 = love.graphics.newFont(20),
	font40 = love.graphics.newFont(40),
	font70 = love.graphics.newFont(70),
	minigameNames = {
		"DiamondHeist",
		"CavePainting",
		--"WalkTheDog",
		"FaceSlap",
		"BeachWalk",
		"ShitPants",
		"HighFive"
	},
	fadeDuration = 0.5,
	sources = {
		blip = love.audio.newSource("assets/audio/blip.wav", "static"),
		errorBlip = love.audio.newSource("assets/audio/error.wav", "static"),
		timerTick = love.audio.newSource("assets/audio/timer_tick.wav", "static"),
		timerGo = love.audio.newSource("assets/audio/timer_go.wav", "static"),
		selection = love.audio.newSource("assets/audio/selection.wav", "static"),
		rolling = love.audio.newSource("assets/audio/rolling.wav", "static"),
		rollingError = love.audio.newSource("assets/audio/rolling_error.wav", "static"),
		jingle = love.audio.newSource("assets/audio/jingle.wav", "static"),
		lost = love.audio.newSource("assets/audio/lost.wav", "static"),
		menuSong = love.audio.newSource("assets/audio/IncompetechLeopardPrintElevator.mp3", "stream"),
		punch = love.audio.newSource({ "assets/audio/punch1.wav", "assets/audio/punch2.wav" }, "static"),
		fart = love.audio.newSource("assets/audio/fart.wav", "static"),
		slap = love.audio.newSource("assets/audio/slap.wav", "static"),
		alarm = love.audio.newSource("assets/audio/alarm.wav", "static"),
		stepSand = love.audio.newSource("assets/audio/step.wav", "static"),
		stepToilet = love.audio.newSource("assets/audio/stepToilet.wav", "static"),
		pickUp = love.audio.newSource("assets/audio/pickup.wav", "static"),
		pass = love.audio.newSource("assets/audio/rolling.wav", "static"),
		paint = love.audio.newSource("assets/audio/paintOk.wav", "static")
	}
}
Game.sources.rolling:setLooping(true)
Game.sources.rollingError:setLooping(true)
Game.sources.menuSong:setLooping(true)
Game.sources.menuSong:addTags("song")
Game.songs = {}
Game.songs.menu = love.audio.play(Game.sources.menuSong)
Game.sources.alarm:setLooping(true)
Game.sources.stepToilet:setLooping(true)

setPitch = function()
	love.audio.tags.all.setPitch(1 + 0.1*(Game.speed - 1))
end

love.graphics.setFont(Game.font14)
Timer = require "lib.timer"	-- Timer (might be used in minigames)
Venus = require "lib.venus"	-- Minigames & menu need to access this
Venus.duration = Game.fadeDuration

local splash = require "src.splash"

function love.load()
	math.randomseed(os.time())
	love.graphics.setDefaultFilter( "nearest", "nearest", 1 )
	Game.minigames = {}
	for i, j in ipairs(Game.minigameNames) do
		Game.minigames[j] = require ("src.minigame"..j)
	end
	Game.face = {
		base = love.graphics.newImage("assets/faceSlap/template.png")
	}

	local facePartNames = {
		"nose",
		"mouth",
		"hat",
		"eyes"
	}

	for i, j in pairs(facePartNames) do
		Game.face[j] = {}
		for k = 1, 4 do 
			Game.face[j][k] = love.graphics.newImage("assets/faceSlap/" .. j .. k .. ".png")
		end
	end
	Venus.registerEvents()
	Venus.switch(splash)
end

function love.keypressed(key, scancode, isRepeat)
	local setScale = function() 
		Game.cooldown = true
		love.window.setMode(Game.original.w * Game.scale, Game.original.h * Game.scale)
	end

	if (key == Controls["PAUSE"]) then
		if Game.paused then
			love.event.quit()
		end
		love.audio.play(Game.sources.blip)	
		Game.paused = true
	elseif (Game.paused and key == Controls["ACTION"]) then
		love.audio.play(Game.sources.blip)
		Game.pauseEnd = true
	end

	if (key == "-") then
		if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") then
			if Game.cooldown then
				Game.cooldown = false
				return 
			end
			love.audio.play(Game.sources.blip)
			Game.scale = math.max(1, Game.scale / 2)
			setScale()
		else
			Game.volume = math.max(0, Game.volume - 0.1)
			love.audio.tags.all.setVolume(Game.volume)
			-- scrollSND
		end
	elseif (key == "+") then
		if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") then
			if Game.cooldown then
				Game.cooldown = false 
				return 
			end
			love.audio.play(Game.sources.blip)
			Game.scale = math.min(3, Game.scale * 2)
			setScale()
		else
			Game.volume = math.min(1, Game.volume + 0.1)
			love.audio.tags.all.setVolume(Game.volume)
			-- scrollSND
		end
	end
end

function love.update(dt)
	if Game.pauseEnd then 
		Game.paused = false 
		Game.pauseEnd = false	
	end
	if Game.paused then return end
	Timer.update(dt)
end

function preDraw()
	love.graphics.push()
	love.graphics.scale(Game.scale, Game.scale)
end

function postDraw()
	if Game.paused then
		love.graphics.setColor(220, 220, 220, 220)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(30, 30, 30, 255)
		love.graphics.setFont(Game.font40)
		local l1 = "Game paused!"
		local l2 = "PAUSE to exit. ACTION to resume."
		love.graphics.print(l1, math.floor(Game.original.w/2 - Game.font40:getWidth(l1)/2), 
			math.floor(Game.original.h/2 - 40))
		love.graphics.setFont(Game.font14)
		love.graphics.print(l2, math.floor(Game.original.w/2 - Game.font14:getWidth(l2)/2), 
			math.floor(Game.original.h/2 + 20))
	end
	love.graphics.pop()
end
