-- Ludum Dare 46

function lerp( a, b, alpha )
	return a + (b-a) * alpha
end

-- Configuration
text_scale( 1 )
filter_mode( "Nearest" )

screen_size( 220, 128 )

WHITE = 0xFFE3E0F2
BRIGHT_RED = 0xFFC23324
LIGHT_GRAY = 0xFFB0B8BF


MIN_ACTIVE_BLOCK_INDEX = 256

SPRITE_SHEET_PIXELS_X = 512
PIXELS_PER_TILE = 16
TILES_X = SPRITE_SHEET_PIXELS_X // PIXELS_PER_TILE

sprite_size( PIXELS_PER_TILE )

WORLD_SIZE_TILES = 32
WORLD_SIZE_PIXELS = WORLD_SIZE_TILES * PIXELS_PER_TILE

DEFAULT_CHROMATIC_ABERRATION = 0.4
DEFAULT_BARREL = 0.2
DEFAULT_BLOOM_INTENSITY = 0.1
DEFAULT_BURN_IN = 0.1

barrel_ = DEFAULT_BARREL
bloom_intensity_ = DEFAULT_BLOOM_INTENSITY
bloom_contrast_ = 10
bloom_brightness_ = 1
burn_in_ = DEFAULT_BURN_IN
chromatic_aberration_ = DEFAULT_CHROMATIC_ABERRATION
noise_ = 0.025
rescan_ = 0.75
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
	if type( x ) == 'table' then
		self.x = x.x
		self.y = x.y
	else
		self.x = x
		self.y = y ~= nil and y or x
	end
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

function table.copy( t )
	local u = {}
	for k, v in pairs(t) do u[k] = v end
	return setmetatable(u, getmetatable(t))
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

function proportion( x, a, b )
	return ( x - a ) / ( b - a )
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

function saveInitialMap()
	initialMap = {}
	for y = 0, WORLD_SIZE_TILES - 1 do
		initialMap[ y ] = {}
		for x = 0, WORLD_SIZE_TILES - 1 do
			initialMap[ y ][ x ] = mget( x, y )
		end
	end
end

function restoreInitialMap()
	if initialMap == nil then 
		trace( 'no initial map to restore' )
		return 
	end

	for y = 0, WORLD_SIZE_TILES - 1 do
		for x = 0, WORLD_SIZE_TILES - 1 do
			mset( x, y, initialMap[ y ][ x ] )
		end
	end
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

ARM_OFFSET = vec2:new( 0, -2 )

function pickupPoint( byActor, useArmLength )
	assert( useArmLength )
	return byActor.pos + ARM_OFFSET + byActor.heading * useArmLength
end

function placementPoint( byActor, useArmLength )
	assert( useArmLength )
	return byActor.pos + ARM_OFFSET + byActor.heading * useArmLength
end

function blockInteractionTile( byActor, useArmLength )
	local point = pickupPoint( byActor, useArmLength )

	local pickupTileX = worldToTile( point.x )
	local pickupTileY = worldToTile( point.y )

	if  pickupTileX < 0 or pickupTileX >= WORLD_SIZE_TILES or
		pickupTileY < 0 or pickupTileY >= WORLD_SIZE_TILES then
			return nil
	end

	return pickupTileX, pickupTileY
end

function blockToPickup( byActor, useArmLength )

	local pickupTileX, pickupTileY = blockInteractionTile( byActor, useArmLength )

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
	assert( position )
	local blockTypeForItem = actorPlacementBlock( item, direction )
	if blockTypeForItem == nil then return nil end

	-- clear block placement area?
	local placementPos = position or item.pos
	local placementX = worldToTile( placementPos.x )
	local placementY = worldToTile( placementPos.y )
	if not mayPlaceBlockOnBlock( placementX, placementY ) then 
		return nil 
	end

	setBlockType( placementX, placementY, blockTypeForItem )

	actorCountAdd( item, -1 )

	return placementX, placementY
end

function playerTryPlaceAsBlock( item, direction, position )

	local placementX, placementY = tryPlaceAsBlock( item, direction, position )
	
	if placementX ~= nil then
		
		-- succeeded
		if item.deleted then
			player.heldItem = nil
		end

		createActor( 'placement_poof', placementX * PIXELS_PER_TILE, placementY * PIXELS_PER_TILE )
		sfx( 'drop_block' )
	end

	return placementX, placementY
end

DEFAULT_ARM_LENGTH = 4

function tryDropHeldItem( options )

	local item = player.heldItem
	if not item then return end

	options = options or { 
		forceAsBlock = false,
		forceAsItem = false,
		preferDropAll = false
	}

	local dropPoint = placementPoint( player, DEFAULT_ARM_LENGTH )

	local placed = false
	if not options.forceAsItem or options.forceAsBlock then
		-- try to place as a block
		local placementX, placementY = playerTryPlaceAsBlock( item, player.heading:cardinalDirection(), dropPoint )
		placed = placed or placementX ~= nil
	end

	if not placed then
		-- try to place as an item

		sfx( 'drop_item' )

		-- does this item have count?
		if not options.preferDropAll and (( item.count or 1 ) > 1 ) then
			createActor( item.configKey, dropPoint.x, dropPoint.y )
			actorCountAdd( item, -1 )
		else
			-- no count, or we're dropping them all. don't create a new item, just drop this one.

			makeNotHeld( item, dropPoint )
		end
	end
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
		if actor.held or not actor.config.mayBePickedUp or actor == forActor then return end
		
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
	item.z = 0
	item.vel = vec2:new( 0, 0)
	item.lastPos = vec2:new( x, y )
	item.vel = vec2:new( 0, 0 )
	item.thrust = vec2:new( 0, 0 )
	item.heading = vec2:new( -1, 0 )

	createShadowForActor( item )
end

function makeNotHeld( item, dropPoint )
	item.held = false
	item.pos:set( dropPoint )
	item.lastPos:set( item.pos )
	item.vel:set( 0 )
	item.ulOffset = nil
	item.z = 0
	item.inert = false
	item.nonColliding = false
	if item.shadow ~= nil then deleteActor( item.shadow ) end
	player.heldItem = nil
end

function tryPickupActor( byActor )

	function tryArmLength( armLength )
		-- look for actors near the pick area
		local point = pickupPoint( byActor, armLength )
		local pickupActor = findPickupActorNear( byAcor, point.x, point.y, 12 )
		if pickupActor == byActor or pickupActor == nil then return nil end

		if byActor.heldItem == nil or canCombine( pickupActor, byActor.heldItem ) then
			sfx( 'lift' )
			worldState.pickedUp = true

			if byActor.heldItem ~= nil then
				combineResources( byActor.heldItem, pickupActor )
			else
				makeHeld( pickupActor )
				byActor.heldItem = pickupActor
			end
			
			return pickupActor
		else
			return nil
		end
	end

	local item = tryArmLength( DEFAULT_ARM_LENGTH )
	if item == nil then
		return tryArmLength( 0 )
	end
	return item
end

function tryPickupBlock( byActor )

	function tryArmLength( armLength )
		local blockX, blockY = blockToPickup( byActor, armLength )
		if blockX ~= nil then
			-- place in inventory
			local creationPos = vec2:new( blockX, blockY ) * PIXELS_PER_TILE

			local blockIndex = mget( blockX, blockY )
			local pickupActor = createActorForBlockIndex( blockIndex, creationPos.x, creationPos.y )

			if pickupActor and ( byActor.heldItem == nil or canCombine( pickupActor, byActor.heldItem )) then

				createActor( 'pickup_particles', blockX * PIXELS_PER_TILE + 8, blockY * PIXELS_PER_TILE + 16 )
				sfx( 'lift' )
				worldState.pickedUp = true

				if byActor.heldItem ~= nil then
					combineResources( byActor.heldItem, pickupActor )
				else
					makeHeld( pickupActor )
					pickupActor.pos = creationPos + actorULOffset( pickupActor )
					byActor.heldItem = pickupActor
				end

				clearBlock( blockX, blockY )

				return pickupActor
			else
				return nil
			end
		end
		return nil
	end

	local item = tryArmLength( DEFAULT_ARM_LENGTH )
	if item == nil then
		return tryArmLength( 0 )
	end
	return item
