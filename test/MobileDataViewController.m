//
//  MobileDataViewController.m
//  test
//
//  Created by tom on 2018/6/8.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "MobileDataViewController.h"

#import <CommonCrypto/CommonDigest.h>

#include <mach/mach.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import "sys/utsname.h"
//MARK: 获取DNS Xcode中添加libresolv.dylib
#import <resolv.h>
#import <CoreTelephony/CoreTelephonyDefines.h>
#include <dlfcn.h>
#import <UIKit/UIKit.h>
#include <stdio.h>
#include <stdlib.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import "FBDeviceInfoManager.h"
#import "MPBluetoothKit.h"
#import "APSSIDInfoObserver.h"

#import "AFNetworking.h"
#import "Reachability.h"
#import "AESCipher.h"
#include "getgateway.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#define KEY @"pil7wyE1dVD58239"

@interface MobileDataViewController ()

@end

@implementation MobileDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self root];
}

static NSString *sp_encryptHelper(id input)
{
    NSString *SALT = KEY;
    NSMutableString *encryptedStuff = nil;
    if ([input isKindOfClass:[NSString class]]) {
        NSData *data = [[input stringByAppendingString:SALT]  dataUsingEncoding:NSUTF8StringEncoding];
        uint8_t digest[CC_SHA256_DIGEST_LENGTH];
        CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
        encryptedStuff = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [encryptedStuff appendFormat:@"%02x", digest[i]];
        }
    }
    return encryptedStuff;
}

NSString *getEncryptKey() {
    return KEY;
}

NSString* encryptByAES(NSString *string) {
    return encryptByAESWithKey(string, getEncryptKey());
}

NSString* encryptByAESWithKey(NSString *string, NSString *key) {
    if (nil == string) {
        return nil;
    }
    if (key.length != 16) {
        return nil;
    }

    NSString *str = aesEncryptString(string, key);

    NSData *encodeData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [encodeData base64EncodedStringWithOptions:0];

    return base64String;
}

+ (NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];

    NSString *jsonString = @"";

    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    }else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符

    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    return jsonString;
}

- (IBAction)sendButtonClicked:(UIButton *)sender {
    NSString *urlStr = @"https://antifraud.niwodai.com/generate/device";
    NSURL *url = [NSURL URLWithString:urlStr];

    NSDictionary *param = @{
                            @"tags":@"",
                            @"imsi":@"460027217499050",
                            @"mbPhone":@"+8618721714600",
                            @"imei":@"865579039308587",
                            @"voiceMail":@"",
                            @"simSerial":@"898600E20916F7000961",
                            @"countryIso":@"cn",@"carrier":@"中国移动",
                            @"mcc":@"460",
                            @"mnc":@"02",
                            @"simOperator":@"CMCC",
                            @"phoneType":@"PHONE_TYPE_GSM",
                            @"radioType":@"NETWORK_TYPE_LTE",
                            @"cellLocation":@"{\"cid\":26278965,\"lac\":6155,\"sid\":0}",
                            @"deviceSVN":@"8655790393085808",
                            @"wifiIp":@"10.17.3.139",
                            @"wifiMac":@"c4:86:e9:29:b8:e7",
                            @"ssid":@"<unknown ssid>",
                            @"bssid":@"00:00:00:00:00:00",
                            @"gateway":@"0.0.0.0",
                            @"wifiNetmask":@"0.0.0.0",
                            @"proxyInfo":@"{\"proxyPort\":-1}",
                            @"dnsAddress":@"{\"localdns\":\"211.136.112.50\",\"wifi-dns1\":\"0.0.0.0\",\"wifi-dns2\":\"0.0.0.0\"}",
                            @"vpnIp":@"",
                            @"vpnNetmask":@"",
                            @"cellIp":@"",
                            @"networkType":@"4G",
                            @"root":@(false),
                            @"timeZone":@"",
                            @"language":@"Simplified Chinese",
                            @"screenRes":@"1440*2416",
                            @"fontHash":@"",
                            @"blueMac":@"02:00:00:00:00:00",
                            @"androidId":@"cc6835d2acc55636",
                            @"cpuFrequency":@"1844000",
                            @"cpuHardware":@"",
                            @"cpuType":@(8),
                            @"totalMemory":@"6GB",
                            @"availableMemory":@"1.49 GB",
                            @"totalStorage":@"53.77 GB",
                            @"availableStorage":@"14.71 GB",
                            @"basebandVersion":@"21C30B322S000C000,21C30B322S000C000",
                            @"kernelVersion":@"4.1.18-gebc47dc",
                            @"allowMockLocation":@(false),
                            @"manufacturer":@"HUAWEI",
                            @"model":@"DUK-AL20",
                            @"has_telephone":@(true),
                            @"bluetooth_version":@"",
                            @"serialno":@"FFK0217603003161",
                            @"sdkversion":@(24),
                            @"hardware":@"",
                            @"score":@"0",
                            @"fpid":@"24700f9f1986800ab4fcc880530dd0ed",
                            @"src":@"android"
                            };

    NSString *str = [MobileDataViewController convertToJSONData:param];

    str = encryptByAES(str);

    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];


    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
        NSLog(@"responseObject is: %@", responseObject);
    }];
    [task resume];
}

