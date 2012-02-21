//
//  ChoicesController.m
//  AskMe
//
//  Created by Daniel Kador on 7/2/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import "ChoicesController.h"
#import "WaitingController.h"
#import "Util.h"
#import "KeenClient.h"


@interface ChoicesController()

- (void) addSelected;

@end

@implementation ChoicesController

@synthesize question=question_, choices=choices_;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self setChoices:[NSMutableArray arrayWithCapacity:4]];
    }
    return self;
}

- (void)dealloc {
    [question_ release];
    [choices_ release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"New Choices";

    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(addSelected)];
    nextButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];
    
    self.tableView.editing = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; // 1 for orig question, 1 for choices
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return [[self choices] count] + 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Your Question";
    } else {
        return @"Your Choices";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
    }
    
    // Configure the cell...
    if (indexPath.section == 0) {
        cell.textLabel.text = self.question;
    } else {
        if (indexPath.row < [self.choices count]) {
            cell.textLabel.text = [self.choices objectAtIndex:indexPath.row];
        } else {
            cell.textLabel.text = @"Add...";
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleInsert && indexPath.row == [self.choices count]) {
        AddChoiceController *theController = [[AddChoiceController alloc] init];
        theController.delegate = self;
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:theController animated:YES];
        [theController release];
    } else if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.row < self.choices.count) {
        [self.choices removeObjectAtIndex:indexPath.row];
        if (self.choices.count == 0) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        [self.tableView reloadData];
    }
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // only allow add cell to be selected
    if (indexPath.section == 1 && indexPath.row == self.choices.count) {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.choices count]) {
        AddChoiceController *theController = [[AddChoiceController alloc] init];
        theController.delegate = self;
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:theController animated:YES];
        [theController release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat retVal = 0;
    NSString *stringVal = nil;
    UIFont *font = [UIFont systemFontOfSize:17];
    if (indexPath.section == 0) {
        stringVal = self.question;
    } else {
        if (indexPath.row < self.choices.count) {
            stringVal = [self.choices objectAtIndex:indexPath.row];
        } else {
            stringVal = @"Add...";
        }
    }
    CGSize max = CGSizeMake([Util getCurrentDeviceWidth] - 20, CGFLOAT_MAX);
    retVal = [stringVal sizeWithFont:font constrainedToSize:max lineBreakMode:UILineBreakModeWordWrap].height;
    return MAX(44, retVal); // table view cell height is 44 - never want it to be smaller than that
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.choices.count) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

# pragma mark - private implementation

- (void) addSelected {
    WaitingController *controller = [[WaitingController alloc] initWithQuestion:self.question AndChoices:self.choices];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:[Util UUIDForDevice], @"user",
                           @"questions and choices finished", @"name", 
                           [NSNumber numberWithInt:self.choices.count], @"number", nil];
    [[KeenClient lastRequestedClient] addEvent:event toCollection:@"flows"];
}

# pragma mark - AddChoiceControllerDelegate impl

- (void)choiceAdded:(NSString *)choice {
    [self.choices addObject:choice];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:[Util UUIDForDevice], @"user", 
                           @"choice added", @"name", 
                           [NSNumber numberWithInt:self.choices.count], @"number", nil];
    [[KeenClient lastRequestedClient] addEvent:event toCollection:@"flows"];
}

@end
