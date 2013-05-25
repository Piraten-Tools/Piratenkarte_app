//
//  PIKServerListViewController.m
//  Piratenkarte
//
//  Created by Dominik Wagner on 25.05.13.
//  Copyright (c) 2013 Dominik Wagner. All rights reserved.
//

#import "PIKServerListViewController.h"
#import "PIKLongDescriptionTableViewCell.h"

@interface PIKServerListViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSArray *liveServerArray;
@property (nonatomic, strong) NSArray *developmentServerArray;
@property (nonatomic, strong) PIKPlakatServer *selectedServer;
@property (nonatomic, strong) PIKPlakatServer *initialSelectedServer;
@property (nonatomic, strong) UILabel *measurementLabel;
@end

@implementation PIKServerListViewController

+ (instancetype)serverListViewControllerWithServerList:(NSArray *)aServerList selectedServer:(PIKPlakatServer *)aSelectedServer {
    PIKServerListViewController *result = [[PIKServerListViewController alloc] initWithNibName:@"PIKServerListViewController" bundle:nil];
    result.selectedServer = aSelectedServer;
    result.initialSelectedServer = aSelectedServer;
    NSMutableArray *liveServers = [NSMutableArray new];
    NSMutableArray *devServers = [NSMutableArray new];
    for (PIKPlakatServer *server in aServerList) {
        [(server.isDevelopment ? devServers : liveServers) addObject:server];
    }
    result.liveServerArray = liveServers;
    result.developmentServerArray = devServers;
    return result;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        PIKLongDescriptionTableViewCell *cell = [[PIKLongDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"unused"];
        cell.frame = CGRectMake(0, 0, 320, 200);
        cell.textLabel.text = @"testtext";
        cell.detailTextLabel.text = @"testtext";
        [cell layoutSubviews];
        self.measurementLabel = cell.detailTextLabel;
        self.measurementLabel.numberOfLines = 0;
        self.measurementLabel.frame = CGRectMake(0,0,280,640);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (NSArray *)serverArrayForSection:(NSInteger)section {
    if (section == 0) return self.liveServerArray;
    if (section == 1) return self.developmentServerArray;
    return nil;
}

- (PIKPlakatServer *)plakatServerAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *serverList = [self serverArrayForSection:indexPath.section];
    PIKPlakatServer *server;
    if (serverList.count > indexPath.row) {
        server = serverList[indexPath.row];
    }
    return server;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self serverArrayForSection:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Live";
    } else {
        return @"Development";
    }
}

- (NSString *)detailForPlakatServer:(PIKPlakatServer *)aPlakatServer {
    NSString *result = [@[aPlakatServer.serverBaseURL, aPlakatServer.serverInfoText] componentsJoinedByString:@"\n"];
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PIKPlakatServer *server = [self plakatServerAtIndexPath:indexPath];
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Server"];
    if (!cell) {
        cell = [[PIKLongDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Server"];
    }
    cell.textLabel.text = server.serverName;
    cell.detailTextLabel.text = [self detailForPlakatServer:server];
    
    if ([server isEqual:self.selectedServer]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedServer = [self plakatServerAtIndexPath:indexPath];
    for (int s=0; s<[self numberOfSectionsInTableView:tableView]; s++) {
        for (int i=0; i<[self tableView:tableView numberOfRowsInSection:s]; i++) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:s]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {    
    PIKPlakatServer *server = [self plakatServerAtIndexPath:indexPath];
    self.measurementLabel.frame = CGRectMake(0,0,280,640);
    
    CGSize testSize = CGSizeMake(260, 640);
    CGSize realSize = [[self detailForPlakatServer:server] sizeWithFont:self.measurementLabel.font constrainedToSize:testSize lineBreakMode:UILineBreakModeWordWrap];
    
    
    CGFloat height = realSize.height;
    height += 32;
    return height;
}

- (void)cancelAction {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)doneAction {
    if (![self.selectedServer.identifier isEqualToString:self.initialSelectedServer.identifier]) {
        [[PIKPlakatServerManager plakatServerManager] selectPlakatServer:self.selectedServer];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end