//
//  SphericalHarmonics.m
//  SphericalHarmonics
//
//  Created by asd on 03/10/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import "SphericalHarmonics.h"

@implementation SphericalHarmonics

+(void) randomize { srand((unsigned)time(NULL)); }
+(float) rnd :(float)range {  return (float)(range * rand())/RAND_MAX; }
+(float) rndInt :(int)range {  return rand() % range; }


+(id)init {
    SphericalHarmonics*sh=[[SphericalHarmonics alloc] init];
    
    sortCodes();
    
    const int res=128;
    sh->colourmap = 7;
    sh->resolution = res;
    sh->im = 1;
    
    // alloc results in 2 x trigs per facet *6
    int nitems = res*res * 3*2;
    sh->coords = calloc(nitems, sizeof(*sh->coords));
    sh->normals= calloc(nitems, sizeof(*sh->normals));
    sh->colors = calloc(nitems, sizeof(*sh->colors));
    sh->textures=calloc(nitems, sizeof(*sh->textures));
    sh->mesh = calloc(1, sizeof(Mesh));
    sh->mesh->coords    = sh->coords;
    sh->mesh->normals   = sh->normals;
    sh->mesh->colors    = sh->colors;
    sh->mesh->textures  = sh->textures;
    
    sh->mesh->nc = nitems;
    sh->multiThread=YES; // YES: doesn't improve
    if(sh->multiThread)  {
        sh->queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        sh->group = dispatch_group_create();
    }
    
    //    [SphericalHarmonics randomize];
    //    [sh readCode: -1]; // random code
    
    return sh;
}

-(void)freeMesh {
    free(mesh->coords);
    free(mesh->normals);
    free(mesh->colors);
    free(mesh->textures);
    free(mesh);
}

-(NSString*)getCode:(int)ix {
    return [NSString stringWithFormat:@"%08d", SphericHarmCodes[ix]];
}
-(void)readCode: (int)index { // read a code from the set. default SEQ. and generate coords
    int n = N_SH_CODES, r;
    
    switch (index) {
        case -2: {
            static int c = 0;
            r = c % n;
            c++;
        };
            break; // seq
        case -1: r = [SphericalHarmonics rndInt:n];     break; // read random code
        default: r = index % n;                         break;
    }
    // generate m vect.
    sprintf(code,"%08d", SphericHarmCodes[r]);
    for (int i = 0; i < 8; i++)  m[i] = code[i] - '0';
    
    // generate coords
    [self genCoords];
}
-(void)randomCode { [self readCode:-1]; }
-(void)nextCode   { [self readCode:-2]; }

-(void)setColorMap:(int)colMap {
    self->colourmap=colMap;
    [self genCoords];
}

XYZ coord(float theta, float phi, float *m) {
    float r = 0;
    
    r += pow(sin(m[0] * phi), (float)m[1]);
    r += pow(cos(m[2] * phi), (float)m[3]);
    r += pow(sin(m[4] * theta), (float)m[5]);
    r += pow(cos(m[6] * theta), (float)m[7]);
    
    XYZ p={ .x=r * sin(phi) * cos(theta),
        .y = r * cos(phi),
        .z = r * sin(phi) * sin(theta)};
    
    return p;
}

-(Mesh*)genCoords {
    return (multiThread) ?
    [self genCoordsMultiThread:(int)[[NSProcessInfo processInfo] processorCount]] :
    [self genCoordsSingleThread];
}
-(Mesh*)genCoordsSingleThread { // single thread
    float du, dv, u, v, dx;
    XYZ q[4], n[4]; // quads q:coords, c:colors, n:normal, t:textures
    Color c[4];
    Texture t[4];
    int nc=0; // coords counter
    
    du = TWOPI / resolution;    // Theta
    dv = M_PI / resolution;       // Phi
    dx = 1. / resolution;
    
    NSArray<NSNumber*>*trigs=[Geo triangularize:4];
    
    for (int i = 0; i < resolution; i++) {
        u = i * du;
        
        for (int j = 0; j < resolution; j++) {
            v = j * dv;
            
            q[0] = coord(u, v, m);
            n[0] = calcNormals(q[0], coord(u + du / 10, v, m), coord(u, v + dv / 10, m));
            c[0] = calcColor(u, 0.0, TWOPI, colourmap);
            t[0] = texture(i*dx, j*dx);
            
            q[1] = coord(u + du, v, m);
            n[1] = calcNormals(q[1], coord(u + du + du / 10, v, m),  coord(u + du, v + dv / 10, m));
            c[1] = calcColor(u + du, 0.0, TWOPI, colourmap);
            t[1] = texture((i + 1)*dx, j*dx);
            
            q[2] = coord(u + du, v + dv, m);
            n[2] = calcNormals(q[2], coord(u + du + du / 10, v + dv, m), coord(u + du, v + dv + dv / 10, m));
            c[2] = calcColor(u + du, 0.0, TWOPI, colourmap);
            t[2] = texture((i + 1)*dx, (j + 1)*dx);
            
            q[3] = coord(u, v + dv, m);
            n[3] = calcNormals(q[3], coord(u + du / 10, v + dv, m), coord(u, v + dv + dv / 10, m));
            c[3] = calcColor(u, 0.0, TWOPI, colourmap);
            t[3] = texture(i*dx, (j + 1)*dx);
            
            
            for (NSNumber*cs in trigs) { // quad -> trigs
                int ics=[cs intValue];
                coords[nc]   = q[ics];       colors[nc]   = c[ics];
                normals[nc]  = n[ics];       textures[nc] = t[ics];
                nc++;
            }
        }
    }
    // create mesh
    [self createNode];
    
    return mesh;
}

