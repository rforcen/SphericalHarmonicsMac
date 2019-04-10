//
//  ViewController.m
//  SphericalHarmonicalMac
//
//  Created by asd on 02/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import "ViewController.h"
#import "Common.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    c = [Common init];
    c.viewController=self;
    
    [c generateImages]; // generate images in backgroud
    [c setTheSceneView:_sceneView];
    
    [self randomCode];
}

-(void)randomCode {
    [c.sh randomCode];
    [self displaySH];
    _code.stringValue = [c getCode];
}

-(void)displaySH {
    if(c.sh->multiThread)
        dispatch_group_notify(c.sh->group, c.sh->queue, ^ { // wait complete all threads
            [c.sh createNode];
            [c addNodeSH];
        });
    else [c addNodeSH];
    _code.stringValue = [c getCode];
}

-(void)refresh {
    [_tablePresets reloadData];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}


//#pragma mark - Table View Delegate
//
//- (void)tableViewSelectionDidChange:(NSNotification *)notification {
//    NSTableView *tableView = notification.object;
//    int selRow = (int)tableView.selectedRow;
//
//    [c.sh readCode:(int)selRow];
//
//    [self displaySH];
//}

@end
