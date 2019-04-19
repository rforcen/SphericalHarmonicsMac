//
//  MBEContext.h
//  MetalKernel
//
//  Created by asd on 28/03/2019.
//  Copyright © 2019 voicesync. All rights reserved.
//

#ifndef MBEContext_h
#define MBEContext_h

#import <Metal/Metal.h>

@interface MetalDevice : NSObject // single metal device object

@property id<MTLDevice> device;
@property id<MTLLibrary> library;
@property id<MTLCommandQueue> commandQueue;
@property id<MTLFunction> kernelFunction;
@property id<MTLCommandBuffer> commandBuffer;
@property id<MTLComputeCommandEncoder> commandEncoder;
@property id<MTLComputePipelineState> pipeline;


+(instancetype)init;
-(void)compileFunc:(NSString*)func;
-(void)run;
-(id<MTLBuffer>)createBuffer: (void*)data length:(NSInteger)len;
-(void)runThreadsWidth:(NSUInteger)width height:(NSUInteger)height;
-(void)copyContentsOn:(void*)data buffer:(id<MTLBuffer>)buffer;
-(void)setBufferParam:(id<MTLBuffer>)buffer index:(uint)index;
-(void)setBytesParam:(void*)data length:(uint)length index:(int)index;
+(NSTimeInterval) timeIt : (void (^) (void))block;

@end




#endif /* MBEContext_h */
