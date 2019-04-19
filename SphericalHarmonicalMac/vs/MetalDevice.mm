//
//  MBEContext.m
//  MetalKernel
//
//  Created by asd on 28/03/2019.
//  Copyright © 2019 voicesync. All rights reserved.
//


#import "MetalDevice.h"
#import <math.h>


@implementation MetalDevice

+(instancetype)init {
    MetalDevice*md=[[super alloc]init];
    md.device=MTLCreateSystemDefaultDevice();
    md.library=[md.device newDefaultLibrary];
    return md;
}

-(id<MTLBuffer>)createBuffer: (void*)data length:(NSInteger)len {
    return [_device newBufferWithBytes:data  length:len options:MTLResourceStorageModeShared];
}

-(void)setBufferParam:(id<MTLBuffer>)buffer index:(uint)index {
    [_commandEncoder setBuffer:buffer offset:0 atIndex:index];
}
-(void)setBytesParam:(void*)data length:(uint)length index:(int)index {
    [_commandEncoder setBytes:data length:length atIndex:index];
}

-(void)runThreadsWidth:(NSUInteger)width height:(NSUInteger)height { // for a w x h grid
    MTLSize threadsPerGrid = MTLSizeMake(width, height, 1);
    NSUInteger _w = _pipeline.threadExecutionWidth;
    NSUInteger _h = _pipeline.maxTotalThreadsPerThreadgroup / _w;
    MTLSize threadsPerThreadgroup = MTLSizeMake(_w, _h, 1);
    [_commandEncoder dispatchThreads: threadsPerGrid
                          threadsPerThreadgroup: threadsPerThreadgroup];
    
    [self run];
}

-(void)copyContentsOn:(void*)data buffer:(id<MTLBuffer>)buffer {
    memcpy(data, [buffer contents], buffer.allocatedSize);
}

-(void)compileFunc:(NSString*)func {
    // prepare shader
    _kernelFunction = [_library newFunctionWithName:func];
    _pipeline = [_device  newComputePipelineStateWithFunction:_kernelFunction error:nil];
    _commandBuffer = [[_device newCommandQueue] commandBuffer];
    _commandEncoder = [_commandBuffer computeCommandEncoder];
    [_commandEncoder setComputePipelineState:_pipeline];
}

-(void)run {
    [_commandEncoder endEncoding];
    [_commandBuffer commit ];
    [_commandBuffer waitUntilCompleted];
}

+(NSTimeInterval) timeIt: (void (^) (void))block {
    NSDate *start = [NSDate date];
    block();
    return -[start timeIntervalSinceNow] * 1000.;
}

@end
