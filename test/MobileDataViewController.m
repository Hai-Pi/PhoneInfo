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

#import "NSData+NAFEncryption.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#define KEY @"pil7wyE1dVD58239"
NSString*(^stringBlock)(NSString*string) = ^(NSString*string) {
    if ([string isKindOfClass:NSString.class]) {
        return string ?: @"";
    }else {
        return @"";
    }
};
#define STRINGSAFEIFY(string) stringBlock(string)

@interface MobileDataViewController ()

@end

@implementation MobileDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSString *)aesEntry:(NSString *)value
{
    if (value.length) {
        NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encryptData = [valueData AES256EncryptWithKey:KEY];
        NSString *resultStr = [encryptData base64Encoding];
        return resultStr;
    }
    return value;
}

- (NSString *)requestSerialization:(NSDictionary *)parameters
{
    /*
    NSMutableString *bodyStr = [[NSMutableString alloc] init];
    for (NSString *someKey in parameters) {
        NSString *someValue = [parameters objectForKey:someKey];
        NSString *someStr = [NSString stringWithFormat:@"%@=%@",someKey,someValue];
        [bodyStr appendFormat:@"%@&",someStr];
    }
    NSString *str = [bodyStr substringToIndex:[bodyStr length] -1];
    str = [self aesEntry:str];
    return str;
    */
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *str = [self aesEntry:jsonString];
    return str;
}

- (IBAction)sendButtonClicked:(UIButton *)sender {
    NSString *urlStr = @"xxx";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *param = @{
                            @"tags":[self tags],
                            @"imsi":[self imsi],
                            @"mbPhone":[self mbPhone],
                            @"imei":[self imei],
                            @"voiceMail":[self voiceMail],
                            @"simSerial":[self simSerial],
                            @"countryIso":[self countryIso],
                            @"carrier":[self carrier],
                            @"mcc":[self mcc],
                            @"mnc":[self mnc],
                            @"simOperator":[self simOperator],
                            @"phoneType":[self phoneType],
                            @"radioType":[self radioType],
                            @"cellLocation":[self cellLocation],
                            @"deviceSVN":[self deviceSVN],
                            @"wifiIp":[self wifiIp],
                            @"wifiMac":[self wifiMac],
                            @"ssid":[self ssid],
                            @"bssid":[self bssid],
                            @"gateway":[self gateway],
                            @"wifiNetmask":[self wifiNetmask],
                            @"proxyInfo":[self proxyInfo],
                            @"dnsAddress":[self dnsAddress],
                            @"vpnIp":[self vpnIp],
                            @"vpnNetmask":[self vpnNetmask],
                            @"cellIp":[self cellIp],
                            @"networkType":[self networkType],
                            @"root":[self root],
                            @"timeZone":[self timeZone],
                            @"language":[self language],
                            @"screenRes":[self screenRes],
                            @"fontHash":[self fontHash],
                            @"blueMac":[self blueMac],
                            @"androidId":[self androidId],
                            @"cpuFrequency":[self cpuFrequency],
                            @"cpuHardware":[self cpuHardware],
                            @"cpuType":[self cpuType],
                            @"totalMemory":[self totalMemory],
                            @"availableMemory":[self availableMemory],
                            @"totalStorage":[self totalStorage],
                            @"availableStorage":[self availableStorage],
                            @"basebandVersion":[self basebandVersion],
                            @"kernelVersion":[self kernelVersion],
                            @"allowMockLocation":[self allowMockLocation],
                            @"manufacturer":[self manufacturer],
                            @"model":[self model],
                            @"hasTelephone":[self hasTelephone],
                            @"bluetoothVersion":[self bluetoothVersion],
                            @"serialno":[self serialno],
                            @"sdkversion":[self sdkversion],
                            @"score":[self score],
                            @"fpid":[self fpid],
                            @"src":[self src],
                            @"idfa" : [self idfa],
                            @"idfv" : [self idfv],
                            @"mac" : [self mac],
                            @"uuid" : [self uuid],
                            @"algoversion" : [self algoversion],
                            };

    NSString *requestData = [self requestSerialization:param];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
        NSLog(@"responseObject is: %@", responseObject);
    }];
    [task resume];
}

/**
 ROM标签
 */
- (NSString*)tags {
    //NULL
    return @"";
}
/**
 IMSI
 */
