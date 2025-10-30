//
// Copyright 2025 New Vector Ltd
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

/*
 * Copyright 2025 (Tên của bạn)
 * Dựa trên SettingsViewController.m
 */

#import "LabsSettingsViewController.h"

// --- CÁC IMPORT CẦN THIẾT ---
#import "ThemeService.h"
//#import "RiotSettings.h"
//#import "AppDelegate.h"
#import "GeneratedInterface-Swift.h"
#import "MXKAccountManager.h"
#import "MXKAccount.h"
#import "MXKTableViewCellWithLabelAndSwitch.h"
#import "MXKTableViewCell.h"
// --- KẾT THÚC IMPORT ---


// Định nghĩa các hàng (rows) - Đã di chuyển từ SettingsViewController.m
typedef NS_ENUM(NSUInteger, LABS_ENABLE)
{
    LABS_ENABLE_RINGING_FOR_GROUP_CALLS_INDEX = 0,
    LABS_ENABLE_THREADS_INDEX,
    LABS_ENABLE_AUTO_REPORT_DECRYPTION_ERRORS,
    LABS_ENABLE_LIVE_LOCATION_SHARING,
    LABS_ENABLE_NEW_SESSION_MANAGER,
    LABS_ENABLE_NEW_CLIENT_INFO_FEATURE,
    LABS_ENABLE_WYSIWYG_COMPOSER,
    LABS_ENABLE_VOICE_BROADCAST
};


@interface LabsSettingsViewController () <UITableViewDelegate, UITableViewDataSource, ThreadsBetaCoordinatorBridgePresenterDelegate>
{
    // Observe kThemeServiceDidChangeThemeNotification to handle user interface theme change.
    __weak id kThemeServiceDidChangeThemeNotificationObserver;
    
    // Mảng động để chứa các hàng (rows)
    NSMutableArray<NSNumber*> *rows;
}

// Thuộc tính (property) đã được di chuyển
@property (nonatomic, strong) ThreadsBetaCoordinatorBridgePresenter *threadsBetaBridgePresenter;

@end

@implementation LabsSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [VectorL10n settingsLabs]; // Đặt tiêu đề
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever; // Dùng tiêu đề nhỏ
    }
    
    // --- TẠO TABLEVIEW BẰNG CODE ---
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    // Đăng ký cell
    [self.tableView registerClass:MXKTableViewCellWithLabelAndSwitch.class forCellReuseIdentifier:[MXKTableViewCellWithLabelAndSwitch defaultReuseIdentifier]];
    
    // Đảm bảo Table View có thể tự co giãn chiều cao cell
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.0f;
    
    // Khởi tạo mảng chứa các hàng
    rows = [NSMutableArray array];
    [self updateRows]; // Cập nhật các hàng sẽ hiển thị

    // Cập nhật giao diện theo theme
    [self userInterfaceThemeDidChange];
    
    // Observe user interface theme change.
    kThemeServiceDidChangeThemeNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kThemeServiceDidChangeThemeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        [self userInterfaceThemeDidChange];
        [self.tableView reloadData]; // Tải lại bảng khi theme đổi
    }];
}

- (void)dealloc
{
    if (kThemeServiceDidChangeThemeNotificationObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kThemeServiceDidChangeThemeNotificationObserver];
        kThemeServiceDidChangeThemeNotificationObserver = nil;
    }
}

/**
 Cập nhật danh sách các hàng (rows) sẽ hiển thị dựa trên cấu hình.
 */
- (void)updateRows
{
    [rows removeAllObjects];
    
    // Đây là logic được di chuyển từ 'updateSections' của SettingsViewController.m
    [rows addObject:@(LABS_ENABLE_RINGING_FOR_GROUP_CALLS_INDEX)];
    [rows addObject:@(LABS_ENABLE_THREADS_INDEX)];
    [rows addObject:@(LABS_ENABLE_AUTO_REPORT_DECRYPTION_ERRORS)];
    if (BuildSettings.locationSharingEnabled)
    {
        [rows addObject:@(LABS_ENABLE_LIVE_LOCATION_SHARING)];
    }
    [rows addObject:@(LABS_ENABLE_NEW_SESSION_MANAGER)];
    [rows addObject:@(LABS_ENABLE_NEW_CLIENT_INFO_FEATURE)];
    if (@available(iOS 15.0, *))
    {
        [rows addObject:@(LABS_ENABLE_WYSIWYG_COMPOSER)];
    }
    [rows addObject:@(LABS_ENABLE_VOICE_BROADCAST)];
    
    [self.tableView reloadData];
}

