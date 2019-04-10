//
//  SCNUtils.h
//  SphericalHarmonics
//
//  Created by asd on 05/10/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCNUtils : NSObject
+(SCNNode*)createCamera: (float)zoom;
+(SCNMaterial*)getMaterial: (NSColor*)color;
+(SCNNode*)createAmbientLight;
+(SCNNode*)createDiffuseLight;
+(SCNNode*)createDiffuseLightWithPosition: (SCNVector3)position;
@end

NS_ASSUME_NONNULL_END
