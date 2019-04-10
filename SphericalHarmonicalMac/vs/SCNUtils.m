//
//  SCNUtils.m
//  SphericalHarmonics
//
//  Created by asd on 05/10/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import "SCNUtils.h"

@implementation SCNUtils
// utils
+(SCNNode*)createCamera: (float)zoom {
    SCNCamera *camera = [SCNCamera camera];
    //camera.fieldOfView = 45;   // Degrees, not radians
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = camera;
    cameraNode.position = SCNVector3Make(0, 0, zoom);
    return cameraNode;
}

+(SCNMaterial*)getMaterial: (NSColor*)color {
    SCNMaterial *mat             = [SCNMaterial material];
    mat.diffuse.contents         = color;
    mat.locksAmbientWithDiffuse  = YES;
    return mat;
}

+(SCNNode*)createAmbientLight {
    SCNLight *ambientLight = [SCNLight light];
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLight.type = SCNLightTypeAmbient;
    ambientLight.color = [NSColor colorWithWhite:0.1 alpha:1.0];
    ambientLightNode.light = ambientLight;
    return ambientLightNode;
}
+(SCNNode*)createDiffuseLight {
    SCNLight *diffuseLight = [SCNLight light];
    SCNNode *diffuseLightNode = [SCNNode node];
    diffuseLight.type = SCNLightTypeOmni;
    diffuseLightNode.light = diffuseLight;
    diffuseLightNode.position = SCNVector3Make(-30, 30, 50);
    return diffuseLightNode;
}
+(SCNNode*)createDiffuseLightWithPosition: (SCNVector3)position{
    SCNLight *diffuseLight = [SCNLight light];
    SCNNode *diffuseLightNode = [SCNNode node];
    diffuseLight.type = SCNLightTypeOmni;
    diffuseLightNode.light = diffuseLight;
    diffuseLightNode.position = position; // SCNVector3Make(-30, 30, 50);
    return diffuseLightNode;
}
@end