- (NSString*)imsi {
    //NULL
    return @"";
}

/**
 电话号码
 */
- (NSString*)mbPhone {
    NSString *number = [[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"];
    NSLog(@"number is: %@", number);
    return STRINGSAFEIFY(number);;
}

/**
 IMEI
 */
- (NSString*)imei {
    //NULL
    return @"";
}

/**
 语音信箱号码
 */
- (NSString*)voiceMail {
    //NULL
    return @"";
}

/**
 SIM卡序列号
 */
- (NSString*)simSerial {
    //NULL
    return @"";
}

/**
 国家代码
 */
- (NSString*)countryIso {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    NSString *mobileCountryCode = carrier.isoCountryCode;//mobileCountryCode;
    return STRINGSAFEIFY(mobileCountryCode);
}

/**
 移动运营商
 */
- (NSString*)carrier {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    NSString *carrierName = carrier.carrierName;
    char*c = carrierName.UTF8String;
    return STRINGSAFEIFY(carrierName);
}

/**
 MNC
 */
- (NSString*)mnc {
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *mnc = [carrier mobileNetworkCode];
    return STRINGSAFEIFY(mnc);
}

/**
 MCC
 */
- (NSString*)mcc {
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *mcc = [carrier mobileCountryCode];
    return STRINGSAFEIFY(mcc);
}

/**
 SIM卡运营商
 */
- (NSString*)simOperator {
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
    return STRINGSAFEIFY(carrier_name);
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

        return STRINGSAFEIFY(deviceString);
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

    return STRINGSAFEIFY(netconnType);
}

/**
 基站信息
 */
- (NSString*)cellLocation {
    //NULL
    return @"";
}

/**
 设备软件版本号
 */
- (NSString*)deviceSVN {
    NSString *strSysVersion = [[UIDevice currentDevice] systemVersion];
    return STRINGSAFEIFY(strSysVersion);
}

/**
 无线IP地址
 */
- (NSString*)wifiIp {
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
    return STRINGSAFEIFY(address);
}

/**
 无线Mac地址
 */
- (NSString*)wifiMac {
    NSString *mac = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getMacAddress];
    return STRINGSAFEIFY(mac);
}

/**
 无线网络名称
 */
- (NSString*)ssid {
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
    return STRINGSAFEIFY(ssid);
}

/**
 无线BSSID
 */
- (NSString*)bssid {
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
    return STRINGSAFEIFY(bssid);
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
    return STRINGSAFEIFY(ip);
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
    return STRINGSAFEIFY(address);
}

/**
 代理配置
 */
- (NSString*)proxyInfo {
    CFDictionaryRef dicRef = CFNetworkCopySystemProxySettings();
    const CFStringRef proxyCFstr = (const CFStringRef)CFDictionaryGetValue(dicRef,
                                                                           (const void*)kCFNetworkProxiesHTTPProxy);
    NSString* proxy = (__bridge NSString *)proxyCFstr;
    return STRINGSAFEIFY(proxy);
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

    return STRINGSAFEIFY(dnsArray.firstObject);
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

    return STRINGSAFEIFY(address);
}

/**
 VPN子网掩码
 */
- (NSString*)vpnNetmask {
    //NULL
    return @"";
}

/**
 CELLIP地址
 */
- (NSString*)cellIp {
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
    return STRINGSAFEIFY(address);
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

    return STRINGSAFEIFY(netconnType);
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
    return STRINGSAFEIFY(res);
}

/**
 时区
 */
- (NSString*)timeZone {
    NSInteger offset = [NSTimeZone localTimeZone].secondsFromGMT;
    offset = offset/3600;
    NSString *tzStr = [NSString stringWithFormat:@"%ld", (long)offset];
    return STRINGSAFEIFY(tzStr);
}
/**
 语言
 */
- (NSString*)language {
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *languageName = [appLanguages objectAtIndex:0];
    languageName = languageName;
    return STRINGSAFEIFY(languageName);
}
/**
 屏幕分辨率
 */
- (NSString*)screenRes {
    CGSize  size = [[[UIScreen mainScreen] preferredMode] size];
    return STRINGSAFEIFY(NSStringFromCGSize(size));
}

/**
 字体列表HASH
 */
- (NSString*)fontHash {
    NSArray *fonts = [UIFont familyNames];
    NSUInteger hash = fonts.hash;
    hash=hash;
    return STRINGSAFEIFY(@(hash).stringValue);
}

/**
 蓝牙MAC地址
 */
- (NSString*)blueMac {
    //NULL
    return @"";
}

/**
 AndroidID
 */
- (NSString*)androidId {
    //NULL
    return @"";
}

/**
 CPU主频
 */
- (NSString*)cpuFrequency {
    NSUInteger frequency = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getCPUFrequency];
    return STRINGSAFEIFY(@(frequency).stringValue);
}

