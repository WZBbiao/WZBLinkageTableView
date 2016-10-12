//
//  ViewController.m
//  WZBLinkageTableView
//
//  Created by WZB on 16/6/1.
//  Copyright © 2016年 王振标. All rights reserved.
//

#import "ViewController.h"

#define WZBScreenHeight [UIScreen mainScreen].bounds.size.height
#define WZBScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView *leftTableView;
@property (weak, nonatomic) UITableView *rightTableView;
@property (nonatomic, strong) NSMutableArray *datas;

// 用来保存当前左边tableView选中的行数
@property (strong, nonatomic) NSIndexPath *currentSelectIndexPath;

@end

@implementation ViewController

#pragma mark - lazy
// Load Datas
- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray array];
        for (NSInteger i = 1; i <= 10; i++) {
            [_datas addObject:[NSString stringWithFormat:@"第%zd分区", i]];
        }
    }
    return _datas;
}

#pragma mark - system
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setBaseTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - private
- (void)setBaseTableView {
    // leftTableView
    UITableView *leftTableView = [[UITableView alloc] initWithFrame:(CGRect){0, 0, WZBScreenWidth * 0.25f, WZBScreenHeight}];
//    leftTableView.backgroundColor = [UIColor redColor];
    [self.view addSubview:leftTableView];
    self.leftTableView = leftTableView;
    
    // rightTableView
    UITableView *rightTableView = [[UITableView alloc] initWithFrame:(CGRect){WZBScreenWidth * 0.25f, 0, WZBScreenWidth * 0.75f, WZBScreenHeight}];
    [self.view addSubview:rightTableView];
    self.rightTableView = rightTableView;
    
    // delegate && dataSource
    rightTableView.delegate = leftTableView.delegate = self;
    rightTableView.dataSource = leftTableView.dataSource = self;
    
    // 默认选择左边tableView的第一行
    [leftTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}

- (void)selectLeftTableViewWithScrollView:(UIScrollView *)scrollView {
    if (self.currentSelectIndexPath) {
        return;
    }
    // 如果现在滑动的是左边的tableView，不做任何处理
    if ((UITableView *)scrollView == self.leftTableView) return;
    // 滚动右边tableView，设置选中左边的tableView某一行。indexPathsForVisibleRows属性返回屏幕上可见的cell的indexPath数组，利用这个属性就可以找到目前所在的分区
    [self.leftTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.rightTableView.indexPathsForVisibleRows.firstObject.section inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.leftTableView) return 1;
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.leftTableView) return self.datas.count;
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == self.leftTableView) return nil;
    return self.datas[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    
    if (tableView == self.leftTableView) cell.textLabel.text = self.datas[indexPath.row];
     else cell.textLabel.text = [NSString stringWithFormat:@"%@ ----- 第%zd行", self.datas[indexPath.section], indexPath.row + 1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 如果点击的是右边的tableView，不做任何处理
    if (tableView == self.rightTableView) return;
    
    // 点击左边的tableView，设置选中右边的tableView某一行。左边的tableView的每一行对应右边tableView的每个分区
    [self.rightTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row] animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.currentSelectIndexPath = indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.leftTableView) return 0;
    return 30;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{ // 监听tableView滑动
    [self selectLeftTableViewWithScrollView:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    // 重新选中一下当前选中的行数，不然会有bug
    if (self.currentSelectIndexPath) self.currentSelectIndexPath = nil;
}

@end
