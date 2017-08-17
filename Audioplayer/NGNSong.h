//
//  NGNSong.h
//  Audioplayer
//
//  Created by Stafeyev Alexei on 09/08/2017.
//  Copyright © 2017 Alexey Stafeyev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NGNSong : NSObject

@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *songName;
@property (copy, nonatomic) NSString *extension;
@property (copy, nonatomic) NSString *author;
@property (copy, nonatomic) NSString *imageURL;

+ (instancetype)songWithFileName:(NSString *)fileName
                        songName:(NSString *)songName
                       extension:(NSString *)extension
                          author:(NSString *)author
                        imageURL:(NSString *)imageURL;

- (instancetype)initWithFileName:(NSString *)fileName
                        songName:(NSString *)songName
                       extension:(NSString *)extension
                          author:(NSString *)author
                        imageURL:(NSString *)imageURL;

@end