/**
 CPU硬件
 */
- (NSString*)cpuHardware {
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
    return STRINGSAFEIFY(cpu);
}

/**
 CPU型号
 */
- (NSString*)cpuType {
    return STRINGSAFEIFY(@([[FBDeviceInfoManager sharedDevieInfoManager] fb_getCPUCount]).stringValue);
}

/**
 内存大小
 */
- (NSString*)totalMemory {
    NSUInteger totalMemory = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getTotalMemory];
    return STRINGSAFEIFY(@(totalMemory).stringValue);
}

/**
 可用内存
 */
- (NSString*)availableMemory {
    NSUInteger availableMemory = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getActiveMemory];
    return STRINGSAFEIFY(@(availableMemory).stringValue);
}
/**
 存储空间大小
 */
- (NSString*)totalStorage {
    NSUInteger totalStorage = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getTotalDiskSpace];
    return STRINGSAFEIFY(@(totalStorage).stringValue);
}

/**
 可用存储空间
 */
- (NSString*)availableStorage {
    NSUInteger availableStorage = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getFreeDiskSpace];
    return STRINGSAFEIFY(@(availableStorage).stringValue);
}
/**
 基带版本
 */
- (NSString*)basebandVersion {
//NULL
    return @"";
}

/**
 内核版本
 */
- (NSString*)kernelVersion {
//NULL
    return @"";
}
/**
 允许位置模拟
 */
- (NSString*)allowMockLocation {
//NULL
    return @"";
}

/**
 广告追踪Id
 */
- (NSString*)idfa {
    NSString *idfa = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getIDFA];
    return STRINGSAFEIFY(idfa);
}

/**
 vendor标识
 */
- (NSString*)idfv {
    NSString* idfvStr = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    return STRINGSAFEIFY(idfvStr);
}

/**
 制造厂商
 */
- (NSString*)manufacturer {
    return @"APPLE";
}
/**
 设备型号
 */
- (NSString*)model {
    NSString* phoneModel = [[UIDevice currentDevice] model];
    phoneModel = [[FBDeviceInfoManager sharedDevieInfoManager] fb_getDeviceModel];
    phoneModel = phoneModel;
    return STRINGSAFEIFY(phoneModel);
}
/**
 mac地址
 */
- (NSString*)mac {
    //NULL
    return @"";
}
/**
 是不是手机
 */
- (NSString*)hasTelephone {
    BOOL res = !((BOOL)TARGET_IPHONE_SIMULATOR);
    return STRINGSAFEIFY(@(res).stringValue);
}
/**
 蓝牙版本
 */
- (NSString*)bluetoothVersion {
    //NULL
    return @"";
}
/**
 手机序列号
 */
- (NSString*)serialno {
    //删除重装会变，重置位置和隐私会变
    NSString *uuidStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    uuidStr=uuidStr;
    return STRINGSAFEIFY(uuidStr);
}
/**
 Sdk版本号
 */
- (NSString*)sdkversion {
    return @"";
}
/**
 移动端生成的uuid
 */
- (NSString*)uuid {
    //https://blog.csdn.net/sir_coding/article/details/68943033
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    CFStringRef uuidStrRef = CFUUIDCreateString(NULL, uuid);
    NSString *uuidStr = (__bridge NSString *)uuidStrRef;
    return STRINGSAFEIFY(uuidStr);
}
/**
 算法版本号，初始值为1.0
 */
- (NSString*)algoversion {
    return @"1.0";
}
/**
 初始值为0
 */
- (NSString*)score {
    return @"0";
}
/**
 上一版本的设备指纹，初始值为null
 */
- (NSString*)fpid {
    return @"";
}
/**
 来源(ios/android)
 */
- (NSString*)src {
    return @"ios";
}
@end
