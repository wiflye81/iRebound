//
//  Ball.m
//  PongBox-cc2
//
//  Created by Gwenole Le bris on 09/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"

@implementation Ball

@synthesize sprite = _sprite;
@synthesize gameLayer = _gameLayer;
@synthesize position = _position;
@synthesize Body = _Body;
@synthesize Fixture = _Fixture;
@synthesize BodyDef = _BodyDef;
@synthesize ShapeDef = _ShapeDef;

const float kPointsToMeterRatio = 32.0f;

- (void)dealloc {
    [super dealloc];
}

- (id)initWithGameLayer:(pongBoxLayer *)layer position:(CGPoint) position {
    if(self = [super initWithGameLayer:layer]) {
        self.sprite = [CCSprite spriteWithSpriteFrameName:@"Ball.png"];
        self.sprite.scale = 0.5;
        self.sprite.position = position;
        [self.gameLayer.spritesBatchNode addChild:self.sprite];
        _BodyDef.type = b2_dynamicBody;
        _BodyDef.position.Set(position.y / kPointsToMeterRatio, position.x / kPointsToMeterRatio);
        _BodyDef.userData = _sprite;
        _Body = layer.world->CreateBody(&_BodyDef);
        
        b2CircleShape circle;
        circle.m_radius = 15 / kPointsToMeterRatio;
        
        _ShapeDef.shape = &circle;
        _ShapeDef.density = 1.0f;
        _ShapeDef.friction = 0.f;
        _ShapeDef.restitution = 1.0f;
        
        _Fixture = _Body->CreateFixture(&_ShapeDef);
        NSLog(@"Ball Before force");
        b2Vec2 force = b2Vec2(5, 5);
        _Body->ApplyLinearImpulse(force, _BodyDef.position);
        
    }
    return self;
}

- (void)update:(ccTime)dt;
{
    //self.sprite.position = self.position;
}
@end
