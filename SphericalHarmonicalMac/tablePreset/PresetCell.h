//
//  PresetCell.h
//  SphericalHarmonicalMac
//
//  Created by asd on 02/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PresetCell : NSTableCellView
@property (weak) IBOutlet NSImageView *image;
@property (weak) IBOutlet NSTextField *text;

@end

NS_ASSUME_NONNULL_END
