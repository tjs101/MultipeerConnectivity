//
//  PEViewController.m
//  Peer_IOS
//
//  Created by quentin on 23/01/2017.
//  Copyright © 2017 Quentin. All rights reserved.
//

#import "PEViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <HAlertController/HAlertController.h>

@interface PEViewController () <MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID  *peerId;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *serviceAdvertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *serviceBrowser;

@property (nonatomic, strong) NSMutableArray *peerItems;

@end

@implementation PEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.peerItems = [NSMutableArray array];
    
    [self observerNearBy];
}

- (void)observerNearBy
{
    MCPeerID *sessionPeerId = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    
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
    
    [self.serviceBrowser stopBrowsingForPeers];
    
    self.peerId = peerID;
    
    [self.peerItems addObject:peerID];
    
    [self.tableView reloadData];
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"MCNearbyServiceBrowser didNotStartBrowsingForPeers");
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    [self.serviceBrowser startBrowsingForPeers];
    
    self.peerId = nil;
    NSLog(@"MCNearbyServiceBrowser lostPeer:%@", peerID);
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler
{
    NSLog(@"didReceiveInvitationFromPeer %@", peerID.displayName);
    NSString *message = [NSString stringWithFormat:@"%@连接您的设备", peerID.displayName];
    
    HAlertController *alertCtrl = [HAlertController alertWithTitle:@"提示" message:message cancelButtonItem:[HAlertAction actionWithTitle:@"接受" handler:^(NSString * _Nonnull title) {
        invitationHandler(true, self.session);
    }] destructiveButtonItem:[HAlertAction actionWithTitle:@"拒绝" handler:^(NSString * _Nonnull title) {
        invitationHandler(false, self.session);
    }]];
    [alertCtrl showIn:self];
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"MCSession didChangeState %@ %d", peerID.displayName, state);
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


#pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    MCPeerID *peer = [self.peerItems objectAtIndex:indexPath.row];
    cell.textLabel.text = peer.displayName;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.peerItems count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.peerItems count] == 0) {
        return;
    }
    
    MCPeerID *peer = [self.peerItems objectAtIndex:indexPath.row];
    
    [self.serviceBrowser invitePeer:peer toSession:self.session withContext:nil timeout:50];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