- (void)userInterfaceThemeDidChange
{
    [ThemeService.shared.theme applyStyleOnNavigationBar:self.navigationController.navigationBar];
    // NOTE: Cần khai báo 'activityIndicator'
    // self.activityIndicator.backgroundColor = ThemeService.shared.theme.overlayBackgroundColor;
    
    self.tableView.backgroundColor = ThemeService.shared.theme.thuybackgroundColor;
    self.view.backgroundColor = self.tableView.backgroundColor;
    self.tableView.separatorColor = ThemeService.shared.theme.lineBreakColor;
    
    [self.tableView reloadData];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ThemeService.shared.theme.statusBarStyle;
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // Chỉ có 1 section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rows.count; // Trả về số lượng hàng đã được tính toán
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Lấy đúng tag của hàng
    NSInteger rowTag = [rows[indexPath.row] integerValue];
    
    UITableViewCell *cell;

    // Toàn bộ khối switch/case được sao chép từ SettingsViewController.m (dòng 1612)
    
    switch (rowTag) {
        case LABS_ENABLE_RINGING_FOR_GROUP_CALLS_INDEX:
        {
            MXKTableViewCellWithLabelAndSwitch *labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
            
            labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableRingingForGroupCalls];
            // NOTE: Cần RiotSettings
            // labelAndSwitchCell.mxkSwitch.on = RiotSettings.shared.enableRingingForGroupCalls;
            labelAndSwitchCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;
            
            // [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableRingingForGroupCalls:) forControlEvents:UIControlEventTouchUpInside];
            
            cell = labelAndSwitchCell;
            break;
        }
        case LABS_ENABLE_THREADS_INDEX:
        {
            MXKTableViewCellWithLabelAndSwitch *labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
            
            labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableThreads];
            // NOTE: Cần RiotSettings
            // labelAndSwitchCell.mxkSwitch.on = RiotSettings.shared.enableThreads;
            labelAndSwitchCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;
            
            // [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableThreads:) forControlEvents:UIControlEventTouchUpInside];
            
            cell = labelAndSwitchCell;
            break;
        }
        case LABS_ENABLE_AUTO_REPORT_DECRYPTION_ERRORS:
        {
            cell = [self buildAutoReportDecryptionErrorsCellForTableView:tableView atIndexPath:indexPath];
            break;
        }
        case LABS_ENABLE_LIVE_LOCATION_SHARING:
        {
            cell = [self buildLiveLocationSharingCellForTableView:tableView atIndexPath:indexPath];
            break;
        }
        case LABS_ENABLE_NEW_SESSION_MANAGER:
        {
            MXKTableViewCellWithLabelAndSwitch *labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];

            labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableNewSessionManager];
            // NOTE: Cần RiotSettings
            // labelAndSwitchCell.mxkSwitch.on = RiotSettings.shared.enableNewSessionManager;
            labelAndSwitchCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;

            // [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableNewSessionManager:) forControlEvents:UIControlEventTouchUpInside];

            cell = labelAndSwitchCell;
            break;
        }
        case LABS_ENABLE_NEW_CLIENT_INFO_FEATURE:
        {
            MXKTableViewCellWithLabelAndSwitch *labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];

            labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableNewClientInfoFeature];
            // NOTE: Cần RiotSettings
            // labelAndSwitchCell.mxkSwitch.on = RiotSettings.shared.enableClientInformationFeature;
            labelAndSwitchCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;

            // [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableNewClientInfoFeature:) forControlEvents:UIControlEventTouchUpInside];

            cell = labelAndSwitchCell;
            break;
        }
        case LABS_ENABLE_WYSIWYG_COMPOSER:
        {
            MXKTableViewCellWithLabelAndSwitch *labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];

            labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableWysiwygComposer];
            // NOTE: Cần RiotSettings
            // labelAndSwitchCell.mxkSwitch.on = RiotSettings.shared.enableWysiwygComposer;
            labelAndSwitchCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;

            // [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableWysiwygComposerFeature:) forControlEvents:UIControlEventTouchUpInside];

            cell = labelAndSwitchCell;
            break;
        }
        case LABS_ENABLE_VOICE_BROADCAST:
        {
            MXKTableViewCellWithLabelAndSwitch *labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];

            labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableVoiceBroadcast];
            // NOTE: Cần RiotSettings
            // labelAndSwitchCell.mxkSwitch.on = RiotSettings.shared.enableVoiceBroadcast;
            labelAndSwitchCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;

            // [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableVoiceBroadcastFeature:) forControlEvents:UIControlEventTouchUpInside];

            cell = labelAndSwitchCell;
            break;
        }
        default:
            // Fallback cell
            cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = @"Lỗi";
            break;
    }

    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = ThemeService.shared.theme.backgroundColor;
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone)
    {
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView.backgroundColor = ThemeService.shared.theme.selectedBackgroundColor;
    }
}

