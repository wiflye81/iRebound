//
//  HelloWorldLayer.mm
//  PongBox-cc2
//
//  Created by Gwenole Le bris on 02/01/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

// Import the interfaces
#import "PongBoxLayer.h"
#import "Paddle.h"
#import "Ball.h"
//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

enum {
	kTagParentNode = 1,
};

#pragma mark - HelloWorldLayer

@implementation pongBoxLayer

@synthesize spritesBatchNode = _spritesBatchNode;
@synthesize player_one = _player_one;
@synthesize player_two = _player_two;
@synthesize first_ball = _first_ball;
@synthesize world = _world;
@synthesize gravity = _gravity;
@synthesize screenBorderDef = _screenBorderDef;
@synthesize screenBorderBody = _screenBorderBody;
@synthesize screenBorderShape = _screenBorderShape;
@synthesize boxShapeDef = _boxShapeDef;
@synthesize ScreenSize = _ScreenSize;
@synthesize Player_World_Joint = _Player_World_Joint;
@synthesize debugDraw = _debugDraw;
@synthesize Score_P1 = _Score_P1;
@synthesize Score_P2 = _Score_P2;
@synthesize contactListener = _contactListener;
@synthesize UpWorldFixture = _UpWorldFixture;
@synthesize DownWorldFixture = _DownWorldFixture;
@synthesize LeftWorldFixture = _LeftWorldFixture;
@synthesize RightWorldFixture = _RightWorldFixture;

const float kPointsToMeterRatio = 32.0f;

int turn = 0;

+(CCScene *) scene {
    CCScene *scene = [CCScene node];
    
    pongBoxLayer *layer = [pongBoxLayer node];
    
    [scene addChild: layer];
    
    return scene;
}

- (void) dealloc {
    [_spritesBatchNode release];
    [_player_one release];
    [_player_two release];
    [_first_ball release];
    [super dealloc];
}

-(float) pixelsToMeterRatio
{
	//return (CC_CONTENT_SCALE_FACTOR() * kPointsToMeterRatio);
    return (kPointsToMeterRatio);
}

-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), [self pixelsToMeterRatio]);
}

-(void) draw
{
	[super draw];
    
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
    
	_world->DrawDebugData();	
    
	kmGLPopMatrix();
	
	CHECK_GL_ERROR_DEBUG();
}

- (void)init_physics
{
    float widthInMeters = _ScreenSize.height / [self pixelsToMeterRatio];
    float heightInMeters = _ScreenSize.width / [self pixelsToMeterRatio];
    
    b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
    b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 0);
    b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
    b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);
    
    _gravity = b2Vec2(0.0f, 0.0f);
    _world = new b2World(gravity);
    _screenBorderDef.position.Set(0,0);
    _screenBorderBody = _world->CreateBody(&_screenBorderDef);
    
    screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
    _DownWorldFixture = _screenBorderBody->CreateFixture(&screenBorderShape, 0);
    
    screenBorderShape.Set(lowerRightCorner, upperRightCorner);
    _RightWorldFixture = _screenBorderBody->CreateFixture(&screenBorderShape, 0);
    
    screenBorderShape.Set(upperRightCorner, upperLeftCorner);
    _UpWorldFixture = _screenBorderBody->CreateFixture(&screenBorderShape, 0);
    
    screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
    _LeftWorldFixture = _screenBorderBody->CreateFixture(&screenBorderShape, 0);
    
//    uint32 flags;
//    _world->SetDebugDraw(&_debugDraw);
//    flags += b2Draw::e_shapeBit;
//    flags += b2Draw::e_jointBit;
//    _debugDraw.SetFlags(flags);
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        // init Physics (to put in method just for test
        
		_ScreenSize = [CCDirector sharedDirector].winSize;
        
        [self init_physics];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        
        _contactListener = new MyContactListener();
        _world->SetContactListener(_contactListener);
        
        // 1.
        self.spritesBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"PongBox.png"];
        [self addChild:self.spritesBatchNode];
        // 2.
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PongBox.plist"];
        
        // Score display
        
        _Score_P1 = [[CCLabelTTF	labelWithString:[NSString stringWithFormat:@"%d",_player_one.Score] fontName:@"Arial" fontSize:25]retain];
        _Score_P1.position = ccp(220,300);
        [self addChild:_Score_P1];
        
        _Score_P2 = [[CCLabelTTF	labelWithString:[NSString stringWithFormat:@"%d",_player_one.Score] fontName:@"Arial" fontSize:25]retain];
        _Score_P2.position = ccp(260,300);
        [self addChild:_Score_P2];
        
        _player_one = [[Paddle alloc] initWithGameLayer:self position:ccp(25, 90)];
        _player_one.Score = 0;
        //_player_two = [[Paddle alloc] initWithGameLayer:self position:ccp(_ScreenSize.height - 25, _ScreenSize.width - 90)];
        //_player_two.Score = 0;
        _first_ball = [[Ball alloc] initWithGameLayer:self position:ccp(_ScreenSize.width / 2, _ScreenSize.height / 2)];
        [self schedule:@selector(update:)];
	}
	return self;
}

