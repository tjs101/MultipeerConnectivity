//
//  ViewController.h
//  Peer_Mac
//
//  Created by quentin on 23/01/2017.
//  Copyright © 2017 Quentin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (nonatomic, assign) IBOutlet NSTableView *connecedTableView;/**<连接的tableview>*/
@property (nonatomic, assign) IBOutlet NSTableView *loserConnecedTableView;/**<失去连接的tableview>*/
@property (nonatomic, strong) IBOutlet NSTextField *deviceNumLabel;/**<设备数>*/

@end

