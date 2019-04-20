//
//  SphericalHarmonics.h
//  SphericalHarmonics
//
//  Created by asd on 03/10/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import "VectUtils.h"
#import "SHCodes.h"
#import "Geo.h"

#define TWOPI           M_PI*2.


NS_ASSUME_NONNULL_BEGIN

@interface SphericalHarmonics : NSObject {
    Vect8f m; // 'm' mgr
    int steps;
    
    int resolution;
    int colourmap; // 1..25 types of colouring 7=rgb
    int im;

@public
    char code[8+1]; // the parameter code
    XYZ *coords,  *normals;
    Texture *textures;
    Color *colors;
    Mesh*mesh;
    SCNNode*node;
    
    dispatch_queue_t queue;
    dispatch_group_t group;
    
    SCNGeometrySource *vertexSource, *normalSource, *colorSource, *tcoordSource;
    BOOL multiThread;
}

+(id)init;
-(void)freeMesh;
-(void)readCode: (int)index;
-(void)randomCode;
-(void)nextCode;
-(void)setColorMap:(int)colMap;
-(Mesh*)genCoords;
-(SCNNode*)createNode;
-(NSString*)getCode:(int) ix;

+(void) randomize;
+(float) rnd :(float)range;
+(float) rndInt :(int)range;

@end


NS_ASSUME_NONNULL_END
