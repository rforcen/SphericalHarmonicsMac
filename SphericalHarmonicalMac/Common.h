//
//  Common.h
//  SphericalHarmonics
//
//  Created by asd on 04/10/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import "SphericalHarmonics.h"
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface Common : NSObject 

@property SCNView*sceneView;
@property SCNScene*myscene;
@property SphericalHarmonics*sh;
@property SCNNode*shNode;
@property NSImage*img;
@property NSMutableArray<NSImage*>*imgs;
@property NSUInteger nCPU;
@property ViewController*viewController;

+(id)init;
-(void)createAnimation;
-(void)setTheSceneView : (SCNView*)inScene;
-(void)addNodeSH;
-(void)setHandleTab: (NSObject*)caller scene:(SCNView*)inScene  selector:(SEL)selector ;
-(NSString*)getCode;
-(void)generateImages;
-(BOOL)imageGenerationCompleted;
-(int) getnImages;
@end

extern Common *c; // main common instance

NS_ASSUME_NONNULL_END