end

function onButton1()
	-- Pickup, prefering actor.
	if tryPickupActor( player ) == nil then
		if tryPickupBlock( player ) == nil then

			-- Couldn't pickup. Drop?
			if player.heldItem ~= nil then
				tryDropHeldItem()
			end
		end
	end
end

function onButton2()
	-- try to drop.
	if player.heldItem ~= nil then
		tryDropHeldItem( { forceAsItem = false, preferDropAll = true } ) -- forcing drop
	else
		-- -- Pickup, prefering block.
		-- if tryPickupBlock( player ) == nil then
		-- 	tryPickupActor( player )
		-- end
	end
end

function updateInput( actor )

	local thrust = vec2:new()

	if btn( 0 ) then
		worldState.moved = true
		thrust.x = thrust.x - 1
	end

	if btn( 1 ) then
		worldState.moved = true
		thrust.x = thrust.x + 1
	end

	if btn( 2 ) then 
		worldState.moved = true
		thrust.y = thrust.y - 1
	end

	if btn( 3 ) then
		worldState.moved = true
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

	-- local desiredViewPoint = ( player.pos - vec2:new( 0, 10 ) ) - viewOffset + player.vel * 32
	
	-- if viewPoint == nil then viewPoint = desiredViewPoint end
	-- viewPoint = lerp( viewPoint, desiredViewPoint, 0.05 )

	local viewPoint = ( player.pos - vec2:new( 0, 10 ) ) - viewOffset

	setWorldView( viewPoint.x, viewPoint.y )
end

function populateWithActors()

	createActor( 'chip', 10 * PIXELS_PER_TILE, 21 * PIXELS_PER_TILE )
	createActor( 'chip', 11 * PIXELS_PER_TILE, 21 * PIXELS_PER_TILE )
	createActor( 'chip', 11 * PIXELS_PER_TILE, 21 * PIXELS_PER_TILE )
end

function startGame()

	music( 'ld46', 0.2 )

	worldState = {}

	blockData = {}
	
	restoreInitialMap()

	actors = {}
	robot = nil
	player = nil

	fixupBlocks()

	chromatic_aberration_ = DEFAULT_CHROMATIC_ABERRATION
	barrel_ = 				DEFAULT_BARREL
	bloom_intensity_ = 		DEFAULT_BLOOM_INTENSITY
	burn_in_ = DEFAULT_BURN_IN

	color_multiplied_r = 1
	color_multiplied_g = 1
	color_multiplied_b = 1
	color_multiplied_r_smoothed = 0
	color_multiplied_g_smoothed = 0
	color_multiplied_b_smoothed = 0

	barrel_ = DEFAULT_BARREL
	barrel_smoothed = barrel_


	player = createActor( 'player', 9 * PIXELS_PER_TILE, 21 * PIXELS_PER_TILE )

	populateWithActors()

	updateViewTransform()
end

function updateShadow( actor )
	if actor.shadowHost == nil then return end
	actor.pos:set( actor.shadowHost.pos )
end

function drawShadow( actor )
	local outerRadius = math.min( actor.shadowHost.config.dims.x, actor.shadowHost.config.dims.y ) * 0.5
	local innerRadius = outerRadius * 0.75
	fillp( ~0x8421 )
	circ( actor.pos.x, actor.pos.y, outerRadius, 0xFF000000, outerRadius - innerRadius )

	fillp( 0xA5A5 )
	circfill( actor.pos.x, actor.pos.y, innerRadius, 0xFF000000 )
	fillp( 0 )
end

GLOBAL_DRAG = 0.175

function updateHeldItem( holder, item )
	item.pos = lerp( item.pos, holder.pos + vec2:new( 0, 1 + math.sin( ticks * 0.06 ) * 1.5 ), 0.08 )
	item.lastPos:set( item.pos )
	item.vel:set( 0, 0 )
	item.z = lerp( item.z or 0, 16, 0.08 )
end

function updatePlayer( actor )
	if player.heldItem then
		updateHeldItem( player, player.heldItem )
	end
end

function canCombine( a, b )
	assert( a and b )
	return a.configKey == b.configKey
		   and ( a.count or 1 ) + ( b.count or 1 ) <= RESOURCE_MAX_COUNT_DEFAULT
		   and a.config.mayCombine
		   and b.config.mayCombine 
end

function canCombineOnGround( a, b )
	assert( a and b )
	return canCombine( a, b ) and
		   not a.held and not b.held
end

function combineResources( a, b )
	assert( a.configKey == b.configKey )

	local total = ( a.count or 1 ) + ( b.count or 1 )

	a.count = math.min( total, RESOURCE_MAX_COUNT_DEFAULT )

	deleteActor( b )
end

function onResourcesCollide( a, b )
	if canCombineOnGround( a, b ) then
		a.pos:set( b.pos )
		a.lastPos:set( a.pos )
		a.vel:set( 0 )	
		combineResources( a, b )
	end
end

ROBOT_TIME_TO_LOSE_FUEL_FROM_ONE_WOOD_SECONDS = 15
FUEL_LOSS_PER_TICK = 1
FUEL_LOSS_PER_SECOND = FUEL_LOSS_PER_TICK * 60
ROBOT_FUEL_PER_WOOD = FUEL_LOSS_PER_SECOND * ROBOT_TIME_TO_LOSE_FUEL_FROM_ONE_WOOD_SECONDS
ROBOT_MAX_FUEL = ROBOT_FUEL_PER_WOOD * 9
MAX_FUEL_FOR_NEEDINESS = FUEL_LOSS_PER_SECOND * 30
MIN_FUEL_FOR_MAX_NEEDINESS_DISPLAY = FUEL_LOSS_PER_SECOND * 5
MIN_FUEL_FOR_MAX_GUAGE_FLICKER = MIN_FUEL_FOR_MAX_NEEDINESS_DISPLAY + FUEL_LOSS_PER_SECOND * 5

function onRobotOutOfFuel( actor )
	if not worldState.gameLost then
		worldState.gameLost = true
		color_multiplied_g = 0
		color_multiplied_b = 0
		music( '' )
		sfx( 'fail' )
	end
end

function onRobotCompletedAllRecipes()
	if not worldState.gameWon then
		worldState.gameWon = true
		sfx( 'win' )
	end
end

