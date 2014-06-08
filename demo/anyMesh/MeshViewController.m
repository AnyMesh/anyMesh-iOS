//
//  MeshViewController.m
//  anyMesh
//
//  Created by David Paul on 4/28/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshViewController.h"
#import "MeshMessage.h"
#import "MeshDeviceInfo.h"
#import "SetupView.h"
#import "UIView+AutoLayout.h"


@implementation MeshViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        am = [AnyMesh sharedInstance];
        am.delegate = self;
        messages = [[NSMutableArray alloc] init];
        
            }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!am.name) {

        SetupView *sView = [[[NSBundle mainBundle] loadNibNamed:@"SetupView" owner:self options:nil] objectAtIndex:0];
        sView.parentController = self;
        [sView presentInView:self.view];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    _msgField.delegate = self;
    _targetField.delegate = self;
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
    return [messages count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    cell.textLabel.text = @"Test";
    return cell;
}


-(void)connectWithInfo:(MeshDeviceInfo *)info
{
    [am connectWithName:info.name listeningTo:info.listensTo];
}

#pragma mark - AnyMesh Delegate Methods
-(void)anyMeshConnectedTo:(MeshDeviceInfo *)device
{
    [messages addObject:[NSString stringWithFormat:@"Connected to %@", device.name]];
    [self.tableView reloadData];
}

-(void)anyMeshDisconnectedFrom:(NSString *)name
{
    [messages addObject:[NSString stringWithFormat:@"Disconnected from %@", name]];
    [self.tableView reloadData];

}

-(void)anyMeshReceivedMessage:(MeshMessage *)message
{
    [messages addObject:[NSString stringWithFormat:@"Message from: %@", message.sender]];
    
    [self.tableView reloadData];
    
        
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!recognizer) {
        recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
        [self.view addGestureRecognizer:recognizer];
    }
}

-(void)dismissKeyboard:(id)sender
{
    [self.view endEditing:TRUE];
    if (recognizer) {
        [self.view removeGestureRecognizer:recognizer];
        recognizer = nil;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:TRUE];
    if (recognizer) {
        [self.view removeGestureRecognizer:recognizer];
        recognizer = nil;
    }
    return TRUE;
}

-(BOOL)shouldAutorotate
{
    return FALSE;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}


@end
