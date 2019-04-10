//
//  PlatoPoly.m
//  sk01
//
//  Created by asd on 21/09/2018.
//  Copyright © 2018 asd. All rights reserved.
//

#import "PlatoPoly.h"

@implementation PlatoPoly
+(float) length: (float*)v1 v2:(float*)v2 {
    float x,y,z;
    x=v1[0]-v2[0];    y=v1[1]-v2[1];    z=v1[2]-v2[2];
    return sqrt(x*x + y*y + z*z);
}
+(GeoObject*)geoTetrahedron {
    static int faces[][3]= {{0, 1, 2}, {0, 2, 3}, {0, 3, 1}, {1, 3, 2}};
    static float xyz[][3]={ {0, 0, 1.732051f},   {1.632993f, 0, -0.5773503f},     {-0.8164966f, 1.414214f, -0.5773503f},  {-0.8164966f, -1.414214f, -0.5773503f} };
    static GeoObject go={   .nCoordsFace=3, .nFaces=4, .nCoords=4 , .faces=(int*)faces, .xyz=(float*)xyz, .name=@"tetra"  };
    return &go;
}
+(GeoObject*)geoCube {
    static const float sz = 1;
    static int faces[][4]= {{3, 0, 1, 2}, {3, 4, 5, 0}, {0, 5, 6, 1}, {1, 6, 7, 2}, {2, 7, 4, 3}, {5, 4, 7, 6}};
    static float xyz[][3]={{sz, sz, sz},   {-sz, sz, sz},  {-sz, -sz, sz},
        {sz, -sz, sz},  {sz, -sz, -sz}, {sz, sz, -sz}, {-sz, sz, -sz}, {-sz, -sz, -sz}};
    static GeoObject go={   .nCoordsFace=4, .nFaces=6, .nCoords=8, .faces=(int*)faces, .xyz=(float*)xyz, .name=@"cube" };
    return &go;
}
+(GeoObject*)geoOctahedron {
    static int faces[8][3] = {{0, 1, 2}, {0, 2, 3}, {0, 3, 4}, {0, 4, 1},
        {1, 4, 5}, {1, 5, 2}, {2, 5, 3}, {3, 5, 4}};
    static float xyz[6][3] = {{0, 0, 1.414f},  {1.414f, 0, 0},   {0, 1.414f, 0},  {-1.414f, 0, 0},    {0, -1.414f, 0}, {0, 0, -1.414f}};
    static GeoObject go={   .nCoordsFace=3, .nFaces=8, .nCoords=6, .faces=(int*)faces, .xyz=(float*)xyz, .name=@"octa" };
    return &go;
}
+(GeoObject*)geoIcosahedron {
    const float X = .525731112119133606, Z = .850650808352039932;
    static float xyz[12][3] = {{-X, 0.0, Z}, {X, 0.0, Z},   {-X, 0.0, -Z},        {X, 0.0, -Z}, {0.0, Z, X},   {0.0, Z, -X},
        {0.0, -Z, X}, {0.0, -Z, -X}, {Z, X, 0.0},        {-Z, X, 0.0}, {Z, -X, 0.0},  {-Z, -X, 0.0}};
    static int faces[20][3] = {{0, 4, 1},  {0, 9, 4},  {9, 5, 4},  {4, 5, 8},
        {4, 8, 1},  {8, 10, 1}, {8, 3, 10}, {5, 3, 8},
        {5, 2, 3},  {2, 7, 3},  {7, 10, 3}, {7, 6, 10},
        {7, 11, 6}, {11, 0, 6}, {0, 1, 6},  {6, 1, 10},
        {9, 0, 11}, {9, 11, 2}, {9, 2, 5},  {7, 2, 11}};
    static GeoObject go={   .nCoordsFace=3, .nFaces=20, .nCoords=12, .faces=(int*)faces, .xyz=(float*)xyz, .name=@"ico" };
    return &go;
}
+(GeoObject*)geoDodecahedron {
    static int faces[12][5] = {
        {0, 1, 4, 7, 2},      {0, 2, 6, 9, 3},      {0, 3, 8, 5, 1},
        {1, 5, 11, 10, 4},    {2, 7, 13, 12, 6},    {3, 9, 15, 14, 8},
        {4, 10, 16, 13, 7},   {5, 8, 14, 17, 11},   {6, 12, 18, 15, 9},
        {10, 11, 17, 19, 16}, {12, 13, 16, 19, 18}, {14, 15, 18, 19, 17}};
    static float xyz[20][3] = {{0, 0, 1.07047},        {0.713644, 0, 0.797878},        {-0.356822, 0.618, 0.797878},
        {-0.356822, -0.618, 0.797878},        {0.797878, 0.618034, 0.356822},        {0.797878, -0.618, 0.356822},
        {-0.934172, 0.381966, 0.356822},        {0.136294, 1., 0.356822},        {0.136294, -1., 0.356822},
        {-0.934172, -0.381966, 0.356822},        {0.934172, 0.381966, -0.356822},        {0.934172, -0.381966, -0.356822},
        {-0.797878, 0.618, -0.356822},        {-0.136294, 1., -0.356822},        {-0.136294, -1., -0.356822},
        {-0.797878, -0.618034, -0.356822},        {0.356822, 0.618, -0.797878},        {0.356822, -0.618, -0.797878},
        {-0.713644, 0, -0.797878},        {0, 0, -1.07047}};
    static GeoObject go={   .nCoordsFace=5, .nFaces=12, .nCoords=20, .faces=(int*)faces, .xyz=(float*)xyz, .name=@"dodeca" };
    return &go;
}


