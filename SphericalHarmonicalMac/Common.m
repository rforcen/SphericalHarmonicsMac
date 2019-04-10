//
//  Common.m
//  SphericalHarmonics
//
//  Created by asd on 04/10/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import "Common.h"
#import "SCNUtils.h"

@interface NSImage(ResizeCategory)
- (NSImage *)imageDefaultResize;
- (void) saveAsJpegWithName:(NSString*) fileName;
@end

@implementation NSImage (ResizeCategory)
- (NSImage *)imageDefaultResize {
    NSImage *sourceImage=self;
    NSSize newSize=NSMakeSize(256, 256);
    
    if (! sourceImage.isValid) return nil;
    
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL
                             pixelsWide:newSize.width
                             pixelsHigh:newSize.height
                             bitsPerSample:8
                             samplesPerPixel:4
                             hasAlpha:YES
                             isPlanar:NO
                             colorSpaceName:NSCalibratedRGBColorSpace
                             bytesPerRow:0
                             bitsPerPixel:0];
    rep.size = newSize;
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
    [sourceImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height) fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
    [newImage addRepresentation:rep];
    newImage.accessibilityDescription = [sourceImage accessibilityDescription];
    return newImage;
}

- (void) saveAsJpegWithName:(NSString*) fileName {
    // Cache the reduced image
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.5] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSBitmapImageFileTypeJPEG properties:imageProps];
    [imageData writeToFile:fileName atomically:NO];
}
@end

@implementation Common 

+(id)init {
    Common *common=[[super alloc]init];
    
    common.sh=[SphericalHarmonics init];
    common.imgs=[NSMutableArray array];
    common.myscene = [SCNScene scene]; // Create an empty scene
    
    [Common randomize];
    [common createAnimation];
    
    common.nCPU=[[NSProcessInfo processInfo] processorCount]; // get number of processors for MThreading
    return common;
}

+(void) randomize { srand((unsigned)time(NULL)); }
+(float) rnd :(float)range {  return (float)(range * rand())/RAND_MAX; }


-(void)addNodeSH {
    SCNNode*root = _myscene.rootNode;
    [_shNode removeFromParentNode]; // remove last from root
    [root addChildNode:_shNode=_sh->node]; // keep node for prev. deletion
}
-(NSString*)getCode {
    return [NSString stringWithCString:_sh->code encoding:NSASCIIStringEncoding];
}
-(void)createAnimation {
    SCNNode*root=_myscene.rootNode; // w/camera & light
    
    [root addChildNode:[SCNUtils createCamera:9]];
    [root addChildNode:[SCNUtils createAmbientLight]];
    [root addChildNode:[SCNUtils createDiffuseLightWithPosition:SCNVector3Make(-30, 30, 50)]];
}
-(void)setTheSceneView : (SCNView*)inScene {
    [self addNodeSH];
    
    _sceneView=inScene;
    inScene.scene = _myscene; // and assign created scene
    inScene.allowsCameraControl = YES; // allows the user to manipulate the camera (move scene)
    inScene.backgroundColor = [NSColor clearColor]; // configure the view
    inScene.showsStatistics = YES;// show statistics such as fps and timing information
}

-(void)setHandleTab: (NSObject*)caller scene:(SCNView*)inScene  selector:(SEL)selector {
    // add a tap gesture recognizer
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:[[NSPanGestureRecognizer alloc] initWithTarget:caller action:selector]];
    [gestureRecognizers addObjectsFromArray:inScene.gestureRecognizers];
    inScene.gestureRecognizers = gestureRecognizers;
}
-(void)generateImages {
    NSString *thumbsPath=@"/SHTHN";
    const int thSize=512;
    
    // Create path for thumbs
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:thumbsPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) // exists?
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder if ! exists
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
        
        Common *ct=[Common init];
        SCNView*scnv=[[SCNView alloc] initWithFrame:CGRectMake(0, 0, thSize, thSize)];
        [ct setTheSceneView:scnv];
        
        for (int nCode=0;  nCode<N_SH_CODES; nCode++) {
            
            NSString *filePath=[NSString stringWithFormat:@"%@/%@.png",dataPath, [ct.sh getCode:nCode]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (! [[NSFileManager defaultManager] fileExistsAtPath:filePath]) { // th exists? no:create, yes:read
                    [ct.sh readCode:nCode]; // generate sh
                    [ct addNodeSH];
                    self->_imgs[nCode] = ct->_sceneView.snapshot; // copy image to self not ct
                    [self->_imgs[nCode] saveAsJpegWithName:filePath]; // Save image.
                    if(nCode==10 && self->_viewController) [self->_viewController refresh];
                } else {
                    self->_imgs[nCode] = [[NSImage alloc] initWithContentsOfFile:filePath];
                }
            });
        }
        
        [ct.sh freeMesh];
        
        if(self->_viewController) [self->_viewController refresh];
    });
    
}
-(int) getnImages {
    return (int)[_imgs count];
}
-(BOOL)imageGenerationCompleted {
    return [_imgs count]==N_SH_CODES;
}
@end

Common*c; // the common instance