// Không cần 'didSelectRowAtIndexPath' vì tất cả đều là switch (nút gạt)

#pragma mark - Các hàm (methods) được di chuyển từ SettingsViewController

// Hàm trợ giúp lấy cell (sao chép từ NotificationSettingsPageViewController.m)
- (MXKTableViewCellWithLabelAndSwitch*)getLabelAndSwitchCell:(UITableView*)tableView forIndexPath:(NSIndexPath *)indexPath
{
    MXKTableViewCellWithLabelAndSwitch *cell = [tableView dequeueReusableCellWithIdentifier:[MXKTableViewCellWithLabelAndSwitch defaultReuseIdentifier] forIndexPath:indexPath];
    
    cell.mxkLabelLeadingConstraint.constant = tableView.vc_separatorInset.left;
    cell.mxkSwitchTrailingConstraint.constant = 15;
    cell.mxkLabel.textColor = ThemeService.shared.theme.textPrimaryColor;

    // --- BỔ SUNG DYNAMIC TYPE START ---
    cell.mxkLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.mxkLabel.adjustsFontForContentSizeCategory = YES;
    cell.mxkLabel.numberOfLines = 0; // Quan trọng để cell co giãn
    // --- BỔ SUNG DYNAMIC TYPE END ---

    [cell.mxkSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [cell layoutIfNeeded];
    
    return cell;
}

// Các hàm trợ giúp tạo cell (sao chép từ SettingsViewController.m, dòng 1205)
- (UITableViewCell *)buildAutoReportDecryptionErrorsCellForTableView:(UITableView*)tableView
                                             atIndexPath:(NSIndexPath*)indexPath
{
    MXKTableViewCellWithLabelAndSwitch* labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
    
    labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableAutoReportDecryptionErrors];

    // --- BỔ SUNG DYNAMIC TYPE START (Cho các hàm build chuyên biệt) ---
    labelAndSwitchCell.mxkLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    labelAndSwitchCell.mxkLabel.adjustsFontForContentSizeCategory = YES;
    labelAndSwitchCell.mxkLabel.numberOfLines = 0;
    // --- BỔ SUNG DYNAMIC TYPE END ---
    
    // NOTE: Cần RiotSettings
    // labelAndSwitchCell.mxkSwitch.on = RiotSettings.shared.enableUISIAutoReporting;
    labelAndSwitchCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;
    labelAndSwitchCell.mxkSwitch.enabled = YES;
    // [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableAutoReportDecryptionErrors:) forControlEvents:UIControlEventTouchUpInside];
    
    return labelAndSwitchCell;
}

