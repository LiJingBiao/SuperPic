//
//  HttpViewController.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/25.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "UIViewController+MMDrawerController.h"
#import "HttpViewController.h"
#import "FtpServer.h"
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "localhostAddresses.h"
#import "NetworkController.h"
#import "FKFileManager.h"
@interface HttpViewController ()
{
    NSDictionary *addresses;
}
@property (weak, nonatomic) IBOutlet UILabel *indicateLabel;
@property (weak, nonatomic) IBOutlet UIButton *openButton;
@property (strong, nonatomic)HTTPServer  *theHTTPServer;
@property (nonatomic, copy) NSString *baseDir;
@property BOOL isServerRunning;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;


@end

@implementation HttpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.backBtn];
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)openHttpServer:(UIButton *)sender {
    [self startServer];
}

- (void) startServer
{
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSLog(@"documentsDirectory%@",documentsDirectory);
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *gifDirectory = [documentsDirectory stringByAppendingPathComponent:@"GIF"];
//    // 创建目录
//    [fileManager createDirectoryAtPath:gifDirectory withIntermediateDirectories:YES attributes:nil error:nil];
//    NSLog(@"%@",gifDirectory);
    NSString *gifDirectory = [FKFileManager myGifPath];
    NSString *localIPAddress = [NetworkController localWifiIPAddress];
    //NSArray *docFolders = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES );
    self.baseDir =  gifDirectory;
    
    self.theHTTPServer = [HTTPServer new];
    [self.theHTTPServer setType:@"_http._tcp."];
    [self.theHTTPServer setConnectionClass:[MyHTTPConnection class]];
    [self.theHTTPServer setDocumentRoot:[NSURL fileURLWithPath:gifDirectory]];
    
    NSError *error;
    if(![self.theHTTPServer start:&error])
    {
        NSLog(@"Error starting HTTP Server: %@", error);
    }
    
    UInt16 theHTTPServerPort = [self.theHTTPServer port];
    
    self.indicateLabel.text =[NSString stringWithFormat:@"%@ %@ %@ %d",
                        @"http://",localIPAddress, @":", theHTTPServerPort];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInfoUpdate:) name:@"LocalhostAdressesResolved" object:nil];
    [localhostAddresses performSelectorInBackground:@selector(list) withObject:nil];
    self.isServerRunning = TRUE;
}

- (void)displayInfoUpdate:(NSNotification *) notification
{
    NSLog(@"displayInfoUpdate:");
    
    if(notification)
    {
        addresses = [[notification object] copy];
        NSLog(@"addresses: %@", addresses);
    }
    
    if(addresses == nil)
    {
        return;
    }
    
    NSString *info;
    //UInt16 port = [theHTTPServer port];
    
    NSString *localIP = nil;
    
    localIP = [addresses objectForKey:@"en0"];
    
    if (!localIP)
    {
        localIP = [addresses objectForKey:@"en1"];
    }
    
    if (!localIP)
        info = @"Wifi: No Connection!\n";
}


- (void)stopFtpServer {
    // ----------------------------------------------------------------------------------------------------------
    NSLog(@"Stopping the FTP server");
    
    self.isServerRunning = FALSE;
    
    if(_theHTTPServer)
    {
        [_theHTTPServer stop];
        _theHTTPServer=nil;
    }
    

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopFtpServer];
}
@end