+(SCNNode*)geoPoints :  (GeoObject*)go material:(SCNMaterial*)material {// spheres
    SCNNode*objNode=[SCNNode node];
    for (int i=0; i<go->nCoords; i++) {
        SCNSphere *sp=[SCNSphere sphereWithRadius:0.05];
        sp.materials=@[material];
        SCNNode*node=[SCNNode nodeWithGeometry:sp];
        
        float *v1=go->xyz + i*3;
        node.position=SCNVector3Make(v1[0], v1[1], v1[2]);
        [objNode addChildNode:node];
    }
    return objNode;
}

+(SCNNode*)geoTubes : (GeoObject*)go material:(SCNMaterial*)material {
    SCNNode*objNode=[SCNNode node];
    
    for (int f=0; f<go->nFaces; f++) {
        int *face=go->faces + go->nCoordsFace * f;
        
        for (int i=0; i<go->nCoordsFace; i++) { // cyl between points
            float *v1=go->xyz + 3 * face[i], *v2=go->xyz + 3 * face[(i+1)%go->nCoordsFace];
            float r=[PlatoPoly length:v1 v2:v2], theta=acos((v2[2]-v1[2])/r), phi=atan2f((v2[1]-v1[1]), (v2[0]-v1[0]) ); // z/r, atan(y/x)
            
            SCNCylinder*cyl = [SCNCylinder cylinderWithRadius:0.03 height:r ]; // cyl
            cyl.materials=@[material];
            SCNNode*node=[SCNNode nodeWithGeometry: cyl];
            node.position=SCNVector3Make((v1[0]+v2[0])/2, (v1[1]+v2[1])/2, (v1[2]+v2[2])/2);
            node.eulerAngles = SCNVector3Make(M_PI_2, theta, phi);
            [objNode addChildNode:node];
        }
    }
    return objNode;
}

+(SCNNode*)geoNode :  (GeoObject*)geoObject material:(SCNMaterial*)material {
    SCNNode*np=[PlatoPoly geoPoints:geoObject material:material];
    SCNNode*nt=[PlatoPoly geoTubes :geoObject material:material];
    
    SCNNode*objNode=[SCNNode node];
    [objNode addChildNode:np];
    [objNode addChildNode:nt];
    
    [objNode setName:geoObject->name];
    
    return objNode;
}

@end
