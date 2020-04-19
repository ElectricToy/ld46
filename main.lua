-- Ludum Dare 46

function lerp( a, b, alpha )
	return a + (b-a) * alpha
end

-- Configuration
text_scale( 1 )
filter_mode( "Nearest" )

screen_size( 220, 128 )

MIN_ACTIVE_BLOCK_INDEX = 256

SPRITE_SHEET_PIXELS_X = 512
PIXELS_PER_TILE = 16
TILES_X = SPRITE_SHEET_PIXELS_X // PIXELS_PER_TILE

sprite_size( PIXELS_PER_TILE )

WORLD_SIZE_TILES = 32
WORLD_SIZE_PIXELS = WORLD_SIZE_TILES * PIXELS_PER_TILE

barrel_ = 0.2
bloom_intensity_ = 0
bloom_contrast_ = 0
bloom_brightness_ = 0
burn_in_ = 0.15
chromatic_aberration_ = 0.4
noise_ = 0.025
rescan_ = 0.5
saturation_ = 1
color_multiplied_r = 1
color_multiplied_g = 1
color_multiplied_b = 1
bevel_ = 0.20

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
	bevel( bevel_smoothed, 1 )
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

function vec2:majorAxis()
	return math.abs( self.x ) > math.abs( self.y ) and 0 or 1
end

function vec2:snappedToMajorAxis()
	if self:majorAxis() == 0 then
		return vec2:new( signNoZero( self.x ), 0 )
	else
		return vec2:new( signNoZero( self.y ), 0 )
	end
end

function vec2:cardinalDirection() -- 0 = north, 1 = east...
	if self:majorAxis() == 0 then
		return self.x >= 0 and 1 or 3
	else
		return self.y >= 0 and 2 or 0
	end
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

function randInt( a, b )
	return math.floor( randInRange( a, b ))
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

function sprite_by_grid( x, y )
	return y // TILES_X + x
end

function range( from, to, step )
	arr = {}
	for i = from, to, step or 1 do
		table.insert( arr, i )
	end
	return arr
end

actors = {}
blocksToActors = {}

function actorCenter( actor )
	return actor.pos - vec2:new( 0, actor.config.dims.y * 0.5 )
end

function actorConveyorForce( actor, force )
	actor.vel = actor.vel + force
end

function actorControlThrust( actor, thrust )
	actor.thrust = thrust
	actor.vel = actor.vel + thrust

	if thrust:lengthSquared() > 0 then
		actor.heading = thrust:normal()
	end
end

ARM_LENGTH = 2
ARM_OFFSET = vec2:new( 0, -2 )

function pickupPoint( byActor )
	return byActor.pos + ARM_OFFSET + byActor.heading * ARM_LENGTH
end

function blockInteractionTile( byActor )
	local point = pickupPoint( byActor )

	local pickupTileX = worldToTile( point.x )
	local pickupTileY = worldToTile( point.y )

	if  pickupTileX < 0 or pickupTileX >= WORLD_SIZE_TILES or
		pickupTileY < 0 or pickupTileY >= WORLD_SIZE_TILES then
			return nil
	end

	return pickupTileX, pickupTileY
end

function blockToPickup( byActor )

	local pickupTileX, pickupTileY = blockInteractionTile( byActor )

	local blockType = blockTypeAt( pickupTileX, pickupTileY )
	if blockType == nil or blockType.stationary then return nil end

	return pickupTileX, pickupTileY
end

function randomGroundBlockIndex()
	return randInt( 256, 256+5 )
end

function blockOnNeighborChanged( x, y, changedX, changedY )
	withBlockTypeAt( x, y, function( blockType, blockTypeIndex )
		withBaseBlockType( blockTypeIndex, function( baseBlockType, baseBlockTypeIndex )
			if baseBlockType ~= nil and baseBlockType.onPlaced ~= nil then
				-- trace( x .. ' ' .. y .. ' ' .. baseBlockTypeIndex )
				baseBlockType.onPlaced( x, y, baseBlockType, blockTypeIndex ) 
			end
		end)
	end)
end

function onBlockChangeNear( x, y )
	blockOnNeighborChanged( x, y, x, y )
	blockOnNeighborChanged( x, y - 1, x, y )
end

