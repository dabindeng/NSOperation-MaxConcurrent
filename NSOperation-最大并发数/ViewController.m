//
//  ViewController.m
//  NSOperation-最大并发数
//
//  Created by DB_MAC on 2017/7/3.
//  Copyright © 2017年 db. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic , strong) NSOperationQueue *opQueue;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self demo1];
}



//懒加载
-(NSOperationQueue *)opQueue
{
    if (!_opQueue) {
        _opQueue = [[NSOperationQueue alloc] init];
        
    }
    return _opQueue;
}
//依赖关系
-(void)dependecy{
    //例子  下载解压 通知用户
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        //下载
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        //解压
    }];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        //通知用户
    }];
    //依赖关系
    [op2 addDependency:op1];//op1 执行结束才能执行 op2
    [op3 addDependency:op2];
    
    [self.opQueue addOperations:@[op1,op2] waitUntilFinished:YES];//yes 的时候 等待op1 2 3 结束才继续后面的操作  会卡住当前线程
    
    //主线程通知
    [[NSOperationQueue mainQueue] addOperation:op3];
}

//挂起的时候 不会清空内部操作  只有在队列继续的时候  才会清空
//正在执行的操作也不会被取消
-(void)cancelAllOperation
{
    [self.opQueue cancelAllOperations];
}

-(void)pause{
    
    /*
     当我们挂起的时候  正在执行的任务不受影响
     
     
     suspended 挂起后 再添加操作  不会执行  等到继续队列的时候才会继续执行
     
     */
    //判断队列是否挂起(暂停)
    if (self.opQueue.isSuspended) {
        //队列继续跑
        self.opQueue.suspended = NO;
    }else
        self.opQueue.suspended = YES;
}

-(void)demo1{
    
    //iOS 8 开始无论 GCD NSOperation 都会开启很多线程
    // iOS 7 之前 大概只会开启 5-6条线程
    //线程多了  说明：1、底层线程池更大  能够拿到的线程资源多了   2、对控制同时并发的现场数，要求变高了（线程开多了就容易导致手机发烫）
    
    self.opQueue.maxConcurrentOperationCount = 6;//设置同时最大并发的操作线程数  wifi:5-6   流量：2-3
    
    for (int i = 0; i < 10; i++) {
        [self.opQueue addOperationWithBlock:^{
            NSLog(@"%@",[NSThread currentThread]);
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