function robotTick( actor )
	if worldState.robotFound and not worldState.robotDialoguing then
		actor.fuel = actor.fuel ~= nil and actor.fuel or actor.config.fuel
		actor.fuel = actor.fuel - FUEL_LOSS_PER_TICK

		local fuelNeediness = clamp( proportion( actor.fuel, MAX_FUEL_FOR_NEEDINESS, MIN_FUEL_FOR_MAX_NEEDINESS_DISPLAY ), 0, 1 ) ^ 2
		
		-- trace( actor.fuel .. ' ' .. fuelNeediness)

		chromatic_aberration_ = lerp( DEFAULT_CHROMATIC_ABERRATION, 1.0, fuelNeediness )
		barrel_ = 				lerp( DEFAULT_BARREL, 				0.7, fuelNeediness )
		bloom_intensity_ = 		lerp( DEFAULT_BLOOM_INTENSITY, 		0.2, fuelNeediness )
		burn_in_ =		 		lerp( DEFAULT_BURN_IN,		 		0.5, fuelNeediness )

		local fuelDesperation = clamp( proportion( actor.fuel, MIN_FUEL_FOR_MAX_NEEDINESS_DISPLAY, 0 ), 0, 1 )
		color_multiplied_g = lerp( 1.0, 0.5, fuelDesperation )
		color_multiplied_b = lerp( 1.0, 0.5, fuelDesperation )

		if actor.fuel <= 0 then
			actor.fuel = 0
			onRobotOutOfFuel( actor )
		end
	end
end


RESOURCE_MAX_COUNT_DEFAULT = 9

actorConfigurations = {
	player = {
		dims = vec2:new( 7, 13 ),
		maxThrust = 0.35,
		ulOffset = vec2:new( 8, 15 ),
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
	shadow = {
		dims = vec2:new( 0, 0 ),
		ulOffset = vec2:new( 0, 8 ),
		tileSizeX = 1,
		tileSizeY = 1,
		nonColliding = true,
		inert = false,
		tick = updateShadow,
		draw = drawShadow,
	},
	robot = {
		tick = robotTick,
		dims = vec2:new( 24, 26 ),
		ulOffset = vec2:new( 16, 34 ),
		nonColliding = true,
		fadeForPlayer = true,
		tileSizeX = 2,
		tileSizeY = 2,
		animations = {
			idle = { speed = 0.1, frames = { 10, 12, 14 }},
		},
	},
	tree = {
		inert = true,
		nonColliding = true,
		fadeForPlayer = true,
		dims = vec2:new( 18, 56 ),
		ulOffset = vec2:new( 16, 64 ),
		tileSizeX = 2,
		tileSizeY = 4,
		animations = {
			idle = { speed = 0, frames = { 320 }},
		},
	},
	tree_rubber = {
		inert = true,
		nonColliding = true,
		fadeForPlayer = true,
		dims = vec2:new( 30, 43 ),
		ulOffset = vec2:new( 24, 48 ),
		tileSizeX = 3,
		tileSizeY = 3,
		animations = {
			idle = { speed = 0, frames = { 322 }},
		},
	},
	placement_poof = {
		inert = true,
		nonColliding = true,
		ulOffset = vec2:new( 16, 0 ),
		tileSizeX = 3,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0.25, frames = {					
				224, 224+3*2, 224+3*3, 224+3*4, 224+3*5, 224+3*6, 224+3*7, 224+3*8,
				{ 	
					frame = 224+3*8, 
					event = function( actor )
						deleteActor( actor )
					end 
				}
			} },
		},
	},
	pickup_particles = {
		inert = true,
		nonColliding = true,
		ulOffset = vec2:new( 8, 16 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0.35, frames = {					
				128, 128+1, 128+2, 128+3, 128+4, 128+5, 128+6, 128+7, 128+8, 128+9, 128+10, 128+11, 128+12, 128+13, 128+14,
				{ 	
					frame = 128+15, 
					event = function( actor )
						deleteActor( actor )
					end 
				}
			} },
		},
	},
	conveyor = {
		mayBePickedUp = true,
		mayCombine = true,
		fadeForPlayer = true,
		convertToBlockWhenPossible = true,
		blockPlacementType = { 261, 261+32, 261+32*2, 261+32*3 } ,
		dims = vec2:new( 16, 16 ),
		ulOffset = vec2:new( 8, 16 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 261 }},
		},
	},
	oven = {
		mayBePickedUp = true,
		mayCombine = true,
		fadeForPlayer = true,
		convertToBlockWhenPossible = true,
		blockPlacementType = { 512, 512, 512, 512 } ,
		dims = vec2:new( 16, 16 ),
		ulOffset = vec2:new( 8, 16 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 512 }},
		},
	},
	combiner = {
		mayBePickedUp = true,
		mayCombine = true,
		fadeForPlayer = true,
		convertToBlockWhenPossible = true,
		blockPlacementType = { 515, 515, 515, 515 } ,
		dims = vec2:new( 16, 16 ),
		ulOffset = vec2:new( 8, 16 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 515 }},
		},
	},
	sensor = {
		mayBePickedUp = true,
		mayCombine = true,
		fadeForPlayer = true,
		convertToBlockWhenPossible = true,
		blockPlacementType = { 517, 517, 517, 517 },
		dims = vec2:new( 16, 16 ),
		ulOffset = vec2:new( 8, 16 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 521 }},
		},
	},
	harvester = {
		mayBePickedUp = true,
		mayCombine = true,
		fadeForPlayer = true,
		convertToBlockWhenPossible = true,
		blockPlacementType = { 519, 519, 519, 519 } ,
		dims = vec2:new( 16, 16 ),
		ulOffset = vec2:new( 8, 16 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 522 }},
		},
	},

	-- RESOURCES
	iron_ore = {
		mayBePickedUp = true,
		mayCombine = true,
		dims = vec2:new( 7, 7 ),
		ulOffset = vec2:new( 8, 11 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 192 }},
		},
	},
	iron = {
		mayBePickedUp = true,
		mayCombine = true,
		dims = vec2:new( 9, 8 ),
		ulOffset = vec2:new( 9, 11 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 193 }},
		},
	},
	copper = {
		mayBePickedUp = true,
		mayCombine = true,
		dims = vec2:new( 9, 8 ),
		ulOffset = vec2:new( 9, 11 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 194 }},
		},
	},
	gold_ore = {
		mayBePickedUp = true,
		mayCombine = true,
		dims = vec2:new( 7, 7 ),
		ulOffset = vec2:new( 8, 11 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 195 }},
		},
	},
	gold = {
		mayBePickedUp = true,
		mayCombine = true,
		dims = vec2:new( 9, 8 ),
		ulOffset = vec2:new( 9, 11 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 196 }},
		},
	},
	wood = {
		mayBePickedUp = true,
		mayCombine = true,
		dims = vec2:new( 11, 6 ),
		ulOffset = vec2:new( 8, 11 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 197 }},
		},
	},
	rubber = {
		mayBePickedUp = true,
		mayCombine = true,
		dims = vec2:new( 7,6 ),
		ulOffset = vec2:new( 8, 10 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 198 }},
		},
	},
	stone = {
		mayBePickedUp = true,
		mayCombine = true,
		dims = vec2:new( 8,11 ),
		ulOffset = vec2:new( 9, 10 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0, frames = { 199 }},
		},
	},
	chip = {
		mayBePickedUp = true,
		mayCombine = true,
		dims = vec2:new( 10, 8 ),
		ulOffset = vec2:new( 9, 12 ),
		tileSizeX = 1,
		tileSizeY = 1,
		animations = {
			idle = { speed = 0.1, frames = { 200, 201 }},
		},
	},
}

function createShadowForActor( actor )
	actor.shadow = createActor( 'shadow', actor.pos.x, actor.pos.y )
	actor.shadow.shadowHost = actor
end

function deleteActor( actor )
	assert( actor ~= nil )

	if actor.deleted then return end

	-- trace( 'deleting actor ' .. actor.configKey )

	if actor.shadow ~= nil then
		actor.shadow.shadowHost = nil
		deleteActor( actor.shadow )
	end

	actor.deleted = true
	tableRemoveValue( actors, actor )
end

