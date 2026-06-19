#import <UIKit/UIKit.h>

static BOOL infiniteCoins = NO;
static BOOL infiniteGems = NO;
static BOOL infiniteFuel = NO;

%hook NSObject

- (int)getPlayerCoins {
    if (infiniteCoins) return 9999999;
    return %orig;
}

- (void)setGems:(int)gems {
    if (infiniteGems) gems = 9999999;
    %orig(gems);
}

- (float)getFuelAmount {
    if (infiniteFuel) return 999.0f;
    return %orig;
}

%end

@interface ModMenuView : UIView
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, assign) BOOL isOpen;
@end

@implementation ModMenuView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(5, 100, 44, 44)];
    if (self) {
        self.isOpen = NO;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(0, 0, 44, 44);
        btn.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:0.9];
        btn.layer.cornerRadius = 22;
        [btn setTitle:@"MOD" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [btn addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        self.panel = [[UIView alloc] initWithFrame:CGRectMake(50, 0, 220, 185)];
        self.panel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
        self.panel.layer.cornerRadius = 12;
        self.panel.hidden = YES;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 220, 28)];
        title.text = @"🎮 HCR Mod Menu";
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont boldSystemFontOfSize:13];
        title.textAlignment = NSTextAlignmentCenter;
        [self.panel addSubview:title];
        
        NSArray *labels = @[@"💰 Sonsuz Sikkə", @"💎 Sonsuz Gem", @"⛽ Sonsuz Yanacaq"];
        NSArray *selectors = @[@"toggleCoins:", @"toggleGems:", @"toggleFuel:"];
        
        for (int i = 0; i < 3; i++) {
            UIView *row = [[UIView alloc] initWithFrame:CGRectMake(10, 42 + i*44, 200, 38)];
            row.backgroundColor = [UIColor colorWithWhite:0.22 alpha:1.0];
            row.layer.cornerRadius = 8;
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 140, 38)];
            lbl.text = labels[i];
            lbl.textColor = [UIColor whiteColor];
            lbl.font = [UIFont systemFontOfSize:13];
            [row addSubview:lbl];
            
            UISwitch *sw = [[UISwitch alloc] init];
            sw.frame = CGRectMake(150, 6, 0, 0);
            sw.transform = CGAffineTransformMakeScale(0.75, 0.75);
            sw.tag = i;
            [sw addTarget:self action:NSSelectorFromString(selectors[i]) forControlEvents:UIControlEventValueChanged];
            [row addSubview:sw];
            [self.panel addSubview:row];
        }
        
        [self addSubview:self.panel];
    }
    return self;
}

- (void)togglePanel {
    self.isOpen = !self.isOpen;
    self.panel.hidden = !self.isOpen;
}

- (void)toggleCoins:(UISwitch *)sw { infiniteCoins = sw.isOn; }
- (void)toggleGems:(UISwitch *)sw  { infiniteGems  = sw.isOn; }
- (void)toggleFuel:(UISwitch *)sw  { infiniteFuel  = sw.isOn; }

@end

%hook UIWindow
- (void)makeKeyAndVisible {
    %orig;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{
            ModMenuView *menu = [[ModMenuView alloc] init];
            [self addSubview:menu];
        });
    });
}
%end