// Touch Events

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (_player_one.mouseJoint != NULL)
        return FALSE;
    
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x / kPointsToMeterRatio, location.y / kPointsToMeterRatio);
    
    _Player_World_Joint.bodyA = _screenBorderBody;
    _Player_World_Joint.bodyB = _player_one.Body;
    _Player_World_Joint.target = locationWorld;
    _Player_World_Joint.collideConnected = true;
    _Player_World_Joint.maxForce = 1000.0f * _player_one.Body->GetMass();
    
    _player_one.mouseJoint = (b2MouseJoint *)_world->CreateJoint(&_Player_World_Joint);
    _player_one.Body->SetAwake(TRUE);
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (_player_one.mouseJoint == NULL)
        return;
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x / kPointsToMeterRatio, location.y / kPointsToMeterRatio);
    
    _player_one.mouseJoint->SetTarget(locationWorld);
    
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (_player_one.mouseJoint) {
        _world->DestroyJoint(_player_one.mouseJoint);
        _player_one.mouseJoint = NULL;
    }
    return;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_player_one.mouseJoint) {
        _world->DestroyJoint(_player_one.mouseJoint);
        _player_one.mouseJoint = NULL;
    }  
}


- (void)update:(ccTime)dt {
    
    //It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
    
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	_world->Step(dt, velocityIterations, positionIterations);
    
    for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
	{
        b2Vec2 BodyVelocity = b->GetLinearVelocity();
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            //NSLog(@"Body pos x = %f et x = %f expected Sprite: x = %f et y = %f", b->GetPosition().x, b->GetPosition().y, b->GetPosition().x * 32, b->GetPosition().y * 32);
            
            // For iPhone 4
            //[myActor setPosition:ccp((b->GetPosition().y * 16), (b->GetPosition().x * 16))];
            [myActor setPosition:ccp((b->GetPosition().x * kPointsToMeterRatio), (b->GetPosition().y * kPointsToMeterRatio))];
            
            // For iPhone 3GS
            //[myActor setPosition:ccp(b->GetPosition().x * 32, b->GetPosition().y * 32)];
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
    
    _player_one.position = _player_one.sprite.position;
    //_player_two.position = _player_two.sprite.position;
    _first_ball.position = _first_ball.sprite.position;
    
    
    std::vector<MyContact>::iterator pos;
    for(pos = _contactListener->_contacts.begin();
        pos != _contactListener->_contacts.end(); ++pos)
    {
        MyContact contact = *pos;
        
        if ((contact.fixtureA == _player_one.Fixture && contact.fixtureB == _first_ball.Fixture) ||
            (contact.fixtureA == _first_ball.Fixture && contact.fixtureB == _player_one.Fixture))
        {
            NSLog(@"Ball hit bottom!");
        }
        
        if ((contact.fixtureA == _RightWorldFixture && contact.fixtureB == _first_ball.Fixture) ||
            (contact.fixtureA == _first_ball.Fixture && contact.fixtureB == _RightWorldFixture))
        {
            NSLog(@"Ball hit Right, Score++!");
        }
        
        
    }
    
    //NSLog(@"Ball x position: %f et screen size = %f", _first_ball.position.x, _ScreenSize.height);
    
    // Score management
//    if ((_first_ball.position.x < _ScreenSize.height / 2) && turn == 1)
//    {
//        turn = 0;
//    }
//    
//    if ((_first_ball.position.x > _ScreenSize.height / 2) && turn == 0)
//    {
//        turn = 1;
//    }
    
    if ((_first_ball.position.x >= (_ScreenSize.height - 25)) && turn == 0)
    {
        _player_one.Score++;
        turn = 1;
        [_Score_P1 setString:[NSString stringWithFormat:@"%d",_player_one.Score]];
        //NSLog(@"Score increase: %i", _player_one.Score);
    }
    
    if ((_first_ball.position.x < 25) && turn == 1)
    {
        _player_two.Score++;
        turn = 0;
        [_Score_P2 setString:[NSString stringWithFormat:@"%d",_player_two.Score]];
        //NSLog(@"Score decrease: %i", _player_one.Score);
        
    }
    
    
}

@end
