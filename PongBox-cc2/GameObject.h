//
//  GameObject.h
//  PongBox-cc2
//
//  Created by Gwenole Le bris on 09/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PongBoxLayer.h"

@interface GameObject : NSObject
{
    b2Body      *Body;
    b2Fixture   *Fixture;
    b2FixtureDef ShapeDef;
    b2BodyDef   *BodyDef;
    b2MouseJoint *mouseJoint;
    int          Score;
}
@property(nonatomic, retain) CCSprite *sprite;
@property (nonatomic, assign) pongBoxLayer *gameLayer;
@property(nonatomic) CGPoint position;
@property(nonatomic, assign) b2Body *Body;
@property(nonatomic, assign) b2Fixture *Fixture;
@property(nonatomic, assign) b2FixtureDef ShapeDef;
@property(nonatomic, assign) b2BodyDef BodyDef;
@property(nonatomic, assign) b2MouseJoint *mouseJoint;
@property(nonatomic, assign) int Score;

- (id)initWithGameLayer:(pongBoxLayer *)layer;
- (CGRect)getBounds;

@end
