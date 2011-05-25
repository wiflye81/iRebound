//
//  HelloWorldLayer.mm
//  PongBox
//
//  Created by Gwenole Le bris on 21/05/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.


// HelloWorldLayer implementation

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize motionManager;

const float kPointsToMeterRatio = CC_CONTENT_SCALE_FACTOR() * 32.0f;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
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
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
}

-(void) addNewSpriteWithCoords:(CGPoint)p
{
    //	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
}



-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
    	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            //NSLog(@"Body pos x = %f et x = %f expected Sprite: x = %f et y = %f", b->GetPosition().x, b->GetPosition().y, b->GetPosition().x * 32, b->GetPosition().y * 32);
            
            // For iPhone 4
            //[myActor setPosition:ccp((b->GetPosition().x * 16) + 10, (b->GetPosition().y * 16) - 10)];
            [myActor setPosition:ccp((b->GetPosition().x * 16), (b->GetPosition().y * 16))];
            
            // For iPhone 3GS
            //[myActor setPosition:ccp(b->GetPosition().x * 32, b->GetPosition().y * 32)];
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
    
    // Code de gestion de la collision
    std::vector<MyContact>::iterator pos;
    for(pos = _contactListener->_contacts.begin(); 
        pos != _contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
            
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        
        b2Manifold* Manifold = contact.GetManifold();
        
        if (((bodyA == groundBody) && (bodyB == body)) || ((bodyB == body) && (bodyB == groundBody)))
        {
            NSLog(@"Collision avec le tour");
            //Vibration quand on touche le tour
            //AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
            
        }
    }
    
    // Code de gestion du gyroscope
//    CMDeviceMotion *currentDeviceMotion = motionManager.deviceMotion;
//    CMAttitude *currentAttitude = currentDeviceMotion.attitude;
//    
//    float roll = currentAttitude.roll;
//    float pitch = currentAttitude.pitch;
//    float yaw = currentAttitude.yaw;
    
    //NSLog(@"roll = %f, pitch = %f et yaw = %f", roll, pitch, yaw);
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event { 
    NSLog(@"move");
    if (_mouseJoint != NULL) return FALSE;
    
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x / kPointsToMeterRatio * 3, location.y / kPointsToMeterRatio * 3);
    
//    if (PaddleFixture->TestPoint(locationWorld)) {
        b2MouseJointDef md;
        md.bodyA = groundBody;
        md.bodyB = PaddleBody;
        md.target = locationWorld;
        md.collideConnected = true;
        md.maxForce = 1000.0f * PaddleBody->GetMass();
        
        _mouseJoint = (b2MouseJoint *)world->CreateJoint(&md);
        PaddleBody->SetAwake(true);
//    }
    return TRUE;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (_mouseJoint == NULL) return;
    
    NSLog(@"Paddle move");
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x / kPointsToMeterRatio * 3, location.y / kPointsToMeterRatio * 3);
    
    _mouseJoint->SetTarget(locationWorld);
    
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (_mouseJoint) {
        world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
    return;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_mouseJoint) {
        world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }  
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
    //NSLog(@"Accel detected: x = %f, y = %f et z = %f", acceleration.x, acceleration.y, acceleration.z);
    
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	b2Vec2 gravity( -accelY * 10, accelX * 10);
	
	//world->SetGravity( gravity );
}


// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init])) {
		
        UIScreen* mainscr = [UIScreen mainScreen];
        CGSize screenSize = mainscr.currentMode.size;
        
        // Initialisation de l'acceleromètre
        self.isAccelerometerEnabled = YES;
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 5)];
        
        
        // Initialisation du Coremotion (gyro and co)
        self.motionManager = [[[CMMotionManager alloc] init] autorelease];
        self.motionManager.deviceMotionUpdateInterval=1.0/60.0;
        if (motionManager.isDeviceMotionAvailable)
            [motionManager startDeviceMotionUpdates];
        
        // Initialisation du Touch Screen
        self.isTouchEnabled = YES;
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        w = screenSize.height;
        h = screenSize.width;
        
        NSLog(@"Screen size w = %d et h = %d", w, h);
        
		Ball = [CCSprite spriteWithFile: @"Ball.png" rect:CGRectMake(0, 0, 40, 40)];
        Ball.position = ccp(0, 0);
        [self addChild:Ball];
        
        Paddle = [CCSprite spriteWithFile: @"paddle.png"];
        Paddle.position = ccp(25, 90);
        [self addChild:Paddle];
        
        Paddle2 = [CCSprite spriteWithFile: @"paddle.png"];
        Paddle2.position = ccp(h / 2, w / 2);
        [self addChild:Paddle2];
        
        // Create a world
        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
        bool doSleep = true;
        world = new b2World(gravity, doSleep);
        
        // Code for collition detection
        _contactListener = new MyContactListener();
        world->SetContactListener(_contactListener);
        
        // Create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        groundBody = world->CreateBody(&groundBodyDef);
        b2PolygonShape groundBox;
        b2FixtureDef boxShapeDef;
        boxShapeDef.shape = &groundBox;
        
        groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.height / [self pixelsToMeterRatio],0));
        groundBody->CreateFixture(&boxShapeDef);
        groundBox.SetAsEdge(b2Vec2(0, screenSize.width / [self pixelsToMeterRatio]), b2Vec2(screenSize.height / [self pixelsToMeterRatio], screenSize.width / [self pixelsToMeterRatio]));
        groundBody->CreateFixture(&boxShapeDef);
        groundBox.SetAsEdge(b2Vec2(0,screenSize.width / [self pixelsToMeterRatio]), b2Vec2(0,0));
        groundBody->CreateFixture(&boxShapeDef);
        groundBox.SetAsEdge(b2Vec2(screenSize.height / [self pixelsToMeterRatio], screenSize.width / [self pixelsToMeterRatio]), b2Vec2(screenSize.height / [self pixelsToMeterRatio], 0));
        groundBody->CreateFixture(&boxShapeDef);
        
        // Create ball body and shape
        b2BodyDef ballBodyDef;
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.position.Set(100 / kPointsToMeterRatio, 1 / kPointsToMeterRatio);
        ballBodyDef.userData = Ball;
        body = world->CreateBody(&ballBodyDef);
        
        b2CircleShape circle;
        circle.m_radius = 15 / [self pixelsToMeterRatio];
        
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 1.0f;
        ballShapeDef.friction = 0.f;
        ballShapeDef.restitution = 1.0f;
        body->CreateFixture(&ballShapeDef);
        
        // Create paddle body
        b2BodyDef paddleBodyDef;
        paddleBodyDef.type = b2_dynamicBody;
        paddleBodyDef.position.Set(25 / kPointsToMeterRatio, 90 / kPointsToMeterRatio);
        paddleBodyDef.userData = Paddle;
        PaddleBody = world->CreateBody(&paddleBodyDef);
        
        // Create paddle shape
        b2PolygonShape paddleShape;
        paddleShape.SetAsBox(Paddle.contentSize.width /kPointsToMeterRatio, 
                             Paddle.contentSize.height/kPointsToMeterRatio);
        
        // Create shape definition and add to body
        b2FixtureDef paddleShapeDef;
        paddleShapeDef.shape = &paddleShape;
        paddleShapeDef.density = 1.0f;
        paddleShapeDef.friction = 0.4f;
        paddleShapeDef.restitution = 0.1f;
        PaddleFixture = PaddleBody->CreateFixture(&paddleShapeDef);
        
        // Blocage des mouvement du paddle
        b2PrismaticJointDef jointDef;
        b2Vec2 worldAxis(0.0f, 1.0f);
        jointDef.collideConnected = true;
        jointDef.Initialize(PaddleBody, groundBody, 
                            PaddleBody->GetWorldCenter(), worldAxis);
        world->CreateJoint(&jointDef);
        
        //PADDLE2
        // Create paddle body
        b2BodyDef paddle2BodyDef;
        paddle2BodyDef.type = b2_dynamicBody;
        paddle2BodyDef.position.Set((w - 25) / kPointsToMeterRatio , (h / 2) / kPointsToMeterRatio);
        paddle2BodyDef.userData = Paddle2;
        Paddle2Body = world->CreateBody(&paddle2BodyDef);
        
        // Create paddle shape
        b2PolygonShape paddle2Shape;
        paddle2Shape.SetAsBox(Paddle.contentSize.width/kPointsToMeterRatio, 
                             Paddle.contentSize.height/kPointsToMeterRatio);
        
        // Create shape definition and add to body
        b2FixtureDef paddle2ShapeDef;
        paddle2ShapeDef.shape = &paddleShape;
        paddle2ShapeDef.density = 1.0f;
        paddle2ShapeDef.friction = 0.4f;
        paddle2ShapeDef.restitution = 0.1f;
        Paddle2Fixture = Paddle2Body->CreateFixture(&paddle2ShapeDef);
        
        // Blocage des mouvement du paddle
        b2PrismaticJointDef jointDef2;
        jointDef2.collideConnected = true;
        jointDef2.Initialize(Paddle2Body, groundBody, 
                            Paddle2Body->GetWorldCenter(), worldAxis);
        world->CreateJoint(&jointDef2);
        
        
        b2Vec2 force = b2Vec2(10, 10);
        body->ApplyLinearImpulse(force, ballBodyDef.position);
        
        //[self scheduleUpdate];
        [self schedule: @selector(tick:)];
        //id animation = [CCMoveTo actionWithDuration:1 position:ccp(x, y)];
        
        //id s = [CCSequence actions:animation, nil];
        //[Ball runAction: s];
        
        // Enable Debug Draw
        _debugDraw = new GLESDebugDraw( [self pixelsToMeterRatio] );
        world->SetDebugDraw(_debugDraw);
        
        uint32 flags = 0;
        flags += b2DebugDraw::e_shapeBit;
        _debugDraw->SetFlags(flags);
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
    delete _contactListener;
	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
