#import <UIKit/UIKit.h>

static BOOL infiniteCoins = NO;
static BOOL infiniteGems = NO;

// --- HOOKS ---
// Coins class-ını hook edirik, NSObject yox

%hook Coins

- (int)getPlayerCoins {
    if (infiniteCoins) return 9999999;
    return %orig;
}

- (void)setCoins:(int)amount {
    if (infiniteCoins) amount = 9999999;
    %orig(amount);
}

- (void)rewardCoins:(int)amount withTitle:(id)title {
    if (infiniteCoins) amount = 9999999;
    %orig(amount, title);
}

%end

// --- MOD MENU UI ---

@interface ModMenuView : UIView
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, assign) BOOL isOpen;
@end

@implementation ModMenuView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(5, 120, 50, 50)];
    if (self) {
        self.isOpen = NO;
        self.userInteractionEnabled = YES;

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 50, 50);
        btn.backgroundColor = [UIColor colorWithRed:0.1 green:0.5 blue:1.0 alpha:0.85];
        btn.layer.cornerRadius = 25;
        btn.layer.borderWidth = 2;
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
        [btn setTitle:@"MOD" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        [btn addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        self.panel = [[UIView alloc] initWithFrame:CGRectMake(58, 0, 230, 140)];
        self.panel.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:0.95];
        self.panel.layer.cornerRadius = 14;
        self.panel.layer.borderWidth = 1;
        self.panel.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
        self.panel.hidden = YES;
        self.panel.userInteractionEnabled = YES;

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 230, 28)];
        title.text = @"🎮 HCR Mod Menu";
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont boldSystemFontOfSize:14];
        title.textAlignment = NSTextAlignmentCenter;
        [self.panel addSubview:title];

        // Coin toggle
        [self addToggle:@"💰 Sonsuz Sikkə" yOffset:45 selector:@selector(toggleCoins:)];
        // Gem toggle
        [self addToggle:@"💎 Sonsuz Gem" yOffset:90 selector:@selector(toggleGems:)];

        [self addSubview:self.panel];
    }
    return self;
}

- (void)addToggle:(NSString *)label yOffset:(CGFloat)y selector:(SEL)sel {
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(10, y, 210, 36)];
    row.backgroundColor = [UIColor colorWithWhite:0.18 alpha:1.0];
    row.layer.cornerRadius = 8;
    row.userInteractionEnabled = YES;

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 145, 36)];
    lbl.text = label;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:13];
    [row addSubview:lbl];

    UISwitch *sw = [[UISwitch alloc] init];
    sw.center = CGPointMake(185, 18);
    sw.transform = CGAffineTransformMakeScale(0.75, 0.75);
    sw.userInteractionEnabled = YES;
    [sw addTarget:self action:sel forControlEvents:UIControlEventValueChanged];
    [row addSubview:sw];
    [self.panel addSubview:row];
}

- (void)togglePanel {
    self.isOpen = !self.isOpen;
    self.panel.hidden = !self.isOpen;
}

- (void)toggleCoins:(UISwitch *)sw { infiniteCoins = sw.isOn; }
- (void)toggleGems:(UISwitch *)sw  { infiniteGems  = sw.isOn; }

@end

// --- INJECT ---

%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{
            UIWindow *win = [UIApplication sharedApplication].keyWindow;
            ModMenuView *menu = [[ModMenuView alloc] init];
            [win addSubview:menu];
            [win bringSubviewToFront:menu];
        });
    });
}

%end
