//
//  SphericalHarmonics.metal
//  SphericalHarmonicalMac
//
//  Created by asd on 19/04/2019.
//  Copyright © 2019 voicesync. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

constant float M_PI=3.141592653589793, TWOPI=M_PI*2.;

typedef float3 XYZ; // matches simd_float3 & 2
typedef float3 Color;
typedef float2 Texture;

typedef struct { // sizeof(float3) == sizeof(simd_float3) == 16, sizeof(float2)==sizeof(simd_float2)==8
    XYZ coords[4],  normals[4];
    Texture textures[4];
    Color colors[4];
} Quad; // sizeof(Quad)==sizeof(CPU.Quad)==224


// funcs
inline XYZ     calcNormals(XYZ p, XYZ p1, XYZ p2);
Color   calcColor(float v, float vmin, float vmax, int type);
Texture texture(float t, float u);
XYZ     calcCoord(float theta, float phi, const device float *m);
void    generate(uint i, uint j, const uint resolution, const float device *m, const uint colourmap,
              Quad device*quad);

// generates a single quad(x+y*res) coord set
kernel void sphericalHarmonics(device Quad*quads[[buffer(0)]], // out-> res x res size
                               
                               const device uint &resolution[[buffer(1)]], // in <-
                               const device float*m[[buffer(2)]],        //
                               const device uint &colourmap[[buffer(3)]],
                               
                               uint2 position [[thread_position_in_grid]] ) // x,y
{
    uint index = position.x + position.y * resolution;
    generate(position.x, position.y, resolution, m, colourmap, quads + index);
}

void generate(uint i, uint j, const uint resolution, const float device *m, const uint colourmap,
              Quad device*quad) {

    XYZ device *q=quad->coords, *n=quad->normals; // quads q:coords, c:colors, n:normal, t:textures
    Color device *c=quad->colors;
    Texture device *t=quad->textures;
    
    float   du = TWOPI / resolution,    // Theta
            dv = M_PI / resolution,     // Phi
            dx = 1. / resolution;
    
    float   u = du * i,  v = dv * j;
    
    q[0] = calcCoord(u, v, m);
    n[0] = calcNormals(q[0], calcCoord(u + du / 10, v, m), calcCoord(u, v + dv / 10, m));
    c[0] = calcColor(u, 0.0, TWOPI, colourmap);
    t[0] = texture(i*dx, j*dx);
    
    q[1] = calcCoord(u + du, v, m);
    n[1] = calcNormals(q[1], calcCoord(u + du + du / 10, v, m),  calcCoord(u + du, v + dv / 10, m));
    c[1] = calcColor(u + du, 0.0, TWOPI, colourmap);
    t[1] = texture((i + 1)*dx, j*dx);
    
    q[2] = calcCoord(u + du, v + dv, m);
    n[2] = calcNormals(q[2], calcCoord(u + du + du / 10, v + dv, m), calcCoord(u + du, v + dv + dv / 10, m));
    c[2] = calcColor(u + du, 0.0, TWOPI, colourmap);
    t[2] = texture((i + 1)*dx, (j + 1)*dx);
    
    q[3] = calcCoord(u, v + dv, m);
    n[3] = calcNormals(q[3], calcCoord(u + du / 10, v + dv, m), calcCoord(u, v + dv + dv / 10, m));
    c[3] = calcColor(u, 0.0, TWOPI, colourmap);
    t[3] = texture(i*dx, (j + 1)*dx);
}

inline float _pow(float x, float y) { // filtered power
    if(y==0) return 1;
    if(x==0) return 0;
    float p = pow(x,y);
    if(isnan(p)) return 0;
    return p;
}

XYZ calcCoord(float theta, float phi, const device float *m) {
    float r;
    
    r  = _pow(sin(m[0] * phi),   m[1]);
    r += _pow(cos(m[2] * phi),   m[3]);
    r += _pow(sin(m[4] * theta), m[5]);
    r += _pow(cos(m[6] * theta), m[7]);
    
    XYZ p={ r * sin(phi) * cos(theta),
            r * cos(phi),
            r * sin(phi) * sin(theta)};
    
    return p;
}

inline Texture  texture(float t, float u) {  return Texture{t,u}; }
inline XYZ    calcNormals(XYZ p, XYZ p1, XYZ p2) {   return normalize(cross(p1-p2, p1-p)); }

