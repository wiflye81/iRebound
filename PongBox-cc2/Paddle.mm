//
//  Paddle.m
//  PongBox-cc2
//
//  Created by Gwenole Le bris on 09/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Paddle.h"

@implementation Paddle

@synthesize sprite = _sprite;
@synthesize gameLayer = _gameLayer;
@synthesize position = _position;
@synthesize Body = _Body;
@synthesize Fixture = _Fixture;
@synthesize BodyDef = _BodyDef;
@synthesize ShapeDef = _ShapeDef;
@synthesize Score = _Score;

const float kPointsToMeterRatio = 32.0f;

- (void)dealloc {
    [super dealloc];
}

- (id)initWithGameLayer:(pongBoxLayer *)layer position:(CGPoint) position {
    if(self = [super initWithGameLayer:layer]) {
        self.sprite = [CCSprite spriteWithSpriteFrameName:@"paddle.png"];
        self.sprite.scale = 0.5;
        self.sprite.position = position;
        [self.gameLayer.spritesBatchNode addChild:self.sprite];
        _BodyDef.type = b2_dynamicBody;
        _BodyDef.position.Set(position.x / kPointsToMeterRatio, position.y / kPointsToMeterRatio);
        _BodyDef.userData = _sprite;
        _Body = layer.world->CreateBody(&_BodyDef);
        
        b2PolygonShape PaddleShape;
        PaddleShape.SetAsBox(((_sprite.contentSize.width - 40)  / (2 / self.sprite.scale)) / kPointsToMeterRatio, (_sprite.contentSize.height / (2 / self.sprite.scale)) / kPointsToMeterRatio);
        //PaddleShape.SetAsBox(25 / kPointsToMeterRatio, 90 / kPointsToMeterRatio);
        _ShapeDef.shape = &PaddleShape;
        _ShapeDef.density = 1.0f;
        _ShapeDef.friction = 0.4f;
        _ShapeDef.restitution = 0.1f;
        _Fixture = _Body->CreateFixture(&_ShapeDef);
        NSLog(@"Paddle after creation");
        
        b2Vec2 worldAxis(0.0f, 1.0f);
        b2PrismaticJointDef jointDef;
        jointDef.collideConnected = true;
        jointDef.Initialize(_Body, layer.screenBorderBody, _Body->GetWorldCenter(), worldAxis);
        layer.world->CreateJoint(&jointDef);
    }
    return self;
}

- (void)update:(ccTime)dt {
 
    //self.sprite.position = self.position;
    //_BodyDef.position.Set(_position.x / kPointsToMeterRatio, _position.y / kPointsToMeterRatio);
}

@end