function createActor( configKey, x, y )
	local config = actorConfigurations[ configKey ]
	assert( config )

	local actor = {
		configKey = configKey,
		config = config,
		birthdate = now(),
		pos = vec2:new( x, y ),
		lastPos = vec2:new( x, y ),
		vel = vec2:new( 0, 0 ),
		thrust = vec2:new( 0, 0 ),
		heading = vec2:new( 0, 1 ),
		animFrame = 0,
		lastFrame = 0,
		occluding = false,
		occlusionOpacity = 1.0
	}

	table.insert( actors, actor )

	-- trace( 'actors ' .. #actors)

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

function actorOccludingBounds( actor )
	return {
		left = actor.pos.x - actor.config.dims.x / 2,
		top =  actor.pos.y - actor.config.dims.y,
		right = actor.pos.x + actor.config.dims.x / 2,
		bottom = actor.pos.y,
	}
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
	local ul = actor.pos - actorULOffset( actor )

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

function floatTermsToColor( r, g, b )

	function term( x )
		return math.floor( x * 0xFF )
	end

	return 0xFF000000 | ( term( r ) << 16 ) | ( term( g ) << 8 ) | term( b )
end

function colorToFloatTerms( color )
	local r = ( color & 0x00FF0000 ) >> 16
	local g = ( color & 0x0000FF00 ) >> 8
	local b = ( color & 0x000000FF ) >> 0

	function term( x )
		return x / 0xFF
	end

	return term( r ), term( g ), term( b )
end

function colorLerp( a, b, alpha )
	local ar, ag, ab = colorToFloatTerms( a )
	local br, bg, bb = colorToFloatTerms( b )

	return floatTermsToColor( lerp( ar, br, alpha ), lerp( ag, bg, alpha ), lerp( ab, bb, alpha ) )
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

	local myBounds = actorOccludingBounds( actor )
	local playerBounds = expandContractRect( actorOccludingBounds( player ), 0 )

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

function actorULOffset( actor )
	local offset = actor.ulOffset or actor.config.ulOffset
	assert( offset )

	local z = actor.z or 0
	return offset + vec2:new( 0, z )
end

function drawCount( count, x, y )
	printShadowed( '' .. count, round( x ), round( y ), LIGHT_GRAY )
end

function drawActorCount( actor )
	if actor.count ~= nil and actor.count > 1 then
		local actorBounds = actorVisualBounds( actor )
		local countPos = vec2:new( actorBounds.right - 4, actorBounds.top )
		drawCount( actor.count, countPos.x, countPos.y )
	end
end

function drawActor( actor )
	local abortDraw = false
	if actor.config.draw ~= nil then
		abortDraw = actor.config.draw( actor )
	end

	if abortDraw then return end

	local animation = currentAnimation( actor )
	if animation == nil then return end

	local frames = animation.frames

	local cur_frame = math.floor( actor.animFrame ) % #frames

	local sprite = frameSpriteIndex( frames[ cur_frame + 1 ] )

	fillp( bitPatternForAlpha( actorOpacityForDither( actor ) ))

	local flipX = actor.heading:majorAxis() == 0 and actor.heading.x > 0

	local ulOffset = actorULOffset( actor )

	spr( sprite, 
		round( actor.pos.x - ulOffset.x ), 
		round( actor.pos.y - ulOffset.y ), 
		actor.config.tileSizeX, 
		actor.config.tileSizeY, 
		flipX,
		false,
		actorColor( actor ),
		actorAdditiveColor( actor )
	)

	fillp( 0 )

	drawActorCount( actor )
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
	if actor.collidingActors ~= nil and actor.collidingActors[ other ] == nil then
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
	if actor.collidingActors ~= nil and actor.collidingActors[ other ] ~= nil then
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

	if rectsOverlap( boundsA, boundsB ) then
		actorOnCollide( actorA, actorB )
		actorOnCollide( actorB, actorA )
	else
		actOnNotCollide( actorA, actorB )
		actOnNotCollide( actorB, actorA )
	end
end

function eachNearbyActorToPos( pos, radius, callback )
	local tileX = worldToTile( pos.x )
	local tileY = worldToTile( pos.y )

	local radiusSquared = radius * radius

	local radiusInTiles = math.max( 1, radius / PIXELS_PER_TILE )
	for y = tileY - radiusInTiles, tileY + radiusInTiles do
		for x = tileX - radiusInTiles, tileX + radiusInTiles do
			forEachActorOnBlock( x, y, function( tileActor )
				if ( tileActor.pos - pos ):lengthSquared() <= radiusSquared then
					callback( tileActor )
				end
			end)		
		end
	end
end

function eachNearbyActorToActor( actor, radius, callback )
	return eachNearbyActorToPos( actor.pos, radius, function( otherActor )
		if otherActor ~= actor then
			callback( otherActor )
		end
	end)
end

function collideActors()

	for i, actor in ipairs( actors ) do
		if actor ~= player then
			collideActorPair( player, actor )
		end
	end
end

function collideActorWithTile( actor, tileX, tileY )
	local bounds = actorBounds( actor )

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


function actorCheckSurroundingTilesForNearbyActors( actor, radius ) 
	eachNearbyActorToActor( actor, radius, function( otherActor )
		onResourcesCollide( actor, otherActor )
	end)
end

function updateActor( actor )

	if actor.additiveColor ~= nil then
		actor.additiveColor = colorLerp( actor.additiveColor, 0, 0.08 )
	end

	if not actor.inert and ( actor.config.inert == nil or not actor.config.inert ) then

		if actor.config.tick ~= nil then
			actor.config.tick( actor )
		end

		actor.lastPos:set( actor.pos )

		actor.vel = actor.vel - actor.vel * GLOBAL_DRAG
		actor.pos = actor.pos + actor.vel

		if actor.mayCollideWithTerrain then
			for i = 1, 4 do
				local collided = collideActorWithTerrain( actor )
				if not collided then break end
			end
		end

		actorCheckSurroundingTilesForNearbyActors( actor, 10 )

		if actor.config.convertToBlockWhenPossible then
			tryPlaceAsBlock( actor, effectiveVelocity( actor ):cardinalDirection(), actor.pos )
		end
	end

	updateAnimation( actor )
end

function updateActorsOnBlocks()
	blocksToActors = {}

	for _, actor in ipairs( actors ) do
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

	-- collideActors()

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

	{ speed = 6, frames = range( 513, 514 ) },
	{ speed = 6, frames = range( 519, 520 ) },
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

CONVEYOR_FORCE = 0.106

function conveyorTick( x, y, blockType, blockTypeIndex )
	local direction = blockType.conveyor.direction
	forEachActorOnBlock( x, y, function( actor )
		actorConveyorForce( actor, direction * CONVEYOR_FORCE )
	end)
end

function withBlockTypeAt( x, y, callback )
	local blockType, blockTypeIndex = blockTypeAt( x, y )
	if blockType == nil then return nil end

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
			mset( x, y, desiredIndex )
		end)
	end)
end

function amendedObject( object, callback )
	local amended = table.copy( object )
	callback( amended )
	return amended
end

function tileCenterToWorldPos( x, y )
	return ( vec2:new( x, y ) + vec2:new( 0.5, 0.5 )) * PIXELS_PER_TILE
end

function ingredientCount( list, configKey )
	for _, item in ipairs( list ) do
		if item[ 1 ] == configKey then return item[ 2 ] end
	end
	return 0
end

function consumeActor( actor )
	actorCountAdd( actor, -1 )
end

