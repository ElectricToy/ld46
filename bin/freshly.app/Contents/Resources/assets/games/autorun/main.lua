-- Ludum Dare 45: Jeff, Ellie, and Liam Wofford

function lerp( a, b, alpha )
	return a + (b-a) * alpha
end

-- Configuration
text_scale( 1 )
filter_mode( "Nearest" )

screen_size( 240, 160 )

SPRITE_SHEET_PIXELS_X = 512
PIXELS_PER_TILE = 16
TILES_X = SPRITE_SHEET_PIXELS_X // PIXELS_PER_TILE

sprite_size( PIXELS_PER_TILE )

WORLD_SIZE_PIXELS = 128 * PIXELS_PER_TILE

barrel_ = 0.2
bloom_intensity_ = 0
bloom_contrast_ = 0
bloom_brightness_ = 0
burn_in_ = 0
chromatic_aberration_ = 0
noise_ = 0.025
rescan_ = 0.25
saturation_ = 1
color_multiplied_r = 1
color_multiplied_g = 1
color_multiplied_b = 1
bevel_ = 0

local barrel_smoothed = barrel_
local bloom_intensity_smoothed = bloom_intensity_
local bloom_contrast_smoothed = bloom_contrast_
local bloom_brightness_smoothed = bloom_brightness_
local burn_in_smoothed = burn_in_
local chromatic_aberration_smoothed = chromatic_aberration_
local noise_smoothed = noise_
local rescan_smoothed = rescan_
local saturation_smoothed = saturation_
local color_multiplied_r_smoothed = color_multiplied_r
local color_multiplied_g_smoothed = color_multiplied_g
local color_multiplied_b_smoothed = color_multiplied_b
local bevel_smoothed = bevel_

SCREEN_EFFECT_SMOOTH_FACTOR = 0.035

function updateScreenParams()
	barrel_smoothed = lerp( barrel_smoothed, barrel_, SCREEN_EFFECT_SMOOTH_FACTOR )
	bloom_intensity_smoothed = lerp( bloom_intensity_smoothed, bloom_intensity_, SCREEN_EFFECT_SMOOTH_FACTOR )
	bloom_contrast_smoothed = lerp( bloom_contrast_smoothed, bloom_contrast_, SCREEN_EFFECT_SMOOTH_FACTOR )
	bloom_brightness_smoothed = lerp( bloom_brightness_smoothed, bloom_brightness_, SCREEN_EFFECT_SMOOTH_FACTOR )
	burn_in_smoothed = lerp( burn_in_smoothed, burn_in_, SCREEN_EFFECT_SMOOTH_FACTOR )
	chromatic_aberration_smoothed = lerp( chromatic_aberration_smoothed, chromatic_aberration_, SCREEN_EFFECT_SMOOTH_FACTOR )
	noise_smoothed = lerp( noise_smoothed, noise_, SCREEN_EFFECT_SMOOTH_FACTOR )
	rescan_smoothed = lerp( rescan_smoothed, rescan_, SCREEN_EFFECT_SMOOTH_FACTOR )
	saturation_smoothed = lerp( saturation_smoothed, saturation_, SCREEN_EFFECT_SMOOTH_FACTOR )
	color_multiplied_r_smoothed = lerp( color_multiplied_r_smoothed, color_multiplied_r, SCREEN_EFFECT_SMOOTH_FACTOR )
	color_multiplied_g_smoothed = lerp( color_multiplied_g_smoothed, color_multiplied_g, SCREEN_EFFECT_SMOOTH_FACTOR )
	color_multiplied_b_smoothed = lerp( color_multiplied_b_smoothed, color_multiplied_b, SCREEN_EFFECT_SMOOTH_FACTOR )
	bevel_smoothed = lerp( bevel_smoothed, bevel_, SCREEN_EFFECT_SMOOTH_FACTOR )
	
	barrel( barrel_smoothed )
	bloom( bloom_intensity_smoothed, bloom_contrast_smoothed, bloom_brightness_smoothed )
	burn_in( burn_in_smoothed )
	chromatic_aberration( chromatic_aberration_smoothed )
	noise( noise_smoothed, rescan_smoothed )
	saturation( saturation_smoothed )
	color_multiplied( color_multiplied_r_smoothed, color_multiplied_g_smoothed, color_multiplied_b_smoothed )
	bevel( bevel_smoothed, 0 )
end

updateScreenParams()

-- Vector

