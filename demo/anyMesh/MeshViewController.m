//
//  MeshViewController.m
//  anyMesh
//
//  Created by David Paul on 4/28/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshViewController.h"
#import "MeshMessage.h"
#import "DeviceCell.h"
#import "MeshDeviceInfo.h"

@interface MeshViewController ()

@end

@implementation MeshViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        am = [AnyMesh sharedInstance];
        am.delegate = self;
        connectedDevices = [[NSMutableArray alloc] init];
        
        [am connectWithName:@"iphone" listeningTo:@[@"mobile", @"global"]];
        
            }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_tableView registerNib:[UINib nibWithNibName:@"DeviceCell" bundle:[NSBundle mainBundle]]  forCellReuseIdentifier:@"Cell"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)publishButtonPressed:(id)sender {
    [am publishToTarget:_targetField.text withData:@{@"msg":_msgField.text}];
    
}
- (IBAction)requestButtonPressed:(id)sender {
    [am requestToTarget:_targetField.text withData:@{@"msg":_msgField.text}];
}


#pragma mark - TableView Datasource and Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [connectedDevices count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    MeshDeviceInfo *info = [connectedDevices objectAtIndex:indexPath.row];
    cell.nameLabel.text = info.name;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 137;
}

#pragma mark - AnyMesh Delegate Methods
-(void)anyMeshConnectedTo:(MeshDeviceInfo *)device
{
    [connectedDevices addObject:device];
    [self.tableView reloadData];
}

-(void)anyMeshDisconnectedFrom:(NSString *)name
{
    MeshDeviceInfo *objectToRemove;
    for (MeshDeviceInfo *device in connectedDevices)
    {
        if ([device.name isEqualToString:name]) {
            objectToRemove = device;
        }
    }
    if (objectToRemove)[connectedDevices removeObject:objectToRemove];
    
    [self.tableView reloadData];
}

-(void)anyMeshReceivedMessage:(MeshMessage *)message
{
    MeshDeviceInfo *objectToRemove;
    for (MeshDeviceInfo *device in connectedDevices)
    {
        if ([device.name isEqualToString:message.sender]) {
            objectToRemove = device;
        }
    }
    if (objectToRemove){
        [connectedDevices removeObject:objectToRemove];
        [connectedDevices insertObject:objectToRemove atIndex:0];
    }
    
    [self.tableView reloadData];
    
    
    NSLog(@"***************************");
    NSLog(@"Received message from %@", message.sender);
    NSLog(@"Message type:%d", message.type);
    NSLog(@"Message target:%@", message.target);
    NSLog(@"%@", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message.data options:0 error:nil] encoding:NSUTF8StringEncoding]);
    NSLog(@"****************************");
    
}

@end
