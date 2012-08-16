//
//  Ball.h
//  PongBox-cc2
//
//  Created by Gwenole Le bris on 09/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"

@interface Ball : GameObject

- (id)initWithGameLayer:(pongBoxLayer *)layer position:(CGPoint) position;

//- (void)update:(ccTime)dt;

@end
