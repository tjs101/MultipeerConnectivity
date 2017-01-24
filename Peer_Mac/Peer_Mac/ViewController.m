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
@property (nonatomic, strong) NSMutableArray *loserPeerItems;
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
    self.loserPeerItems = [NSMutableArray array];
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
        [self.serviceBrowser invitePeer:[self.bindPeerItems firstObject] toSession:self.session withContext:nil timeout:30];
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
    
    MCPeerID *sessionPeerId = [[MCPeerID alloc] initWithDisplayName:[NSString stringWithFormat:@"%@%@", host.localizedName, host.name]];
    
    self.session = [[MCSession alloc] initWithPeer:sessionPeerId securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    self.session.delegate = self;
    
    self.serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:sessionPeerId discoveryInfo:@{@"type" : @"OSX"} serviceType:@"abc-txtchat"];
    self.serviceAdvertiser.delegate = self;
    [self.serviceAdvertiser startAdvertisingPeer];
    
    self.serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:sessionPeerId serviceType:@"abc-txtchat"];
    self.serviceBrowser.delegate = self;
    [self.serviceBrowser startBrowsingForPeers];
    
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
    [self.typeItems addObject:[info objectForKey:@"type"]];
    [self.statusItems addObject:@"未连接"];
    
    [self.loserPeerItems removeObject:peerID];
    
    [self updateDeviceNum];

    [self.connecedTableView reloadData];
    [self.loserConnecedTableView reloadData];
    
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
    [self.peerItems removeObject:peerID];
    [self.typeItems removeObjectAtIndex:index];
    [self.statusItems removeObjectAtIndex:index];
    
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

    if (YES) {
        invitationHandler(true, self.session);
        
        NSInteger index = [self.peerItems indexOfObject:peerID];
        [self.statusItems replaceObjectAtIndex:index withObject:@"已连接"];
        
        [self.connecedTableView reloadData];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"%@请求连接您的设备？是否接受？", peerID.displayName];
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = message;
    
    [alert addButtonWithTitle:@"拒绝"];
    [alert addButtonWithTitle:@"接受"];
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode == NSAlertFirstButtonReturn) {
            invitationHandler(false, self.session);
            
            NSInteger index = [self.peerItems indexOfObject:peerID];
            [self.statusItems replaceObjectAtIndex:index withObject:@"已拒绝"];
            
        }
        else if (returnCode == NSAlertSecondButtonReturn) {

            invitationHandler(true, self.session);
            
            NSInteger index = [self.peerItems indexOfObject:peerID];
            [self.statusItems replaceObjectAtIndex:index withObject:@"已连接"];
        }
        
        [self.connecedTableView reloadData];
    }];

}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (YES) {
        [self.bindPeerItems removeObject:peerID];
        [self.bindPeerItems addObject:peerID];
        
        NSInteger index = [self.peerItems indexOfObject:peerID];
        [self.statusItems replaceObjectAtIndex:index withObject:@"已连接"];
        
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = [NSString stringWithFormat:@"%@连接了您的设备", peerID.displayName];
        if (state == MCSessionStateConnected) {
            
            [self.bindPeerItems removeObject:peerID];
            [self.bindPeerItems addObject:peerID];
            
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = message;
            [alert addButtonWithTitle:@"知道了"];
            [alert beginSheetModalForWindow:self.view.window completionHandler:NULL];
        }
        
    });

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
    else if (tableView == _loserConnecedTableView) {
        return [self.loserPeerItems count];
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
        else if (tableView == _loserConnecedTableView) {
            
            peerId = [self.loserPeerItems objectAtIndex:row];
            
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
