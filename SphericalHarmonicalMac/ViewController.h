//
//  ViewController.h
//  SphericalHarmonicalMac
//
//  Created by asd on 02/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface ViewController : NSViewController
-(void)displaySH;
-(void)refresh;

@property (weak) IBOutlet SCNView *sceneView;
@property (weak) IBOutlet NSTextField *code;
@property (weak) IBOutlet NSTableView *tablePresets;


@end

