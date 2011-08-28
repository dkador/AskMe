//
//  ChoicesController.m
//  AskMe
//
//  Created by Daniel Kador on 7/2/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import "ChoicesController.h"
#import "WaitingController.h"


@interface ChoicesController()

- (void) addSelected;

@end

@implementation ChoicesController

@synthesize question=question_, choices=choices_;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self setChoices:[NSMutableArray arrayWithCapacity:4]];
    }
    return self;
}

- (void)dealloc
{
    [question_ release];
    [choices_ release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(addSelected)];
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self choices] count] + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@\nAdd answers!", self.question];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if (indexPath.row < [self.choices count]) {
        cell.textLabel.text = [self.choices objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = @"Add...";
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.choices count]) {
        AddChoiceController *theController = [[AddChoiceController alloc] init];
        theController.delegate = self;
        [self.navigationController pushViewController:theController animated:YES];
        [theController release];
    }
}

# pragma mark - private implementation

- (void) addSelected {
    NSLog(@"addSelected");
    WaitingController *controller = [[WaitingController alloc] initWithQuestion:self.question AndChoices:self.choices];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

# pragma mark - AddChoiceControllerDelegate impl

- (void)choiceAdded:(NSString *)choice {
    [self.choices addObject:choice];
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
