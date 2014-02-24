//
//  MainViewController.m
//  Prototyper
//
//  Created by Andy Qua on 12/01/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

#import "MainViewController.h"
#import "Project.h"
#import "ProjectSelectTableViewCell.h"
#import "PopoverView.h"
#import "PlaybackViewController.h"
#import "Constants.h"

#import "IASKAppSettingsViewController.h"

@interface MainViewController () <IASKSettingsDelegate, PopoverViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    PopoverView *popoverView;

    NSMutableArray *projects;
    NSString *selectedProjectName;
    
    UIBarButtonItem *actionButton;
    UIBarButtonItem *doneButton;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionPressed:)];
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
    self.navigationItem.rightBarButtonItem = actionButton;
}

- (void) viewWillAppear:(BOOL)animated
{
    // Register for import notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProjects) name:NOTIF_IMPORTED object:nil];

    [self loadProjects];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)unwindFromViewController:(UIStoryboardSegue *)segue
{
}


-( IBAction) addProjectPressed:(id)sender
{
/*
    // Display new window showing asking user to import project
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Import project" message:@"Enter URL of project to import" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av textFieldAtIndex:0].text = @"http://";
    [av show];
*/
}

-( IBAction) actionPressed:(id)sender
{
    NSArray *items = @[@"Delete projects", @"Settings", @"Add demo project"];
    popoverView = [PopoverView showPopoverAtPoint:CGPointMake( self.view.frame.size.width - 20, 0) inView:self.view withStringArray:items delegate:self];
}


#pragma mark - UIAlertViewDelegate methods
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if ( inputText.length <= 7 )
        return NO;
    
    NSURL *url = [NSURL URLWithString:inputText];
    if ( url == nil )
        return NO;
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 1 )
    {
        NSString *text = [alertView textFieldAtIndex:0].text;
        NSURL *url = [NSURL URLWithString:text];

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            __block NSError *err = nil;
            
            
            
            [Project importProjectArchiveFromURL:url error:&err];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ( err )
                {
                    // Error - go no futher
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Problem" message:err.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                }
                
                [self loadProjects];
                [self.tableView reloadData];
            });
        });
    }
}


#pragma mark - PopoverView delegate

- (void)popoverView:(PopoverView *)thePopoverView didSelectItemAtIndex:(NSInteger)index itemText:(NSString *)text
{
    if ( [text isEqualToString:@"Delete projects"] )
    {
        self.tableView.editing = YES;
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem = doneButton;
        self.addButton.enabled = NO;
    }
    else if ( [text isEqualToString:@"Settings"] )
    {
        IASKAppSettingsViewController *appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
        appSettingsViewController.delegate = self;
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            appSettingsViewController.showDoneButton = YES;
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:appSettingsViewController];
            nc.modalPresentationStyle = UIModalPresentationFormSheet;
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
            [self presentViewController:nc animated:YES completion:^{ }];
        }
        else
        {
            appSettingsViewController.showDoneButton = NO;
            [self.navigationController pushViewController:appSettingsViewController animated:YES];
        }
    }
    else if ( [text isEqualToString:@"Add demo project"] )
    {
        // Copy over demo file into place
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"demo" withExtension:@"zip"];
        [Project importProjectArchiveFromURL:url error:nil];

        [self loadProjects];
        [self.tableView reloadData];
    }
    [popoverView dismiss];
    popoverView = nil;
    
}

- (void)popoverViewDidDismiss:(PopoverView *)thePopoverView;
{
    popoverView = nil;
}


- (void) donePressed:(id)sender
{
    self.tableView.editing = NO;
    [self.tableView reloadData];

    self.navigationItem.rightBarButtonItem = actionButton;
    self.addButton.enabled = YES;
}

#pragma mark - Load projects
- (void) loadProjects
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    projects = [NSMutableArray array];
    NSArray *files = [fm contentsOfDirectoryAtPath:[Project getDocsDir] error:nil];
    for ( NSString *file in files )
    {
        NSString *path = [[Project getDocsDir] stringByAppendingPathComponent:file];
        BOOL isDir = NO;
        if (![file hasPrefix:@"."] && [fm fileExistsAtPath:path isDirectory:&isDir] && isDir)
        {
            Project *p = [[Project alloc] init];
            p.projectName = file;
            [projects addObject:p];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"PlayProject"] )
    {
        PlaybackViewController *vc = segue.destinationViewController;
        Project *project = [[Project alloc] initWithProjectName:selectedProjectName];
        vc.project = project;
    }
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return projects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Project *project = projects[indexPath.row];
    cell.projectName.text = project.projectName;

    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Project *project = projects[indexPath.row];
    selectedProjectName = project.projectName;
    [self performSegueWithIdentifier:@"PlayProject" sender:self];
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( editingStyle == UITableViewCellEditingStyleDelete )
    {
        Project *project = projects[indexPath.row];
        [Project deleteProjectWithName:project.projectName];
        [projects removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - InAppSettingsKit Delegate
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