- (void)HTTPPost:(NSString *)url parameters:(NSDictionary *)parameters formdata:(void (^)(id<AFMultipartFormData>))formdata progress:(void (^)(NSProgress *))progress success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    // 开启网络指示器
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 20.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    // 请求参数类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/xml",@"text/html", nil ];
    // post请求
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        if (formdata)
        {
            formdata(formData);
        }

    } progress:^(NSProgress * _Nonnull uploadProgress) {

        if (progress)
        {
            progress(uploadProgress);
        }

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 成功，关闭网络指示器
        if (success)
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;

            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 失败，关闭网络指示器
        if (failure)
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;

            failure(error);
        }
    }];
}

/**
 ROM标签
 */
- (void)tags {
    //NULL
}
/**
 IMSI
 */
- (void)imsi {
    //NULL
}

/**
 电话号码
 */
- (void)mbPhone {
    NSString *number = [[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"];
    NSLog(@"number is: %@", number);
}

/**
 IMEI
 */
- (void)imei {
    //NULL
}

/**
 语音信箱号码
 */
- (void)voiceMail {
    //NULL
}

/**
 SIM卡序列号
 */
- (void)simSerial {
    //NULL
}

/**
 国家代码
 */
- (void)countryIso {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    NSString *mobileCountryCode = carrier.isoCountryCode;//mobileCountryCode;
}

/**
 移动运营商
 */
- (void)carrier {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    NSString *carrierName = carrier.carrierName;
}

/**
 MNC
 */
- (void)mnc {
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *mnc = [carrier mobileNetworkCode];
}

/**
 MCC
 */
- (void)mcc {
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *mcc = [carrier mobileCountryCode];
}

/**
 SIM卡运营商
 */
- (void)simOperator {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSString *carrier_name = nil;    //网络运营商的名字
    NSString *code = [carrier mobileNetworkCode];
    if ([code isEqualToString:@"00"] || [code isEqualToString:@"02"] || [code isEqualToString:@"07"]) {
        //移动
        carrier_name = @"CMCC";
    }
    if ([code isEqualToString:@"03"] || [code isEqualToString:@"05"]) {
        // ret = @"电信";
        carrier_name =  @"CTCC";
    }
    if ([code isEqualToString:@"01"] || [code isEqualToString:@"06"]) {
        // ret = @"联通";
        carrier_name =  @"CUCC";
    }
    if (code == nil) {
        carrier_name = @"";
    }
}

/**
 手机制式
 */
- (NSString*)phoneType {
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

        if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
        if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
        if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
        if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
        if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
        if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
        if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
        if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
        if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
        if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
        if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
        if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
        if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
        if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
        if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";

        // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
        if ([deviceString isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
        if ([deviceString isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
        if ([deviceString isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
        if ([deviceString isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";

        if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
        if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
        if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
        if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
        if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
        if ([deviceString isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";

        if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
        if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
        if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
        if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
        if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
        if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
        if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
        if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
        if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
        if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
        if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
        if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
        if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
        if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
        if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
        if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
        if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
        if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
        if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
        if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
        if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
        if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
        if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (Cellular)";
        if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
        if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (Cellular)";
        if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
        if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
        if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7-inch (WiFi)";
        if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7-inch (Cellular)";
        if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9-inch (WiFi)";
        if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9-inch (Cellular)";

        if ([deviceString isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
        if ([deviceString isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
        if ([deviceString isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
        if ([deviceString isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";

        if ([deviceString isEqualToString:@"i386"])         return @"i386 Simulator";
        if ([deviceString isEqualToString:@"x86_64"])       return @"x86_64 Simulator";

        return deviceString;
}

/**
 网络制式
 */
- (NSString*)radioType {
    NSString *netconnType = @"";
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];

    switch ([reach currentReachabilityStatus]) {
        case NotReachable:// 没有网络
        {
            netconnType = @"0";
        }
            break;

        case ReachableViaWiFi:// Wifi
        {
            netconnType = @"Wifi";
        }
            break;

        case ReachableViaWWAN:// 手机自带网络
        {
            // 获取手机网络类型
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];

            NSString *currentStatus = info.currentRadioAccessTechnology;

            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {

                netconnType = @"GPRS";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {

                netconnType = @"2.75G EDGE";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){

                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){

                netconnType = @"3.5G HSDPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){

                netconnType = @"3.5G HSUPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){

                netconnType = @"2G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){

                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){

                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){

                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){

                netconnType = @"HRPD";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){

                netconnType = @"4G";
            }
        }
            break;

        default:
            break;
    }

    return netconnType;
}

/**
 基站信息
 */
- (void)cellLocation {
    //NULL
}

/**
 设备软件版本号
 */
- (void)deviceSVN {
    NSString *strSysVersion = [[UIDevice currentDevice] systemVersion];
}

/**
 无线IP地址
 */
- (void)wifiIp {
    NSDictionary *addresses = ({
        NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
        // retrieve the current interfaces - returns 0 on success
        struct ifaddrs *interfaces;
        if(!getifaddrs(&interfaces)) {
            // Loop through linked list of interfaces
            struct ifaddrs *interface;
            for(interface=interfaces; interface; interface=interface->ifa_next) {
                if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                    continue; // deeply nested code harder to read
                }
                const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
                char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
                if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                    NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                    NSString *type;
                    if(addr->sin_family == AF_INET) {
                        if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                            type = IP_ADDR_IPv4;
                        }
                    } else {
                        const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                        if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                            type = IP_ADDR_IPv6;
                        }
                    }
                    if(type) {
                        NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                        addresses[key] = [NSString stringWithUTF8String:addrBuf];
                    }
                }
            }
            // Free memory
            freeifaddrs(interfaces);
        }
        [addresses count] ? addresses : nil;
    });
    NSString *key = IOS_WIFI @"/" IP_ADDR_IPv4;
    NSString *address = addresses[key];
    //筛选出IP地址格式
//    return [self isValidatIP:address] ? address : @"0.0.0.0";
    ^(NSString *ipAddress){
        if (ipAddress.length == 0) {
            return false;

        }
        NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
        "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
        "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
        "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";

        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];

        if (regex != nil) {
            NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];

            if (firstMatch) {
                NSRange resultRange = [firstMatch rangeAtIndex:0];
                NSString *result=[ipAddress substringWithRange:resultRange];
                //输出结果
                NSLog(@"%@",result);
                return true;
            }
        }
        return false;
    }(address) ? address : @"0.0.0.0";
    address = address;
}

/**
 无线Mac地址
 */
- (void)wifiMac {
    NSString *mac = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getMacAddress];
}

/**
 无线网络名称
 */
- (void)ssid {
    NSString __block *ssid;
    APSSIDInfoObserver *observer = [APSSIDInfoObserver new];
    [observer setSSIDChangedBlock:^(APSSIDModel *model){
        if (model) {
             ssid = model.ssid;
        } else {
            ssid = @"Cannot find wifi network";
        }
    }];
    [observer startObserving];
}

/**
 无线BSSID
 */
- (void)bssid {
    NSString __block *bssid;
    APSSIDInfoObserver *observer = [APSSIDInfoObserver new];
    [observer setSSIDChangedBlock:^(APSSIDModel *model){
        if (model) {
            bssid = model.bssid;
        } else {
            bssid = @"Cannot find wifi network";
        }
    }];
    [observer startObserving];
}

/**
 网关地址
 */
- (NSString*)gateway {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;

    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    NSLog(@"本机地址：%@",address);

                    //routerIP----192.168.1.255 广播地址
                    NSLog(@"广播地址：%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);

                    //--192.168.1.106 本机地址
                    NSLog(@"本机地址：%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]);

                    //--255.255.255.0 子网掩码地址
                    NSLog(@"子网掩码地址：%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);

                    //--en0 接口
                    //  en0       Ethernet II    protocal interface
                    //  et0       802.3             protocal interface
                    //  ent0      Hardware device interface
                    NSLog(@"接口名：%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }

    freeifaddrs(interfaces);
    in_addr_t i = inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
    in_addr_t* x = &i;
    unsigned char *s = getdefaultgateway(x);
    NSString *ip=[NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];
    free(s);
    return ip;
}

/**
 WIFI子网掩码
 */
- (NSString*)wifiNetmask {
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
//                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                NSLog(@"子网掩码:%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
                //                NSLog(@"本地IP:%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]);
                //                NSLog(@"广播地址:%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);

            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

/**
 代理配置
 */
- (NSString*)proxyInfo {
    CFDictionaryRef dicRef = CFNetworkCopySystemProxySettings();
    const CFStringRef proxyCFstr = (const CFStringRef)CFDictionaryGetValue(dicRef,
                                                                           (const void*)kCFNetworkProxiesHTTPProxy);
    NSString* proxy = (__bridge NSString *)proxyCFstr;
    return  proxy;
}

/**
 DNS地址
 */
- (NSString*)dnsAddress {
    res_state res = malloc(sizeof(struct __res_state));

    int result = res_ninit(res);

    NSMutableArray *dnsArray = @[].mutableCopy;

    if ( result == 0 )
    {
        for ( int i = 0; i < res->nscount; i++ )
        {
            NSString *s = [NSString stringWithUTF8String :  inet_ntoa(res->nsaddr_list[i].sin_addr)];

            [dnsArray addObject:s];
        }
    }
    else{
        NSLog(@"%@",@" res_init result != 0");
    }

    res_nclose(res);

    return dnsArray.firstObject;
}

/**
 VPNIP地址
 */
- (NSString*)vpnIp {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;

    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }

            temp_addr = temp_addr->ifa_next;
        }
    }

    // Free memory
    freeifaddrs(interfaces);

    return address;
}

/**
 VPN子网掩码
 */
- (void)vpnNetmask {
    //NULL
}

/**
 CELLIP地址
 */
- (void)cellIp {
    NSArray *searchArray = false ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;

    NSDictionary *addresses = ({
        NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];

        // retrieve the current interfaces - returns 0 on success
        struct ifaddrs *interfaces;
        if(!getifaddrs(&interfaces)) {
            // Loop through linked list of interfaces
            struct ifaddrs *interface;
            for(interface=interfaces; interface; interface=interface->ifa_next) {
                if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                    continue; // deeply nested code harder to read
                }
                const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
                char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
                if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                    NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                    NSString *type;
                    if(addr->sin_family == AF_INET) {
                        if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                            type = IP_ADDR_IPv4;
                        }
                    } else {
                        const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                        if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                            type = IP_ADDR_IPv6;
                        }
                    }
                    if(type) {
                        NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                        addresses[key] = [NSString stringWithUTF8String:addrBuf];
                    }
                }
            }
            // Free memory
            freeifaddrs(interfaces);
        }
        [addresses count] ? addresses : nil;
    });

    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         //         if([self isValidatIP:address]) *stop = YES;
         if( ^(NSString *ipAddress){
             if (ipAddress.length == 0) {
                 return false;

             }
             NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
             "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
             "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
             "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";

             NSError *error;
             NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];

             if (regex != nil) {
                 NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];

                 if (firstMatch) {
                     NSRange resultRange = [firstMatch rangeAtIndex:0];
                     NSString *result=[ipAddress substringWithRange:resultRange];
                     //输出结果
                     NSLog(@"%@",result);
                     return true;
                 }
             }
             return false;
         }(address) ) *stop = true;
     }];
    address = address ? address : @"0.0.0.0";
    address=address;
}

/**
 网络类型
 */
- (NSString*)networkType {
    NSString *netconnType = @"";
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];

    switch ([reach currentReachabilityStatus]) {
        case NotReachable:// 没有网络
        {
            netconnType = @"0";
        }
            break;

        case ReachableViaWiFi:// Wifi
        {
            netconnType = @"Wifi";
        }
            break;

        case ReachableViaWWAN:// 手机自带网络
        {
            // 获取手机网络类型
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];

            NSString *currentStatus = info.currentRadioAccessTechnology;

            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {

                netconnType = @"GPRS";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {

                netconnType = @"2.75G EDGE";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){

                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){

                netconnType = @"3.5G HSDPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){

                netconnType = @"3.5G HSUPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){

                netconnType = @"2G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){

                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){

                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){

                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){

                netconnType = @"HRPD";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){

                netconnType = @"4G";
            }
        }
            break;

        default:
            break;
    }

    return netconnType;
}

/**
 是否ROOT
 */
- (NSString*)root {
    const char* jailbreak_apps[] =
    {
        "/Applications/Cydia.app",
        "/Applications/blackra1n.app",
        "/Applications/blacksn0w.app",
        "/Applications/greenpois0n.app",
        "/Applications/limera1n.app",
        "/Applications/redsn0w.app",
        NULL,
    };

    NSString *res = nil;

    for (int i = 0; jailbreak_apps[i] != NULL; ++i)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_apps[i]]])
        {
            res = @"1";
        }
    }
    res = res ?: @"0";
    return res;
}

