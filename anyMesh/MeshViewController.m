//
//  MeshViewController.m
//  anyMesh
//
//  Created by David Paul on 4/28/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshViewController.h"
#import "MeshMessage.h"

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
        
        //[_tableView registerClass:[UITableViewCell class]  forCellReuseIdentifier:@"Cell"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)publishButtonPressed:(id)sender {
    
}
- (IBAction)requestButtonPressed:(id)sender {
    
}


#pragma mark - TableView Datasource and Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [connectedDevices count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = @"Test";
    return cell;
}

#pragma mark - AnyMesh Delegate Methods
-(void)anyMeshConnectedTo:(MeshDeviceInfo *)device
{
    [connectedDevices addObject:device];
}

-(void)anyMeshDisconnectedFrom:(MeshDeviceInfo *)device
{
    [connectedDevices removeObject:device];
}

-(void)anyMeshReceivedMessage:(MeshMessage *)message
{
    NSLog(@"***************************");
    NSLog(@"Received message from %@", message.sender);
    NSLog(@"Message type:%d", message.type);
    NSLog(@"Message target:%@", message.target);
    NSLog(@"****************************");
    
}

@end