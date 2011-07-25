//
//  EditCompositeViewController.m
//  Filer
//
//  Created by ohashi tosikazu on 11/07/15.
//  Copyright 2011 nagoya-bunri. All rights reserved.
//

#import "EditCompositeViewController.h"


#import "Composite.h"
#import "Folder.h"
#import "File.h"

@implementation EditCompositeViewController

@synthesize parentComposite, editComposite;
@synthesize managedObjectContext;
@synthesize nameInput;

- (void)dealloc
{
    [parentComposite release];
    [editComposite release];
    [nameInput release];
    
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    nameInput = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"新規作成";
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.navigationItem.leftBarButtonItem = saveButton;
    [saveButton release];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
    
    // タイトル入力のビューを作成して親のビューに追加
	UITextField *aNameInput = [[UITextField alloc] init];
	aNameInput.font = [UIFont systemFontOfSize:20.0f];
    aNameInput.placeholder = @"ファイル名を入力";
	self.nameInput = aNameInput;
	[aNameInput release];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
        
    [self.tableView reloadData];
}



#pragma mark -
#pragma mark TableViewDataSourceDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.row == 0) {
        // セルに最適なサイズを取得してタイトル入力フィールドに設定
        CGRect frame = CGRectInset(cell.contentView.bounds, 16, 8);
        nameInput.frame = frame;
        // タイトル入力フィールドをセルに追加
        [cell.contentView addSubview:nameInput];
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = @"ファイルの種類";
    }
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 1) {
        FileTypeSelectorViewController *fileTypeSelectorViewController = [[FileTypeSelectorViewController alloc] init];
        fileTypeSelectorViewController.delegate = self;
        [self.navigationController pushViewController:fileTypeSelectorViewController animated:YES];
        [fileTypeSelectorViewController release];
    }
}

- (IBAction)cancel:(id)sender {
    // 削除
    [self dismissModalViewControllerAnimated:YES];
}

- (void)createFile {
    File *newFile = (File*)[NSEntityDescription insertNewObjectForEntityForName:@"File" inManagedObjectContext:managedObjectContext];
    
    // 保存
    if (nameInput.text.length == 0) {
        newFile.name = @"新規ファイル";
    } else {
        newFile.name = nameInput.text;
    }
    
    [parentComposite addChildrenObject:newFile];
    newFile.parent = parentComposite;
    
    self.editComposite = newFile;
}

- (void)createFolder {
    Folder *newFolder = (Folder*)[NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:managedObjectContext];
        
    // 保存
    if (nameInput.text.length == 0) {
        newFolder.name = @"新規ファイル";
    } else {
        newFolder.name = nameInput.text;
    }
    
    [parentComposite addChildrenObject:newFolder];
    newFolder.parent = parentComposite;
    
    self.editComposite = newFolder;
}

- (IBAction)save:(id)sender {
    
    if (selectedFileType == TYPE_FILE) {
        [self createFile];
    }
    if (selectedFileType == TYPE_FOLDER) {
        [self createFolder];
    }
        
    // Save the context.
    NSError *error = nil;
    if (![managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)fileTypeSelector:(FileTypeSelectorViewController*)fileTypeSelector selectedFileType:(NSInteger)fileType
{
    selectedFileType = fileType;
}

@end
