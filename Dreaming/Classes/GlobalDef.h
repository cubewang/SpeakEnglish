/*
 *  GlobalDef.h
 *  Dreaming
 *
 *  Created by Cube on 11-7-12.
 *  Copyright 2011 Dreaming Team. All rights reserved.
 *
 */

//当前设备的屏幕宽度
#define SCREEN_WIDTH   [[UIScreen mainScreen] bounds].size.width

//当前设备的屏幕高度
#define SCREEN_HEIGHT   [[UIScreen mainScreen] bounds].size.height

//当前设备的屏幕高度
#define IS_IPHONE_5   ([[UIScreen mainScreen] bounds].size.height == 568)

//iPad文章列表的宽度
#define ARTICLE_AREA_WIDTH_IPAD   568


//当Left View打开时Deck View显示区域的大小
#define LEFT_LEDGE_SIZE     120

//当Right View打开时Deck View显示区域的大小
#define RIGHT_LEDGE_SIZE    50


//广告条高度
#define AD_BAR_HEIGHT       50


//Dreaming默认背景颜色
#define CELL_BACKGROUND  [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0]


//用户选中反馈颜色
#define SELECTED_BACKGROUND [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]


//官方回复颜色
#define OFFICIAL_COLOR [UIColor colorWithRed:255.0/255.0 green:155.0/255.0 blue:57.0/255.0 alpha:1.0]

#define NAV_BAR_ITEM_COLOR [UIColor grayColor]

//菜单栏和社交栏字体颜色
#define MENU_TEXT_COLOR [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0]

//菜单栏和社交栏section字体颜色
#define SECTION_TEXT_COLOR [UIColor whiteColor]


//设置页面cell字体颜色
#define CELLTEXT_COLOR [UIColor colorWithRed:53.0/255.0 green:53.0/255.0 blue:53.0/255.0 alpha:1.0]

//STYLE
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#define MANU_font ([UIFont systemFontOfSize:18])
#define ZBSTYLE_font ([UIFont systemFontOfSize:14])
#define ZBSTYLE_font_smaller ([UIFont systemFontOfSize:14])
#define ZBSTYLE_tableFont ([UIFont boldSystemFontOfSize:17])
#define ZBSTYLE_highlightedTextColor ([UIColor blackColor])
#define ZBSTYLE_tableSubTextColor CELLTEXT_COLOR
#define ZBSTYLE_textColor CELLTEXT_COLOR
#define ZBSTYLE_secondaryColor ([UIColor grayColor])

#define English_font_des ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ? \
[UIFont fontWithName:@"Georgia" size:15] : [UIFont fontWithName:@"Georgia" size:17])

#define English_font_title ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ? \
[UIFont fontWithName:@"Georgia" size:17] : [UIFont fontWithName:@"Georgia" size:19])

#define English_font_small ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ? \
[UIFont systemFontOfSize:14] : [UIFont systemFontOfSize:15])

#define English_font_smallest ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ? \
[UIFont systemFontOfSize:11] : [UIFont systemFontOfSize:11])

#define kTableCellSmallMargin   6.0f
#define kTableCellSpacing       8.0f
#define kTableCellMargin        10.0f


//字符串
#define SAFE_STRING(str) ([(str) length] ? (str) : @"")
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

#define ENABLE_SDWEBIMAGE_DECODER


#define DOCUMENT_FOLDER	   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define AUDIO_CACHE_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/AudioCache"]

