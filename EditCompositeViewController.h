//
//  EditCompositeViewController.h
//  Filer
//
//  Created by ohashi tosikazu on 11/07/15.
//  Copyright 2011 nagoya-bunri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileTypeSelectorViewController.h"

@class Composite, Folder;

@interface EditCompositeViewController : UITableViewController <FileTypeSelectorDelegate>{
    NSInteger selectedFileType;
}

@property (nonatomic, retain) Folder *parentComposite;
@property (nonatomic, retain) Composite *editComposite;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UITextField *nameInput;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end