- (UITableViewCell *)buildLiveLocationSharingCellForTableView:(UITableView*)tableView
                                                  atIndexPath:(NSIndexPath*)indexPath
{
    MXKTableViewCellWithLabelAndSwitch* labelAndSwitchCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
    
    labelAndSwitchCell.mxkLabel.text = [VectorL10n settingsLabsEnableLiveLocationSharing];

    // --- BỔ SUNG DYNAMIC TYPE START (Cho các hàm build chuyên biệt) ---
    labelAndSwitchCell.mxkLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    labelAndSwitchCell.mxkLabel.adjustsFontForContentSizeCategory = YES;
    labelAndSwitchCell.mxkLabel.numberOfLines = 0;
    // --- BỔ SUNG DYNAMIC TYPE END ---
    
    // NOTE: Cần RiotSettings
    // labelAndSwitchCell.mxkSwitch.on = RiotSettings.shared.enableLiveLocationSharing;
    labelAndSwitchCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;
    labelAndSwitchCell.mxkSwitch.enabled = YES;
    // [labelAndSwitchCell.mxkSwitch addTarget:self action:@selector(toggleEnableLiveLocationSharing:) forControlEvents:UIControlEventTouchUpInside];
    
    return labelAndSwitchCell;
}


// Các hàm xử lý hành động (sao chép từ SettingsViewController.m, dòng 2616)
- (void)toggleEnableRingingForGroupCalls:(UISwitch *)sender
{
    // RiotSettings.shared.enableRingingForGroupCalls = sender.isOn;
}

- (void)toggleEnableThreads:(UISwitch *)sender
{
    // NOTE: Hàm này phức tạp và cần nhiều import/khai báo. Chỉ giữ logic Dynamic Type.
    /*
    if (sender.isOn && !self.mainSession.store.supportedMatrixVersions.supportsThreads)
    {
        // ... (Logic tạo và trình bày ThreadsBetaCoordinatorBridgePresenter) ...
        return;
    }
    */

    [self enableThreads:sender.isOn];
}

- (void)enableThreads:(BOOL)enable
{
    // RiotSettings.shared.enableThreads = enable;
    // MXSDKOptions.sharedInstance.enableThreads = enable;
    // [[MXKRoomDataSourceManager sharedManagerForMatrixSession:self.mainSession] reset];
    // [[AppDelegate theDelegate] restoreEmptyDetailsViewController];
}

- (void)toggleEnableNewSessionManager:(UISwitch *)sender
{
    // RiotSettings.shared.enableNewSessionManager = sender.isOn;
    // [self updateRows];
}

- (void)toggleEnableNewClientInfoFeature:(UISwitch *)sender
{
    // BOOL isEnabled = sender.isOn;
    // RiotSettings.shared.enableClientInformationFeature = isEnabled;
    // MXSDKOptions.sharedInstance.enableNewClientInformationFeature = isEnabled;
    // [self.mainSession updateClientInformation];
}

- (void)toggleEnableWysiwygComposerFeature:(UISwitch *)sender
{
    // RiotSettings.shared.enableWysiwygComposer = sender.isOn;
}

- (void)toggleEnableVoiceBroadcastFeature:(UISwitch *)sender
{
    // RiotSettings.shared.enableVoiceBroadcast = sender.isOn;
}

- (void)toggleEnableAutoReportDecryptionErrors:(UISwitch *)sender
{
    // RiotSettings.shared.enableUISIAutoReporting = sender.isOn;
}

- (void)toggleEnableLiveLocationSharing:(UISwitch *)sender
{
    // RiotSettings.shared.enableLiveLocationSharing = sender.isOn;
}

#pragma mark - ThreadsBetaCoordinatorBridgePresenterDelegate (Sao chép từ SettingsViewController.m, dòng 3108)

- (void)threadsBetaCoordinatorBridgePresenterDelegateDidTapEnable:(ThreadsBetaCoordinatorBridgePresenter *)coordinatorBridgePresenter
{
    // MXWeakify(self);
    // [self.threadsBetaBridgePresenter dismissWithAnimated:YES completion:^{
    //     MXStrongifyAndReturnIfNil(self);
    //     [self enableThreads:YES];
    //     [self updateRows]; // Cập nhật lại bảng
    // }];
}

- (void)threadsBetaCoordinatorBridgePresenterDelegateDidTapCancel:(ThreadsBetaCoordinatorBridgePresenter *)coordinatorBridgePresenter
{
    // MXWeakify(self);
    // [self.threadsBetaBridgePresenter dismissWithAnimated:YES completion:^{
    //     MXStrongifyAndReturnIfNil(self);
    //     [self updateRows]; // Cập nhật lại bảng
    // }];
}

@end
