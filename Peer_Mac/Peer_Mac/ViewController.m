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

@interface ViewController ()<MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, NSTableViewDataSource ,NSTableViewDelegate>

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *serviceAdvertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *serviceBrowser;

@property (nonatomic, strong) NSMutableArray *peerItems;
@property (nonatomic, strong) NSMutableArray *bindPeerItems;

@property (nonatomic, strong) NSMutableArray *typeItems;
@property (nonatomic, strong) NSMutableArray *statusItems;

@property (nonatomic, strong) NSMutableArray *chatItems;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.peerItems = [NSMutableArray array];
    self.bindPeerItems = [NSMutableArray array];
    
    self.typeItems = [NSMutableArray array];
    self.statusItems = [NSMutableArray array];
    
    self.chatItems = [NSMutableArray array];

    [self observerNearBy];
}

#pragma mark - IBAction

- (IBAction)onSendClick:(id)sender
{
    
    NSData *data = [_inputField.stringValue dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    BOOL success = [self.session sendData:data toPeers:self.bindPeerItems withMode:MCSessionSendDataReliable error:&error];
    if (!success) {
        NSLog(@"error %@", error);
    }
    else {
        
        [self.chatItems addObject:[NSString stringWithFormat:@"(我:)%@", _inputField.stringValue]];
        
        [self.chatTableView reloadData];
    }
}

#pragma mark - nearby

- (void)observerNearBy
{
    NSHost *host = [NSHost currentHost];
    
    MCPeerID *sessionPeerId = [[MCPeerID alloc] initWithDisplayName:host.localizedName];
    
    self.session = [[MCSession alloc] initWithPeer:sessionPeerId securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    self.session.delegate = self;
    
    self.serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:sessionPeerId discoveryInfo:@{@"type" : @"OSX"} serviceType:@"abc-txtchat"];
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

    NSInteger index = [self.peerItems indexOfObject:peerID];
    if (index == NSNotFound) {
        [self.peerItems addObject:peerID];
        [self.typeItems addObject:[info objectForKey:@"type"] != nil ? [info objectForKey:@"type"] : @"未知"];
        [self.statusItems addObject:@"离线"];
    }
    else {

        [self.statusItems replaceObjectAtIndex:index withObject:@"离线"];
    }

    [self.connecedTableView reloadData];
    
    [self.serviceBrowser invitePeer:peerID toSession:self.session withContext:nil timeout:30];
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
    
    [self.bindPeerItems removeObject:peerID];
    
    NSInteger index = [self.peerItems indexOfObject:peerID];

    [self.statusItems replaceObjectAtIndex:index withObject:@"离线"];

    NSLog(@"MCNearbyServiceBrowser lostPeer:%@", peerID);

    [self.connecedTableView reloadData];
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler
{
    NSLog(@"didReceiveInvitationFromPeer %@", peerID.displayName);
    
    invitationHandler(true, self.session);
    
    NSInteger index = [self.peerItems indexOfObject:peerID];
    if (index != NSNotFound) {
        [self.statusItems replaceObjectAtIndex:index withObject:@"在线"];
    }
    [self.connecedTableView reloadData];
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    [self.bindPeerItems removeObject:peerID];
    [self.bindPeerItems addObject:peerID];
    
    NSInteger index = [self.peerItems indexOfObject:peerID];
    if (index != NSNotFound) {
        if (state == MCSessionStateConnected) {
            [self.statusItems replaceObjectAtIndex:index withObject:@"在线"];
        }
        else if (state == MCSessionStateConnecting) {
            [self.statusItems replaceObjectAtIndex:index withObject:@"连线中"];
        }
        else {
            [self.statusItems replaceObjectAtIndex:index withObject:@"离线"];
        }
    }
    
    [self.connecedTableView reloadData];
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.chatItems addObject:[NSString stringWithFormat:@"(%@:)%@", peerID.displayName, message]];
    
    [self.chatTableView reloadData];
    
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
    else if (tableView == _chatTableView) {
        return [self.chatItems count];
    }
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{

    if (tableView == _chatTableView) {// 聊天
        
        return [self.chatItems objectAtIndex:row];
        
    }
    else {
        MCPeerID *peerId = nil;
        
        NSString *identifier = tableColumn.identifier;
        
        if (tableView == _connecedTableView) {
            
            peerId = [self.peerItems objectAtIndex:row];
            
        }

        if ([identifier isEqualToString:@"name"]) {
            
            return peerId.displayName;
        }
        else if ([identifier isEqualToString:@"type"]) {
            
            return [self.typeItems objectAtIndex:row];
        }
        else if ([identifier isEqualToString:@"status"]) {
            
            return [self.statusItems objectAtIndex:row];
        }
    }
    
    return @"";
}

//- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
//{
//    if (tableView == _connecedTableView) {
//        
//        MCPeerID *peerId = [self.peerItems objectAtIndex:row];
//        [self.serviceBrowser invitePeer:peerId toSession:self.session withContext:nil timeout:30];
//    }
//    return YES;
//}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
