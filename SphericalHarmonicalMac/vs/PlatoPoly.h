//
//  PlatoPoly.h
//  sk01
//
//  Created by asd on 21/09/2018.
//  Copyright © 2018 asd. All rights reserved.
//

#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    uint nCoordsFace, nFaces, nCoords;
    int *faces;
    float *xyz;
    NSString*name;
} GeoObject;

@interface PlatoPoly : NSObject
+(float) length: (float*)v1 v2:(float*)v2;

+(GeoObject*)geoTetrahedron;
+(GeoObject*)geoCube;
+(GeoObject*)geoOctahedron;
+(GeoObject*)geoIcosahedron;
+(GeoObject*)geoDodecahedron;

+(SCNNode*)geoPoints:  (GeoObject*)geoObject material:(SCNMaterial*)material;
+(SCNNode*)geoTubes :  (GeoObject*)geoObject material:(SCNMaterial*)material;
+(SCNNode*)geoNode  :  (GeoObject*)geoObject material:(SCNMaterial*)material;

@end

NS_ASSUME_NONNULL_END
