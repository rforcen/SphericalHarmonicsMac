//
//  PresetTable.m
//  SphericalHarmonicalMac
//
//  Created by asd on 02/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import "PresetTable.h"
#import "PresetCell.h"
#import "Common.h"


@implementation PresetTable 

-(void)awakeFromNib {
 
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return N_SH_CODES;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
//    NSLog(@"set item:%ld / %d", row, [c getnImages]);
    
    PresetCell*cell=[tableView makeViewWithIdentifier:@"PresetCell" owner:self];
    
    if (row<[c getnImages])     cell.image.image = c.imgs[row];
    else                        cell.image.image = nil; // still not generated
    cell.text.stringValue   = [NSString stringWithFormat:@"%08d", SphericHarmCodes[row]];
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    int selRow = (int)tableView.selectedRow;
  
//    NSLog(@"selected item:%d", selRow);
    
    [c.sh readCode:(int)selRow];
    [c.viewController displaySH];
}


@end
