//
//  ViewController.m
//  VideoPlayer
//
//  Created by RichMan on 4/26/17.
//  Copyright © 2017 DanakaMobDev. All rights reserved.
//

#import "ViewController.h"
#import "MediaPlayerUIVIew.h"


@interface ViewController (){
    MediaPlayerUIVIew *mediaPlayerView;
    CMTime currentTime;
    
}

@property (strong, nonatomic) AVPlayerViewController * videoController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    
}

- (void) viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    if (mediaPlayerView.player != nil ){
        [mediaPlayerView addObserver];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [mediaPlayerView playerPause];
    if (mediaPlayerView.player != nil ){
        [mediaPlayerView removeObserver];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}



-(void) appEnteredForeground {
    //    AVPlayerLayer *player = (AVPlayerLayer *)[playerView layer];
    //    [player setPlayer:NULL];
    //    [player setPlayer:_player];
    [self playAt:currentTime];
}

-(void) appEnteredBackground {
    
    [mediaPlayerView playerPause];
    currentTime = [mediaPlayerView.player currentTime];
}

-(void)playAt: (CMTime)time {
    if(mediaPlayerView.player.status == AVPlayerStatusReadyToPlay && mediaPlayerView.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        [mediaPlayerView.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            [mediaPlayerView.btnBigPlay sendActionsForControlEvents:UIControlEventTouchUpInside];
        }];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self playAt:time];
        });
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [mediaPlayerView playerPause];
    
    
}

-(void) initView {
    
    
    mediaPlayerView = [MediaPlayerUIVIew customView];
    mediaPlayerView.strVideoUrl = @"http://vimeo.com/52760742";
    
    
    
    [mediaPlayerView.btnFullScreen1 addTarget:self action:@selector(showVideoFullScreen:) forControlEvents:UIControlEventTouchUpInside];
    [mediaPlayerView.btnFullscreen2 addTarget:self action:@selector(showVideoFullScreen:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect rect = mediaPlayerView.frame;
    //    float rateWidth =  self.vlcVideoView.frame.size.width /rect.size.width;
    rect.size.width = self.view.frame.size.width;
    rect.size.height = self.view.frame.size.height/2;
    rect.origin.y = self.view.frame.size.height/4;
    rect.origin.x = 0;
    mediaPlayerView.frame = rect;
    [self.view addSubview:mediaPlayerView];
    
}


- (void) showVideoFullScreen:(UIButton *) slider {
    //    AVPlayer *player;
    
    //    if(mediaPlayerView.player != nil)
    //        player = mediaPlayerView.player;
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    self.videoController = [[AVPlayerViewController alloc] init];
    self.videoController.showsPlaybackControls = true;
    self.videoController.player = mediaPlayerView.player;
    //self.videoController.player.automaticallyWaitsToMinimizeStalling = YES;
    //    [_player play];
    
    [mediaPlayerView hidePlayerToolbar:^(BOOL fiished) {
        [self presentViewController:self.videoController animated:YES completion:nil];
    }];
}
- (IBAction)onClickBtnBack:(id)sender {
    [mediaPlayerView playerPause];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