function setBlockType( x, y, blockTypeIndex )
	mset( x, y, blockTypeIndex )
	onBlockChangeNear( x, y )
end

function clearBlock( x, y )
	setBlockType( x, y, randomGroundBlockIndex() )
end

function createActorForBlockIndex( blockTypeIndex, x, y )
	return withBaseBlockType( blockTypeIndex, function( baseBlockType, baseBlockTypeIndex )
		if baseBlockType.actorConfigName ~= nil then
			-- trace( 'creating ' .. baseBlockType.actorConfigName )
			return createActor( baseBlockType.actorConfigName, x, y )
		end
	end)
end

function mayPlaceBlockOnBlock( x, y )
	local blockType, blockTypeIndex = blockTypeAt( x, y )
	if blockType == nil then return false end

	return blockType.mayBePlacedUpon or false
end

function tryPlaceAsBlock( item, direction, position )
	local blockTypeForHeldItem = actorPlacementBlock( item, direction )
	if blockTypeForHeldItem ~= nil then 

		-- clear block placement area?
		local placementPos = position or actorCenter( item )
		local placementX = worldToTile( placementPos.x )
		local placementY = worldToTile( placementPos.y )
		if not mayPlaceBlockOnBlock( placementX, placementY ) then return end

		setBlockType( placementX, placementY, blockTypeForHeldItem )

		deleteActor( item )

		return true
	else
		return false
	end
end

function tryDropHeldItem( forceAsBlock, forceAsItem )
	if not player.heldItem then return end

	-- placeable as block?

	if not forceAsBlock and 
	   (forceAsItem or 
	   		not tryPlaceAsBlock( player.heldItem, player.heading:cardinalDirection(), player.pos )) then

		-- placeable as item?
		player.heldItem.held = false	-- probably moot, but just in case
		player.heldItem.inert = false
		player.heldItem.nonColliding = false
		player.heldItem = nil
		return
	end

	player.heldItem = nil
end

function forEachActorNear( x, y, radius, callback )
	local pos = vec2:new( x, y )
	local rSquared = radius * radius
	for _, actor in ipairs( actors ) do
		local distSquared = ( actor.pos - pos ):lengthSquared()
		if distSquared <= rSquared then
			callback( actor, distSquared )
		end
	end
end

function findPickupActorNear( forActor, x, y, radius )
	local nearestActor = nil
	local nearestDistSquared = nil
	forEachActorNear( x, y, radius, function( actor, distSquared )
		if not actor.config.mayBePickedUp or actor == forActor then return end
		
		if nearestDistSquared == nil or distSquared < nearestDistSquared then
			nearestDistSquared = distSquared
			nearestActor = actor
		end
	end)

	return nearestActor
end

function makeHeld( item )
	item.held = true
	item.inert = true
	item.nonColliding = true
	item.vel = vec2:new( 0, 0)
	item.lastPos = vec2:new( x, y )
	item.vel = vec2:new( 0, 0 )
	item.thrust = vec2:new( 0, 0 )
	item.heading = vec2:new( -1, 0 )
end

function tryPickupActor( byActor )
	if byActor.heldItem ~= nil then return nil end

	-- look for actors near the pick area
	local point = pickupPoint( byActor )
	local pickupActor = findPickupActorNear( byAcor, point.x, point.y, 8 )
	if pickupActor == byActor or pickupActor == nil then return nil end

	makeHeld( pickupActor )
	byActor.heldItem = pickupActor
	return pickupActor
end

function tryPickupBlock( byActor )
	if byActor.heldItem ~= nil then return nil end

	local blockX, blockY = blockToPickup( byActor )
	if blockX ~= nil then
		-- place in inventory
		local blockIndex = mget( blockX, blockY )
		byActor.heldItem = createActorForBlockIndex( blockIndex, byActor.pos.x, byActor.pos.y )

		if byActor.heldItem ~= nil then
			makeHeld( byActor.heldItem )

			clearBlock( blockX, blockY )
			return true
		end
	end

	return false
end

function onButton1()

	if player.heldItem ~= nil then
		tryDropHeldItem()
	else
		-- Pickup

		if tryPickupActor( player ) == nil then
			tryPickupBlock( player )
		end
	end
end

