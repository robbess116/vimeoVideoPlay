//
//  MediaPlayerUIVIew.h
//  vimeoVideo
//
//  Created by MacDev on 6/4/17.
//  Copyright © 2017 Robbess. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
@interface MediaPlayerUIVIew : UIView
@property (strong, nonatomic) IBOutlet UIImageView *imgViewPlaceholder;
@property (strong, nonatomic) IBOutlet UIButton *btnBigPlay;
@property (strong, nonatomic) IBOutlet UIView *viewVideoTool;
@property (strong, nonatomic) IBOutlet UISlider *sliderVideo;
@property (strong, nonatomic) IBOutlet UILabel *lbCurrentTime;
@property (strong, nonatomic) IBOutlet UIButton *btnFullScreen1;
@property (strong, nonatomic) IBOutlet UIView *viewFlip;
@property (strong, nonatomic) IBOutlet UISlider *sliderVolume;
@property (strong, nonatomic) IBOutlet UIButton *btnVolume;
@property (strong, nonatomic) IBOutlet UIButton *btnBackward;
@property (strong, nonatomic) IBOutlet UIButton *btnSmallPlay;
@property (strong, nonatomic) IBOutlet UIButton *btnForward;
@property (strong, nonatomic) IBOutlet UIButton *btnFullscreen2;
@property (strong, nonatomic) IBOutlet UIView *viewPlayer;
@property (strong, nonatomic) IBOutlet UILabel *lbVideoDurationTime;
@property (assign, nonatomic) NSString *strVideoUrl;
@property (assign, nonatomic) NSURL *urlThumb;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewSmallPlay;
@property (weak, nonatomic) AVPlayer *player;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, assign) Boolean isPlaying;
@property (nonatomic, assign) NSInteger backGNumber;


+(id)customView;
- (void) initView;
- (void) initData;
- (void) playerPause;
- (void) loadMediaPlayer;
- (void) removeObserver;
- (void) addObserver;
- (void) hidePlayerToolbar:(void(^)(BOOL fiished)) completion ;
- (void) showPlayerToolbar:(UITapGestureRecognizer *) recognizer;

@end
