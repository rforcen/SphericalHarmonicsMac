//
//  Geo.h
//  SphericalHarmonics
//
//  Created by asd on 07/10/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Geo : NSObject
+(SCNVector3)normalise:(SCNVector3)p;
+(SCNVector3)normal:(SCNVector3)p p1:(SCNVector3)p1 p2:(SCNVector3) p2;
+(NSArray*)triangularize:(int)nSides;
@end

NS_ASSUME_NONNULL_END
