//
//  MobileDataViewController.m
//  test
//
//  Created by tom on 2018/6/8.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "MobileDataViewController.h"

#include <mach/mach.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import "FBDeviceInfoManager.h"
#import "MPBluetoothKit.h"
#import "APSSIDInfoObserver.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@interface MobileDataViewController ()

@end

@implementation MobileDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self vpnIp];
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
- (void)phoneNumber {
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
- (void)phoneType {

}

/**
 网络制式
 */
- (void)radioType {

}

/**
 基站信息
 */
- (void)cellLocation {

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
- (void)gateway {

}

/**
 WIFI子网掩码
 */
- (void)wifiNetmask {

}

/**
 代理配置
 */
- (void)proxyInfo {

}

/**
 DNS地址
 */
- (void)dnsAddress {

}

/**
 VPNIP地址
 */
- (void)vpnIp {
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

    NSLog(@"addresses: %@", addresses);

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
 VPN子网掩码
 */
- (void)vpnNetmask {

}

/**
 CELLIP地址
 */
- (void)cellIp {

}

/**
 网络类型
 */
- (void)networkType {

}

/**
 是否ROOT
 */
- (void)root {

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

}

/**
 内核版本
 */
- (void)kernelVersion {

}
/**
 允许位置模拟
 */
- (void)allowMockLocation {

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
- (void)has_telephone {

}
/**
 蓝牙版本
 */
- (void)bluetooth_version {
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
