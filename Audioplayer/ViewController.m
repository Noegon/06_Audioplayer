//
//  ViewController.m
//  Audioplayer
//
//  Created by Alexey Stafeyev on 09.08.17.
//  Copyright © 2017 Alexey Stafeyev. All rights reserved.
//

#import "ViewController.h"
#import "NGNSong.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIImageView *albumCoverImageView;
@property (strong, nonatomic) IBOutlet UILabel *timeElapsedLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLeftLabel;
@property (strong, nonatomic) IBOutlet UISlider *timeScaleSlider;
@property (strong, nonatomic) IBOutlet UILabel *songNameLabel;

@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSTimer *timer;
@property (copy, nonatomic) NSArray *songList;
@property (assign, nonatomic) NSInteger currentSongIndex;

- (IBAction)playButtonTapped:(UIButton *)sender;
- (IBAction)timeScaleSliderValueChanged:(UISlider *)sender;
- (IBAction)timeScaleSliderValueSelected:(UISlider *)sender;
- (IBAction)nextSongButtonTapped;
- (IBAction)previousSongButtonTapped;

#pragma mark - timer methods
- (void)timerFired:(NSTimer *)timer;
- (void)startTimer;
- (void)stopTimer;

#pragma mark - additional handling methods

- (void)configuratePlayerWithAudioURL:(NSURL *)url;
- (NSString *)stringfiedTimeValue:(NSTimeInterval)time;
- (void)updateValuesOnDisplay;
- (void)updateTimeOnDisplay;
- (void)switchSong;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.songList = @[[NGNSong songWithFileName:@"Midnight_Express" songName:@"Midnight express" extension:@"mp3" author:@"Extreme" imageURL:@"https://a3-images.myspacecdn.com/images04/8/92965445adf04ee099211aea557fd9fd/300x300.jpg"],
                      [NGNSong songWithFileName:@"Polet_valkirii" songName:@"Ride of the Valkyries" extension:@"mp3" author:@"R. Wagner" imageURL:@"https://images-na.ssl-images-amazon.com/images/I/41J8T16MNXL.jpg"],
                      [NGNSong songWithFileName:@"Shestvie_bogov" songName:@"Gods march into Valhalla" extension:@"mp3" author:@"R. Wagner" imageURL:@"https://lastfm-img2.akamaized.net/i/u/300x300/47623965062f4d26b91eeeb4aef03029.jpg"]
                      ];
    self.player = nil;
    self.currentSongIndex = 0;
    [self switchSong];
}

- (IBAction)playButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        [self.player pause];
        [self stopTimer];
        [self updateValuesOnDisplay];
    } else {
        [self.player play];
        [self startTimer];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)timeScaleSliderValueChanged:(UISlider *)sender {
    if(self.timer)
        [self stopTimer];
    [self updateTimeOnDisplay];
}

- (IBAction)timeScaleSliderValueSelected:(UISlider *)sender {
    [self.player stop];
    self.player.currentTime = sender.value;
    [self updateTimeOnDisplay];
    if (self.playButton.isSelected) {
        [self.player prepareToPlay];
        [self.player play];
        [self startTimer];
    }
}

- (IBAction)nextSongButtonTapped {
    if (self.currentSongIndex < [self.songList indexOfObject:self.songList.lastObject]) {
        self.currentSongIndex += 1;
    } else {
        self.currentSongIndex = [self.songList indexOfObject:self.songList.firstObject];
    }
    [self switchSong];
}

- (IBAction)previousSongButtonTapped {

    if (self.currentSongIndex > [self.songList indexOfObject:self.songList.firstObject]) {
        self.currentSongIndex -= 1;
    } else {
        self.currentSongIndex = [self.songList indexOfObject:self.songList.lastObject];
    }
    [self switchSong];
}

#pragma mark - timer methods
- (void)timerFired:(NSTimer *)timer {
    [self updateValuesOnDisplay];
    self.timeScaleSlider.value = self.player.currentTime;
}

- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - additional handling methods
- (void)configuratePlayerWithAudioURL:(NSURL *)url {
    self.player = nil;
    
    NSAssert(url, @"URL is valid.");
    NSError* error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if(!self.player) {
        NSLog(@"Error creating player: %@", error);
    }
    self.player.delegate = self;
    [self.player prepareToPlay];
    self.timeLeftLabel.text = [NSString stringWithFormat:@"%@", [self stringfiedTimeValue:self.player.duration]];
    self.timeScaleSlider.minimumValue = 0;
    self.timeScaleSlider.maximumValue = self.player.duration;
}

- (void)updateValuesOnDisplay {
    self.timeScaleSlider.value = self.player.currentTime;
    [self updateTimeOnDisplay];
    NGNSong *song = self.songList[self.currentSongIndex];
    self.songNameLabel.text = song.songName;
}

- (void)updateTimeOnDisplay {
    self.timeElapsedLabel.text = [self stringfiedTimeValue:self.player.currentTime];
    self.timeLeftLabel.text = [self stringfiedTimeValue:self.player.duration - self.player.currentTime];
}

- (NSString *)stringfiedTimeValue:(NSTimeInterval)time {
    NSInteger minutes = time / 60;
    NSTimeInterval seconds = time - (minutes * 60);
    return [NSString stringWithFormat:@"%ld:%02.f", minutes, seconds];
}

#pragma mark - AudioplayerDelegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag {
    [self stopTimer];
    self.playButton.selected = NO;
    [self updateValuesOnDisplay];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError * __nullable)error {
    [self stopTimer];
    self.playButton.selected = NO;
    [self updateValuesOnDisplay];
    NSLog(@"%@", error.userInfo);
}

- (void)switchSong {
    [self.player stop];
    [self stopTimer];
    NGNSong *song = self.songList[self.currentSongIndex];
    NSURL *url = [[NSBundle mainBundle] URLForResource:song.fileName withExtension:song.extension];
    NSAssert(url, @"URL is invalid.");
    [self configuratePlayerWithAudioURL:url];
    [self updateValuesOnDisplay];
    if (self.playButton.isSelected) {
        self.playButton.selected = YES;
        [self.player play];
        [self startTimer];
    }
    [self loadAlbumImageWithURL:song.imageURL];
}

- (void)loadAlbumImageWithURL:(NSString *)imageURL {
    NSURL *url = [NSURL URLWithString:imageURL];
    NSURLSessionTask *task =
        [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:
         ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
             if (data) {
                 UIImage *image = [UIImage imageWithData:data];
                 if (image) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         self.albumCoverImageView.image = [UIImage imageWithData:data];
                     });
                 }
             }
    }];
    [task resume];
}

@end