Color calcColor(float v, float vmin, float vmax, int type) {
    float dv, vmid;
    Color c = {1.0, 1.0, 1.0};
    Color c1, c2, c3;
    float ratio;
    
    if (vmax < vmin) {
        dv = vmin;
        vmin = vmax;
        vmax = dv;
    }
    if (vmax - vmin < 0.000001) {
        vmin -= 1;
        vmax += 1;
    }
    
    if (v < vmin)     v = vmin;
    if (v > vmax)     v = vmax;
    dv = vmax - vmin;
    
    switch (type) {
        case 1:
            if (v < (vmin + 0.25 * dv)) {
                c.r = 0;
                c.g = 4 * (v - vmin) / dv;
                c.b = 1;
            }
            else if (v < (vmin + 0.5 * dv)) {
                c.r = 0;
                c.g = 1;
                c.b = 1 + 4 * (vmin + 0.25 * dv - v) / dv;
            }
            else if (v < (vmin + 0.75 * dv)) {
                c.r = 4 * (v - vmin - 0.5 * dv) / dv;
                c.g = 1;
                c.b = 0;
            }
            else {
                c.r = 1;
                c.g = 1 + 4 * (vmin + 0.75 * dv - v) / dv;
                c.b = 0;
            }
            break;
        case 2:
            c.r = (v - vmin) / dv;
            c.g = 0;
            c.b = (vmax - v) / dv;
            break;
        case 3:
            c.r = (v - vmin) / dv;
            c.b = c.r;
            c.g = c.r;
            break;
        case 4:
            if (v < (vmin + dv / 6.0)) {
                c.r = 1;
                c.g = 6 * (v - vmin) / dv;
                c.b = 0;
            }
            else if (v < (vmin + 2.0 * dv / 6.0)) {
                c.r = 1 + 6 * (vmin + dv / 6.0 - v) / dv;
                c.g = 1;
                c.b = 0;
            }
            else if (v < (vmin + 3.0 * dv / 6.0)) {
                c.r = 0;
                c.g = 1;
                c.b = 6 * (v - vmin - 2.0 * dv / 6.0) / dv;
            }
            else if (v < (vmin + 4.0 * dv / 6.0)) {
                c.r = 0;
                c.g = 1 + 6 * (vmin + 3.0 * dv / 6.0 - v) / dv;
                c.b = 1;
            }
            else if (v < (vmin + 5.0 * dv / 6.0)) {
                c.r = 6 * (v - vmin - 4.0 * dv / 6.0) / dv;
                c.g = 0;
                c.b = 1;
            }
            else {
                c.r = 1;
                c.g = 0;
                c.b = 1 + 6 * (vmin + 5.0 * dv / 6.0 - v) / dv;
            }
            break;
        case 5:
            c.r = (v - vmin) / (vmax - vmin);
            c.g = 1;
            c.b = 0;
            break;
        case 6:
            c.r = (v - vmin) / (vmax - vmin);
            c.g = (vmax - v) / (vmax - vmin);
            c.b = c.r;
            break;
        case 7:
            if (v < (vmin + 0.25 * dv)) {
                c.r = 0;
                c.g = 4 * (v - vmin) / dv;
                c.b = 1 - c.g;
            }
            else if (v < (vmin + 0.5 * dv)) {
                c.r = 4 * (v - vmin - 0.25 * dv) / dv;
                c.g = 1 - c.r;
                c.b = 0;
            }
            else if (v < (vmin + 0.75 * dv)) {
                c.g = 4 * (v - vmin - 0.5 * dv) / dv;
                c.r = 1 - c.g;
                c.b = 0;
            }
            else {
                c.r = 0;
                c.b = 4 * (v - vmin - 0.75 * dv) / dv;
                c.g = 1 - c.b;
            }
            break;
        case 8:
            if (v < (vmin + 0.5 * dv)) {
                c.r = 2 * (v - vmin) / dv;
                c.g = c.r;
                c.b = c.r;
            }
            else {
                c.r = 1 - 2 * (v - vmin - 0.5 * dv) / dv;
                c.g = c.r;
                c.b = c.r;
            }
            break;
        case 9:
            if (v < (vmin + dv / 3)) {
                c.b = 3 * (v - vmin) / dv;
                c.g = 0;
                c.r = 1 - c.b;
            }
            else if (v < (vmin + 2 * dv / 3)) {
                c.r = 0;
                c.g = 3 * (v - vmin - dv / 3) / dv;
                c.b = 1;
            }
            else {
                c.r = 3 * (v - vmin - 2 * dv / 3) / dv;
                c.g = 1 - c.r;
                c.b = 1;
            }
            break;
        case 10:
            if (v < (vmin + 0.2 * dv)) {
                c.r = 0;
                c.g = 5 * (v - vmin) / dv;
                c.b = 1;
            }
            else if (v < (vmin + 0.4 * dv)) {
                c.r = 0;
                c.g = 1;
                c.b = 1 + 5 * (vmin + 0.2 * dv - v) / dv;
            }
            else if (v < (vmin + 0.6 * dv)) {
                c.r = 5 * (v - vmin - 0.4 * dv) / dv;
                c.g = 1;
                c.b = 0;
            }
            else if (v < (vmin + 0.8 * dv)) {
                c.r = 1;
                c.g = 1 - 5 * (v - vmin - 0.6 * dv) / dv;
                c.b = 0;
            }
            else {
                c.r = 1;
                c.g = 5 * (v - vmin - 0.8 * dv) / dv;
                c.b = 5 * (v - vmin - 0.8 * dv) / dv;
            }
            break;
        case 11:
            c1.r = 200 / 255.0;
            c1.g = 60 / 255.0;
            c1.b = 0 / 255.0;
            c2.r = 250 / 255.0;
            c2.g = 160 / 255.0;
            c2.b = 110 / 255.0;
            c.r = (c2.r - c1.r) * (v - vmin) / dv + c1.r;
            c.g = (c2.g - c1.g) * (v - vmin) / dv + c1.g;
            c.b = (c2.b - c1.b) * (v - vmin) / dv + c1.b;
            break;
        case 12:
            c1.r = 55 / 255.0;
            c1.g = 55 / 255.0;
            c1.b = 45 / 255.0;
            /* c2.r = 200 / 255.0; c2.g =  60 / 255.0; c2.b =   0 / 255.0; */
            c2.r = 235 / 255.0;
            c2.g = 90 / 255.0;
            c2.b = 30 / 255.0;
            c3.r = 250 / 255.0;
            c3.g = 160 / 255.0;
            c3.b = 110 / 255.0;
            ratio = 0.4;
            vmid = vmin + ratio * dv;
            if (v < vmid) {
                c.r = (c2.r - c1.r) * (v - vmin) / (ratio * dv) + c1.r;
                c.g = (c2.g - c1.g) * (v - vmin) / (ratio * dv) + c1.g;
                c.b = (c2.b - c1.b) * (v - vmin) / (ratio * dv) + c1.b;
            }
            else {
                c.r = (c3.r - c2.r) * (v - vmid) / ((1 - ratio) * dv) + c2.r;
                c.g = (c3.g - c2.g) * (v - vmid) / ((1 - ratio) * dv) + c2.g;
                c.b = (c3.b - c2.b) * (v - vmid) / ((1 - ratio) * dv) + c2.b;
            }
            break;
        case 13:
            c1.r = 0 / 255.0;
            c1.g = 255 / 255.0;
            c1.b = 0 / 255.0;
            c2.r = 255 / 255.0;
            c2.g = 150 / 255.0;
            c2.b = 0 / 255.0;
            c3.r = 255 / 255.0;
            c3.g = 250 / 255.0;
            c3.b = 240 / 255.0;
            ratio = 0.3;
            vmid = vmin + ratio * dv;
            if (v < vmid) {
                c.r = (c2.r - c1.r) * (v - vmin) / (ratio * dv) + c1.r;
                c.g = (c2.g - c1.g) * (v - vmin) / (ratio * dv) + c1.g;
                c.b = (c2.b - c1.b) * (v - vmin) / (ratio * dv) + c1.b;
            }
            else {
                c.r = (c3.r - c2.r) * (v - vmid) / ((1 - ratio) * dv) + c2.r;
                c.g = (c3.g - c2.g) * (v - vmid) / ((1 - ratio) * dv) + c2.g;
                c.b = (c3.b - c2.b) * (v - vmid) / ((1 - ratio) * dv) + c2.b;
            }
            break;
        case 14:
            c.r = 1;
            c.g = 1 - (v - vmin) / dv;
            c.b = 0;
            break;
        case 15:
            if (v < (vmin + 0.25 * dv)) {
                c.r = 0;
                c.g = 4 * (v - vmin) / dv;
                c.b = 1;
            }
            else if (v < (vmin + 0.5 * dv)) {
                c.r = 0;
                c.g = 1;
                c.b = 1 - 4 * (v - vmin - 0.25 * dv) / dv;
            }
            else if (v < (vmin + 0.75 * dv)) {
                c.r = 4 * (v - vmin - 0.5 * dv) / dv;
                c.g = 1;
                c.b = 0;
            }
            else {
                c.r = 1;
                c.g = 1;
                c.b = 4 * (v - vmin - 0.75 * dv) / dv;
            }
            break;
        case 16:
            if (v < (vmin + 0.5 * dv)) {
                c.r = 0.0;
                c.g = 2 * (v - vmin) / dv;
                c.b = 1 - 2 * (v - vmin) / dv;
            }
            else {
                c.r = 2 * (v - vmin - 0.5 * dv) / dv;
                c.g = 1 - 2 * (v - vmin - 0.5 * dv) / dv;
                c.b = 0.0;
            }
            break;
        case 17:
            if (v < (vmin + 0.5 * dv)) {
                c.r = 1.0;
                c.g = 1 - 2 * (v - vmin) / dv;
                c.b = 2 * (v - vmin) / dv;
            }
            else {
                c.r = 1 - 2 * (v - vmin - 0.5 * dv) / dv;
                c.g = 2 * (v - vmin - 0.5 * dv) / dv;
                c.b = 1.0;
            }
            break;
        case 18:
            c.r = 0;
            c.g = (v - vmin) / (vmax - vmin);
            c.b = 1;
            break;
        case 19:
            c.r = (v - vmin) / (vmax - vmin);
            c.g = c.r;
            c.b = 1;
            break;
        case 20:
            c1.r = 0 / 255.0;
            c1.g = 160 / 255.0;
            c1.b = 0 / 255.0;
            c2.r = 180 / 255.0;
            c2.g = 220 / 255.0;
            c2.b = 0 / 255.0;
            c3.r = 250 / 255.0;
            c3.g = 220 / 255.0;
            c3.b = 170 / 255.0;
            ratio = 0.3;
            vmid = vmin + ratio * dv;
            if (v < vmid) {
                c.r = (c2.r - c1.r) * (v - vmin) / (ratio * dv) + c1.r;
                c.g = (c2.g - c1.g) * (v - vmin) / (ratio * dv) + c1.g;
                c.b = (c2.b - c1.b) * (v - vmin) / (ratio * dv) + c1.b;
            }
            else {
                c.r = (c3.r - c2.r) * (v - vmid) / ((1 - ratio) * dv) + c2.r;
                c.g = (c3.g - c2.g) * (v - vmid) / ((1 - ratio) * dv) + c2.g;
                c.b = (c3.b - c2.b) * (v - vmid) / ((1 - ratio) * dv) + c2.b;
            }
            break;
        case 21:
            c1.r = 255 / 255.0;
            c1.g = 255 / 255.0;
            c1.b = 200 / 255.0;
            c2.r = 150 / 255.0;
            c2.g = 150 / 255.0;
            c2.b = 255 / 255.0;
            c.r = (c2.r - c1.r) * (v - vmin) / dv + c1.r;
            c.g = (c2.g - c1.g) * (v - vmin) / dv + c1.g;
            c.b = (c2.b - c1.b) * (v - vmin) / dv + c1.b;
            break;
        case 22:
            c.r = 1 - (v - vmin) / dv;
            c.g = 1 - (v - vmin) / dv;
            c.b = (v - vmin) / dv;
            break;
        case 23:
            if (v < (vmin + 0.5 * dv)) {
                c.r = 1;
                c.g = 2 * (v - vmin) / dv;
                c.b = c.g;
            }
            else {
                c.r = 1 - 2 * (v - vmin - 0.5 * dv) / dv;
                c.g = c.r;
                c.b = 1;
            }
            break;
        case 24:
            if (v < (vmin + 0.5 * dv)) {
                c.r = 2 * (v - vmin) / dv;
                c.g = c.r;
                c.b = 1 - c.r;
            }
            else {
                c.r = 1;
                c.g = 1 - 2 * (v - vmin - 0.5 * dv) / dv;
                c.b = 0;
            }
            break;
        case 25:
            if (v < (vmin + dv / 3)) {
                c.r = 0;
                c.g = 3 * (v - vmin) / dv;
                c.b = 1;
            }
            else if (v < (vmin + 2 * dv / 3)) {
                c.r = 3 * (v - vmin - dv / 3) / dv;
                c.g = 1 - c.r;
                c.b = 1;
            }
            else {
                c.r = 1;
                c.g = 0;
                c.b = 1 - 3 * (v - vmin - 2 * dv / 3) / dv;
            }
            break;
    }
    return c;
}