function onButton2()
	tryDropHeldItem( false, true ) -- forcing drop
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

	thrust = thrust:normal() * actor.config.maxThrust

	actorControlThrust( actor, thrust )

	if btnp( 4 ) then
		onButton1()
	end
	if btnp( 5 ) then
		onButton2()
	end
end

function updateViewTransform()
	local viewOffset = vec2:new( screen_wid() / 2, screen_hgt() / 2 )

	viewOffset.y = screen_hgt() / 2

	local viewPoint = ( player.pos - vec2:new( 0, 10 ) ) - viewOffset

	setWorldView( viewPoint.x, viewPoint.y )
end

function startGame()

	fixupBlockData()

	actors = {}

	color_multiplied_r = 1
	color_multiplied_g = 1
	color_multiplied_b = 1
	color_multiplied_r_smoothed = 0
	color_multiplied_g_smoothed = 0
	color_multiplied_b_smoothed = 0


	player = createActor( 'player', 2 * PIXELS_PER_TILE, 3 * PIXELS_PER_TILE )

	updateViewTransform()
end

GLOBAL_DRAG = 0.175

function updateHeldItem( holder, item )
	item.pos = holder.pos + vec2:new( 0, -14 - math.sin( ticks * 0.08 ) * 1 )
	item.lastPos:set( item.pos.x, item.pos.y )
	item.vel:set( 0, 0 )
end

function updatePlayer( actor )
	if player.heldItem then
		updateHeldItem( player, player.heldItem )
	end
end

actorConfigurations = {
	player = {
		dims = vec2:new( 7, 13 ),
		maxThrust = 0.35,
		ulOffset = vec2:new( 9, 15 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle_south = { speed = 0, frames = { 1 }},
			run_south =  { speed = 0.4, frames = range( 2, 2 + 7 )},
			idle_north = { speed = 0, frames = { 33 }},
			run_north =  { speed = 0.4, frames = range( 34, 34 + 7 )},
			idle_side = { speed = 0, frames = { 65 }},
			run_side = { speed = 0.4, frames = range( 66, 66 + 7 ) },
		},
		amendAnimName = function( self, animName )
			if self.heading:majorAxis() == 0 then return animName .. '_side' end

			return animName .. '_' .. ( self.heading.y < 0 and 'north' or 'south' )
		end,
		tick = updatePlayer,
	},
	conveyor = {
		mayBePickedUp = true,
		convertToBlockWhenPossible = true,
		blockPlacementType = { 261, 261+32, 261+32*2, 261+32*3 } ,
		dims = vec2:new( 16, 16 ),
		ulOffset = vec2:new( 8, 16 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 261 }},
		},
	}
}

function deleteActor( actor )
	tableRemoveValue( actors, actor )
end

function createActor( configKey, x, y )
	local config = actorConfigurations[ configKey ]
	assert( config )

	local actor = {
		birthdate = now(),
		config = config,
		pos = vec2:new( x, y ),
		lastPos = vec2:new( x, y ),
		vel = vec2:new( 0, 0 ),
		thrust = vec2:new( 0, 0 ),
		heading = vec2:new( -1, 0 ),
		animFrame = 0,
		lastFrame = 0,
		occluding = false,
		occlusionOpacity = 1.0
	}

	table.insert( actors, actor )

	return actor
end

function effectiveVelocity( actor )
	return actor.pos - actor.lastPos
end

function speed( actor )
	return actor.vel:length()
end

function actorPlacementBlock( actor, placementDirectionCardinal )
	if type( actor.config.blockPlacementType ) == 'number' then
		return actor.config.blockPlacementType
	elseif actor.config.blockPlacementType == nil then
		return nil
	else
		return actor.config.blockPlacementType[ placementDirectionCardinal + 1 ]
	end
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

function currentAnimation( actor )
	local animations = actor.config.animations
	
	if animations == nil then return nil end

	local anim = ( math.abs( actor.thrust:length() ) > 0.1 ) and 'run' or 'idle'

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

function frameSpriteIndex( frame )
	return ( type( frame ) == 'table' and frame.frame ) or frame
end

function actorColor( actor )
	return actor.flickerColor or 0xFFFFFFFF
end

function floatTermToColor( term )
	local component = math.floor( lerp( 0, 0xFF, term ))
	return ( 0xFF << 24 ) | ( component << 16 ) | ( component << 8 ) | component
