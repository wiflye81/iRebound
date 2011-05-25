//
//  HelloWorldLayer.h
//  PongBox
//
//  Created by Gwenole Le bris on 21/05/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"
#include "CoreMotion/CoreMotion.h"
#import <AudioToolbox/AudioToolbox.h>

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    CMMotionManager *motionManager;
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    // Ball body
    b2Body *body;
    
    // Paddle Body
    b2Body *PaddleBody;
    b2Fixture *PaddleFixture;
    
    b2Body *Paddle2Body;
    b2Fixture *Paddle2Fixture;
    
    b2MouseJoint *_mouseJoint;
    
    // Body du tour de l'ecran pour la gestion de la collision
    b2Body *groundBody;
    
    GLESDebugDraw *_debugDraw;
    
    MyContactListener *_contactListener;
    
    CCSprite *Ball;
    CCSprite *Wall;
    CCSprite *Paddle;
    CCSprite *Paddle2;
    float x; 
    float y;
    int w;
    int h;

}

@property (nonatomic, retain) CMMotionManager *motionManager;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
// adds a new sprite at a given coordinate
-(void) addNewSpriteWithCoords:(CGPoint)p;


@end
