//
//  ViewController.m
//  Peer_Mac
//
//  Created by quentin on 23/01/2017.
//  Copyright © 2017 Quentin. All rights reserved.
//

#import "ViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController ()<MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, NSTableViewDataSource ,NSTableViewDelegate>

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *serviceAdvertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *serviceBrowser;

@property (nonatomic, strong) NSMutableArray *peerItems;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.peerItems = [NSMutableArray array];

    [self observerNearBy];
}

- (void)observerNearBy
{
    MCPeerID *sessionPeerId = [[MCPeerID alloc] initWithDisplayName:@"dd"];
    
    self.session = [[MCSession alloc] initWithPeer:sessionPeerId securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    self.session.delegate = self;
    
    self.serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:sessionPeerId discoveryInfo:nil serviceType:@"abc-txtchat"];
    self.serviceAdvertiser.delegate = self;
    [self.serviceAdvertiser startAdvertisingPeer];
    
    self.serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:sessionPeerId serviceType:@"abc-txtchat"];
    self.serviceBrowser.delegate = self;
    [self.serviceBrowser startBrowsingForPeers];
    
}

#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info
{
    NSLog(@"info %@ peerId %@", info, peerID.displayName);
    
//    [self.serviceBrowser stopBrowsingForPeers];

    [self.peerItems addObject:peerID];

    [self.tableView reloadData];
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"MCNearbyServiceBrowser didNotStartBrowsingForPeers");
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    [self.peerItems removeObject:peerID];
    NSLog(@"MCNearbyServiceBrowser lostPeer:%@", peerID);
    
    [self.tableView reloadData];
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler
{
    NSLog(@"didReceiveInvitationFromPeer %@", peerID.displayName);
    NSString *message = [NSString stringWithFormat:@"%@连接您的设备", peerID.displayName];
    
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
    NSLog(@"MCSession didChangeState %@ %d", peerID.displayName, state);
    if (state == MCSessionStateConnected) {
        
    }
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
    return [self.peerItems count];
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    MCPeerID *peerId = [self.peerItems objectAtIndex:row];
    return peerId.displayName;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