function blockStartRecipe( x, y, blockType, blockTypeIndex, recipe, availableIngredients )
	-- consume ingredients
	for key, count in pairs( recipe.inputs ) do
		for _, actor in ipairs( availableIngredients[ key ] ) do
			if count <= 0 then break end
			consumeActor( actor )
			count = count - 1
		end
	end

	-- cook
	local data = dataForBlockAt( x, y )
	data.doneTick = ticks + recipe.duration * 60
	data.recipe = recipe

	setBlockType( x, y, blockType.on_version )
end

function creationPositionFromBlockAt( x, y )
	return tileCenterToWorldPos( x, y ) + vec2:new( 0, 14 )
end

function blockCompleteRecipe( x, y, blockType, blockTypeIndex )

	local data = dataForBlockAt( x, y )
	local recipe = data.recipe
	if recipe == nil then return end

	local creationPosition = creationPositionFromBlockAt( x, y )

	if recipe.output then
		for key, count in pairs( recipe.output ) do
			for i = 1, count do
				createActor( key, creationPosition.x, creationPosition.y )
			end
		end	
	end

	if recipe.effect then
		recipe.effect( x, y, blockType, blockTypeIndex )
	end

	sfx( 'produce', 0.5 )
end

function blockUpdateCooking( x, y, blockType, blockTypeIndex )
	local data = dataForBlockAt( x, y )
	if data == nil then return end

	local doneTick = data.doneTick or ticks
	if ticks >= doneTick then
		blockCompleteRecipe( x, y, blockType, blockTypeIndex )
		setBlockType( x, y, blockType.off_version )
	end
end

function blockCheckRecipes( x, y, blockType, blockTypeIndex )
	local recipes = blockType.recipes
	if recipes == nil or #recipes == 0 then return end

	local availableIngredients = {}

	eachNearbyActorToPos( tileCenterToWorldPos( x, y ), 16, function( actor )
		if not actor.held then
			if availableIngredients[ actor.configKey ] == nil then
				availableIngredients[ actor.configKey ] = {}
			end
			-- insert the actor once for each of its counts
			for i = 1, ( actor.count or 1 ) do
				table.insert( availableIngredients[ actor.configKey ], actor )
			end
		end
	end)

	for i, recipe in ipairs( recipes ) do
		if recipe.enabled == nil or recipe.enabled then
			local satisfied = true
			for key, count in pairs( recipe.inputs ) do
				if availableIngredients[ key ] ~= nil then
					local availableCount = #availableIngredients[ key ]
					if( availableCount or 0 ) < count then
						satisfied = false
						break
					end
				else
					satisfied = false
					break
				end
			end

			if satisfied then
				blockStartRecipe( x, y, blockType, blockTypeIndex, recipe, availableIngredients )
			end
		end
	end
end

local DEFAULT_HARVEST_RATE = 5

function harvesterTick( x, y, blockType, blockTypeIndex )
	-- get the block just north.

	withBlockTypeAt( x, y - 1, function( neighborBlockType, neighborBlockTypeIndex )
		withBaseBlockType( neighborBlockTypeIndex, function( neighborBlockTypeBase, neighborBaseBlockTypeIndex )
			if neighborBlockTypeBase.harvestSource ~= nil then
				local harvestRate = ( neighborBlockTypeBase.harvestRate or DEFAULT_HARVEST_RATE ) * 60
				if ( ticks + 1 ) % harvestRate == 0 then
					local creationPosition = creationPositionFromBlockAt( x, y )
					createActor( neighborBlockTypeBase.harvestSource, creationPosition.x, creationPosition.y )
					sfx( 'produce', 0.5 )
				end
			end
		end)
	end)
end

function conveyorRotatedVersion( fromBlockTypeIndex, turnsClockwise )
	local MIN = 256
	local MAX = 256 + 32*4

	local turned = fromBlockTypeIndex + turnsClockwise * 32

	turned = MIN + ( turned - MIN ) % ( MAX - MIN )

	return turned
end

function onConveyorTriggered( x, y, blockType, blockTypeIndex, turningOn )
	if dataForBlockAt( x, y ).triggeredOn ~= turningOn then
		mset( x, y, conveyorRotatedVersion( blockTypeIndex, turningOn and 1 or -1 ))
	end
end

function sensorChanged( x, y, blockType, blockTypeIndex, turningOn )
	-- trigger or untrigger the south block
	withBlockTypeAt( x, y + 1, function( southernBlockType, southernBlockTypeIndex )
		withBaseBlockType( southernBlockTypeIndex, function( southernBlockTypeBase, southernBaseBlockTypeIndex )

			if southernBlockTypeBase.onTriggered ~= nil then
				southernBlockTypeBase.onTriggered( x, y + 1, southernBlockType, southernBlockTypeIndex, turningOn )
			end
			dataForBlockAt( x, y + 1 ).triggeredOn = turningOn
		end)
	end)
end

function sensorTick( x, y, blockType, blockTypeIndex, triggerIfSensed, toTypeIfTriggered )
	local sensedActor = nil
	forEachActorOnBlock( x, y - 1, function( actor )
		if  not actor.held and 
			actor ~= player and
			actor.shadowHost == nil and
			not actor.config.invisibleToSensors then
			sensedActor = actor
		end
	end)		

	if triggerIfSensed == ( sensedActor ~= nil ) then
		sensorChanged( x, y, blockType, blockTypeIndex, triggerIfSensed )
		mset( x, y, toTypeIfTriggered )
	end
end

function sensorTickOff( x, y, blockType, blockTypeIndex )
	sensorTick( x, y, blockType, blockTypeIndex, true, blockTypeIndex + 1 )
end

function sensorTickOn( x, y, blockType, blockTypeIndex )
	sensorTick( x, y, blockType, blockTypeIndex, false, blockTypeIndex - 1 )
end

function reportIfNil( label, value )
	trace( label .. ' nil? ' .. ( value == nil and 'true' or 'false' ) )
end

function robotOnCompletedRecipe()

	sfx( 'eat_wood' )

	-- reportIfNil( 'blockConfigs', blockConfigs )
	-- reportIfNil( 'robot_base_off', blockConfigs.robot_base_off )
	-- reportIfNil( 'blockConfigs', blockConfigs.robot_base_off.recipes )
	-- reportIfNil( '2', blockConfigs.robot_base_off.recipes[ 2 ] )

	local recipes = blockConfigs.robot_base_off.recipes

	assert( robot.recipeSequence ~= nil )
	assert( recipes[ robot.recipeSequence ] ~= nil )
	
	if robot.recipeSequence > 1 then
		recipes[ robot.recipeSequence ].enabled = false
	end

	robot.recipeSequence = robot.recipeSequence + 1

	if robot.recipeSequence > #recipes then
		onRobotCompletedAllRecipes()
	else
		recipes[ robot.recipeSequence ].enabled = true
	end
end

function robotOnWood( x, y, blockType, blockTypeIndex )
	-- trace( 'robotOnWood' )
	robot.fuel = math.min( ROBOT_MAX_FUEL, robot.fuel + ROBOT_FUEL_PER_WOOD )
	guage.flashBrightness = 1
	robot.additiveColor = 0xFFFFFF00

	if robot.recipeSequence == nil or robot.recipeSequence == 1 then
		robot.recipeSequence = 1
		robotOnCompletedRecipe()
	end
end
function robotOnIron( x, y, blockType, blockTypeIndex )
	-- trace( 'robotOnIron' )
	robotOnCompletedRecipe()
end
function robotOnConveyor( x, y, blockType, blockTypeIndex )
	-- trace( 'robotOnConveyor' )
	robotOnCompletedRecipe()
end
function robotOnSensor( x, y, blockType, blockTypeIndex )
	-- trace( 'robotOnSensor' )
	robotOnCompletedRecipe()