end

function actorAdditiveColor( actor )
	return actor.additiveColor or 0x00000000
end

function updateAnimation( actor )

	if actor.animPlaying ~= nil and not actor.animPlaying then return end

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

function actorOccludesPlayer( actor )
	if player.pos.y > actor.pos.y then return false end

	local myBounds = actorBounds( actor )
	local playerBounds = expandContractRect( actorBounds( player ), 16 )

	return rectsOverlap( myBounds, playerBounds )
end


function bitPatternForAlpha( alpha )
	local iAlpha = math.floor( alpha * 16 )
	local pattern = 0

	local bit = 1
	for i = 0, iAlpha do
		pattern = pattern | bit
		bit = ( bit << 7 ) % 0xFFFF
	end

	return ~pattern
end

function actorOpacityForDither( actor )
	return actor.occlusionOpacity or 1.0
end

function drawActor( actor )
	local animation = currentAnimation( actor )
	if animation == nil then return end

	local frames = animation.frames

	local cur_frame = math.floor( actor.animFrame ) % #frames

	local sprite = frameSpriteIndex( frames[ cur_frame + 1 ] )

	fillp( bitPatternForAlpha( actorOpacityForDither( actor ) ))

	local flipX = actor.heading:majorAxis() == 0 and actor.heading.x > 0

	spr( sprite, 
		round( actor.pos.x - actor.config.ulOffset.x ), 
		round( actor.pos.y - actor.config.ulOffset.y ), 
		actor.config.tileSizeX, 
		actor.config.tileSizeY, 
		flipX,
		false,
		actorColor( actor ),
		actorAdditiveColor( actor )
	)

	fillp( 0 )
end

-- GLOBALS

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

-- UPDATE

function actorMayCollideWith( actor, other )
	if actor.config.nonColliding then return false end
	return true
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

function collideActorWithTile( actor, tileX, tileY )
	local bounds = actorBounds( actor )

	-- trace( actorFoot( actor ).x .. ' ' .. actorFoot( actor ).y .. ' ' .. bounds.left .. ' ' .. bounds.top .. ' ' .. bounds.right .. ' ' .. bounds.bottom )

	local tileSprite = mget( tileX, tileY )

	local tileCollides = fget( tileSprite, 1 ) ~= 0

	if tileCollides then

		local vel = effectiveVelocity( actor )

		local colliding, normalX, normalY, hitAxis, adjustmentDistance = table.unpack( rect_collision_adjustment( 
			bounds.left, bounds.top, bounds.right, bounds.bottom, 
			tileX * PIXELS_PER_TILE, tileY * PIXELS_PER_TILE, ( tileX + 1 ) * PIXELS_PER_TILE, ( tileY + 1 ) * PIXELS_PER_TILE,
			vel.x, vel.y ))

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

function updateActor( actor )

	if not actor.inert and ( actor.config.inert == nil or not actor.config.inert ) then

		if actor.config.tick ~= nil then
			actor.config.tick( actor )
		end
		
		actor.lastPos:set( actor.pos.x, actor.pos.y )

		actor.vel = actor.vel - actor.vel * GLOBAL_DRAG
		actor.pos = actor.pos + actor.vel

		if actor.mayCollideWithTerrain then
			for i = 1, 4 do
				local collided = collideActorWithTerrain( actor )
				if not collided then break end
			end
		end

		if actor.config.convertToBlockWhenPossible then
			tryPlaceAsBlock( actor, effectiveVelocity( actor ):cardinalDirection(), actor.pos )
		end
	end

	updateAnimation( actor )
end

function updateActorsOnBlocks()
	for _, actor in ipairs( actors ) do
		-- TODO check corners and pick what I'm *most* on

		local actorTileX = worldToTile( actor.pos.x )
		local actorTileY = worldToTile( actor.pos.y )

		local tileIndex = worldTilePosToIndex( actorTileX, actorTileY )

		if blocksToActors[ tileIndex ] == nil then blocksToActors[ tileIndex ] = {} end

		table.insert( blocksToActors[ tileIndex ], actor )
	end
end

