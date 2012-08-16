//
//  HelloWorldLayer.h
//  PongBox-cc2
//
//  Created by Gwenole Le bris on 02/01/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"

@class Paddle;
@class Ball;

// pongBoxLayer
@interface pongBoxLayer : CCLayer
{
    CGSize              ScreenSize;
	b2World             *world;// strong ref
    b2Vec2              gravity;
    b2BodyDef           screenBorderDef;
    b2Body              *screenBorderBody;
    b2EdgeShape         screenBorderShape;
    b2FixtureDef        boxShapeDef;
    b2Fixture           *UpWorldFixture;
    b2Fixture           *DownWorldFixture;
    b2Fixture           *LeftWorldFixture;
    b2Fixture           *RightWorldFixture;
	GLESDebugDraw       debugDraw;
    int                 width;
    int                 height;
    Paddle              *player_one;
    Paddle              *player_two;
    Ball                *first_ball;
    b2MouseJointDef     Player_World_Joint;
    CCLabelTTF          *Score_P1;
    CCLabelTTF          *Score_P2;
    MyContactListener   *contactListener;
}

@property(nonatomic, retain) CCSpriteBatchNode *spritesBatchNode;
@property(nonatomic, retain) Paddle *player_one;
@property(nonatomic, retain) Paddle *player_two;
@property(nonatomic, retain) Ball *first_ball;
@property(nonatomic, assign) b2World *world;
@property(nonatomic, assign) b2Vec2 gravity;
@property(nonatomic, assign) b2BodyDef screenBorderDef;
@property(nonatomic, assign) b2Body *screenBorderBody;
@property(nonatomic, assign) b2EdgeShape screenBorderShape;
@property(nonatomic, assign) b2FixtureDef boxShapeDef;
@property(nonatomic, assign) CGSize ScreenSize;
@property(nonatomic, assign) b2MouseJointDef Player_World_Joint;
@property(nonatomic, assign) GLESDebugDraw debugDraw;
@property(nonatomic, assign) CCLabelTTF *Score_P1;
@property(nonatomic, assign) CCLabelTTF *Score_P2;
@property(nonatomic, assign) MyContactListener *contactListener;
@property(nonatomic, assign) b2Fixture *UpWorldFixture;
@property(nonatomic, assign) b2Fixture *DownWorldFixture;
@property(nonatomic, assign) b2Fixture *LeftWorldFixture;
@property(nonatomic, assign) b2Fixture *RightWorldFixture;

+ (CCScene *) scene;

@end
