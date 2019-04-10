//
//  Geo.m
//  SphericalHarmonics
//
//  Created by asd on 07/10/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import "Geo.h"

@implementation Geo
+(float) length: (SCNVector3)v1 v2:(SCNVector3)v2 {
    float x,y,z;
    x=v1.x-v2.x;    y=v1.y-v2.y;    z=v1.z-v2.z;
    return sqrt(x*x + y*y + z*z);
}
+(SCNVector3)normalise:(SCNVector3)p {
    float length = p.x * p.x + p.y * p.y + p.z * p.z;
    if (length > 0) {
        length = sqrt(length);
        p.x /= length;
        p.y /= length;
        p.z /= length;
    }
    else {
        p.x = p.y = p.z = 0;
    }
    return p;
}

+(SCNVector3)normal:(SCNVector3)p p1:(SCNVector3)p1 p2:(SCNVector3) p2 {
    SCNVector3 n, pa, pb;
    
    pa.x = p1.x - p.x;
    pa.y = p1.y - p.y;
    pa.z = p1.z - p.z;
    pb.x = p2.x - p.x;
    pb.y = p2.y - p.y;
    pb.z = p2.z - p.z;
    n.x = pa.y * pb.z - pa.z * pb.y;
    n.y = pa.z * pb.x - pa.x * pb.z;
    n.z = pa.x * pb.y - pa.y * pb.x;
    
    return [Geo normalise:n];
}
+(NSArray<NSNumber*>*)triangularize:(int)nSides { // generate nSides polygon set of trig index coords
    NSMutableArray*res=[NSMutableArray array];
    for (int i=1; i<nSides-1; i++) {// 0, i, i+1 : i=1..ns-1, for quad=4: 0 1 2 0 2 3
        int vi[]={0, i, i+1};
        for (int j=0; j<3; j++) [res addObject:[NSNumber numberWithInt:vi[j]]];
    }
    return res;
}
@end
