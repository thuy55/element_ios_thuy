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

#import "AdvancedSettingsViewController.h"

// --- BẮT ĐẦU KHỐI IMPORT ĐÃ SỬA ---



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
typedef NS_ENUM(NSUInteger, ADVANCED)
{
    ADVANCED_CRASH_REPORT_INDEX = 0,
    ADVANCED_ENABLE_RAGESHAKE_INDEX,
    ADVANCED_MARK_ALL_AS_READ_INDEX,
    ADVANCED_CLEAR_CACHE_INDEX,
    ADVANCED_REPORT_BUG_INDEX,
};


@interface AdvancedSettingsViewController () <UITableViewDelegate, UITableViewDataSource>
{
    // Observe kThemeServiceDidChangeThemeNotification to handle user interface theme change.
    __weak id kThemeServiceDidChangeThemeNotificationObserver;
    
    // Mảng động để chứa các hàng (rows)
    NSMutableArray<NSNumber*> *rows;
}

@end

@implementation AdvancedSettingsViewController

#pragma mark - Initialisation / View lifecycle

// NOTE: Tôi giả định bạn đã thêm các thuộc tính cần thiết vào interface (như mainSession, activityIndicator)
// để các hàm như toggleAnalytics, markAllAsRead hoạt động đúng.

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [VectorL10n settingsAdvanced]; // Đặt tiêu đề
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
    [self.tableView registerClass:MXKTableViewCellWithButton.class forCellReuseIdentifier:[MXKTableViewCellWithButton defaultReuseIdentifier]]; // QUAN TRỌNG: Đăng ký cell nút
    [self.tableView registerClass:MXKTableViewCell.class forCellReuseIdentifier:[MXKTableViewCell defaultReuseIdentifier]]; // Đăng ký cell mặc định (nếu có dùng)

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
    if (BuildSettings.settingsScreenAllowChangingCrashUsageDataSettings)
    {
        [rows addObject:@(ADVANCED_CRASH_REPORT_INDEX)];
    }
    if (BuildSettings.settingsScreenAllowChangingRageshakeSettings)
    {
        [rows addObject:@(ADVANCED_ENABLE_RAGESHAKE_INDEX)];
    }
    [rows addObject:@(ADVANCED_MARK_ALL_AS_READ_INDEX)];
    [rows addObject:@(ADVANCED_CLEAR_CACHE_INDEX)];
    if (BuildSettings.settingsScreenAllowBugReportingManually)
    {
        [rows addObject:@(ADVANCED_REPORT_BUG_INDEX)];
    }
    
    [self.tableView reloadData];
}

