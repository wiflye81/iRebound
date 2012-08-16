//
//  GameObject.m
//  PongBox-cc2
//
//  Created by Gwenole Le bris on 09/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"

@implementation GameObject

@synthesize sprite = _sprite;
@synthesize gameLayer = _gameLayer;
@synthesize position = _position;
@synthesize Body = _Body;
@synthesize Fixture = _Fixture;
@synthesize BodyDef = _BodyDef;
@synthesize ShapeDef = _ShapeDef;
@synthesize mouseJoint = _mouseJoint;
@synthesize Score = _Score;

const float kPointsToMeterRatio = 32.0f;

- (void)dealloc {
    [_sprite release];
    [super dealloc];
}

- (id)initWithGameLayer:(pongBoxLayer *)layer {
    if(self = [super init]) {
        self.gameLayer = layer;
    }
    return self;
}

// 1
- (void) setPosition:(CGPoint)position {
    _position = position;
    _sprite.position = position;
}

// 2
- (CGRect)getBounds {
    CGSize size = [self.sprite contentSize];
    return CGRectMake(self.position.x - size.width * self.sprite.anchorPoint.x,
                      self.position.y - size.height * self.sprite.anchorPoint.y,
                      size.width, size.height);
}

@end
