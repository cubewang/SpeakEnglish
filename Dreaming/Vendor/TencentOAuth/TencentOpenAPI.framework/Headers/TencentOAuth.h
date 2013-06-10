///
/// \file TencentOAuth.h
/// \brief QQ互联开放平台授权登录及相关开放接口实现类
///
/// Created by Tencent on 12-12-21.
/// Copyright (c) 2012年 Tencent. All rights reserved.
///

#import "sdkdef.h"
#import <UIKit/UIKit.h>

@protocol TencentSessionDelegate;


/**
 * \brief TencentOpenAPI授权登录及相关开放接口调用
 *
 * TencentOAuth实现授权登录逻辑以及相关开放接口的请求调用
 */
@interface TencentOAuth : NSObject{
	NSString* _accessToken;
	NSDate* _expirationDate;
	id<TencentSessionDelegate> _sessionDelegate;
	NSString* _localAppId;
	NSString* _openId;
	NSString* _redirectURI;
	NSArray* _permissions;	

}

/** Access Token凭证，用于后续访问各开放接口 */
@property(nonatomic, copy) NSString* accessToken;

/** Access Token的失效期 */
@property(nonatomic, copy) NSDate* expirationDate;

/** 已实现的开放接口的回调委托对象 */
@property(nonatomic, assign) id<TencentSessionDelegate> sessionDelegate;

/** 第三方应用在开发过程中设置的URLSchema，用于浏览器登录后后跳到第三方应用 */
@property(nonatomic, copy) NSString* localAppId;

/** 用户授权登录后对该用户的唯一标识 */
@property(nonatomic, copy) NSString* openId;

/** 用户登录成功过后的跳转页面地址 */
@property(nonatomic, copy) NSString* redirectURI;

/** 第三方应用在互联开放平台申请的appID */
@property(nonatomic, retain) NSString* appId;

/**
 * 初始化TencentOAuth对象
 * \param appId 第三方应用在互联开放平台申请的唯一标识
 * \param delegate 第三方应用用于接收请求返回结果的委托对象
 * \return 初始化后的授权登录对象
 */
- (id)initWithAppId:(NSString *)appId
        andDelegate:(id<TencentSessionDelegate>)delegate;

/**
 * 登录授权
 * \param permissions 授权信息列表
 * \param bInSafari 是否使用safari进行登录.<b>IOS SDK 1.3版本开始此参数废除</b>
 */
- (BOOL)authorize:(NSArray *)permissions
		 inSafari:(BOOL)bInSafari;

/**
 * 登录授权
 * \param permissions 授权信息列表
 * \param localAppId 应用APPID
 * \param bInSafari 是否使用safari进行登录.<b>IOS SDK 1.3版本开始此参数废除</b>
 */
- (BOOL)authorize:(NSArray *)permissions
       localAppId:(NSString *)localAppId
		 inSafari:(BOOL)bInSafari;

/**
 * 处理应用拉起协议
 * \param url 处理被其他应用呼起时的逻辑
 * \return 处理结果，YES表示成功，NO表示失败
 */
- (BOOL)handleOpenURL:(NSURL *)url;

/**
 * (静态方法)处理应用拉起协议
 * \param url 处理被其他应用呼起时的逻辑
 * \return 处理结果，YES表示成功，NO表示失败
 */
+ (BOOL)HandleOpenURL:(NSURL *)url;

/**
 * 退出登录
 * \param delegate 第三方应用用于接收请求返回结果的委托对象
 */
- (void)logout:(id<TencentSessionDelegate>)delegate;

/**
 * 判断登录态是否有效
 * \return 处理结果，YES表示有效，NO表示无效，请用户重新登录授权
 */
- (BOOL)isSessionValid;

////////////////////////////////////////////////////////////////////////////////
// APIs, can be called after accesstoken and openid have received 