/**
 时区
 */
- (void)timeZone {
    NSInteger offset = [NSTimeZone localTimeZone].secondsFromGMT;
    offset = offset/3600;
    NSString *tzStr = [NSString stringWithFormat:@"%ld", (long)offset];
}
/**
 语言
 */
- (void)language {
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *languageName = [appLanguages objectAtIndex:0];
    languageName = languageName;
}
/**
 屏幕分辨率
 */
- (void)screenRes {
    CGSize  size = [[[UIScreen mainScreen] preferredMode] size];
}

/**
 字体列表HASH
 */
- (void)fontHash {
    NSArray *fonts = [UIFont familyNames];
    NSUInteger hash = fonts.hash;
    hash=hash;
}

/**
 蓝牙MAC地址
 */
- (void)blueMac {
    //NULL
}

/**
 AndroidID
 */
- (void)androidId {
    //NULL
}

/**
 CPU主频
 */
- (void)cpuFrequency {
    NSUInteger frequency = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getCPUFrequency];
}

/**
 CPU硬件
 */
- (void)cpuHardware {
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount;

    infoCount = HOST_BASIC_INFO_COUNT;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);

    NSString *cpu;
    switch (hostInfo.cpu_type) {
        case CPU_TYPE_ARM:
            cpu = @"CPU_TYPE_ARM";
            break;
        case CPU_TYPE_ARM64:
            cpu = @"CPU_TYPE_ARM64";
            break;
        case CPU_TYPE_X86:
            cpu = @"CPU_TYPE_X86";
            break;
        case CPU_TYPE_X86_64:
            cpu = @"CPU_TYPE_X86_64";
            break;
        default:
            cpu = @"";
            break;
    }
}

