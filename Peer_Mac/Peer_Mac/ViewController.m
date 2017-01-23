//
//  ViewController.m
//  Peer_Mac
//
//  Created by quentin on 23/01/2017.
//  Copyright © 2017 Quentin. All rights reserved.
//

#import "ViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <MBProgressHUD-OSX/MBProgressHUD.h>

static NSString *NAME_TAG = @"__________";

@interface ViewController ()<MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, NSTableViewDataSource ,NSTableViewDelegate>

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *serviceAdvertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *serviceBrowser;

@property (nonatomic, strong) NSMutableArray *peerItems;
@property (nonatomic, strong) NSMutableArray *loserPeerItems;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.peerItems = [NSMutableArray array];
    self.loserPeerItems = [NSMutableArray array];

    [self observerNearBy];
}

- (void)observerNearBy
{
    NSString *name = [NSString stringWithFormat:@"%@%@%@", @"dd", NAME_TAG, @"OSX"];
    
    MCPeerID *sessionPeerId = [[MCPeerID alloc] initWithDisplayName:name];
    
    self.session = [[MCSession alloc] initWithPeer:sessionPeerId securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    self.session.delegate = self;
    
    self.serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:sessionPeerId discoveryInfo:nil serviceType:@"abc-txtchat"];
    self.serviceAdvertiser.delegate = self;
    [self.serviceAdvertiser startAdvertisingPeer];
    
    self.serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:sessionPeerId serviceType:@"abc-txtchat"];
    self.serviceBrowser.delegate = self;
    [self.serviceBrowser startBrowsingForPeers];
    
}

#pragma mark - 解析名字

- (NSString *)nameForPeer:(MCPeerID *)peer
{
    if (!peer) {
        return @"";
    }
    return [[peer.displayName componentsSeparatedByString:NAME_TAG] firstObject];
}

- (NSString *)osForPeer:(MCPeerID *)peer
{
    if (!peer) {
        return @"";
    }
    return [[peer.displayName componentsSeparatedByString:NAME_TAG] lastObject];
}

#pragma mark - update device num

- (void)updateDeviceNum
{
    _deviceNumLabel.stringValue = [NSString stringWithFormat:@"%@", @([self.peerItems count])];
}

#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info
{
    NSLog(@"info %@ peerId %@", info, peerID.displayName);

    [self.peerItems addObject:peerID];
    [self.loserPeerItems removeObject:peerID];
    
    [self updateDeviceNum];

    [self.connecedTableView reloadData];
    [self.loserConnecedTableView reloadData];
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"MCNearbyServiceBrowser didNotStartBrowsingForPeers");
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHud.mode = MBProgressHUDModeText;
    progressHud.labelText = [NSString stringWithFormat:@"%@已失去连接", peerID.displayName];
    [progressHud hide:YES afterDelay:2];
    
    [self.peerItems removeObject:peerID];
    [self.loserPeerItems addObject:peerID];
    NSLog(@"MCNearbyServiceBrowser lostPeer:%@", peerID);
    
    [self updateDeviceNum];
    
    [self.connecedTableView reloadData];
    [self.loserConnecedTableView reloadData];
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler
{
    NSLog(@"didReceiveInvitationFromPeer %@", peerID.displayName);
    NSString *message = [NSString stringWithFormat:@"%@请求连接您的设备？是否接受？", peerID.displayName];
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = message;
    [alert addButtonWithTitle:@"接受"];
    [alert addButtonWithTitle:@"拒绝"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode == NSModalResponseOK) {
            invitationHandler(true, self.session);
        }
        else {
            invitationHandler(true, self.session);
        }
    }];

}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = [NSString stringWithFormat:@"%@连接了您的设备", peerID.displayName];
        if (state == MCSessionStateConnected) {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = message;
            [alert addButtonWithTitle:@"知道了"];
            [alert beginSheetModalForWindow:self.view.window completionHandler:NULL];
        }
    });

}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

#pragma mark - NSTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == _connecedTableView) {
        return [self.peerItems count];
    }
    else if (tableView == _loserConnecedTableView) {
        return [self.loserPeerItems count];
    }
    return 0;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    MCPeerID *peerId = nil;
    
    NSString *identifier =  tableView.identifier;
    
    if (tableView == _connecedTableView) {

        peerId = [self.peerItems objectAtIndex:row];

    }
    else if (tableView == _loserConnecedTableView) {

        peerId = [self.loserPeerItems objectAtIndex:row];

    }
    
    if ([identifier isEqualToString:@"left"]) {
        
        return [self nameForPeer:peerId];
    }
    else if ([identifier isEqualToString:@"right"]) {
        
        return [self osForPeer:peerId];
    }
    
    return @"";
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