function updateActors()

	for _, actor in ipairs( actors ) do
		updateActor( actor )
	end

	collideActors()

	-- clamp the player to the world
	player.pos.x = clamp( player.pos.x, 16, WORLD_SIZE_PIXELS - 16 )
	player.pos.y = clamp( player.pos.y, 16, WORLD_SIZE_PIXELS - 16 )
end

blockAnimSets = {
	{ speed = 2, frames = range( 261, 264 ) },
	{ speed = 2, frames = range( 265, 268 ) },
	{ speed = 2, frames = range( 293, 293+3 ) },
	{ speed = 2, frames = range( 297, 297+3 ) },
	{ speed = 2, frames = range( 325, 325+3 ) },
	{ speed = 2, frames = range( 329, 329+3 ) },
	{ speed = 2, frames = range( 357, 357+3 ) },
	{ speed = 2, frames = range( 361, 361+3 ) },
}

function worldTilePosToIndex( x, y )
	return x + y * WORLD_SIZE_TILES
end

function forEachActorOnBlock( x, y, callback )
	local tileIndex = worldTilePosToIndex( x, y )
	local actors = blocksToActors[ tileIndex ]
	if actors then
		for _, actor in ipairs( actors ) do
			if not actor.config.inert then
				callback( actor )
			end
		end
	end
end

CONVEYOR_FORCE = 0.105

function conveyorTick( x, y, blockType, blockTypeIndex )
	local direction = blockType.conveyor.direction
	forEachActorOnBlock( x, y, function( actor )
		actorConveyorForce( actor, direction * CONVEYOR_FORCE )
	end)
end

function withBlockTypeAt( x, y, callback )
	local blockType, blockTypeIndex = blockTypeAt( x, y )
	return callback( blockType, blockTypeIndex )
end

function blockAbuttingSouthVersion( blockTypeIndex, southIsConveyor )
	local baseType = baseBlockTypeIndex( blockTypeIndex )

	if southIsConveyor then
		return baseType + 4
	else
		return baseType
	end
end

function blockPickupVersion( blockTypeIndex )
	return blockTypeForIndex( blockTypeIndex )
end

function conveyorOnPlaced( x, y, blockType, blockTypeIndex )
	withBlockTypeAt( x, y + 1, function( southernBlockType, southernBlockTypeIndex )
		withBaseBlockType( southernBlockTypeIndex, function( southernBlockTypeBase, southernBaseBlockTypeIndex )
			local desiredIndex = blockAbuttingSouthVersion( blockTypeIndex, southernBlockTypeBase and southernBlockTypeBase.conveyor ~= nil )
			-- trace( 'cp: ' .. x .. ' ' .. y .. ' ' .. blockTypeIndex .. ' ' .. southernBaseBlockTypeIndex .. ' ' .. desiredIndex )
			mset( x, y, desiredIndex )
		end)
	end)
end

blockTypes = {
	[256] = {
		mayBePlacedUpon = true,
	},
	[257] = {
		mayBePlacedUpon = true,
	},
	[258] = {
		mayBePlacedUpon = true,
	},
	[259] = {
		mayBePlacedUpon = true,
	},
	[260] = {
		mayBePlacedUpon = true,
	},
	[261] = {
		actorConfigName = 'conveyor',
		conveyor = { direction = vec2:new( 0, -1 )},
		onPlaced = conveyorOnPlaced,
		tick = conveyorTick,
	},
	[261+4] = {
		baseType = 261,
	},
	[261+32] = {
		actorConfigName = 'conveyor',
		conveyor = { direction = vec2:new( 1, 0 )},
		onPlaced = conveyorOnPlaced,
		tick = conveyorTick,
	},
	[261+32+4] = {
		baseType = 261+32,
	},
	[261+32*2] = {
		actorConfigName = 'conveyor',
		conveyor = { direction = vec2:new( 0, 1 )},
		onPlaced = conveyorOnPlaced,
		tick = conveyorTick,
	},
	[261+32*2+4] = {
		baseType = 261+32*2,
	},
	[261+32*3] = {
		actorConfigName = 'conveyor',
		conveyor = { direction = vec2:new( -1, 0 )},
		onPlaced = conveyorOnPlaced,
		tick = conveyorTick,
	},
	[261+32*3+4] = {
		baseType = 261+32*3,
	},
}