/**
 * 获取用户个人信息
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)getUserInfo;

/**
 * 获取用户QZone相册列表
 * \attention 需\ref apply_perm
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)getListAlbum;

/**
 * 获取用户QZone相片列表
 * \attention 需\ref apply_perm
 * \param params 参数字典,字典的关键字参见TencentOAuthObject.h中的\ref TCListPhotoDic
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)getListPhotoWithParams:(NSMutableDictionary *)params;


/**
 * 分享到QZone
 * \param params 参数字典,字典的关键字参见TencentOAuthObject.h中的\ref TCAddShareDic 
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)addShareWithParams:(NSMutableDictionary *)params;


/**
 * 上传照片到QZone指定相册
 * \attention 需\ref apply_perm
 * \param params 参数字典,字典的关键字参见TencentOAuthObject.h中的\ref TCUploadPicDic
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)uploadPicWithParams:(NSMutableDictionary *)params;

/**
 * 在QZone相册中创建一个新的相册
 * \attention 需\ref apply_perm
 * \param params 参数字典,字典的关键字参见TencentOAuthObject.h中的\ref TCAddAlbumDic
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)addAlbumWithParams:(NSMutableDictionary *)params;

/**
 * 检查是否是QZone某个用户的粉丝
 * \param params 参数字典,字典的关键字参见TencentOAuthObject.h中的\ref TCCheckPageFansDic
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)checkPageFansWithParams:(NSMutableDictionary *)params;

/**
 * 在QZone中发表一篇日志
 * \attention 需\ref apply_perm
 * \param params 参数字典,字典的关键字参见TencentOAuthObject.h中的\ref TCAddOneBlogDic
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)addOneBlogWithParams:(NSMutableDictionary *)params;

/**
 * 在QZone中发表一条说说
 * \attention 需\ref apply_perm
 * \param params 参数字典,字典的关键字参见TencentOAuthObject.h中的\ref TCAddTopicDic
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)addTopicWithParams:(NSMutableDictionary *)params;

/**
 * 设置QQ头像
 * \attention 需\ref apply_perm
 * \param params 参数字典,字典的关键字参见TencentOAuthObject.h中的\ref TCSetUserHeadpic
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)setUserHeadpic:(NSMutableDictionary *)params;

/**
 * 获取QQ会员信息(仅包括是否为QQ会员,是否为年费QQ会员)
 * \attention 需\ref apply_perm
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)getVipInfo;

/**
 * 获取QQ会员详细信息
 * \attention 需\ref apply_perm
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)getVipRichInfo;

/**
 * 获取微博好友名称输入提示,即通过字符串查找匹配的微博好友
 * \param params 参数字典,字典的关键字参见TencentOAuthObject.h中的\ref TCMatchNickTipsDic
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)matchNickTips:(NSMutableDictionary *)params;

/**
 * 获取最近的微博好友
 * \param params 参数字典,字典的关键字参见TencentOAuthObject.h中的\ref TCGetIntimateFriendsDic
 * \return 处理结果，YES表示API调用成功，NO表示API调用失败，登录态失败，重新登录
 */
- (BOOL)getIntimateFriends:(NSMutableDictionary *)params;

@end

////////////////////////////////////////////////////////////////////////////////

/**
 * \brief TencentSessionDelegate ios OPen SDK 1.3 API回调协议
 *
 * 第三方应用需要实现每条需要调用的API的回调协议
 */

@protocol TencentSessionDelegate <NSObject>

@optional

/**
 * 登录成功后的回调 
 */
- (void)tencentDidLogin;


/**
 * 登录失败后的回调
 * param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled;

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork;


/**
 * 退出登录的回调
 */
- (void)tencentDidLogout;

/**
 * 获取用户个人信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getUserInfoResponse.exp success
 *          错误返回示例: \snippet example/getUserInfoResponse.exp fail
 */
- (void)getUserInfoResponse:(APIResponse*) response;

/**
 * 获取用户QZone相册列表回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getListAlbumResponse.exp success
 *          错误返回示例: \snippet example/getListAlbumResponse.exp fail
 */
- (void)getListAlbumResponse:(APIResponse*) response;

/**
 * 获取用户QZone相片列表
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getListPhotoResponse.exp success
 *          错误返回示例: \snippet example/getListPhotoResponse.exp fail
 */
- (void)getListPhotoResponse:(APIResponse*) response;

/**
 * 检查是否是QZone某个用户的粉丝回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/checkPageFansResponse.exp success
 *          错误返回示例: \snippet example/checkPageFansResponse.exp fail
 */
- (void)checkPageFansResponse:(APIResponse*) response;
 
/**
 * 分享到QZone回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/addShareResponse.exp success
 *          错误返回示例: \snippet example/addShareResponse.exp fail
 */
- (void)addShareResponse:(APIResponse*) response;

/**
 * 在QZone相册中创建一个新的相册回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/addAlbumResponse.exp success
 *          错误返回示例: \snippet example/addAlbumResponse.exp fail
 */
- (void)addAlbumResponse:(APIResponse*) response;

/**
 * 上传照片到QZone指定相册回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/uploadPicResponse.exp success
 *          错误返回示例: \snippet example/uploadPicResponse.exp fail
 */
- (void)uploadPicResponse:(APIResponse*) response;

/**
 * 在QZone中发表一篇日志回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/addOneBlogResponse.exp success
 *          错误返回示例: \snippet example/addOneBlogResponse.exp fail
 */
- (void)addOneBlogResponse:(APIResponse*) response;

/**
 * 在QZone中发表一条说说回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/addTopicResponse.exp success
 *          错误返回示例: \snippet example/addTopicResponse.exp fail
 */
- (void)addTopicResponse:(APIResponse*) response;

/**
 * 设置QQ头像回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/setUserHeadpicResponse.exp success
 *          错误返回示例: \snippet example/setUserHeadpicResponse.exp fail
 */
- (void)setUserHeadpicResponse:(APIResponse*) response;

/**
 * 获取QQ会员信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getVipInfoResponse.exp success
 *          错误返回示例: \snippet example/getVipInfoResponse.exp fail
 */
- (void)getVipInfoResponse:(APIResponse*) response;

/**
 * 获取QQ会员详细信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 */
- (void)getVipRichInfoResponse:(APIResponse*) response;

/**
 * 获取微博好友名称输入提示回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/matchNickTipsResponse.exp success
 *          错误返回示例: \snippet example/matchNickTipsResponse.exp fail
 */
- (void)matchNickTipsResponse:(APIResponse*) response;

/**
 * 获取最近的微博好友回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getIntimateFriendsResponse.exp success
 *          错误返回示例: \snippet example/getIntimateFriendsResponse.exp fail
 */
- (void)getIntimateFriendsResponse:(APIResponse*) response;


@end