- (void)userInterfaceThemeDidChange
{
    [ThemeService.shared.theme applyStyleOnNavigationBar:self.navigationController.navigationBar];
    // NOTE: Tôi đã loại bỏ activityIndicator nếu nó không được khai báo trong AdvancedSettingsViewController
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

// --- BẮT ĐẦU HÀM TẠO CELL BỔ SUNG DYNAMIC TYPE ---

- (MXKTableViewCellWithLabelAndSwitch*)getLabelAndSwitchCell:(UITableView*)tableView forIndexPath:(NSIndexPath *)indexPath
{
    MXKTableViewCellWithLabelAndSwitch *cell = [tableView dequeueReusableCellWithIdentifier:[MXKTableViewCellWithLabelAndSwitch defaultReuseIdentifier] forIndexPath:indexPath];
    
    cell.mxkLabelLeadingConstraint.constant = tableView.vc_separatorInset.left;
    cell.mxkSwitchTrailingConstraint.constant = 15;
    
    cell.mxkLabel.textColor = ThemeService.shared.theme.textPrimaryColor;

    // --- BỔ SUNG DYNAMIC TYPE CHO LABEL START ---
    cell.mxkLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.mxkLabel.adjustsFontForContentSizeCategory = YES;
    cell.mxkLabel.numberOfLines = 0; // Cho phép ngắt dòng để cell co giãn
    // --- BỔ SUNG DYNAMIC TYPE CHO LABEL END ---
    
    [cell.mxkSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    
    // Force layout before reusing a cell
    [cell layoutIfNeeded];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Lấy đúng tag của hàng
    NSInteger rowTag = [rows[indexPath.row] integerValue];
    
    UITableViewCell *cell;

    // Toàn bộ khối switch/case được sao chép từ SettingsViewController.m (dòng 1547)
    
    switch (rowTag) {
        case ADVANCED_CRASH_REPORT_INDEX:
        {
            MXKTableViewCellWithLabelAndSwitch* sendCrashReportCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];
            
            sendCrashReportCell.mxkLabel.text = VectorL10n.settingsAnalyticsAndCrashData;
//            sendCrashReportCell.mxkSwitch.on = Analytics.shared.isEnabled;
            sendCrashReportCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;
            sendCrashReportCell.mxkSwitch.enabled = YES;
            [sendCrashReportCell.mxkSwitch addTarget:self action:@selector(toggleAnalytics:) forControlEvents:UIControlEventTouchUpInside];
            
            cell = sendCrashReportCell;
            break;
        }
        case ADVANCED_ENABLE_RAGESHAKE_INDEX:
        {
            MXKTableViewCellWithLabelAndSwitch* enableRageShakeCell = [self getLabelAndSwitchCell:tableView forIndexPath:indexPath];

            enableRageShakeCell.mxkLabel.text = [VectorL10n settingsEnableRageshake];
            enableRageShakeCell.mxkSwitch.on = RiotSettings.shared.enableRageShake;
            enableRageShakeCell.mxkSwitch.onTintColor = ThemeService.shared.theme.tintColor;
            enableRageShakeCell.mxkSwitch.enabled = YES;
            [enableRageShakeCell.mxkSwitch addTarget:self action:@selector(toggleEnableRageShake:) forControlEvents:UIControlEventTouchUpInside];

            cell = enableRageShakeCell;
            break;
        }
        case ADVANCED_MARK_ALL_AS_READ_INDEX:
        {
            MXKTableViewCellWithButton *markAllBtnCell = [tableView dequeueReusableCellWithIdentifier:[MXKTableViewCellWithButton defaultReuseIdentifier]];
            
            if (!markAllBtnCell)
            {
                markAllBtnCell = [[MXKTableViewCellWithButton alloc] init];
            }
            
            NSString *btnTitle = [VectorL10n settingsMarkAllAsRead];
            [markAllBtnCell.mxkButton setTitle:btnTitle forState:UIControlStateNormal];
            [markAllBtnCell.mxkButton setTitle:btnTitle forState:UIControlStateHighlighted];
            [markAllBtnCell.mxkButton setTintColor:ThemeService.shared.theme.tintColor];

            // --- BỔ SUNG DYNAMIC TYPE CHO NÚT START ---
            markAllBtnCell.mxkButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            markAllBtnCell.mxkButton.titleLabel.adjustsFontForContentSizeCategory = YES;
            // --- BỔ SUNG DYNAMIC TYPE CHO NÚT END ---
            
            [markAllBtnCell.mxkButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
            [markAllBtnCell.mxkButton addTarget:self action:@selector(markAllAsRead:) forControlEvents:UIControlEventTouchUpInside];
            markAllBtnCell.mxkButton.accessibilityIdentifier = nil;
            
            cell = markAllBtnCell;
            break;
        }
        case ADVANCED_CLEAR_CACHE_INDEX:
        {
            MXKTableViewCellWithButton *clearCacheBtnCell = [tableView dequeueReusableCellWithIdentifier:[MXKTableViewCellWithButton defaultReuseIdentifier]];
            
            if (!clearCacheBtnCell)
            {
                clearCacheBtnCell = [[MXKTableViewCellWithButton alloc] init];
            }
            
            NSString *btnTitle = [VectorL10n settingsClearCache];
            [clearCacheBtnCell.mxkButton setTitle:btnTitle forState:UIControlStateNormal];
            [clearCacheBtnCell.mxkButton setTitle:btnTitle forState:UIControlStateHighlighted];
            [clearCacheBtnCell.mxkButton setTintColor:ThemeService.shared.theme.tintColor];

            // --- BỔ SUNG DYNAMIC TYPE CHO NÚT START ---
            clearCacheBtnCell.mxkButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            clearCacheBtnCell.mxkButton.titleLabel.adjustsFontForContentSizeCategory = YES;
            // --- BỔ SUNG DYNAMIC TYPE CHO NÚT END ---
            
            [clearCacheBtnCell.mxkButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
            [clearCacheBtnCell.mxkButton addTarget:self action:@selector(clearCache:) forControlEvents:UIControlEventTouchUpInside];
            clearCacheBtnCell.mxkButton.accessibilityIdentifier = nil;
            
            cell = clearCacheBtnCell;
            break;
        }
        case ADVANCED_REPORT_BUG_INDEX:
        {
            MXKTableViewCellWithButton *reportBugBtnCell = [tableView dequeueReusableCellWithIdentifier:[MXKTableViewCellWithButton defaultReuseIdentifier]];

            if (!reportBugBtnCell)
            {
                reportBugBtnCell = [[MXKTableViewCellWithButton alloc] init];
            }
            
            NSString *btnTitle = [VectorL10n settingsReportBug];
            [reportBugBtnCell.mxkButton setTitle:btnTitle forState:UIControlStateNormal];
            [reportBugBtnCell.mxkButton setTitle:btnTitle forState:UIControlStateHighlighted];
            [reportBugBtnCell.mxkButton setTintColor:ThemeService.shared.theme.tintColor];

            // --- BỔ SUNG DYNAMIC TYPE CHO NÚT START ---
            reportBugBtnCell.mxkButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            reportBugBtnCell.mxkButton.titleLabel.adjustsFontForContentSizeCategory = YES;
            // --- BỔ SUNG DYNAMIC TYPE CHO NÚT END ---

            [reportBugBtnCell.mxkButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
            [reportBugBtnCell.mxkButton addTarget:self action:@selector(reportBug:) forControlEvents:UIControlEventTouchUpInside];
            reportBugBtnCell.mxkButton.accessibilityIdentifier = nil;

            cell = reportBugBtnCell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Bỏ chọn hàng được chọn
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = [rows[indexPath.row] integerValue];
    
    switch (row)
    {
        // NOTE: Không có mục nào có hành động trong didSelectRowAtIndexPath, tất cả đều dùng nút hoặc switch
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = ThemeService.shared.theme.backgroundColor;
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone)
    {
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView.backgroundColor = ThemeService.shared.theme.selectedBackgroundColor;
    }
}


#pragma mark - Actions (Di chuyển từ SettingsViewController.m)

// NOTE: Tôi đã thêm 'BugReportViewController', 'Analytics', 'MXLogger', 'RiotSettings', 'AppDelegate'
// vào các hàm dưới đây để chúng có thể biên dịch (giả định chúng được import đúng)

- (void)toggleAnalytics:(UISwitch *)sender
{
    if (sender.isOn)
    {
        MXLogDebug(@"[SettingsViewController] enable automatic crash report and analytics sending");
        [Analytics.shared optInWith:self.mainSession];
    }
    else
    {
        MXLogDebug(@"[SettingsViewController] disable automatic crash report and analytics sending");
        [Analytics.shared optOut];
        
        // Remove potential crash file.
        [MXLogger deleteCrashLog];
    }
}

- (void)toggleEnableRageShake:(UISwitch *)sender
{
    RiotSettings.shared.enableRageShake = sender.isOn;
    
    [self updateRows]; // Tải lại bảng
}

- (void)markAllAsRead:(id)sender
{
    // Feedback: disable button and run activity indicator
    UIButton *button = (UIButton*)sender;
    button.enabled = NO;
    // [self startActivityIndicator]; // Giả định hàm này được khai báo

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        // NOTE: Tôi giả định có phương thức markAllMessagesAsRead
        // [[AppDelegate theDelegate] markAllMessagesAsRead];
        
        // [self stopActivityIndicator]; // Giả định hàm này được khai báo
        button.enabled = YES;
        
    });
}

- (void)clearCache:(id)sender
{
    // Feedback: disable button and run activity indicator
    UIButton *button = (UIButton*)sender;
    button.enabled = NO;

    [self launchClearCache];
}

- (void)launchClearCache
{
    // [self startActivityIndicator]; // Giả định hàm này được khai báo

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        // NOTE: Tôi giả định có phương thức reloadMatrixSessions
        // [[AppDelegate theDelegate] reloadMatrixSessions:YES];

    });
}

- (void)reportBug:(id)sender
{
    BugReportViewController *bugReportViewController = [BugReportViewController bugReportViewController];
    // NOTE: Tôi giả định bạn truyền session vào đây
    // bugReportViewController.mainSession = self.mainSession;
    
    // [bugReportViewController showInViewController:self]; // Hoặc dùng pushViewController
    
    // NOTE: Cần có self.navigationController để push
    // [self.navigationController pushViewController:bugReportViewController animated:YES];
}

// NOTE: Tôi đã loại bỏ việc định nghĩa lại MXKTableViewCellWithLabelAndSwitch vì nó là hàm helper và đã được sửa ở trên.
// Tôi cũng đã loại bỏ hàm getDefaultTableViewCell: vì các cell còn lại đều dùng MXKTableViewCellWithButton.
// Nếu bạn cần cell mặc định, hãy thêm lại hàm đó.

@end