function baseBlockTypeIndex( blockTypeIndex )
	local blockType = blockTypes[ blockTypeIndex ]
	if blockType == nil then return blockTypeIndex end

	if blockType.baseType and blockType.baseType ~= blockTypeIndex then
		return baseBlockTypeIndex( blockType.baseType )
	end
	return blockTypeIndex
end

function withBaseBlockType( blockTypeIndex, callback )
	local baseTypeIndex = baseBlockTypeIndex( blockTypeIndex )
	local baseType = blockTypes[ baseTypeIndex ]
	if baseType ~= nil then
		return callback( baseType, baseTypeIndex )
	end
end

function blockTypeForIndex( blockTypeIndex )
	return blockTypes[ blockTypeIndex ]
end

function blockTypeAt( x, y )
	local blockTypeIndex = mget( x, y )
	return blockTypeForIndex( blockTypeIndex ), blockTypeIndex
end

function forEachBlock( callback )
	for y = 0, WORLD_SIZE_TILES - 1 do
		for x = 0, WORLD_SIZE_TILES - 1 do
			local tileSpriteIndex = mget( x, y )
			if tileSpriteIndex >= MIN_ACTIVE_BLOCK_INDEX then
				local blockType = blockTypeForIndex( tileSpriteIndex )
				if blockType ~= nil then
					callback( x, y, blockType, tileSpriteIndex )
				end
			end
		end
	end
end

function fixupBlockData()
	for _, animSet in pairs( blockAnimSets ) do
		local animSetBase = animSet.frames[ 1 ]

		for _, block in pairs( animSet.frames ) do
			if blockTypes[ block ] == nil then
				blockTypes[ block ] = {}
			end
			
			if block ~= animSetBase then
				blockTypes[ block ].baseType = animSetBase
			end
			blockTypes[ block ].animSet = animSet
		end
	end

	forEachBlock( function( x, y, blockType, blockTypeIndex )
		withBaseBlockType( blockTypeIndex, function( baseBlockType, baseBlockTypeIndex )
			if baseBlockType.onPlaced ~= nil then 
				baseBlockType.onPlaced( x, y, blockType, blockTypeIndex ) 
			end
		end)
	end )
end


function updateBlock( x, y, blockType, blockTypeIndex )
	assert( blockType )

	withBaseBlockType( blockTypeIndex, function( baseBlockType, baseBlockTypeIndex )
		if baseBlockType.tick then
			baseBlockType.tick( x, y, baseBlockType, baseBlockTypeIndex )
		end
		
		local animSet = blockType.animSet
		if animSet then
			local changeSpeed = animSet.speed or 4
			local frame = math.floor( ticks // changeSpeed )

			local block = animSet.frames[ 1 + frame % #animSet.frames ]

			mset( x, y, block )
		end
	end)
end

function updateBlocks()
	forEachBlock( function( x, y, blockType, blockTypeIndex )
		updateBlock( x, y, blockType, blockTypeIndex )
	end )
end

function updateActive()

	blocksToActors = {}

	updateInput( player )

	updateActors()
	updateActorsOnBlocks()
	updateBlocks()

	ticks = ticks + 1
end

function update()

	updateActive()

	updateScreenParams()

	realTicks = realTicks + 1
end


-- DRAW

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

function worldBoundsToTerrainBounds( bounds )
	local tileBounds = {
		left = 		worldToTile( bounds.left ),
		top = 		worldToTile( bounds.top ),
		right = 	worldToTile( bounds.right ),
		bottom = 	worldToTile( bounds.bottom ),
	}
	return tileBounds
end

function drawMap()
	local bounds = viewBounds()
	local tiles = worldBoundsToTerrainBounds( bounds )
	local wid = tiles.right - tiles.left + 1
	local hgt = tiles.bottom - tiles.top + 1

	map( tiles.left, tiles.top, tiles.left * PIXELS_PER_TILE, tiles.top * PIXELS_PER_TILE, wid, hgt )
end

function actorDrawBounds()
	local bounds = viewBounds()
	expandContractRect( bounds, actorDrawMargin )
	return bounds
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

function draw()
	cls( 0xff000040 )

	updateViewTransform()

	fillp( 0 )
	drawMap()

	drawActors()

	camera( 0, 0 )
	drawDebug()
end

startGame()