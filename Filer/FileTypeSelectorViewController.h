//
//  FileTypeSelectorViewController.h
//  Filer
//
//  Created by ohashi tosikazu on 11/07/18.
//  Copyright 2011 nagoya-bunri. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FileTypeSelectorDelegate;

enum fileType{
    TYPE_FILE,
    TYPE_FOLDER
};

@interface FileTypeSelectorViewController : UITableViewController {
    id <FileTypeSelectorDelegate> delegate;
}

@property (nonatomic, assign) id <FileTypeSelectorDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;

@end

@protocol FileTypeSelectorDelegate

- (void)fileTypeSelector:(FileTypeSelectorViewController*)fileTypeSelector selectedFileType:(NSInteger)fileType;

@end