/**
 CPU型号
 */
- (void)cpuType {
    [[FBDeviceInfoManager sharedDevieInfoManager] fb_getCPUCount];
}

/**
 内存大小
 */
- (void)totalMemory {
    NSUInteger totalMemory = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getTotalMemory];
}

/**
 可用内存
 */
- (void)availableMemory {
    NSUInteger availableMemory = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getActiveMemory];
}
/**
 存储空间大小
 */
- (void)totalStorage {
    NSUInteger totalStorage = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getTotalDiskSpace];
}

/**
 可用存储空间
 */
- (void)availableStorage {
    NSUInteger availableStorage = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getFreeDiskSpace];
}
/**
 基带版本
 */
- (void)basebandVersion {
//NULL
}

/**
 内核版本
 */
- (void)kernelVersion {
//NULL
}
/**
 允许位置模拟
 */
- (void)allowMockLocation {
//NULL
}

/**
 广告追踪Id
 */
- (void)idfa {
    NSString *idfa = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getIDFA];
}

/**
 vendor标识
 */
- (void)idfv {
    NSString* idfvStr = [[UIDevice currentDevice] identifierForVendor].UUIDString;
}

/**
 制造厂商
 */
- (void)manufacturer {
    @"APPLE";
}
/**
 设备型号
 */
- (void)model {
    NSString* phoneModel = [[UIDevice currentDevice] model];
    phoneModel = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getDeviceModel];
    phoneModel = phoneModel;
}
/**
 mac地址
 */
- (void)mac {
    //NULL
}
/**
 是不是手机
 */
- (void)hasTelephone {
    BOOL res = !((BOOL)TARGET_IPHONE_SIMULATOR);
}
/**
 蓝牙版本
 */
- (void)bluetoothVersion {
    //NULL
}
/**
 手机序列号
 */
- (void)serialno {
    //删除重装会变，重置位置和隐私会变
    NSString *uuidStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    uuidStr=uuidStr;
}
/**
 Sdk版本号
 */
- (void)sdkversion {

}
/**
 移动端生成的uuid
 */
- (void)uuid {
    //https://blog.csdn.net/sir_coding/article/details/68943033
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
}
/**
 算法版本号，初始值为1.0
 */
- (void)algoversion {

}
/**
 初始值为0
 */
- (void)score {

}
/**
 上一版本的设备指纹，初始值为null
 */
- (void)fpid {

}
/**
 来源(ios/android)
 */
- (void)src {
    @"iOS";
}
@end
