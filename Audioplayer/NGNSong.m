//
//  NGNSong.m
//  Audioplayer
//
//  Created by Stafeyev Alexei on 09/08/2017.
//  Copyright © 2017 Alexey Stafeyev. All rights reserved.
//

#import "NGNSong.h"

@implementation NGNSong

+ (instancetype)songWithFileName:(NSString *)fileName
                        songName:(NSString *)songName
                       extension:(NSString *)extension
                          author:(NSString *)author
                        imageURL:(NSString *)imageURL {
    return [[self alloc] initWithFileName:fileName songName:songName extension:extension author:author imageURL:imageURL];
}

- (instancetype)initWithFileName:(NSString *)fileName
                       songName:(NSString *)songName
                       extension:(NSString *)extension
                          author:(NSString *)author
                        imageURL:(NSString *)imageURL {
    if (self = [super init]) {
        _fileName = [fileName copy];
        _songName = [songName copy];
        _extension = [extension copy];
        _author = [author copy];
        _imageURL = [imageURL copy];
    }
    return self;
}

@end