--[[ 
Vector class ported/inspired from 
Processing (http://processing.org) 
]]--
vec2 = {}

function vec2:new( x, y )
  
  x = x or 0
  y = y or x
  
  local o = {
    x = x,
    y = y
  }
  
  self.__index = self
  return setmetatable(o, self)
end

function vec2:__add(v)
  return vec2:new( self.x + v.x, self.y + v.y )
end

function vec2:__sub(v)
	return vec2:new( self.x - v.x, self.y - v.y )
end

function vec2:__mul(v)
	if v == nil then
		trace( 'vec2:__mul called with nil operand.' )
		return
	end

	if type( v ) == 'number' then
		v = { x = v, y = v }
	end

	return vec2:new( self.x * v.x, self.y * v.y )
end

function vec2:__div(v)

	if type( v ) == 'number' then
		v = { x = v, y = v }
	end
	
	if v.x == nil or v.x == 0 then
		v.x = 1
	end

	if v.y == nil or v.y == 0 then
		v.y = 1
	end

	return vec2:new( self.x / v.x, self.y / v.y )
end

function vec2:length()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

function vec2:lengthSquared()
  return self.x * self.x + self.y * self.y
end


function vec2:dist(v)
  local dx = self.x - v.x
  local dy = self.y - v.y
  
  return math.sqrt(dx * dx + dy * dy)
end

function vec2:dot(v)
  return self.x * v.x + self.y * v.y
end

function vec2:normal()
  local m = self:length()
  if m ~= 0 then
    return self / m
  else
	return self
  end
end

function vec2:limit(max)
  local m = self.lengthSquared()
  if m >= max * max then
    return self:normal() * max
  end
end

 function vec2:heading()
  local angle = math.atan2(-self.y, self.x)
  return -1 * angle
end

function vec2:rotate(theta)
  local tempx = self.x
  self.x = self.x * math.cos(theta) - self.y * math.sin(theta)
  self.y = tempx * math.sin(theta) + self.y * math.cos(theta)
end

function vec2:angle_between(v1, v2)
  if v1.x == 0 and v1.y then 
    return 0
  end
  
  if v2.x == 0 and v2.y == 0 then
    return 0
  end
  
  local dot = v1.x * v2.x + v1.y * v2.y 
  local v1mag = math.sqrt(v1.x * v1.x + v1.y * v1.y)
  local v2mag = math.sqrt(v2.x * v2.x + v2.y * v2.y)
  local amt = dot / (v1mag * v2mag)
  
  if amt <= -1 then
    return math.pi
  elseif amt >= 1 then
    return 0
  end
  
  return math.acos(amt)
end

function vec2:set(x, y)
  self.x = x
  self.y = y
end

function vec2:equals(o)
  o = o or {}
  return self.x == o.x and self.y == o.y
end

function vec2:__tostring()
  return '(' .. string.format( "%.2f", self.x ) .. ', ' .. string.format( "%.2f", self.y ) .. ')'
end

-- UTILITY

function randInRange( a, b )
	return lerp( a, b, math.random() )
end

function randomElement( tab )
	local n = #tab
	if n == 0 then return nil end

	return tab[ math.random( 1, #tab ) ]
end

function tableString( tab )
	local str = ''
	for key, value in pairs( tab ) do
		str = str .. key .. '=' .. value .. ', '
	end
	return str
end

function tableStringValues( tab )
	local str = ''
	for _, value in pairs( tab ) do
		str = str .. value .. ' '
	end
	return str
end

function tableFind( tab, element )
    for index, value in pairs(tab) do
        if value == element then
            return index
        end
	end
	return nil
end

function tableRemoveValue( tab, element )

	table.remove( tab, tableFind( tab, element ))
end
	
local debugCircles = {}
local debugMessages = {}

function drawDebugCircles()
	for _, circle in ipairs( debugCircles ) do
		circ( circle[1].x, circle[1].y, 32 )	-- TODO!!!
	end

	debugCircles = {}
end

function drawDebug()
	print( '', 0, 0 )

	-- print( tostring( mousex ) .. ',' .. tostring( mousey ) .. '::' .. tostring( placeableRoom ))
	-- print( tostring( world.focusX ) .. ',' .. tostring( world.focusY ))

	-- print( 'actors: ' .. tostring( #actors ), 0, 0 )
	-- print( 'plr: ' .. player.pos:__tostring() )

	-- TODO
	-- local count = 0
	-- for _, actor in ipairs( actors ) do
	-- 	if actor.config.name == 'tree_large' or actor.config.name == 'tree_small' then
	-- 		count = count + 1
	-- 	end
	-- end

	-- print( 'trees: ' .. tostring( count ), 0, 0 )

	for _,message in ipairs( debugMessages ) do
		print( message )
	end

	while #debugMessages > 10 do
		table.remove( debugMessages, 1 )
	end
end

function spriteIndex( x, y )
	return y * TILES_X + x
end

function worldToTile( x )
	return math.floor( x / PIXELS_PER_TILE )
end

function debugCircle( center, radius, color )
	table.insert( debugCircles, {center, radius, color })
end

function trace( message )
	table.insert( debugMessages, message )
end

function length( x, y )
	return math.sqrt( x * x + y * y )
end

function sign( x )
	return x < 0 and -1 or ( x > 0 and 1 or 0 )
end

function signNoZero( x )
	return x < 0 and -1 or 1
end

function clamp( x, minimum, maximum )
	return math.min( maximum, math.max( x, minimum ))
end

function pctChance( percent )
	return randInRange( 0, 100 ) <= percent
end

function round( x, divisor )
	divisor = divisor or 1
	return x // divisor * divisor
end

function quantize( x )
	return round( x + 4, PIXELS_PER_TILE )
end

function sheet_pixels_to_sprite( x, y )
	return ( y // PIXELS_PER_TILE ) * (SPRITE_SHEET_PIXELS_X//PIXELS_PER_TILE) + ( x // PIXELS_PER_TILE )
end

-- Objects

-- GLOBALS

desiredMaxActors = 800

actorUpdateMargin = PIXELS_PER_TILE * 3

actorDeleteMargin = actorUpdateMargin + PIXELS_PER_TILE * 3
actorSpawnInset = PIXELS_PER_TILE * 1

actorDrawMargin = PIXELS_PER_TILE

-- TIME

ticks = 0
function now()
	return ticks * 1 / 60.0
end

realTicks = 0
function realNow()
	return realTicks * 1 / 60.0
end

-- ACTORS

function isEnemyInRange( actor )
	local aiConfig = actor.config.ai

	if actor.enemy == nil then
		actor.enemy = player
	end

	if actor.enemy.health <= 0 then return false end

	local toEnemy = actor.enemy.pos - actor.pos
	local dist = toEnemy:length()

	return dist <= aiConfig.awarenessRadius
end

function actorMayPursueEnemy( actor )
	return isEnemyInRange( actor ) and not actorUntouchable( actor.enemy )
end

wanderPause = {
	name = 'wanderPause',
	start = function( actor )
	end,
	update = function( actor )
		if actorMayPursueEnemy( actor ) then
			actorPerformAction( actor, pursue )
		end
	end,
	finish = function( actor )
		actorPerformAction( actor, wander, randInRange( 2, 3 ) )
	end
}

wander = {
	name = 'wander',
	start = function( actor )
		actor.heading = vec2:new( 1, 0 )
		actor.heading:rotate( randInRange( 0.0, math.pi * 2.0 ))
	end,
	update = function( actor )
		actorControlThrust( actor, actor.heading:normal() * actor.config.maxThrust * 0.5 )
		if actorMayPursueEnemy( actor ) then
			actorPerformAction( actor, pursue )
		end
	end,
	finish = function( actor )
		actorPerformAction( actor, wanderPause, randInRange( 1, 2 ) )
	end
}

pursue = {
	name = 'pursue',
	start = function( actor )
		if actor.config.ai.alertSound ~= nil then
			sfx( actor.config.ai.alertSound )
		end
	end,
	update = function( actor )
		if actor.enemy == nil then
			actor.enemy = player
		end
		local toEnemy = actor.enemy.pos - actor.pos

		local toEnemyNorm = toEnemy:normal()
	
		actorControlThrust( actor, toEnemyNorm * actor.config.maxThrust )

		if not actorMayPursueEnemy( actor ) then
			actorPerformAction( actor, wanderPause, randInRange( 1, 1 ) )
		end
	end,
	finish = function( actor )
		actorPerformAction( actor, wanderPause, randInRange( 1, 3 ) )
	end
}

flee = {
	name = 'flee',
	start = function( actor )
	end,
	update = function( actor )
		if actor.enemy == nil then
			actor.enemy = player
		end
		local toEnemy = actor.enemy.pos - actor.pos

		local toEnemyNorm = toEnemy:normal()
	
		actorControlThrust( actor, toEnemyNorm * (actor.config.maxThrust * -0.35) )
	end,
	finish = function( actor )
		actorPerformAction( actor, wanderPause, randInRange( 1, 3 ) )
	end
}

local testConversation = {
	{ 	
		'this is message 1 line 1',
		'and now line 2!' 
	},
	{ 
		'this is message 2 line 1',
		'and now message 2 line 2!!',
		'and three!' 
	},
}

function createFrames( startX, startY, numFrames, deltaX )
	local frames = {}
	for i = 0, numFrames - 1 do
		table.insert( frames, spriteIndex( startX + i * deltaX, startY ))
	end
	return frames
end

local healthFlash = 0
local coinFlash = 0

function deleteActor( actor )
	tableRemoveValue( actors, actor )
end

local healthDrop = { config = 'healthPickup', chance = 20, tries = 2 }

actorConfigurations = {
	player = {
		dims = vec2:new( 10, 4 ),
		maxThrust = 2.52,
		drag = 0.60,
		ulOffset = vec2:new( 16, 29 ),
		tileSizeX = 2,
		tileSizeY = 2,
		flickerSpeed = 4.0,
		mayCollideWithTerrain = true,
		mayInitiateActorCollision = true,
		attackRadius = 12,
		maxHealth = 5,
		knockbackPower = 20,
		hurtTimeout = 2,
		damagedSound = 'ouch_01',
		animations = {
			idle = {
				speed = 0.1,
				frames = { 0, 0, 2, 2, 4, 6 }
			},
			idle_sword = {
				speed = 0.1,
				frames = { 64, 64, 66, 66, 68, 70 }
			},
			run = {
				speed = 0.2,
				frames = { 128, 128, 130, 130, 132, 134 }
			},
			run_sword = {
				speed = 0.2,
				frames = { 192, 192, 194, 194, 196, 198 }
			},
			attack = {
				speed = 0.4,
				frames = { 256, 256, 258, 258, 258, 260, 260, 260, 260 }
			},
			die = {
				speed = 0.1,
				frames = { 262, 262, 262, 264, 264, 266, 266, 266, 
					{ 	
						frame = 266, 
						event = function( actor )
							actor.animPlaying = false
						end 
					}
				}
			}
		},
		amendAnimName = function( self, animName )			
			if actorHas( self, 'sword' ) then
				animName = animName .. '_sword'
			end
			return animName
		end,
		onActorCollisionStart = function( self, other )
			if other.config.pickup ~= nil then
				
				if actorAge( other ) >= 0.6 then
				
					if other.config.pickup.onPickedUp ~= nil then
						if other.config.pickup.onPickedUp( other, self ) then
							return
						end
					end

					actorGain( self, other )

					if other.config.pickup.sound ~= nil then
						sfx( other.config.pickup.sound )
					end

					deleteActor( other )

				end

			elseif other.config.mob ~= nil and not other.config.inert then
				local normal = ( self.pos - other.pos ):normal()
				self.knockback = normal * other.config.knockbackPower
				other.knockback = normal * ( other.config.knockbackPower * -0.5 )

				healthFlash = 1.0

				chromatic_aberration_smoothed = 2.0
				
				local healthRemaining = ( self.health - 1 ) / self.config.maxHealth

				color_multiplied_g_smoothed = healthRemaining
				color_multiplied_b_smoothed = healthRemaining

				actorTakeDamage( self, 1 )
			elseif other.config.name == 'market' then
				onPlayerTouchedMarket( other )
			elseif other.config.name == 'husband_jail' then
				onPlayerTouchedJail( other )
			elseif other.config.name == 'husband_free' then
				onPlayerTouchedFreeHusband( other )
			elseif other.config.name == 'twins' then
				onPlayerTouchedTwins( other )
			elseif other.config.name == 'child' then
				onPlayerTouchedChild( other )
			end
		end
	},
	market = {
		dims = vec2:new( 40, 8 ),
		ulOffset = vec2:new( 26, 64 ),
		tileSizeX = 4,
		tileSizeY = 4,
		inert = true,
		fadeForPlayer = true,
		nonColliding = false,
		animations = {
			idle = {
				speed = 0.0,
				frames = { spriteIndex( 4, 28 ) }
			}
		},
	},
	shopkeeper = {
		dims = vec2:new( 30, 16 ),
		ulOffset = vec2:new( 16, 39 ),
		tileSizeX = 2,
		tileSizeY = 2,
		inert = true,
		fadeForPlayer = true,
		nonColliding = true,
		animations = {
			idle = {
				speed = 0.12,
				frames = { 8, 10, 8, 10, 8, 10, 8, 10, 8, 8, 8, 8, }
			}
		},
	},
	outhouse = {
		dims = vec2:new( 50, 61 ),
		ulOffset = vec2:new( 21, 64 ),
		tileSizeX = 4,
		tileSizeY = 4,
		inert = true,
		fadeForPlayer = true,
		nonColliding = false,
		animations = {
			idle = {
				speed = 0.0,
				frames = { spriteIndex( 8, 28 ) }
			}
		},
	},	
	house1 = {
		dims = vec2:new( 86, 89 ),
		ulOffset = vec2:new( 48, 91 ),
		tileSizeX = 6,
		tileSizeY = 6,
		inert = true,
		fadeForPlayer = true,
		nonColliding = false,
		animations = {
			idle = {
				speed = 0.0,
				frames = { spriteIndex( 12, 26 ) }
			}
		},
	},	
	house2 = {
		dims = vec2:new( 112, 96 ),
		ulOffset = vec2:new( 50, 96 ),
		tileSizeX = 8,
		tileSizeY = 6,
		inert = true,
		fadeForPlayer = true,
		nonColliding = false,
		animations = {
			idle = {
				speed = 0.0,
				frames = { spriteIndex( 18, 26 ) }
			}
		},
	},
	jail = {
		dims = vec2:new( 96, 100 ),
		ulOffset = vec2:new( 60, 105 ),
		tileSizeX = 9,
		tileSizeY = 7,
		inert = true,
		fadeForPlayer = true,
		nonColliding = false,
		animations = {
			idle = {
				speed = 0.0,
				frames = { spriteIndex( 23, 19 ) }
			}
		},
	},
	husband_jail = {
		dims = vec2:new( 24, 28 ),
		ulOffset = vec2:new( 20, 35 ),
		tileSizeX = 2,
		tileSizeY = 2,
		inert = true,
		fadeForPlayer = true,
		nonColliding = true,
		animations = {
			idle = {
				speed = 0.08,
				frames = { 16, 16, 16, 12, 14, 12 }
			}
		},
	},
	husband_free = {
		dims = vec2:new( 14, 31 ),
		ulOffset = vec2:new( 16, 32 ),
		tileSizeX = 2,
		tileSizeY = 2,
		inert = true,
		fadeForPlayer = true,
		nonColliding = true,
		animations = {
			idle = {
				speed = 0.2,
				frames = { 76 }
			}
		},
	},
	twins = {
		dims = vec2:new( 24, 24 ),
		ulOffset = vec2:new( 16, 30 ),
		tileSizeX = 2,
		tileSizeY = 2,
		inert = true,
		fadeForPlayer = true,
		nonColliding = true,
		animations = {
			idle = {
				speed = 0.1,
				frames = { 138, 140 }
			}
		},
	},
	child = {
		dims = vec2:new( 16, 26 ),
		ulOffset = vec2:new( 16, 30 ),
		tileSizeX = 2,
		tileSizeY = 2,
		inert = true,
		fadeForPlayer = true,
		nonColliding = true,
		animations = {
			idle = {
				speed = 0.08,
				frames = { 200, 202, 204 }
			}
		},
	},
	sword_blockage = {
		dims = vec2:new( 32, 64 ),
		ulOffset = vec2:new( 16, 64 ),
		tileSizeX = 2,
		tileSizeY = 4,
		inert = true,
		fadeForPlayer = false,
		nonColliding = false,
		damagedSound = 'ouch_00',
		animations = {
			idle = {
				speed = 0.0,
				frames = { spriteIndex( 10, 24 ) }
			}
		},
		mob = {
		},
		onTakeDamage = function( actor )
			setSwordBlockTilesBlocking( false )
			actor.health = 0
		end,
	},
	tree_large = {
		dims = vec2:new( 96, 96 ),
		ulOffset = vec2:new( 48, 87 ),
		tileSizeX = 6,
		tileSizeY = 6,
		inert = true,
		fadeForPlayer = true,
		nonColliding = true,
		animations = {
			idle = {
				speed = 0.0,
				frames = { spriteIndex( 0, 22 ) }
			}
		},
	},
	tree_small = {
		dims = vec2:new( 50, 44 ),
		ulOffset = vec2:new( 24, 58 ),
		tileSizeX = 4,
		tileSizeY = 4,
		inert = true,
		fadeForPlayer = true,
		nonColliding = true,
		animations = {
			idle = {
				speed = 0.0,
				frames = { spriteIndex( 6, 24 ) }
			}
		},
	},
	mushroom_red = {
		humanReadableName = 'Shroom',
		dims = vec2:new( 16, 16 ),
		ulOffset = vec2:new( 6, 11 ),
		iconOffsetY = -1,
		animations = {
			idle = {
				speed = 0.0,
				frames = { 92 }
			}
		},
		pickup = { invColor = 0xFFFF0000, sound = 'pickup_00' },
	},
	crystal = {
		humanReadableName = 'Gem',
		dims = vec2:new( 11, 13 ),
		ulOffset = vec2:new( 8, 13 ),
		iconOffsetY = -2,
		animations = {
			idle = {
				speed = 0.0,
				frames = { 29 }
			}
		},
		pickup = { invColor = 0xFFfff8ec, sound = 'pickup_00' },
	},
	wood = {
		humanReadableName = 'Wood',
		dims = vec2:new( 14, 13 ),
		ulOffset = vec2:new( 8, 11 ),
		iconOffsetY = -3,
		animations = {
			idle = {
				speed = 0.0,
				frames = { 125 }
			}
		},
		pickup = { invColor = 0xFFaf967e, sound = 'pickup_00' },
	},
	coin = {
		humanReadableName = 'Coin',
		dims = vec2:new( 6, 6 ),
		ulOffset = vec2:new( 8, 8 ),
		animations = {
			idle = {
				speed = 0.0,
				frames = { 30 }
			}
		},
		pickup = {
			onPickedUp = function( actor, by )
				by.coins = by.coins + 1
				coinFlash = 1
				return false
			end,
			sound = 'coin_00' 
		},
	},
	healthPickup = {
		humanReadableName = 'Health',
		dims = vec2:new( 12, 12 ),
		ulOffset = vec2:new( 8, 8 ),
		animations = {
			idle = {
				speed = 0.0,
				frames = { spriteIndex( 31, 3 ) }
			}
		},
		pickup = { 
			sound = 'pickup_01',
			onPickedUp = function( actor, by )
				if by.health >= by.config.maxHealth then
					healthFlash = 1.0
					return true
				end
				by.health = math.min( by.health + 1, by.config.maxHealth )
				return false
			end
		},
	},
	sword = {
		humanReadableName = 'Sword',
		dims = vec2:new( 16, 14 ),
		ulOffset = vec2:new( 8, 16 ),
		animations = {
			idle = {
				speed = 0.0,
				frames = { spriteIndex( 30, 1 ) }
			}
		},
		pickup = 
		{ 
			sound = 'powerup_00',
		},
	},
	slime = {
		dims = vec2:new( 11, 9 ),
		ulOffset = vec2:new( 17, 28 ),
		mayCollideWithTerrain = true,
		tileSizeX = 2,
		tileSizeY = 2,
		hurtTimeout = 1.5,
		knockbackPower = 10,
		maxHealth = 2,
		damagedSound = 'attack_00',
		animations = {
			idle = {
				speed = 0.0,
				frames = { 320 }
			},
			run = {
				speed = 0.1,
				velScalar = 0.2,
				frames = { 324, 324, 324, 320, 320, 322, 322, }
			},
		},
		mob = {
			drops = {
				{ config = 'slimeDrop', chance = 50, tries = 2 },
				healthDrop,
			}
		},
		ai = {
			initialAction = wander,
			awarenessRadius = 80,
			alertSound = 'alert_02',
		},
	},
	rat = {
		dims = vec2:new( 34, 15 ),
		ulOffset = vec2:new( 25, 28 ),
		mayCollideWithTerrain = true,
		tileSizeX = 4,
		tileSizeY = 2,
		hurtTimeout = 1,
		knockbackPower = 15,
		damagedSound = 'attack_00',
		animations = {
			idle = {
				speed = 0.0,
				frames = { 384 }
			},
			run = {
				speed = 0.1,
				velScalar = 0.2,
				frames = { 388, 388, 448, 384, 384, 384, }
			}
		},
		mob = {
			drops = {
				{ config = 'meat', chance = 80, tries = 1 },
				healthDrop,
			}
		},
		ai = {
			initialAction = wander,
			awarenessRadius = 80,
			alertSound = 'alert_00',
		},
	},
	deathCloud = {
		dims = vec2:new( 0, 0 ),
		ulOffset = vec2:new( 16, 16 ),
		tileSizeX = 2,
		tileSizeY = 2,
		animations = {
			idle = {
				speed = 0.2,
				frames = { 72, 74, 74, 136, 136, 136,
					{ frame = 136, event = deleteActor }
				},
			}
		},
	},
	slimeDrop = {
		humanReadableName = 'Slime',
		dims = vec2:new( 16, 12 ),
		ulOffset = vec2:new( 8, 6 ),
		iconOffsetY = -1,
		animations = {
			idle = {
				speed = 0,
				frames = { spriteIndex( 28, 1 ) }
			},
		},
		pickup = 
		{
			invColor = 0XFF78cb3f, 
			sound = 'pickup_00',
		},
	},
	meat = {
		humanReadableName = 'Meat',
		dims = vec2:new( 20, 16 ),
		ulOffset = vec2:new( 10, 14 ),
		iconOffsetY = -4,
		animations = {
			idle = {
				speed = 0,
				frames = { spriteIndex( 29, 1 ) }
			},
		},
		pickup = 
		{ 
			invColor = 0xFFff9585,
			sound = 'pickup_00',
		},
	},
	rock_pile = {
		dims = vec2:new( 29, 24 ),
		ulOffset = vec2:new( 16, 29 ),
		tileSizeX = 2,
		tileSizeY = 2,
		inert = true,
		maxHealth = 1,
		damagedSound = 'ouch_02',
		animations = {
			idle = {
				speed = 0.0,
				frames = { spriteIndex( 6, 22 ) }
			}
		},
		mob = {
			drops = {
				{ config = 'coin', chance = 20, tries = 4 },
				{ config = 'healthPickup', chance = 10, tries = 1 },
			}
		},
	},
	sticks_pile = {
		dims = vec2:new( 30, 24 ),
		ulOffset = vec2:new( 16, 29 ),
		tileSizeX = 2,
		tileSizeY = 2,
		inert = true,
		maxHealth = 1,
		damagedSound = 'ouch_00',
		animations = {
			idle = {
				speed = 0.0,
				frames = { spriteIndex( 8, 22 ) }
			}
		},
		mob = {
			drops = {
				{ config = 'wood', chance = 30, tries = 3 },
				{ config = 'coin', chance = 10, tries = 3 },
				{ config = 'healthPickup', chance = 10, tries = 2 },
				{ config = 'slime', chance = 10, tries = 1 },
			}
		},
	},
}

function fixupConfig( config, name )
	config.tileSizeX = config.tileSizeX or 1
	config.tileSizeY = config.tileSizeY or 1
	config.drag = config.drag or 0.3
	config.maxThrust = config.maxThrust or 0.35
	config.flickerSpeed = config.flickerSpeed or 10.0
end

function fixupConfigs()

	for key, config in pairs( actorConfigurations ) do
		config.name = key
		fixupConfig( config )
	end

end

fixupConfigs()

function createActor( configKey, x, y )
	local config = actorConfigurations[ configKey ]
	assert( config )

	local actor = {
		birthdate = now(),
		config = config,
		pos = vec2:new( x, y ),
		lastPos = vec2:new( x, y ),
		vel = vec2:new( 0, 0 ),
		heading = vec2:new( -1, 0 ),
		knockback = vec2:new( 0, 0 ),
		knockbackDrag = 0.25,
		hurtTimeoutEnd = nil,
		animFrame = 0,
		lastFrame = 0,
		flickerColor = 0xFFFFFFFF,
		occlusionOpacity = 1.0,
		occluding = false,
		hurtColor = 0,
		mayCollideWithTerrain = config.mayCollideWithTerrain,
		inventory = {},
		attacking = false,
		action = nil,
		actionEndTime = nil,
		health = config.maxHealth or 3,
		animPlaying = true,
		lastAnimation = nil,
		collidingActors = {},
	}

	table.insert( actors, actor )

	if actor.config.ai ~= nil and actor.config.ai.initialAction ~= nil then
		actorPerformAction( actor, actor.config.ai.initialAction, randInRange( 1, 1 ))
	end

	return actor
end

function actorAge( actor )
	return now() - actor.birthdate
end

function createItemDrop( actor, drop )
	if drop.chance ~= nil then
		if not pctChance( drop.chance ) then
			return
		end
	end
	local item = createActor( drop.config, actor.pos.x, actor.pos.y )
	
	item.vel = vec2:new( randInRange( 6, 12 ), 0 )
	item.vel:rotate( randInRange( 0.0, math.pi * 2.0 ))
end

function actorDie( actor )

	if actor == player then
		playerDie()
		return
	end

	-- item drops
	if actor.config.mob ~= nil and actor.config.mob.drops ~= nil then
		for _, drop in ipairs(actor.config.mob.drops) do
			local count = drop.tries or 1
			for i = 1, count do
				createItemDrop( actor, drop )
			end
		end
	end

	-- puff of smoke
	local cloud = createActor( 'deathCloud', actor.pos.x, actor.pos.y )

	deleteActor( actor )
end

function playerDie()
	player.health = 0

	sfx( 'death_00' )

	-- start death screen

	startConversation({
		{ 	
			'YOU HAVE DIED',
			'',
			'You started with nothing,',
			'you come back with',
			'half your $$.'
		},	
		{ 	
			'Try Again!',
			"You'll win this time.",
			'',
			'(Press X)',
		},
	}, 
	false,
	function()
		startGame()
	end)
end

function actorPerformAction( actor, action, duration )
	-- not an ai character?
	if actor.config.ai == nil then return end

	if actor.action == action then return end

	if actor.action ~= nil then
		-- aborting action. no current need for response.
	end

	actor.action = action
	actor.actionEndTime = ( duration ~= nil ) and ( now() + duration ) or nil

	if actor.action ~= nil and actor.action.start ~= nil then
		actor.action.start( actor )
	end
end

function actorUpdateActions( actor )
	if actor.actionEndTime ~= nil and now() > actor.actionEndTime then
		local finishingAction = actor.action

		actor.action = nil
		actor.actionEndTime = nil

		if finishingAction and finishingAction.finish ~= nil then
			finishingAction.finish( actor )
		end
	end

	if actor.action ~= nil and actor.action.update ~= nil then
		-- trace( 'updating action ' .. actor.action.name )
		actor.action.update( actor )
	end
end

function speed( actor )
	return actor.vel:length()
end

function onFrameChanged( actor )
	local animation = currentAnimation( actor )
	if animation ~= nil then
		
		-- call event if it's there.

		local frames = animation.frames
		local frameIndex = math.floor( actor.animFrame ) % #frames
		local frame = frames[ frameIndex + 1 ]

		if type( frame ) == 'table' then
			if frame.event ~= nil then
				frame.event( actor )
			end
		end
	end
end

function actorSetFrame( actor, frame )
	actor.animFrame = frame

	if math.floor( actor.animFrame ) ~= math.floor( actor.lastFrame ) then
		onFrameChanged( actor )
		actor.lastFrame = actor.animFrame
	end
end

function actorCollisionRadius( actor )
	return math.max( actor.config.dims.x, actor.config.dims.y )
end

function actorAttack( actor )

	if actorHas( actor, 'sword' ) then
		sfx( 'hit_swing_04', 0.2 )
		actor.attacking = true
		actorSetFrame( actor, 0 )
	end
end

function actorsInCircle( center, radius )

	local results = {}
	for _, actor in ipairs(actors) do
		if ( actor.pos - center ):length() - actorCollisionRadius( actor ) <= radius then
			table.insert( results, actor )
		end
	end
	return results
end

function maybeHurtVictim( attacker, victim )

	if victim.config.mob ~= nil and not actorUntouchable( victim ) then
		actorTakeDamage( victim, 1 )

		victim.knockback = ( victim.pos - attacker.pos ):normal() * attacker.config.knockbackPower
	end
end

function updateAttack( actor )
	local attackAnim = actor.config.animations.attack
	if attackAnim == nil then
		actor.attacking = false
		return
	end

	if not actor.attacking then return end

	local frames = attackAnim.frames
	if actor.animFrame >= #frames then
		actor.attacking = false
		return
	end

	-- hurting others?

	if actor.animFrame >= 0 and actor.animFrame < 4 then
		local victims = actorsInCircle( actor.pos - vec2:new( 0, 8 ), actor.config.attackRadius )
	
		for _, victim in ipairs( victims ) do
			if victim ~= actor then
				maybeHurtVictim( actor, victim )
			end
		end
	end 
end

function actorHas( actor, itemName )
	return actor.inventory[ itemName ] ~= nil and actor.inventory[ itemName ] > 0
end

function actorGain( actor, item )
	local itemName = item.config.name
	if actor.inventory[ itemName ] == nil then
		actor.inventory[ itemName ] = 0
	end
	actor.inventory[ itemName ] = clampCommodity( actor.inventory[ itemName ] + 1 )
end

function effectiveVelocity( actor )
	return actor.pos - actor.lastPos
end

function currentAnimation( actor )
	local animations = actor.config.animations
	
	if animations == nil then return nil end

	if actor.health <= 0 and animations.die ~= nil then
		return animations.die
	end

	if actor.attacking and animations.attack ~= nil then
		return animations.attack
	end

	local anim = ( math.abs( speed( actor )) > 0.1 ) and 'run' or 'idle'
	if anim == 'run' and animations.run == nil then
		anim = 'idle'
	end

	if actor.config.amendAnimName ~= nil then
		anim = actor.config.amendAnimName( actor, anim )
	end

	return animations[ anim ]
end

function actorBounds( actor )
	local foot = actor.pos

	return {
		left = foot.x - actor.config.dims.x / 2,
		top = foot.y - actor.config.dims.y,
		right = foot.x + actor.config.dims.x / 2,
		bottom = foot.y,
	}
end

function actorVisualBounds( actor )
	local ul = actor.pos - actor.config.ulOffset

	local wid = actor.config.tileSizeX * PIXELS_PER_TILE
	local hgt = actor.config.tileSizeY * PIXELS_PER_TILE

	return {
		left = ul.x,
		top = ul.y,
		right = ul.x + wid,
		bottom = ul.y + hgt,
	}
end

function onPlayerTouchedMarket( market )
	startMarket( market.market )
end

GOAL_AMOUNT = 100

function onPlayerSpringsHusband( husband )
	sfx( 'powerup_00' )
	createActor( 'husband_free', husband.pos.x + 32, husband.pos.y + 16 )

	deleteActor( husband )
end

restartGameTime = nil

function endGame()
	-- pause game
	restartGameTime = realNow() + 2

	color_multiplied_r = 0
	color_multiplied_g = 0
	color_multiplied_b = 0
end

function onPlayerTouchedFreeHusband( husband )
	startConversation( {
		{
			"Honey! YOU'RE AMAZING!",
			"",
			"You earned all that money",
			"and paid off our debts!",
		},
		{
			"Now we'll be happy again.",
			"",
			"You STARTED FROM NOTHING,",
			"but now we have EVERYTHING!",
		},
		{
			"Let's go home.",
			"",
			"(Score: " .. player.coins .. ")",
			"",
			"(Press X)",
		},
	},
	nil,
	function()		-- finish game
		endGame()
	end,
	'family0',
	'talk_husband' )
end

function onPlayerTouchedJail( husband )

	if player.coins >= GOAL_AMOUNT then
		onPlayerSpringsHusband( husband )
		return
	end

	local jailConversation = {
		{
			"Honey!",
			"We're ruined!",
		},
		{
			"Old Man Snuckers ran off with",
			"all our money.",
			"",
			"We're broke!",
		},
		{
			"They've thrown me in",
			"debtor's prison!",
			"",
			"Our kids will starve.",
		},
		{
			"If you can earn $" .. GOAL_AMOUNT,
			"we could pay off our debts,",
			"",
			"We'd be happy again.",
		},
		{
			"BUY LOW and SELL HIGH!",
			"Some towns pay more for",
			"items you can get for cheap",
			"in other towns.",
			"",
			"GEMS especially!",
		},
		{
			"We're STARTING FROM NOTHING.",
			"",
			"Please rescue us!",
			'',
			"(Press X)",
		},
	}
	startConversation( jailConversation, nil, nil, 'family0', 'talk_husband' )
end

function onPlayerTouchedTwins( actor )
	local troubleConversation = {
		randomElement( {
			{
				"We're hungry, Mommy.",
				"",
				"When will Daddy come home?"
			},
			{
				"We're too tired to play.",
				"",
				"When will Daddy come home?"
			},
			{
				"Why did they take",
				"all our toys?",
				"",
				"It's lonely now."
			},
			{
				"Can people eat leaves, Mommy?",
				"",
				"We're hungry."
			},
			{
				"Don't cry anymore, Mommy.",
				"",
				"We'll take care of you."
			},
		})
	}

	local winConversation = {
		{
			"Yay!",
			"",
			"We knew you'd save us!",
		}
	}

	if player.coins >= GOAL_AMOUNT then
		startConversation( winConversation, nil, nil, 'family0', 'talk_twins' )
	else
		startConversation( troubleConversation, nil, nil, 'family0', 'talk_twins' )
	end
end

function onPlayerTouchedChild( actor )
	local troubleConversation = {
		randomElement( {
			{
				"Hi Mom!",
				"",
				"The other day I saw a sword",
				"not far from here."
			},
			{
				"Hi Mom!",
				"",
				"You can sell things you find",
				"at the market."
			},
			{
				"Hi Mom!",
				"",
				"I hear prices are higher",
				"in other towns.",
			},
			{
				"Hi Mom!",
				"",
				"I hear you can break rocks",
				"to find Gems.",
			},
			{
				"Hi Mom!",
				"",
				"Watch out for monsters",
				"along the paths!",
			},
		})
	}

	local winConversation = {
		{
			"Great job, Mom!",
			"",
			"Now Dad can come home!",
			"",
			"We won't have to starve!"
		}
	}
	
	if player.coins >= GOAL_AMOUNT then
		startConversation( winConversation, nil, nil, 'family0', 'talk_boyo' )
	else
		startConversation( troubleConversation, nil, nil, 'family0', 'talk_boyo' )
	end
end

function collideActorWithTile( actor, tileX, tileY )
	local bounds = actorBounds( actor )

	-- trace( actorFoot( actor ).x .. ' ' .. actorFoot( actor ).y .. ' ' .. bounds.left .. ' ' .. bounds.top .. ' ' .. bounds.right .. ' ' .. bounds.bottom )

	local tileSprite = mget( tileX, tileY )

	local tileCollides = fget( tileSprite, 1 ) ~= 0

	if tileCollides then

		local vel = effectiveVelocity( actor )

		local colliding, normalX, normalY, hitAxis, adjustmentDistance = rect_collision_adjustment( 
			bounds.left, bounds.top, bounds.right, bounds.bottom, 
			tileX * PIXELS_PER_TILE, tileY * PIXELS_PER_TILE, ( tileX + 1 ) * PIXELS_PER_TILE, ( tileY + 1 ) * PIXELS_PER_TILE,
			vel.x, vel.y )

		if colliding then
			local adjustment = vec2:new( normalX * adjustmentDistance, normalY * adjustmentDistance )
			actor.pos = actor.pos + adjustment
			if( hitAxis == 0 ) then
				actor.vel.x = 0
			else
				actor.vel.y = 0
			end
		end

		return colliding
	end
	return false
end

function collideActorWithTerrain( actor )
	if actor.config.nonColliding then return end

	local bounds = actorBounds( actor )

	local startX = worldToTile( bounds.left )
	local endX = worldToTile( bounds.right )
	local startY = worldToTile( bounds.top )
	local endY = worldToTile( bounds.bottom )

	local vel = effectiveVelocity( actor )

	local stepX = signNoZero( vel.x )
	local stepY = signNoZero( vel.y )

	if stepX < 0 then
		startX, endX = endX, startX
	end

	if stepY < 0 then
		startY, endY = endY, startY
	end

	for y = startY, endY, stepY do
		for x = startX, endX, stepX do
			collided = collideActorWithTile( actor, x, y )
			if collided then return true end
		end
	end

	return false
end

function actorTakeDamage( actor, amount )
	if actor.health <= 0 then return end

	if actorUntouchable( actor ) then return end

	if actor.config.damagedSound ~= nil then
		sfx( actor.config.damagedSound )
	end

	if actor.config.damagedSound ~= nil then
		sfx( actor.config.damagedSound )
	end

	if actor.config.onTakeDamage ~= nil then
		actor.config.onTakeDamage( actor )
	end

	actor.hurtColor = 1.0

	actor.health = actor.health - ( amount or 1 )

	-- trace( 'mob hurt now health ' .. actor.health )

	if actor.health <= 0 then
		actorDie( actor )
	else
		if actor.config.hurtTimeout ~= nil then
			actor.hurtTimeoutEnd = now() + actor.config.hurtTimeout
		end

		-- actorPerformAction( actor, flee, actor.config.hurtTimeout or 2.0 )
	end
end

function actorMayCollideWith( actor, other )
	if actor ~= player then return false end		 -- TODO prohibits actors colliding with actors
	if actor.config.nonColliding then return false end

	if other.config.mob ~= nil then
		if other.config.mob.isFriendly then return false end
		return actor.health > 0 and not actorUntouchable( actor ) and not actorUntouchable( other )
	end

	return true
end

function actorUntouchable( actor )
	return actor.hurtTimeoutEnd ~= nil and now() <= actor.hurtTimeoutEnd
end

function actorColor( actor )
	return actor.flickerColor or 0xFFFFFFFF
end

function colorMultiplyComponents( argb, alpha )

	local terms = {
		a = (( argb & 0xFF000000 ) >> 24 ) / 255.0,
		r = (( argb & 0x00FF0000 ) >> 16 ) / 255.0,
		g = (( argb & 0x0000FF00 ) >> 8 ) / 255.0,
		b = (( argb & 0x000000FF ) ) / 255.0,
	}

	for key, term in pairs( terms ) do
		terms[ key ] = math.floor( term * alpha * 0xFF )
	end

	return ( terms.a << 24 ) | ( terms.r << 16 ) | ( terms.g << 8 ) | terms.b
end

function floatTermToColor( term )
	local component = math.floor( lerp( 0, 0xFF, term ))
	return ( 0xFF << 24 ) | ( component << 16 ) | ( component << 8 ) | component
end

function actorAdditiveColor( actor )
	return floatTermToColor( actor.hurtColor )
end

function updateAnimation( actor )

	if not actor.animPlaying then return end

	local animation = currentAnimation( actor )
	if animation ~= nil then
		local frameStep = animation.speed
		if animation.velScalar ~= nil then
			frameStep = animation.speed + animation.velScalar * speed( actor )
		end
		actorSetFrame( actor, actor.animFrame + frameStep )
	end	

	if animation ~= actor.lastAnimation then
		actor.lastAnimation = animation
		if not animation.keepFrame then
			actor.animFrame = 0
		end
	end
end

function updateActor( actor )

	if not actor.config.inert then
		actorUpdateActions( actor )

		if actorUntouchable( actor ) then
			actor.flickerColor = math.sin( now() * math.pi * 2.0 * (actor.config.flickerSpeed or 4.0 ) ) >= 0 and 0xFFFFFFFF or 0
		else
			actor.flickerColor = 0xFFFFFFFF
		end

		actor.hurtColor = lerp( actor.hurtColor, 0, 0.1 )

		actor.lastPos:set( actor.pos.x, actor.pos.y )

		if actor.drag == nil then actor.drag = actor.config.drag end

		actor.vel = actor.vel - actor.vel * actor.drag
		actor.knockback = actor.knockback - actor.knockback * actor.knockbackDrag
		actor.pos = actor.pos + actor.vel + actor.knockback

		if actor.mayCollideWithTerrain then
			for i = 1, 4 do
				local collided = collideActorWithTerrain( actor )
				if not collided then break end
			end
		end
	end

	updateAnimation( actor )

	if not actor.config.inert then
		updateAttack( actor )
	end
end

function frameSpriteIndex( frame )
	return ( type( frame ) == 'table' and frame.frame ) or frame
end

function actorOccludesPlayer( actor )
	if player.pos.y > actor.pos.y then return false end

	local myBounds = actorBounds( actor )
	local playerBounds = expandContractRect( actorBounds( player ), 16 )

	return rectsOverlap( myBounds, playerBounds )
end

function drawActor( actor )
	local animation = currentAnimation( actor )
	if animation == nil then return end

	local frames = animation.frames

	local cur_frame = math.floor( actor.animFrame ) % #frames

	local sprite = frameSpriteIndex( frames[ cur_frame + 1 ] )

	spr( sprite, 
		round( actor.pos.x - actor.config.ulOffset.x ), 
		round( actor.pos.y - actor.config.ulOffset.y ), 
		actor.config.tileSizeX, 
		actor.config.tileSizeY, 
		actor.vel.x > 0,
		false,
		colorMultiplyComponents( actorColor( actor ), actor.occlusionOpacity ),
		actorAdditiveColor( actor )
	)
end

function rectsOverlap( rectA, rectB )
	return not ( rectB.right < rectA.left or rectB.left > rectA.right or rectB.bottom < rectA.top or rectB.top > rectA.bottom )
end

function rectOverlapsPoint( rect, pos )
	return rect.left <= pos.x and pos.x <= rect.right and rect.top <= pos.y and pos.y <= rect.bottom
end

function expandContractRect( rect, expansion )
	rect.left = rect.left - expansion
	rect.top = rect.top - expansion
	rect.right = rect.right + expansion
	rect.bottom = rect.bottom + expansion
	return rect
end


function actorOnCollide( actor, other )

	-- add to colliding actors if it's not there already
	if actor.collidingActors[ other ] == nil then
		actor.collidingActors[ other ] = true
		if actor.config.onActorCollisionStart ~= nil then
			actor.config.onActorCollisionStart( actor, other )
		end
	end

	-- call the continual callback
	if actor.config.onActorCollide ~= nil then
		actor.config.onActorCollide( actor, other )
	end
end

function actOnNotCollide( actor, other )
	if actor.collidingActors[ other ] ~= nil then
		actor.collidingActors[ other ] = nil
		if actor.config.onActorCollisionEnd ~= nil then
			actor.config.onActorCollisionEnd( actor, other )
		end
	end
end

function collideActorPair( actorA, actorB )
	if not( actorMayCollideWith( actorA, actorB ) or actorMayCollideWith( actorB, actorA ) ) then
		return 
	end

	local boundsA = actorBounds( actorA )
	local boundsB = actorBounds( actorB )

	-- trace( boundsA.left .. ' ' .. boundsA.right .. ' ' .. boundsB.left .. ' ' .. boundsB.right )

	if rectsOverlap( boundsA, boundsB ) then
		actorOnCollide( actorA, actorB )
		actorOnCollide( actorB, actorA )
	else
		actOnNotCollide( actorA, actorB )
		actOnNotCollide( actorB, actorA )
	end
end

function collideActors()

	for i, actor in ipairs( actors ) do
		if actor ~= player then
			if player.config.mayInitiateActorCollision or actor.config.mayInitiateActorCollision then
				collideActorPair( player, actor )
			end
		end
	end
end

function deleteOutOfBoundsActors()
	local bounds = deleteActorBounds()

	for _, actor in ipairs( actors ) do
		if not actor.surviveOutOfBounds and not rectOverlapsPoint( bounds, actor.pos ) then
			deleteActor( actor )
		end
	end
end

function worldBoundsToTerrainBounds( bounds )
	local tileBounds = {
		left = 		worldToTile( bounds.left ),
		top = 		worldToTile( bounds.top ),
		right = 	worldToTile( bounds.right ),
		bottom = 	worldToTile( bounds.bottom ),
	}
	return tileBounds
end

function populateForMapCell( x, y )

	local here = vec2:new( x, y )
	local distFromHome = homeTown.pos:dist( player.pos )
	local locationScalar = distFromHome / ( 128 * PIXELS_PER_TILE )
	local wealthScalar = player.coins / GOAL_AMOUNT * 0.75
	local difficultyScalar = clamp(( locationScalar + wealthScalar ) / 2, 0.0, 1.0 )
	local overallScalar = 1.0

	local ratChance = overallScalar * lerp( 0.1, 2, difficultyScalar )
	local slimeChance = overallScalar * lerp( 0.25, 3, difficultyScalar )

	local mushroomDrop = { config = 'mushroom_red', chance = 0.125, tries = 2 }
	local woodDrop = { config = 'wood', chance = 0.1, tries = 1 }
	local rockDrop = { config = 'rock_pile', chance = 0.1, tries = 1 }
	local sticksDrop = { config = 'sticks_pile', chance = 0.4, tries = 1 }
	local vergeSpawn = { mushroomDrop, woodDrop, rockDrop }
	local leavesSpawn = {
		{ config = 'slime', chance = slimeChance, tries = 1 },
		{ config = 'rat', chance = ratChance, tries = 1 },
		{ config = 'coin', chance = 0.05, tries = 1 },
		{ config = 'healthPickup', chance = 0.01, tries = 1 },
		rockDrop,		
		sticksDrop,
	}

	local mapSpriteSpawns = {
		[spriteIndex(27,27)] = { 	-- forest
			{ config = 'tree_large', chance = 10, tries = 1 },
			{ config = 'tree_small', chance = 30, tries = 1 },		
		},
		[spriteIndex(30,27)] = leavesSpawn,
		[spriteIndex(30,30)] = leavesSpawn,
		[spriteIndex(27,30)] = { 	-- path
			rockDrop,
		},
		[spriteIndex(26,26)] = vergeSpawn,
		[spriteIndex(27,26)] = vergeSpawn,
		[spriteIndex(28,26)] = vergeSpawn,
		[spriteIndex(26,27)] = vergeSpawn,
		[spriteIndex(28,27)] = vergeSpawn,
		[spriteIndex(26,28)] = vergeSpawn,
		[spriteIndex(27,28)] = vergeSpawn,
		[spriteIndex(28,28)] = vergeSpawn,
		[spriteIndex(26,29)] = vergeSpawn,
		[spriteIndex(27,29)] = vergeSpawn,
		[spriteIndex(28,29)] = vergeSpawn,
		[spriteIndex(26,30)] = vergeSpawn,
		[spriteIndex(28,30)] = vergeSpawn,
		[spriteIndex(26,31)] = vergeSpawn,
		[spriteIndex(27,31)] = vergeSpawn,
		[spriteIndex(28,31)] = vergeSpawn,
	} 

	local mapSprite = mget( x, y )
	
	if mapSpriteSpawns[ mapSprite ] ~= nil then
		local spawns = mapSpriteSpawns[ mapSprite ]
		for _, spawn in ipairs( spawns ) do
			local tries = spawn.tries or 1
			for i = 1, tries do

				local chance = spawn.chance

				if pctChance( chance ) then

					if #actors >= desiredMaxActors then return end

					local point = vec2:new( 
						randInRange( x * PIXELS_PER_TILE, (x+1) * PIXELS_PER_TILE ), 
						randInRange( y * PIXELS_PER_TILE, (y+1) * PIXELS_PER_TILE )
					)

					local configName = spawn.config

					-- don't spawn mobs in town
					local config = actorConfigurations[ configName ]

					if config.mob == nil or not isInTown( point ) then
						createActor( configName, point.x, point.y )
					end
				end
			end
		end
	end	
end


local viewLeft = 0
local viewTop = 0
function setWorldView( x, y )
	x = clamp( x, 0, WORLD_SIZE_PIXELS - screen_wid() )
	y = clamp( y, 0, WORLD_SIZE_PIXELS - screen_hgt() )

	viewLeft = round( x, 1.0 )
	viewTop = round( y, 1.0 )
	camera( viewLeft, viewTop )
end

function viewBounds()
	return {
		left = viewLeft,
		top = viewTop,
		right = viewLeft + screen_wid(),
		bottom = viewTop + screen_hgt(),
	}
end

function actorUpdateBounds()
	local bounds = viewBounds()
	expandContractRect( bounds, actorUpdateMargin )
	return bounds
end

function deleteActorBounds()
	local bounds = viewBounds()
	expandContractRect( bounds, actorDeleteMargin )
	return bounds
end

function spawnActorBounds()
	local bounds = deleteActorBounds()
	expandContractRect( bounds, -actorSpawnInset )
	return bounds
end

function actorDrawBounds()
	local bounds = viewBounds()
	expandContractRect( bounds, actorDrawMargin )
	return bounds
end

local lastPopulatingLocation = nil

function spawnPopulatingActors( fill )
	local bounds = spawnActorBounds()
	local terrainBounds = worldBoundsToTerrainBounds( bounds )

	local location = vec2:new( terrainBounds.left, terrainBounds.top )

	if lastPopulatingLocation ~= nil and lastPopulatingLocation:equals( location ) then return end
	
	local delta = lastPopulatingLocation ~= nil and location - lastPopulatingLocation or vec2:new( 0, 0 )
	lastPopulatingLocation = location

	if fill then
		for y = terrainBounds.top, terrainBounds.bottom do
			for x = terrainBounds.left, terrainBounds.right do
				populateForMapCell( x, y )
			end
		end
	else
		for x = terrainBounds.left, terrainBounds.right do
			populateForMapCell( x, delta.y > 0 and terrainBounds.bottom or terrainBounds.top )
		end

		for y = terrainBounds.top, terrainBounds.bottom do
			populateForMapCell( delta.x > 0 and terrainBounds.right or terrainBounds.left, y )
		end
	end
end

function updateActors()
	deleteOutOfBoundsActors()

	spawnPopulatingActors()

	local bounds = actorUpdateBounds()

	for _, actor in ipairs( actors ) do
		if actor == player or rectOverlapsPoint( bounds, actor.pos ) then
			updateActor( actor )
		end
	end

	collideActors()

	-- clamp the player to the world
	player.pos.x = clamp( player.pos.x, 16, WORLD_SIZE_PIXELS - 16 )
	player.pos.y = clamp( player.pos.y, 16, WORLD_SIZE_PIXELS - 16 )
end

function drawActors()
	local bounds = actorDrawBounds()

	-- only draw actors in bounds.
	local drawnActors = {}

	for _, actor in ipairs( actors ) do
		if rectsOverlap( bounds, actorVisualBounds( actor ) ) then
			table.insert( drawnActors, actor )
		end
	end

	table.sort( drawnActors, function( a, b )
		return a.pos.y < b.pos.y
	end )

	-- count occluders
	local numOccludingActors = 0
	for _, actor in ipairs( drawnActors ) do
		actor.occluding = actor.config.fadeForPlayer and actorOccludesPlayer( actor )
		if actor.occluding then
			numOccludingActors = numOccludingActors + 1
		end
	end

	local targetOpacity = numOccludingActors > 0 and ( 0.5 / ( numOccludingActors ^ (1/2) )) or 1.0

	-- trace( numOccludingActors .. ' ' .. targetOpacity )

	for _, actor in ipairs( drawnActors ) do
		local actorOpacity = actor.occluding and targetOpacity or 1.0
		actor.occlusionOpacity = lerp( actor.occlusionOpacity, actorOpacity, 0.2 )

		drawActor( actor )
	end

end

-- CONVERSATION SYSTEM

MAX_CONVERSATION_HEIGHT = 110
conversationHeight = 0
TEXT_SPEED = 0.6

local currentConversation = nil
local currentConversationMusic = nil
local pauseInConversation = nil
local conversationCallback = nil
local messageIndex = 1
local messageLineIndex = 1
local messageCharIndex = 1

function startConversation( conversation, pauseGame, onFinished, musicName, soundName )
	currentConversation = conversation
	
	if pauseGame ~= nil and pauseGame == false then
		pauseInConversation = false
	else
		pauseInConversation = true
	end

	currentConversationMusic = musicName
	if currentConversationMusic ~= nil then
		music( currentConversationMusic, 0.5 )
	end

	conversationTypeSound = soundName or 'talk_lady'

	conversationCallback = onFinished
	messageIndex = 1
	messageLineIndex = 1
	messageCharIndex = 1

	if #conversation == 0 then
		conversation = { '...' }
	end
end

function endConversation()
	currentConversation = nil
	pauseInConversation = nil
	conversationTypeSound = nil

	if currentConversationMusic ~= nil then
		-- restore wild music
		music( 'wilds', 0.25 )
	end
	currentConversationMusic = nil

	if conversationCallback ~= nil then
		conversationCallback()
		conversationCallback = nil
	end
end

function conversationNextMessage()
	messageIndex = messageIndex + 1
	messageLineIndex = 1
	messageCharIndex = 1

	if messageIndex > #currentConversation then
		endConversation()
	end
end

function updateConversationInput()
	local message = currentMessage()

	if isMarketMessage( message ) then
		updateMarketInput( message )
		return
	end

	if isMessageComplete() and ( btnp( 4 ) or btnp( 5 )) then
		conversationNextMessage()
	end
end

function currentMessage()
	return currentConversation[ messageIndex ]
end

function currentLine()
	return currentMessage()[ messageLineIndex ]
end

function isMessageComplete()
	if messageIndex > #currentConversation then return true end

	local message = currentMessage()

	if messageLineIndex > #message then return true end

	local currentLine = message[ messageLineIndex ]

	return messageLineIndex == #message and math.floor( messageCharIndex ) >= #currentLine
end

function updateConversation()
	if not isMessageComplete() then
		local lastCharInt = math.floor( messageCharIndex )
		messageCharIndex = messageCharIndex + TEXT_SPEED * ( (btn( 4 ) or btn( 5 )) and 4.0 or 1.0 )

		if conversationTypeSound ~= nil and (lastCharInt % 3 == 0) and lastCharInt < math.floor( messageCharIndex ) then
			sfx( conversationTypeSound, 0.5 )
		end			

		local line = currentLine()

		if math.floor( messageCharIndex ) > #line then
			messageLineIndex = messageLineIndex + 1
			messageCharIndex = 1
		end
	end

	updateConversationInput()
end

function drawConversation()
	camera( 0, -( screen_hgt() - conversationHeight ))
	rectfill( 0, 0, screen_wid(), screen_hgt(), 0xFF202020 )

	if currentConversation == nil then
		return
	end

	local message = currentMessage()

	if isMarketMessage( message ) then
		drawMarket( message )
		return
	end

	-- Vertical and horizontal centering

	local maxLines = 8
	local maxWidth = ( screen_wid() - 8 ) / 8

	local numLines = #message
	local topLineOffset = (maxLines - numLines) * 8

	print( '', 4, -4 + topLineOffset )

	local talkFont = 0

	function drawLine( text, line )
		local lineLen = #line
		local offsetX = 4 + 8 * ( maxWidth - lineLen ) / 2

		print( text, offsetX, nil, nil, talkFont )
	end

	for index, line in ipairs( message ) do
		if index <= messageLineIndex then
			if index < messageLineIndex then
				-- draw whole line
				drawLine( line, line )
			else
				drawLine( line:sub( 1, math.floor( messageCharIndex )), line )
			end
		end
	end
end

-- MARKET SYSTEM

local currentMarketControlX = 0
local currentPurchaseOrder = nil

function startMarket( market )
	assert( market ~= nil )

	currentMarketControlX = 0
	currentMarketControlY = 0
	currentPurchaseOrder = { buy = {}, sell = {} }

	for _, commodity in ipairs( market.marketProper.commodities ) do
		currentPurchaseOrder.buy[  commodity.config ] = 0
		currentPurchaseOrder.sell[ commodity.config ] = 0
	end

	startConversation({
			market.greeting,
			market.marketProper,
			market.goodbye
		},
		nil,
		nil,
		'shopkeep' --music
	)
end

function isMarketMessage( message )
	return message.commodities ~= nil
end

function commodityCost( marketProper, commodity )
	return 5 	-- TODO
end

function clampCommodity( commodityAmount )
	return clamp( math.floor( commodityAmount ), 0, 9 )
end

function commodityAvailability( marketProper, typeOfTrade, commodity )
	if typeOfTrade == 'buy' then
		return commodity.available
	else
		if player.inventory[ commodity.config ] == nil then
			player.inventory[ commodity.config ] = 0
		end
		return player.inventory[ commodity.config ]
	end
end

function contemplatedCommodityTrade( marketProper )
	if currentMarketControlY == #marketProper.commodities then
		return nil
	end

	local commodity = marketProper.commodities[ currentMarketControlY + 1 ]

	return commodity, currentMarketControlX == 0 and 'buy' or 'sell'
end

function canAffordAdditionalCost( marketProper, additionalCost )
	local currentGainLoss = purchaseOrderNetGainLoss( marketProper, currentPurchaseOrder )
	local currentProposedPlayerBalance = player.coins + currentGainLoss
	
	return additionalCost <= currentProposedPlayerBalance
end

function drawMarket( marketProper )
	local commodities = marketProper.commodities

	local buyColumn = 80
	local sellColumn = buyColumn + ( screen_wid() - buyColumn ) / 2

	print( 'BUY', buyColumn, 4, 0xFF00FF00, 1 )
	print( 'SELL', sellColumn, 4, 0xFFFFFF00, 1 )

	print( 'have', buyColumn + 44, 4, 0xFF808080, 2 )
	print( 'have', sellColumn + 44, 4, 0xFF808080, 2 )

	print( 'z', buyColumn + 30, 12, 0xFF808080, 2 )
	print( 'z', sellColumn + 30, 12, 0xFF808080, 2 )
	print( 'x', buyColumn + 42, 12, 0xFF808080, 2 )
	print( 'x', sellColumn + 42, 12, 0xFF808080, 2 )

	local currentMarketControl = ( currentMarketControlY == #commodities and 0 or currentMarketControlX ) + currentMarketControlY * 2

	local iControl = 0
	for i, commodity in ipairs( commodities ) do
		local y = 3 + i * 17

		spr( commodity.icon, 6, y + commodity.iconOffsetY )
		print( commodity.name, 24, y )
		print( '$' .. commodity.playerBuysFor, buyColumn, y )
		print( '$' .. commodity.playerSellsFor, sellColumn, y )

		local availableForPlayerToBuy = commodityAvailability( marketProper, 'buy', commodity )
		local proposedBuy = currentPurchaseOrder.buy[ commodity.config ]

		local isCurrentControl = iControl == currentMarketControl

		local canLess = proposedBuy > 0

		local canAffordOneMore = canAffordAdditionalCost( marketProper, commodity.playerBuysFor )
		local canMore = availableForPlayerToBuy - proposedBuy > 0 and canAffordOneMore

		print( '<', buyColumn + 6 * 5, y, isCurrentControl and ( canLess and 0xFFFFFFFF or 0xFF808080 ) or 0xFF808080 )
		print( proposedBuy, buyColumn + 6 * 6, y, isCurrentControl and 0xFFFFFFFF or 0xFF808080 )
		print( '>', buyColumn + 6 * 7, y, isCurrentControl and ( canMore and 0xFFFFFFFF or 0xFF808080 ) or 0xFF808080 )

		print( '(', buyColumn + 6 * 9, y, 0xFF808080 )
		print( availableForPlayerToBuy, buyColumn + 6 * 9 + 5, y, 0xFF808080 )
		print( ')', buyColumn + 6 * 9 + 10, y, 0xFF808080 )
		
		iControl = iControl + 1

		local availableForPlayerToSell = commodityAvailability( marketProper, 'sell', commodity )
		local proposedSell = currentPurchaseOrder.sell[ commodity.config ]

		isCurrentControl = iControl == currentMarketControl

		canLess = proposedSell > 0
		canMore = availableForPlayerToSell - proposedSell > 0

		print( '<', sellColumn + 6 * 5, y, isCurrentControl and ( canLess and 0xFFFFFFFF or 0xFF808080 ) or 0xFF808080 )
		print( proposedSell, sellColumn + 6 * 6, y, isCurrentControl and 0xFFFFFFFF or 0xFF808080 )
		print( '>', sellColumn + 6 * 7, y, isCurrentControl and ( canMore and 0xFFFFFFFF or 0xFF808080 ) or 0xFF808080 )

		print( '(', sellColumn + 6 * 9, y, 0xFF808080 )
		print( availableForPlayerToSell, sellColumn + 6 * 9 + 5, y, 0xFF808080 )
		print( ')', sellColumn + 6 * 9 + 10, y, 0xFF808080 )

		iControl = iControl + 1
	end

	-- print( 'Z - less  X - more', 6, MAX_CONVERSATION_HEIGHT - 10, 0xFF808080, 2 )

	local controlColor = iControl == currentMarketControl and 0xFFFFFFFF or 0xFF808080
	print( 'DONE', 240 - 6 * 6, MAX_CONVERSATION_HEIGHT - 10, controlColor )
end

function purchaseOrderNetGainLoss( marketProper, order )

	local totalCoinsGained = 0

	for _, commodity in ipairs( marketProper.commodities ) do
		local buyAmount = order.buy[ commodity.config ]
		local sellAmount = order.sell[ commodity.config ]

		local buyCost = buyAmount * commodity.playerBuysFor
		local sellCost = sellAmount * commodity.playerSellsFor
	
		totalCoinsGained = totalCoinsGained - buyCost + sellCost
	end

	return totalCoinsGained
end

function enactTrades( marketProper )

	local totalCoinsGained = 0

	for _, commodity in ipairs( marketProper.commodities ) do
		-- TODO surely not both?!
		local buyAmount = currentPurchaseOrder.buy[ commodity.config ]
		local sellAmount = currentPurchaseOrder.sell[ commodity.config ]

		local buyCost = buyAmount * commodity.playerBuysFor
		local sellCost = sellAmount * commodity.playerSellsFor
	
		totalCoinsGained = totalCoinsGained - buyCost + sellCost

		if player.inventory[ commodity.config ] == nil then
			player.inventory[ commodity.config ] = 0
		end
		player.inventory[ commodity.config ] = 
			clampCommodity( player.inventory[ commodity.config ] - sellAmount + buyAmount )

		commodity.available = clampCommodity( commodity.available + sellAmount - buyAmount )
	end

	if totalCoinsGained ~= 0 then
		player.coins = player.coins + totalCoinsGained
		coinFlash = 1.0
		sfx( 'purchase_00' )
	end
end

local lastAdjustmentTIme = now()
MARKET_ADJUSTMENT_INTERVAL = 10

function forEachMarket( callback )
	for _, actor in ipairs( actors ) do
		if actor.config.name == 'market' then
			callback( actor )
		end
	end
end

function maybeAdjustMarkets()
	if now() < lastAdjustmentTIme + MARKET_ADJUSTMENT_INTERVAL then return end

	lastAdjustmentTIme = now()

	-- trace( 'adjusting markets' )

	forEachMarket( function( marketActor )
		local commodities = marketActor.market.marketProper.commodities
		for _, commodity in ipairs( commodities ) do
			local price = commodity.playerSellsFor
			local maxPrice = 20
			local minChance = 1
			local maxChance = 10

			local cheapness = 1.0 - clamp( price / maxPrice, 0.0, 1.0 )
			local chance = lerp( minChance, maxChance, cheapness )

			if pctChance( chance ) then
				commodity.available = clampCommodity( commodity.available + 1 )
			end
		end
	end)
end

function updateMarketInput( marketProper )
	if btnp( 0 ) then
		sfx( 'alert_03' )
		if currentMarketControlY == #marketProper.commodities then
			currentMarketControlY = currentMarketControlY - 1
			currentMarketControlX = 0
		else
			currentMarketControlX = currentMarketControlX - 1
		end
	end

	if btnp( 1 ) then
		sfx( 'alert_03' )
		if currentMarketControlY == #marketProper.commodities then
			currentMarketControlY = currentMarketControlY - 1
			currentMarketControlX = 1
		else
			currentMarketControlX = currentMarketControlX + 1
		end
	end

	if currentMarketControlX < 0 then
		currentMarketControlX = 1
		currentMarketControlY = currentMarketControlY - 1
	end

	if currentMarketControlX >= 2 then
		currentMarketControlX = 0
		currentMarketControlY = currentMarketControlY + 1
	end

	if btnp( 2 ) then
		sfx( 'alert_03' )
		currentMarketControlY = currentMarketControlY - 1
	end

	if btnp( 3 ) then
		sfx( 'alert_03' )
		currentMarketControlY = currentMarketControlY + 1
	end

	if currentMarketControlY < 0 then
		currentMarketControlY = #marketProper.commodities
	end

	if currentMarketControlY > #marketProper.commodities then
		currentMarketControlY = 0
	end

	if currentMarketControlY == #marketProper.commodities then
		if btnp( 4 ) or btnp( 5 ) then
			enactTrades( marketProper )
			conversationNextMessage()
		end
	else
		local commodity, typeOfTrade = contemplatedCommodityTrade( marketProper )
		local commodityName = commodity.config
		if btnp( 4 ) then	-- less
			sfx( 'item_down' )
			currentPurchaseOrder[ typeOfTrade ][ commodityName ] = math.max( 0, currentPurchaseOrder[ typeOfTrade ][ commodityName ] - 1 )
		end

		if btnp( 5 ) then	-- more
			sfx( 'item_up' )
			if typeOfTrade == 'buy' then
				local proposedBuy = currentPurchaseOrder.buy[ commodity.config ]
				local canAffordOneMore = canAffordAdditionalCost( marketProper, commodity.playerBuysFor )
				local availableForPlayerToBuy = commodityAvailability( marketProper, typeOfTrade, commodity )
				local canMore = availableForPlayerToBuy - proposedBuy > 0 and canAffordOneMore

				if canMore then
					currentPurchaseOrder[ typeOfTrade ][ commodityName ] = math.min( availableForPlayerToBuy, currentPurchaseOrder[ typeOfTrade ][ commodityName ] + 1 )
				else
					if not canAffordOneMore then
						coinFlash = 1
					end
				end
			else
				local availableForPlayerToSell = commodityAvailability( marketProper, 'sell', commodity )
				currentPurchaseOrder[ typeOfTrade ][ commodityName ] = math.min( availableForPlayerToSell, currentPurchaseOrder[ typeOfTrade ][ commodityName ] + 1 )
			end
		end
	end
end

-- TILES

-- Impassable tiles
fset( spriteIndex( 27, 27 ), 1, 1 )		-- forest
fset( spriteIndex( 12, 21 ), 1, 1 )		-- water

-- MAINS

function updateViewTransform()
	local viewOffset = vec2:new( screen_wid() / 2, screen_hgt() / 2 )

	viewOffset.y = ( screen_hgt() - conversationHeight ) / 2

	local viewPoint = ( player.pos - vec2:new( 0, 10 ) ) - viewOffset

	setWorldView( viewPoint.x, viewPoint.y )
end

function roundSellPrice( price )
	return math.floor( round( price, 1.0 ))
end

function roundBuyPrice( price )
	local roundTerm = price >= 10 and 5 or 1
	return math.floor( round( price, roundTerm ))
end

function createMarket( x, y, market )
	-- Set sale prices and fixup things

	local buyRate = market.marketProper.buyRate
	for _, commodity in ipairs( market.marketProper.commodities ) do

		commodity.playerBuysFor = commodity.playerSellsFor * buyRate

		commodity.playerSellsFor = math.max( 0, roundSellPrice( commodity.playerSellsFor, 1 ))
		commodity.playerBuysFor  = roundBuyPrice( commodity.playerBuysFor )

		commodity.playerBuysFor = math.max( 0, math.max( commodity.playerBuysFor, commodity.playerSellsFor + 1 ))

		commodity.available = clampCommodity( math.floor( commodity.available ~= nil and commodity.available or 0 ))

		local config = actorConfigurations[ commodity.config ]
		commodity.name = config.humanReadableName
		commodity.icon = config.animations.idle.frames[1]
		commodity.iconOffsetY = config.iconOffsetY or 0
	end

	table.sort( market.marketProper.commodities, function( a, b )
		return a.playerBuysFor < b.playerBuysFor
	end )

	local marketActor = createActor( 'market', x, y )
	marketActor.market = market

	createActor( 'shopkeeper', x, y+1 )

	return marketActor
end

local centralMarket = vec2:new( 700, 1100 )

function standardGreeting( marketName )
	return {
	'Welcome to',
	(marketName or "my market") .. '!',
	'',
	"Do you have anything you'd",
	"like to BUY or SELL?"
	}
end

local standardGoodbye = {
	'Thanks for stopping in!',
	'',
	'(Press X)'
}

function commodityForConfig( commodities, configName )
	for _, commodity in ipairs( commodities ) do
		if commodity.config == configName then
			return commodity
		end
	end
	return nil
end

function createRandomizedMarket( tileX, tileY, premiumName, discountName, marketName )

	local x = PIXELS_PER_TILE * tileX
	local y = PIXELS_PER_TILE * tileY

	local dist = centralMarket:dist( vec2:new( x, y ))

	local commodities = {
		{ 
			config = 'meat', 		
			available = clampCommodity( math.random( 0, 5 )), 
			playerSellsFor = math.random( 2, 4 ),
		},
		{ 
			config = 'slimeDrop', 
			available = clampCommodity( math.random( 0, 2 )),
			playerSellsFor = math.random( 1, 5 ),
		},
		{ 
			config = 'wood', 		
			available = clampCommodity( math.random( 0, 5 )),
			playerSellsFor = math.random( 2, 4 ),
		},
		{ 
			config = 'mushroom_red', 
			available = clampCommodity( math.random( 0, 6 )),
			playerSellsFor = math.random( 3, 8 ),
		},
		{ 
			config = 'crystal', 	
			available = clampCommodity( math.random( 0, 2 )),
			playerSellsFor = math.random( 10, 15 ),
		},
	}

	if premiumName ~= nil then
		local commodity = commodityForConfig( commodities, premiumName )
		commodity.playerSellsFor = math.max( 0, roundSellPrice( commodity.playerSellsFor * randInRange( 1.5, 2.0 )))
		commodity.available = clampCommodity( math.floor( math.random( 0, 2 )))
	end

	if discountName ~= nil then
		local commodity = commodityForConfig( commodities, discountName )
		commodity.playerSellsFor = math.max( 0, roundSellPrice( commodity.playerSellsFor * randInRange( 0.25, 0.5 )))
		commodity.available = clampCommodity((( 1 + commodity.available ) * randInRange( 1.5, 2 ) ))
	end

	if premiumName == nil and discountName == nil then
		-- randomized premium/discount
		for i, commodity in ipairs( commodities ) do
			if pctChance( 25 ) then
				-- premium
				commodity.playerSellsFor = math.max( 0, roundSellPrice( commodity.playerSellsFor * randInRange( 1.25, 1.5 )))
				commodity.available = clampCommodity( math.floor( math.random( 0, 2 )))
			elseif pctChance( 20 ) then
				-- discount
				commodity.playerSellsFor = math.max( 0, roundSellPrice( commodity.playerSellsFor * randInRange( 0.5, 0.9 )))
				commodity.available = clampCommodity( math.floor(( 1 + commodity.available ) * randInRange( 1.5, 2 ) ))
			end
		end
	end

	local marketInfo = {
		greeting = standardGreeting( marketName ),
		marketProper = {
			buyRate = randInRange( 1.25, 2.5 ),
			commodities = commodities
		},
		goodbye = standardGoodbye,
	}
	return createMarket( x, y, marketInfo )
end

function createTown( tileX, tileY, radius, premiumName, discountName, marketName )

	local townCenter = vec2:new( tileX, tileY )
	radius = radius or 6

	local town = {
		pos = townCenter * PIXELS_PER_TILE,
		radius = radius * PIXELS_PER_TILE,
		buildings = {}
	}

	createRandomizedMarket( townCenter.x, townCenter.y, premiumName, discountName, marketName )

	if pctChance( 50 ) then
		local building = createActor( 'outhouse', 0, 0 )
		table.insert( town.buildings, building )
	end

	if pctChance( 75 ) then
		local building = createActor( 'house1', 0, 0 )
		table.insert( town.buildings, building )
	end
	if pctChance( 75 ) then
		local building = createActor( 'house2', 0, 0 )
		table.insert( town.buildings, building )
	end

	local numBuildings = #town.buildings

	local buildingAngle = randInRange( 0, math.pi )
	local buildingAngleStep = math.pi * 2 / numBuildings

	function getBuildingLocation( angle )
		local buildingDistance = randInRange( radius * 0.75, radius )

		local loc = vec2:new( buildingDistance, 0 )
		loc:rotate( angle )

		return townCenter + loc
	end

	for i, building in ipairs( town.buildings ) do
		local angle = buildingAngle + ( i - 1 ) * buildingAngleStep
		local loc = getBuildingLocation( angle )
		building.pos = loc * PIXELS_PER_TILE
	end

	table.insert( towns, town )
end

towns = {}

TOWN_BORDER = 128

function isInTown( pos )
	for _, town in ipairs( towns ) do
		local dist = pos:dist( town.pos )
		if dist <= town.radius + TOWN_BORDER then
			return true
		end
	end
	return false
end

local blockageSpriteIndex = spriteIndex( 15, 23 )

function setSwordBlockTilesBlocking( block )
	fset( blockageSpriteIndex, 1, block and 1 or 0 )
end

function createHomeTown( tileX, tileY, radius, premiumName, discountName, marketName )

	local townCenter = vec2:new( tileX, tileY )
	radius = radius or 8

	local town = {
		pos = townCenter * PIXELS_PER_TILE,
		radius = radius * PIXELS_PER_TILE,
		buildings = {}
	}

	homeTown = town


	-- make jail
	jail = createActor( 'jail', town.pos.x + 80, town.pos.y + 48 )
	table.insert( town.buildings, jail )

	-- fixup jail character position
	local pos = jail.pos + vec2:new( -28, 1 )
	createActor( 'husband_jail', pos.x, pos.y )

	-- make market
	createRandomizedMarket( townCenter.x + 0, townCenter.y - 5, premiumName, discountName, marketName )

	-- make home
	local housePos = town.pos + vec2:new( -96, 32 )
	createActor( 'house1', housePos.x, housePos.y )

	-- family
	createActor( 'child', housePos.x + 48, housePos.y - 10 )
	createActor( 'twins', housePos.x - 16, housePos.y + 16 )

	-- make sword
	createActor( 'sword', 224, 48 )

	local blockageTileX = 24
	local blockageTileY = 21

	createActor( 'sword_blockage', ( blockageTileX + 0.5 ) * PIXELS_PER_TILE, blockageTileY * PIXELS_PER_TILE )
	for i = 1, 4 do
		mset( blockageTileX, blockageTileY - i, blockageSpriteIndex )
	end

	setSwordBlockTilesBlocking( true )

	
	table.insert( towns, town )
end	

function startGame()
	restartGameTime = nil
	color_multiplied_r = 1
	color_multiplied_g = 1
	color_multiplied_b = 1
	color_multiplied_r_smoothed = 0
	color_multiplied_g_smoothed = 0
	color_multiplied_b_smoothed = 0


	actors = {}
	towns = {}

	music( 'wilds', 0.25 )

	-- createActor( 'rat', 160, 160 )

	-- create towns

	createHomeTown( 13, 22, nil, 'crystal', 'mushroom_red', "The Mushy Gemstone" ) -- North West
	createTown( 110, 22, 8, 'mushroom_red', 'wood', "Shrooms 4 Wood" )       -- North East
	createTown( 76, 49, 9, 'wood', 'slimeDrop', "Woody's Slime Hut" )           -- Central
	createTown( 23, 91, 12, 'slimeDrop', 'meat', '"Slimes Beat Meat"' )          -- South West
	createTown( 97, 89, 10, 'meat', 'crystal', "Gems 4 Cheap" )            -- South East

	lastPopulatingLocation = nil

	local priorCoins = player ~= nil and player.coins or 0

	player = createActor( 'player', 8 * PIXELS_PER_TILE, 44 * PIXELS_PER_TILE )
	player.coins = math.floor( priorCoins // 2 )


	-- mark all current actors as permanent
	for _, actor in ipairs( actors ) do
		actor.surviveOutOfBounds = true
	end

	updateViewTransform()

	-- initial spawn
	spawnPopulatingActors( true )

	-- Title screen conversation
	startConversation( {
		{
			"Welcome to BONNIE.",
			"",
			"Use the arrow keys to move.",
			"Z to strike.",
			"",
			"Press Z or X to begin."
		},
	})
end

function actorControlThrust( actor, thrust )
	actor.vel = actor.vel + thrust

	if thrust:lengthSquared() > 0 then
		actor.heading = thrust:normal()
	end
end

function updateInput( actor )

	local thrust = vec2:new()

	if btn( 0 ) then
		thrust.x = thrust.x - 1
	end

	if btn( 1 ) then
		thrust.x = thrust.x + 1
	end

	if btn( 2 ) then 
		thrust.y = thrust.y - 1
	end

	if btn( 3 ) then
		thrust.y = thrust.y + 1
	end

	if not actor.attacking and btnp( 4 ) then
		actorAttack( actor )
	end

	thrust = thrust:normal() * actor.config.maxThrust

	actorControlThrust( actor, thrust )

	if ( leapNextAvailableTime == nil or now() > leapNextAvailableTime ) and ( btnp( 5 ) and thrust:lengthSquared() > 0 ) then
		actor.knockback = thrust * 2
		actor.vel:set( 0, 0 )
		createActor( 'deathCloud', actor.pos.x, actor.pos.y )

		leapNextAvailableTime = now() + 0.5
		-- sfx( TODO )
		-- TODO
	end
end

function drawMap()
	local bounds = viewBounds()
	local tiles = worldBoundsToTerrainBounds( bounds )
	local wid = tiles.right - tiles.left + 1
	local hgt = tiles.bottom - tiles.top + 1

	map( tiles.left, tiles.top, tiles.left * PIXELS_PER_TILE, tiles.top * PIXELS_PER_TILE, wid, hgt )
end

function update()

	if restartGameTime ~= nil and restartGameTime < realNow() then
		startGame()
		return
	end

	updateScreenParams()

	if restartGameTime == nil and ( currentConversation == nil or pauseInConversation == false ) then 
		updateActive()
	end
	
	if currentConversation ~= nil then
		updateConversation()
	end

	local needConversationMarquee = currentConversation ~= nil
	conversationHeight = lerp( conversationHeight, needConversationMarquee and MAX_CONVERSATION_HEIGHT or 0, 0.1 )

	realTicks = realTicks + 1
end

local coinSprite = spriteIndex( 27, 0 )

function drawHUD()
	camera(  0, 0 )

	-- player.inventory[ "mushroom_red" ] = 2
	-- player.inventory[ "crystal" ] = 3

	-- inventory
	local j = 0
	local invY = 21
	local size = 2
	for key, amount in pairs( player.inventory ) do
		local config = actorConfigurations[ key ]
		if config.pickup.invColor ~= nil then
			for i = 1, amount do
				local x = 4 + ( j % 10 ) * 4
				local y = invY + ( j // 10 ) * 4
				rectfill( x, y, x + size, y + size, config.pickup.invColor )
				j = j + 1
			end
		end
	end

	coinFlash = lerp( coinFlash, 0, 0.1 )
	local coinAdditive = floatTermToColor( coinFlash )

	spr( coinSprite, 4, 4, 1, 1, false, false, 0xFFFFFFFF, coinAdditive )
	print( math.floor( player.coins ), 17, 5, ( 0xffffff00 | coinAdditive ), 1, 2 )


	local heartSprite = spriteIndex( 27, 1 )
	local spacing = 16

	local left = screen_wid() - player.config.maxHealth * spacing - 4
	local top = 4

	healthFlash = lerp( healthFlash, 0, 0.1 )

	for i = 1, player.config.maxHealth do
		local dimming = i > player.health and 0.5 or 0
		local additiveFloat = math.max( healthFlash, dimming )

		local additive = floatTermToColor( additiveFloat )

		spr( heartSprite, left + ( i - 1 ) * spacing, top, 1, 1, false, false, 0xFFFFFFFF, additive )
	end
end

function draw()
	-- cls( 0xff220044 )

	updateViewTransform()

	drawMap()

	drawActors()

	-- drawDebugCircles()

	drawHUD()

	drawConversation()
	
	camera( 0, 0 )
	drawDebug()
end

function updateDeadMode()
end

function updateActive()
	if player.health <= 0 then
		updateDeadMode()
	else
		updateInput( player )
	end

	updateActors()

	maybeAdjustMarkets()

	ticks = ticks + 1
end


startGame()
