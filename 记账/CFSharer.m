//
//  Sharer.m
//  CFShareCircle
//
//  Created by Camden on 1/15/13.
//  Copyright (c) 2013 Camden. All rights reserved.
//

#import "CFSharer.h"

@implementation CFSharer

@synthesize name = _name;
@synthesize image = _image;

- (id)initWithName:(NSString *)name imageName:(NSString *)imageName {
    self = [super init];
    if (self) {
        _name = name;
        _image = [UIImage imageNamed:imageName];
    }
    return self;    
}

+ (CFSharer *)mail {
    return [[CFSharer alloc] initWithName:@"Mail" imageName:@"mail.png"];
}

+ (CFSharer *)photoLibrary {
    return [[CFSharer alloc] initWithName:@"Photos" imageName:@"photo_library.png"];
}

+ (CFSharer *)logout {
    return [[CFSharer alloc] initWithName:@"Log Out" imageName:@"logout.png"];
}

+ (CFSharer *)evernote {
    return [[CFSharer alloc] initWithName:@"Evernote" imageName:@"evernote.png"];
}

+ (CFSharer *)facebook {
    return [[CFSharer alloc] initWithName:@"Info" imageName:@"info.png"];
}

+ (CFSharer *)googleDrive {
    return [[CFSharer alloc] initWithName:@"Login" imageName:@"login.png"];
}

+ (CFSharer *)pinterest {
    return [[CFSharer alloc] initWithName:@"Add" imageName:@"add.png"];
}

+ (CFSharer *)twitter {
    return [[CFSharer alloc] initWithName:@"Sync" imageName:@"sync.png"];
}

@end
