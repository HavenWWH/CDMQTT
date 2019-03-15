//
//  ViewController.m
//  CDMQTT
//
//  Created by 吴文海 on 2019/2/28.
//  Copyright © 2019 吴文海. All rights reserved.
//

#import "ViewController.h"
#import <MQTTClient/MQTTClient.h>

@interface ViewController ()<MQTTSessionManagerDelegate>///<>
@property (nonatomic, strong) MQTTSession *session;
@property (nonatomic, strong) NSMutableDictionary *receiveDataDict;
@property (nonatomic, strong) MQTTSessionManager *sessionManager;

@property (nonatomic, strong) NSMutableDictionary *topicDict;
@end

@implementation ViewController

- (void)dealloc {
    [_sessionManager removeObserver:self forKeyPath:@"effectiveSubscriptions"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1, 初始化
//    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
//    // MQTT服务器地址
//    transport.host = @"106.14.120.242";
//    // MQTT服务器端口
//    transport.port = 1883;
//
//
//    // 2, 初始化session
//    self.session.transport = transport;
//
//
//    [self.session connect];
    // 1, 初始化
//    MQTTSSLSecurityPolicy * policy = [MQTTSSLSecurityPolicy defaultPolicy];
    
    [self connectMQTT];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//
//    NSLog(@"状态%@ %@ %@",change, object, @(self.session.status));
//    if (self.session.status == 2) {
//
//        // 3, 订阅主题
//        [self.session subscribeToTopic:@"changdao/live/test" atLevel:MQTTQosLevelAtLeastOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
//
//            if (error) {
//
//                NSLog(@"订阅失败:%@", error.localizedDescription);
//            } else {
//
//                NSLog(@"订阅成功:%@", gQoss);
//            }
//        }];
//
//    } else if(self.session.status == 4) {
//
//        [self.session connect];
//    }
//}

#pragma mark - init -
- (MQTTSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [[MQTTSessionManager alloc] initWithPersistence:YES maxWindowSize:MQTT_MAX_WINDOW_SIZE maxMessages:MQTT_MAX_MESSAGES maxSize:MQTT_MAX_SIZE maxConnectionRetryInterval:64 connectInForeground:YES streamSSLLevel:nil queue:dispatch_get_main_queue()];
        _sessionManager.delegate = self;
        [_sessionManager addObserver:self
                          forKeyPath:@"effectiveSubscriptions"
                             options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior
                             context:nil];
        // 订阅主题  value表示Qos
        _sessionManager.subscriptions = self.topicDict;
        
    }
    return _sessionManager;
}

- (void)connectMQTT {
    
    [self.sessionManager  connectTo:@"106.14.120.242" port:1883 tls:NO keepalive:10 clean:NO auth:YES user:@"changdao" pass:@"changdao@123" will:NO willTopic:nil willMsg:nil willQos:0 willRetainFlag:NO withClientId:@"wuwenhai00123e23424232r2" securityPolicy:nil certificates: nil protocolLevel:MQTTProtocolVersion50 connectHandler: nil];
}



//- (MQTTSession *)session {
//    if (!_session) {
//        _session = [[MQTTSession alloc] init];
//        _session.userName = @"changdao";
//        _session.password = @"changdao@123";
//        _session.delegate  = self;
//        [_session connectAndWaitTimeout:1];
//        [_session addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionOld context:nil];
//    }
//    return _session;
//}
//- (NSMutableDictionary *)receiveDataDict {
//    if (!_receiveDataDict) {
//        _receiveDataDict = [[NSMutableDictionary alloc] init];
//    }
//    return _receiveDataDict;
//}

#pragma mark - public Methods -
// 手动断开连接
- (IBAction)close:(UIButton *)sender {
    
    [self.sessionManager disconnectWithDisconnectHandler:^(NSError *error) {
        
        NSLog(@"断开连接%@", error);
    }];
}

// 发送消息
- (IBAction)sendMsg:(UIButton *)sender {
    
    NSLog(@"subscriptions::::%@", self.sessionManager.subscriptions);
    [self.sessionManager sendData:[@"吴文海发到消息Haven-007" dataUsingEncoding:NSUTF8StringEncoding] topic:@"changdao/live/test" qos:MQTTQosLevelAtLeastOnce retain:YES];
}


- (void)connectToLast {
    
    // connectToLast利用最后一次保持的客户端数据进行连接
    [self.sessionManager connectToLast:^(NSError *error) {
        if (error) {
            
            NSLog(@"连接失败:%@", error.localizedDescription);
        } else {
            
            NSLog(@"连接成功");
        }
    }];
}

#pragma mark - MQTTSessionManagerDelegate -
- (NSMutableDictionary *)topicDict {
    if (!_topicDict) {
        _topicDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@(1), @"changdao/live/test2222222", @(1), @"changdao/live/test", @(1), @"1111", nil];
    }
    return _topicDict;
}
// 接收消息
- (void)sessionManager:(MQTTSessionManager *)sessionManager
     didReceiveMessage:(NSData *)data
               onTopic:(NSString *)topic
              retained:(BOOL)retained {
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到消息::::::%@", str);
}


// 监听session状态
- (void)sessionManager:(MQTTSessionManager *)sessionManager didChangeState:(MQTTSessionManagerState)newState {
    
    NSLog(@"状态%@", @(newState));
    
    if (newState == 3) {

    } else if (newState == 5) {
    // 不管是主动还是被动的断开连接都会进入次方法
    }
}

// 消息ID
- (void)messageDelivered:(UInt16)msgID {
    
    NSLog(@"消息ID::::msdId%@", @(msgID));
}

#pragma mark - KVO -
// 监听订阅的状态
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"effectiveSubscriptions"]) {
        
        MQTTSessionManager *manager = (MQTTSessionManager *)object;
        // 此处打印的主题才是订阅成功的主题, 否则需要进行重新订阅
        NSLog(@"effectiveSubscriptions changed: %@ lastErrorCode: %@", manager.effectiveSubscriptions, manager.lastErrorCode);
//        if (manager.effectiveSubscriptions) {
//            NSArray *allKeys = self.topicDict.allKeys;
//            for (NSString *topic in allKeys) {
//                if ([manager.effectiveSubscriptions objectForKey:topic]) {
//
//                    NSLog(@"存在此主题%@",topic);
//                } else {
//
//                    NSLog(@"不存在此主题%@",topic);
//                }
//            }
//        } else {
//
//        }
    }
}



#pragma mark - MQTTSessionDelegate -
// 获取MQTT数据
//- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid {
//
////    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
////    [self.receiveDataDict addEntriesFromDictionary:dataDict];
//
//    NSLog(@"接受数据receuveDataDict%@", str);
//
//}

@end