end
function robotOnChip( x, y, blockType, blockTypeIndex )
	-- trace( 'robotOnChip' )
	robotOnCompletedRecipe()
end

ROBOT_NAME = '@73N'

ROBOT_RECIPE_DURATION = 0

function robotBaseClass()
	return {
		name = ROBOT_NAME,
		sponsoredActorConfig = 'robot',
		drawRecipes = false,
		on_version = 290,
		recipes = {
			{
				inputs = { wood = 1 },
				effect = robotOnWood,
				duration = ROBOT_RECIPE_DURATION,
			},
			{
				enabled = false,
				inputs = { iron = 4 },
				effect = robotOnIron,
				duration = ROBOT_RECIPE_DURATION,
			},
			{
				enabled = false,
				inputs = { conveyor = 9 },
				effect = robotOnConveyor,
				duration = ROBOT_RECIPE_DURATION,
			},
			{
				enabled = false,
				inputs = { sensor = 2 },
				effect = robotOnSensor,
				duration = ROBOT_RECIPE_DURATION,
			},
			{
				enabled = false,
				inputs = { chip = 1 },
				effect = robotOnChip,
				duration = 1.5,
			},
		},	
		onPlaced = function( x, y, blockType, blockTypeIndex ) 
			if robot == nil then
				robot = createActor( blockType.sponsoredActorConfig, ( x + 0.5 ) * PIXELS_PER_TILE + 22, ( y + 1 ) * PIXELS_PER_TILE - 1 )
				robot.fuel = FUEL_LOSS_PER_SECOND * 60 * 4
			end
		end,
		tick = function( x, y, blockType, blockTypeIndex )
			blockCheckRecipes( x, y, blockType, blockTypeIndex )
		end,
	}
end

blockData = {}

function dataForBlockAt( x, y )
	local index = worldTilePosToIndex( x, y )
	if blockData[ index ] == nil then blockData[ index ] = {} end
	return blockData[ index ]
end

CONVEYOR_EXPLANATION = { 'When placing, direction', "depends on", "which way you're moving." }
SENSOR_EXPLANATION = { 'Detects items.', 'Triggers Conveyors.' }
HARVESTER_EXPLANATION = 'Gathers resources.'
COMBINER_EXPLANATION = { 'Makes items and blocks.' }
OVEN_EXPLANATION = 'Turns ore into metal.'

blockConfigs = {
	ground = {
		mayBePlacedUpon = true,
	},
	conveyor = {
		name = 'Conveyor',
		explanation = CONVEYOR_EXPLANATION,
		actorConfigName = 'conveyor',
		conveyor = { direction = vec2:new( 0, -1 )},
		onPlaced = conveyorOnPlaced,
		tick = conveyorTick,
		onTriggered = onConveyorTriggered,
	},
	harvester = {
		name = 'Harvester',
		explanation = HARVESTER_EXPLANATION,
		actorConfigName = 'harvester',
		onPlaced = function( x, y, blockType, blockTypeIndex ) end,
		tick = harvesterTick,
	},
	combiner_off = {
		name = 'Combiner',
		explanation = COMBINER_EXPLANATION,
		actorConfigName = 'combiner',
		on_version = 516,
		recipes = {
			{
				inputs = { iron = 3, rubber = 2 },
				output = { conveyor = 1 },
				duration = 0.5,
			},
			{
				inputs = { stone = 2, iron = 3 },
				output = { harvester = 1 },
				duration = 0.5,
			},
			{
				inputs = { iron = 2, gold = 2 },
				output = { sensor = 1 },
				duration = 0.5,
			}, 
			{
				inputs = { stone = 3, wood = 2 },
				output = { oven = 1 },
				duration = 0.5,
			},
			{
				inputs = { oven = 1, copper = 3 },
				output = { combiner = 1 },
				duration = 0.5,
			},
			{
				inputs = { copper = 9, gold = 9 },
				output = { chip = 1 },
				duration = 0.5,
			},
		},
		onPlaced = function( x, y, blockType, blockTypeIndex ) end,
		tick = function( x, y, blockType, blockTypeIndex )
			if worldState.robotFound then
				blockCheckRecipes( x, y, blockType, blockTypeIndex )
			end
		end, 
	},
	combiner_on = {
		name = 'Combiner',
		explanation = COMBINER_EXPLANATION,
		actorConfigName = 'combiner',
		off_version = 515,
		onPlaced = function( x, y, blockType, blockTypeIndex ) end,
		tick = function( x, y, blockType, blockTypeIndex )
			blockUpdateCooking( x, y, blockType, blockTypeIndex )
		end,
	},
	sensor_off = {
		name = 'Sensor',
		explanation = SENSOR_EXPLANATION,
		actorConfigName = 'sensor',
		on_version = 518,
		tick = sensorTickOff,
	},
	sensor_on = {
		name = 'Sensor',
		explanation = SENSOR_EXPLANATION,
		actorConfigName = 'sensor',
		off_version = 517,
		tick = sensorTickOn,
	},
	tree_base = {
		sponsoredActorConfig = 'tree',
		harvestSource = 'wood',
		harvestRate = 10,
		onPlaced = function( x, y, blockType, blockTypeIndex ) 
			sponsoredActor = createActor( blockType.sponsoredActorConfig, ( x + 0.5 ) * PIXELS_PER_TILE, ( y + 1 ) * PIXELS_PER_TILE )
		end,
	},
	rubber_tree_base = {
		sponsoredActorConfig = 'tree_rubber',
		harvestSource = 'rubber',
		harvestRate = 12,
		onPlaced = function( x, y, blockType, blockTypeIndex ) 
			sponsoredActor = createActor( blockType.sponsoredActorConfig, ( x + 0.5 ) * PIXELS_PER_TILE, ( y + 1 ) * PIXELS_PER_TILE )
		end,
	},
	source_iron_ore = { name = 'Iron Ore', harvestSource = 'iron_ore', harvestRate = 15 },
	source_gold_ore = { name = 'Gold Ore', harvestSource = 'gold_ore', harvestRate = 60 }, 
	source_copper = { name = 'Copper', harvestSource = 'copper', harvestRate = 20 }, 
	source_stone = { name = 'Stone', harvestSource = 'stone', harvestRate = 12 }, 
	robot_base_off = robotBaseClass(),
	robot_base_on = {
		drawRecipes = false,
		off_version = 288,
		tick = function( x, y, blockType, blockTypeIndex )
			blockUpdateCooking( x, y, blockType, blockTypeIndex )
		end,
	},
}

blockTypes = {
	[261] = blockConfigs.conveyor,
	[261+4] = {
		baseType = 261,
	},
	[261+32] = amendedObject( blockConfigs.conveyor, function( conveyor ) 
		conveyor.conveyor = { direction = vec2:new( 1, 0 ) }
	end),
	[261+32+4] = {
		baseType = 261+32,
	},
	[261+32*2] = amendedObject( blockConfigs.conveyor, function( conveyor ) 
		conveyor.conveyor = { direction = vec2:new( 0, 1 ) }
	end),
	[261+32*2+4] = {
		baseType = 261+32*2,
	},
	[261+32*3] = amendedObject( blockConfigs.conveyor, function( conveyor ) 
		conveyor.conveyor = { direction = vec2:new( -1, 0 ) }
	end),
	[261+32*3+4] = {
		baseType = 261+32*3,
	},

	[512] = {
		name = 'Oven',
		explanation = OVEN_EXPLANATION,
		actorConfigName = 'oven',
		on_version = 513,
		recipes = {
			{
				inputs = { iron_ore = 2 },
				output = { iron = 2 },
				duration = 2,
			},
			{
				inputs = { gold_ore = 2 },
				output = { gold = 1 },
				duration = 3,
			},
		},
		tick = function( x, y, blockType, blockTypeIndex )
			blockCheckRecipes( x, y, blockType, blockTypeIndex )
		end,
	},
	[513] = {
		name = 'Oven',
		explanation = OVEN_EXPLANATION,
		actorConfigName = 'oven',
		off_version = 512,
		tick = function( x, y, blockType, blockTypeIndex )
			blockUpdateCooking( x, y, blockType, blockTypeIndex )
		end,
	},
	[515] = blockConfigs.combiner_off,
	[516] = blockConfigs.combiner_on,
	[517] = blockConfigs.sensor_off,
	[518] = blockConfigs.sensor_on,
	[519] = blockConfigs.harvester,

	-- [288] = blockConfigs.robot_base_off,
	[290] = blockConfigs.robot_base_on,

	[480] = blockConfigs.tree_base,
	[481] = blockConfigs.source_iron_ore,
	[482] = blockConfigs.source_gold_ore,
	[483] = blockConfigs.source_copper,
	[484] = blockConfigs.source_stone,
	[485] = blockConfigs.rubber_tree_base,
}