-(Mesh*)genCoordsMultiThread:(int)nCPU { // multithread version
    
    
    NSArray<NSNumber*>*trigs=[Geo triangularize:4];
    int __block ncc=0;
    
    for (int nt=0; nt < nCPU; nt++) {
        
        int trigsCnt=(int)[trigs count];
        
        dispatch_group_async(group, queue, ^ {
            
            float du, dv, u, v, dx;
            XYZ q[4], n[4]; // quads q:coords, c:colors, n:normal, t:textures
            Color c[4];
            Texture t[4];
            int nc=nt, res=self->resolution; // coords counter
            
            du = TWOPI / res;    // Theta
            dv = M_PI / res;     // Phi
            dx = 1. / res;
            
            for (int i = 0; i < res; i++) {
                
                u = i * du;
                
                for (int j = nt; j < res; j+=nCPU) { // in nCPU slices from nt
                    
                    v = j * dv;
                    
                    q[0] = coord(u, v, self->m);
                    n[0] = calcNormals(q[0], coord(u + du / 10, v, self->m), coord(u, v + dv / 10, self->m));
                    c[0] = calcColor(u, 0.0, TWOPI, self->colourmap);
                    t[0] = texture(i*dx, j*dx);
                    
                    q[1] = coord(u + du, v, self->m);
                    n[1] = calcNormals(q[1], coord(u + du + du / 10, v, self->m),  coord(u + du, v + dv / 10, self->m));
                    c[1] = calcColor(u + du, 0.0, TWOPI, self->colourmap);
                    t[1] = texture((i + 1)*dx, j*dx);
                    
                    q[2] = coord(u + du, v + dv, self->m);
                    n[2] = calcNormals(q[2], coord(u + du + du / 10, v + dv, self->m), coord(u + du, v + dv + dv / 10, self->m));
                    c[2] = calcColor(u + du, 0.0, TWOPI, self->colourmap);
                    t[2] = texture((i + 1)*dx, (j + 1)*dx);
                    
                    q[3] = coord(u, v + dv, self->m);
                    n[3] = calcNormals(q[3], coord(u + du / 10, v + dv, self->m), coord(u, v + dv + dv / 10, self->m));
                    c[3] = calcColor(u, 0.0, TWOPI, self->colourmap);
                    t[3] = texture(i*dx, (j + 1)*dx);
                    
                    nc=((i*res) + j) * trigsCnt;
                    for (NSNumber*cs in trigs) { // quad -> trigs
                        int ics=[cs intValue];
                        self->coords[nc]   = q[ics];       self->colors[nc]   = c[ics];
                        self->normals[nc]  = n[ics];       self->textures[nc] = t[ics];
                        nc++;
                        ncc++;
                    }
                }
            }
        });
    }
    // wait to completetion, after must [self createNode]
    return mesh;
}


-(SCNNode*)createNode {
    int vertexCount=mesh->nc;
    
    vertexSource = [SCNGeometrySource geometrySourceWithData:[NSData dataWithBytes:mesh->coords length:sizeof(*mesh->coords)*vertexCount]
                                                    semantic:SCNGeometrySourceSemanticVertex
                                                 vectorCount:vertexCount
                                             floatComponents:YES
                                         componentsPerVector:3 // x, y, z
                                           bytesPerComponent:sizeof(float)
                                                  dataOffset:0
                                                  dataStride:sizeof(*mesh->coords)];
    normalSource = [SCNGeometrySource geometrySourceWithData:[NSData dataWithBytes:mesh->normals length:sizeof(*mesh->normals)*vertexCount]
                                                    semantic:SCNGeometrySourceSemanticNormal
                                                 vectorCount:vertexCount
                                             floatComponents:YES
                                         componentsPerVector:3 // nx, ny, nz
                                           bytesPerComponent:sizeof(float)
                                                  dataOffset:0
                                                  dataStride:sizeof(*mesh->normals)];
    
    colorSource = [SCNGeometrySource geometrySourceWithData:[NSData dataWithBytes:mesh->colors length:sizeof(*mesh->colors)*vertexCount]
                                                   semantic:SCNGeometrySourceSemanticColor
                                                vectorCount:vertexCount
                                            floatComponents:YES
                                        componentsPerVector:3 // r,g,b
                                          bytesPerComponent:sizeof(float)
                                                 dataOffset:0
                                                 dataStride:sizeof(*mesh->colors)];
    
    tcoordSource = [SCNGeometrySource geometrySourceWithData:[NSData dataWithBytes:mesh->textures length:sizeof(*mesh->textures)*vertexCount]
                                                    semantic:SCNGeometrySourceSemanticTexcoord
                                                 vectorCount:vertexCount
                                             floatComponents:YES
                                         componentsPerVector:2 // s, t
                                           bytesPerComponent:sizeof(float)
                                                  dataOffset:0
                                                  dataStride:sizeof(*mesh->textures)];
    
    
    int *_elem=calloc(vertexCount, sizeof(int)); // create array 0..vertexCount
    for (int i=0; i<vertexCount; i++) _elem[i]=i;
    
    
    SCNGeometryElement*element=[SCNGeometryElement geometryElementWithData:[NSData dataWithBytes:_elem length:vertexCount*sizeof(int)] primitiveType:SCNGeometryPrimitiveTypeTriangles primitiveCount:vertexCount/3  bytesPerIndex:sizeof(int)];
    
    free(_elem); // copy so we can free all the lot
    
    SCNGeometry*geo=[SCNGeometry geometryWithSources:@[vertexSource, normalSource, colorSource, tcoordSource] elements:@[element]];
    node=[SCNNode nodeWithGeometry:geo];
    return node;
}


@end