function setBlockTypeRange( config, start, count )
	for i = start, start + count - 1 do
		blockTypes[ i ] = config
	end
end

function blockTypeForIndex( blockTypeIndex )
	return blockTypes[ blockTypeIndex ]
end

function baseBlockTypeIndex( blockTypeIndex )
	local blockType = blockTypeForIndex( blockTypeIndex )
	if blockType == nil then return blockTypeIndex end

	if blockType.baseType and blockType.baseType ~= blockTypeIndex then
		return baseBlockTypeIndex( blockType.baseType )
	end
	return blockTypeIndex
end

function withBaseBlockType( blockTypeIndex, callback )
	local baseTypeIndex = baseBlockTypeIndex( blockTypeIndex )
	local baseType = blockTypeForIndex( baseTypeIndex )
	if baseType ~= nil then
		return callback( baseType, baseTypeIndex )
	end
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

function fixupBlocks()
	setBlockTypeRange( blockConfigs.ground, 256, 5 )

	blockConfigs.robot_base_off = robotBaseClass()
	blockTypes[ 288 ] = blockConfigs.robot_base_off

	
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
		local animSet = blockType.animSet
		if animSet then
			local changeSpeed = animSet.speed or 4
			local frame = math.floor( ticks // changeSpeed )

			local block = animSet.frames[ 1 + frame % #animSet.frames ]

			mset( x, y, block )
		end

		if baseBlockType.tick then
			baseBlockType.tick( x, y, baseBlockType, baseBlockTypeIndex )
		end		
	end)
end

function updateBlocks()
	forEachBlock( function( x, y, blockType, blockTypeIndex )
		updateBlock( x, y, blockType, blockTypeIndex )
	end )
end

function speechSound()
	sfx( 'speech' .. math.floor( randInt( 1, 4 )) )
end

function onRobotFound()
	if not worldState.robotFound then
		worldState.robotDialoguing = true
		sfx( 'speech3' )
	end
end

function updateGameLogic()
	if not worldState.robotDialoguing then
		if player.pos.x >= 19 * PIXELS_PER_TILE and player.pos.y >= 13 * PIXELS_PER_TILE and player.pos.y <= 17 * PIXELS_PER_TILE then
			onRobotFound()
		end
	end
end

function updateActive()

	updateGameLogic()

	updateInput( player )

	updateActors()
	updateActorsOnBlocks()
	updateBlocks()

	ticks = ticks + 1
end

function pressToRestart()
	if btnp( 4 ) or btnp( 5 ) then
		startGame()
	end
end

function updateGameWon()
	pressToRestart()
end

function updateGameLost()
	pressToRestart()
end

function updateDialogue()
	if btnp( 4 ) or btnp( 5 ) then
		worldState.dialogueStep = worldState.dialogueStep + 1

		if worldState.dialogueStep > #dialogue then
			worldState.robotDialoguing = false
			worldState.robotFound = true
		else
			speechSound()
		end
	end
end

function update()

	if worldState.robotDialoguing then
		updateDialogue()
	elseif worldState.gameWon then
		updateGameWon()
	elseif worldState.gameLost then
		updateGameLost()
	else
		updateFuelGuage()
		updateActive()
	end

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

function actorCountAdd( actor, amount )
	amount = amount ~= nil and amount or 1

	if actor.count == nil then actor.count = 1 end
	actor.count = actor.count + amount

	if actor.count > RESOURCE_MAX_COUNT_DEFAULT then
		actor.count = RESOURCE_MAX_COUNT_DEFAULT
	end

	if actor.count < 1 then 
		deleteActor( actor )
	end

	-- count established.
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
		actor.occluding = actor.config.fadeForPlayer and not actor.held and actorOccludesPlayer( actor )
		if actor.occluding then
			numOccludingActors = numOccludingActors + 1
		end
	end

	local targetOpacity = numOccludingActors > 0 and ( 0.2 / ( numOccludingActors ^ (1/2) )) or 1.0

	for _, actor in ipairs( drawnActors ) do
		local actorOpacity = actor.occluding and targetOpacity or 1.0
		actor.occlusionOpacity = lerp( actor.occlusionOpacity, actorOpacity, 0.2 )

		drawActor( actor )
	end

end

guage = {
	flashBrightness = 1,
}

function updateFuelGuage()
	guage.flashBrightness = lerp( guage.flashBrightness, 0.0, 0.1 )

	local guageFlashSpeed = ( robot.fuel <= MIN_FUEL_FOR_MAX_GUAGE_FLICKER ) and 10 or ( robot.fuel <= MAX_FUEL_FOR_NEEDINESS and 60 or 0 )

	if guageFlashSpeed > 0 and ( ticks % guageFlashSpeed ) == 0 then
		guage.flashBrightness = 1
		sfx( 'warning' )
	end
end

function drawHUDFuelGuage()
	if not worldState.robotFound then return end

	local screen_mid = screen_wid() // 2
	local fuelGuageMaxWid = screen_wid() * 0.65
	local guageWid = fuelGuageMaxWid * clamp( proportion( robot.fuel, MIN_FUEL_FOR_MAX_NEEDINESS_DISPLAY, ROBOT_MAX_FUEL ), 0, 1 )
	local halfWid = guageWid // 2

	local guageColor = colorLerp( BRIGHT_RED, WHITE, guage.flashBrightness )

	rectfill( screen_mid - halfWid, screen_hgt() - 5, screen_mid + halfWid, screen_hgt() - 3, guageColor )
end

RECIPE_TEXT_COLOR = 0xFFE3E0F2
RECIPE_TEXT_OFFSET_Y = 4

function drawResourceIcon( resourceKey, x, y )
	local config = actorConfigurations[ resourceKey ]
	local sprite = config.animations.idle.frames[1]
	if sprite == nil then return end

	spr( sprite, x, y + 1, 1, 1, false, false, 0xFF000000 )
	spr( sprite, x, y )

	return 8
end

function drawIngredientList( ingredients, x, y )
	local i = 1
	for key, count in pairs( ingredients ) do
		if i > 1 then
			printShadowed( '+', x, y + RECIPE_TEXT_OFFSET_Y, RECIPE_TEXT_COLOR )
			x = x + 8
		end

		x = x + drawResourceIcon( key, x, y ) + 4

		if count > 1 then
			drawCount( count, x, y )
		end
		x = x + 8

		i = i + 1
	end

	return x
end

function drawBlockRecipes( blockType )

	local y = 26
	for _, recipe in ipairs( blockType.recipes ) do
		if recipe.output ~= nil then
			local x = drawIngredientList( recipe.output, 10, y ) + 2

			printShadowed( '<=', x, y + RECIPE_TEXT_OFFSET_Y, RECIPE_TEXT_COLOR )
			x = x + 14

			drawIngredientList( recipe.inputs, x, y )

			y = y + 17
		end
	end
end

function printShadowed( text, x, y, color, shadowColor )
	print( text, x, y+1, shadowColor or 0xFF161C21 )
	print( text, x, y, color )
end

function drawHUDBlockInfo()
	local screen_mid = screen_wid() // 2

	local x = worldToTile( player.pos.x )
	local y = worldToTile( player.pos.y )

	withBlockTypeAt( x, y, function( blockType, blockTypeIndex )
		withBaseBlockType( blockTypeIndex, function( blockTypeBase, baseBlockTypeIndex )
			local textX = 6
			local textY = 6
			local name = blockTypeBase.name
			if name ~= nil then
				name = name .. ( blockTypeBase.harvestSource ~= nil and ' - use Harvester' or '' )
				printShadowed( name or '', textX, textY, BRIGHT_RED )
				textY = textY + 10
			end

			if type( blockTypeBase.explanation ) == 'table' then
				for _, text in ipairs( blockTypeBase.explanation ) do					
					printShadowed( text, textX, textY, 0xFFB0B8BF )
					textY = textY + 10
				end
			else
				print( blockTypeBase.explanation or '', textX, textY, 0xFFB0B8BF )
				textY = textY + 10
			end

			if blockTypeBase.drawRecipes ~= false and blockTypeBase.recipes ~= nil then
				drawBlockRecipes( blockTypeBase )
			end

			if blockTypeBase.draw ~= nil then
				blockTypeBase.draw()
			end
		end)
	end)
end

function printRightAligned( text, x, y, color, printFn )
	( printFn or print )( text, x - #text * 8, y, color )
end

function printCentered( text, x, y, color, printFn )
	( printFn or print )( text, x - #text * 4, y, color )
end

function drawRobotNeed( needRecipe )
	if worldState.robotFound then
		printRightAligned( ROBOT_NAME, screen_wid() - 10, 6, WHITE, printShadowed )
		printRightAligned( ' needs', screen_wid() - 10, 14, WHITE, printShadowed )
		drawIngredientList( needRecipe.inputs, screen_wid() - 16 - 10, 22 )
	end
end

function drawHUDQuest()
	local robotRecipes = blockConfigs.robot_base_off.recipes
	assert( robotRecipes ~= nil )

	local sequence = robot.recipeSequence or 1
	if sequence > #robotRecipes then return end

	local currentNeed = robotRecipes[ sequence ]
	assert( currentNeed ~= nil )

	drawRobotNeed( currentNeed )
end

function drawInstructions()
	if not worldState.moved then
		printCentered( 'ARROW KEYS TO MOVE.', screen_wid() // 2, screen_hgt() - (16+20), BRIGHT_RED, printShadowed )
	end

	if not worldState.pickedUp then
		printCentered( 'Z and X TO PICK UP', screen_wid() // 2, screen_hgt() - (16+10), WHITE, printShadowed )
		printCentered( 'AND PLACE THINGS.', screen_wid() // 2, screen_hgt() - (16), WHITE, printShadowed )
		
	end
end

function drawHUD()
	camera( 0, 0 )

	drawInstructions()

	drawHUDFuelGuage()

	drawHUDQuest()

	drawHUDBlockInfo()
end

function drawPlayAgain( x )
	printCentered( 'PLAY AGAIN!', x, 90, WHITE, printShadowed )
	printCentered( '[X]', x, 100, WHITE, printShadowed )
end

function drawGameWon()
	camera( 0, 0 )
	local midX = screen_wid() / 2
	printCentered( 'YOU WON!', midX, 24, BRIGHT_RED, printShadowed )
	printCentered( 'You Kept ' .. ROBOT_NAME .. ' Alive', midX, 40, WHITE, printShadowed )
	printCentered( 'and helped him get fixed!', midX, 50, WHITE, printShadowed )

	drawPlayAgain( midX )
end

function drawGameLost()
	camera( 0, 0 )
	local midX = screen_wid() / 2
	printCentered( 'GAME OVER', midX, 24, BRIGHT_RED, printShadowed )
	printCentered( 'You failed', midX, 40, WHITE, printShadowed )
	printCentered( 'to Keep ' .. ROBOT_NAME .. ' Alive.', midX, 50, WHITE, printShadowed )

	drawPlayAgain( midX )
end

dialogue = {
	{ "HELLO AGAIN, OLD FRIEND!", 
	  "Yes, it's me: " .. ROBOT_NAME .. "!" },
	{ "It's been",
	  "SUCH a LONG time!" },
	{ "As you may have noticed,", 
	  "I've seen BETTER DAYS." },
	{ "I'd be much OBLIGED", 
	  "if you would HELP me." },
	{ "I need WOOD to stay alive,", 
	  "and some other ITEMS", 
	  "to help FIX me." },
	{ "Would you FIND or MAKE",
	  "these items", 
	  "and BRING them to me?" },
	{ "You may need to create", 
	  "almost a FACTORY",
	  "to make it all." },
	{ "And DON'T FORGET:" },
	{ "I'll need WOOD",
	  "from time to time",
	  "to KEEP ALIVE!" },
	{ "I can't THANK YOU enough!" },
}

function drawDialogue()
	camera( 0, 0 )

	worldState.dialogueStep = worldState.dialogueStep or 1

	local midX = screen_wid() / 2

	local speech = dialogue[ worldState.dialogueStep ]

	local y = 24
	for i, text in ipairs( speech ) do
		printCentered( text, midX, y, (worldState.dialogueStep == 1 and i == 1 ) and BRIGHT_RED or WHITE, printShadowed )
		y = y + 12
	end

	printCentered( '[X] or [Z] to continue', midX, 100, BRIGHT_RED, printShadowed )
end

TITLE_FADE_DURATION_SECS = 3

function drawTitle()

	if worldState.robotDialoguing or worldState.robotFound then return end

	if( worldState.pickedUp or worldState.moved ) and worldState.titleFadeStart == nil then
		worldState.titleFadeStart = ticks
	end

	local opacity = 1

	if worldState.titleFadeStart ~= nil then
		local titleShownDuration = ( ticks - worldState.titleFadeStart ) / 60

		if titleShownDuration > TITLE_FADE_DURATION_SECS then
			return
		end

		opacity = ( 1 - clamp( titleShownDuration / TITLE_FADE_DURATION_SECS, 0, 1 )) ^ (1/2)
	end

	local midX = screen_wid()/2

	-- fillp( bitPatternForAlpha( opacity * 0.1 ))
	-- spr( 19, midX - 2.5*16, 20, 6, 2, false, false, 0xFF000000 )

	fillp( bitPatternForAlpha( opacity ))
	spr( 19, midX - 42, 4, 6, 2 )
	printCentered( 'KEEP. HIM. ALIVE.', midX + 4, 36, WHITE, printShadowed )

	fillp(0)
end

function draw()
	-- cls( 0xff000040 )

	updateViewTransform()

	fillp( 0 )
	drawMap()

	drawActors()

	if worldState.robotDialoguing then
		drawDialogue()
	elseif worldState.gameWon then
		drawGameWon()
	elseif worldState.gameLost then
		drawGameLost()
	else
		drawHUD()
	end

	drawTitle()

	camera( 0, 0 )
	drawDebug()
end

saveInitialMap()

worldState = {}

startGame()

