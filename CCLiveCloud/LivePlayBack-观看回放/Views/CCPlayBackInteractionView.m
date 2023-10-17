//
//  CCPlayBackInteractionView.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/14.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCPlayBackInteractionView.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

#define lowVersionDeviceLoadDataCount 20 // 低版本设备加载数据条数

@interface CCPlayBackInteractionView () <UIScrollViewDelegate, CCChatViewDataSourceManagerDelegate,CCQuestionViewDelegate>
@property (nonatomic, assign)BOOL                   isSmallDocView;//是否是文档小窗
@property (nonatomic, strong)NSMutableArray         *allQuestions; //所有问题数组
@property (nonatomic, strong)NSMutableArray         *allAnswers; // 所有回答数组
@property (nonatomic, assign)int                    replayCurrentPage;// 回放当前问答分页
@property (nonatomic, assign)BOOL                   isDoneAllData; //加载完所有数据
/** 查看历史问答翻页标记已添加回复 */
@property (nonatomic,strong)NSMutableDictionary     *QADicFlag;
@end

@implementation CCPlayBackInteractionView

-(instancetype)initWithFrame:(CGRect)frame docViewType:(BOOL)isSmallDocView{
    self = [super initWithFrame:frame];
    if (self) {
        _currentChatTime = 0;//当天聊天时间
        _currentChatIndex = -1;//当前聊天消息位置
        _isDoneAllData = NO;// 是否加载完所有数据
        _replayCurrentPage = 0; //加载当前页
        _isSmallDocView = isSmallDocView;
        [self setUpUI];
    }
    return self;
}
- (void)dealloc
{
    [self removeData];
}

#pragma mark - 设置UI布局
-(void)setUpUI{
    //UISegmentedControl,功能控制,聊天文档等
    [self addSubview:self.segment];
    self.segment.frame = CGRectMake(0, 0, SCREEN_WIDTH, 41);
    //添加分界线
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = CCRGBColor(232,232,232);
    [self addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.segment);
        make.height.mas_equalTo(1);
    }];
    //添加阴影
    [self addSubview:self.shadowView];
    self.line = [[UIView alloc] init];
    self.line.backgroundColor = [UIColor colorWithHexString:@"#dddddd" alpha:1.0f];
    [self addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.segment);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(self.shadowView);
    }];
    //UIScrollView分块,聊天,问答,简介均添加在这里
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH , SCREEN_HEIGHT - (HDGetRealHeight + 40)-SCREEN_STATUS)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollEnabled = NO;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 3, _scrollView.frame.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    //聊天
    [_scrollView addSubview:self.chatView];
    self.chatView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    //问答
    [_scrollView addSubview:self.questionChatView];
    self.questionChatView.frame = CGRectMake(_scrollView.frame.size.width * 1, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    //简介
    [_scrollView addSubview:self.introductionView];
    self.introductionView.frame = CGRectMake(_scrollView.frame.size.width * 2, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
    //添加文档
    if (!_isSmallDocView) {
        [_scrollView addSubview:self.docView];
        self.docView.frame = CGRectMake(_scrollView.frame.size.width * 3, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    }
}
#pragma mark - 私有方法-----
/**
 移除文档视图(接收到房间信息，不支持房间类型时移除文档视图
 
 @param docView docView
 */
-(void)hiddenDocView:(UIView *)docView{
    if (!_isSmallDocView) {
        [_docView setHidden:YES];
        _docView = nil;
    }else{
        [docView setHidden:YES];
    }
}
#pragma mark - SDK代理方法 -----------
#pragma mark- 房间信息
/**
 *    @brief  获取房间信息，主要是要获取直播间模版来类型，根据直播间模版类型来确定界面布局
 *    房间简介：dic[@"desc"];_docView
 *    房间名称：dic[@"name"];
 *    房间模版类型：[dic[@"templateType"] integerValue];
 *    模版类型为1: 聊天互动： 无 直播文档： 无 直播问答： 无
 *    模版类型为2: 聊天互动： 有 直播文档： 无 直播问答： 有
 *    模版类型为3: 聊天互动： 有 直播文档： 无 直播问答： 无
 *    模版类型为4: 聊天互动： 有 直播文档： 有 直播问答： 无
 *    模版类型为5: 聊天互动： 有 直播文档： 有 直播问答： 有
 *    模版类型为6: 聊天互动： 无 直播文档： 无 直播问答： 有
 */
-(void)roomInfo:(NSDictionary *)dic playerView:(nonnull CCPlayBackView *)playerView{
    NSArray *array = [_introductionView subviews];
    for(UIView *view in array) {
        [view removeFromSuperview];
    }
    // 3.16.0 new
    NSString *desc = @"";
    if ([dic.allKeys containsObject:@"recordInfo"]) {
        NSDictionary *recordInfo = dic[@"recordInfo"];
        if ([recordInfo.allKeys containsObject:@"description"]) {
            desc = recordInfo[@"description"];
        }else {
            if ([dic.allKeys containsObject:@"baseRecordInfo"]) {
                NSDictionary *baseRecordInfo = dic[@"baseRecordInfo"];
                if ([baseRecordInfo.allKeys containsObject:@"description"]) {
                    desc = baseRecordInfo[@"description"];
                }
            }
        }
    }else {
        if ([dic.allKeys containsObject:@"baseRecordInfo"]) {
            NSDictionary *baseRecordInfo = dic[@"baseRecordInfo"];
            if ([baseRecordInfo.allKeys containsObject:@"description"]) {
                desc = baseRecordInfo[@"description"];
            }
        }
    }
    self.introductionView.roomDesc = desc.length == 0 ? EMPTYINTRO : desc;
    self.introductionView.roomName = _roomName;
//    self.introductionView.roomDesc = dic[@"desc"];
//    if(!StrNotEmpty(dic[@"desc"])) {
//        self.introductionView.roomDesc = EMPTYINTRO;
//    }
//    self.introductionView.roomName = dic[@"name"];
    
    //CGFloat shadowViewY = self.segment.frame.origin.y+self.segment.frame.size.height-2;
    CGFloat shadowViewY = 39;
    
    // 回放模板类型
    if ([dic.allKeys containsObject:@"templateType"]) {
        _templateType = [dic[@"templateType"] integerValue];
    }
    // 房间模板类型
    if ([dic.allKeys containsObject:@"template"]) {
        NSDictionary *templateDic = dic[@"template"];
        if ([templateDic.allKeys containsObject:@"type"]) {
            _templateType = [templateDic[@"type"] integerValue];
        }
    }
    //    @"文档",@"聊天",@"问答",@"简介"
    if (_templateType == 1) {
        //聊天互动： 无 直播文档： 无 直播问答： 无
        [_segment setWidth:0.0f forSegmentAtIndex:0];
        [_segment setTitle:@"" forSegmentAtIndex:0];
        [_segment setWidth:0.0f forSegmentAtIndex:1];
        [_segment setTitle:@"" forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width forSegmentAtIndex:2];
//        [_segment setWidth:0.0f forSegmentAtIndex:3];
        _segment.selectedSegmentIndex = 2;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0] + [self.segment widthForSegmentAtIndex:1]+[self.segment widthForSegmentAtIndex:2]/4, shadowViewY, [self.segment widthForSegmentAtIndex:2]/2, 2);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 2, py)];
        
        /*    隐藏文档视图,隐藏切换按钮   */
        [self hiddenDocView:playerView.smallVideoView];
        playerView.changeButton.hidden = YES;
    } else if (_templateType == 2) {
        //聊天互动： 有 直播文档： 无 直播问答： 有
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:0];
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:2];
//        [_segment setWidth:0.0f forSegmentAtIndex:3];
        _segment.selectedSegmentIndex = 0;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]/4, shadowViewY, [self.segment widthForSegmentAtIndex:1]/2, 2);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH*0, py)];
        
        /*    隐藏文档视图,隐藏切换按钮   */
        [self hiddenDocView:playerView.smallVideoView];
        playerView.changeButton.hidden = YES;
    } else if (_templateType == 3) {
        //聊天互动： 有 直播文档： 无 直播问答： 无
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:0];
        [_segment setWidth:0.0f forSegmentAtIndex:1];
        [_segment setTitle:@"" forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:2];
//        [_segment setWidth:self.segment.frame.size.width/3 forSegmentAtIndex:3];
        _segment.selectedSegmentIndex = 0;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]/4, shadowViewY, [self.segment widthForSegmentAtIndex:1]/2, 2);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH*0, py)];
        
        /*    隐藏文档视图,隐藏切换按钮   */
        [self hiddenDocView:playerView.smallVideoView];
        playerView.changeButton.hidden = YES;
    } else if (_templateType == 4) {
        //聊天互动： 有 直播文档： 有 直播问答： 无
        _segment.selectedSegmentIndex = 0;
        CGFloat count = _isSmallDocView ? 2 : 3;
//        CGFloat docWidth = _isSmallDocView ? 0 : self.segment.frame.size.width / count;
        [_segment setWidth:self.segment.frame.size.width/count forSegmentAtIndex:0];
        [_segment setWidth:0.0f forSegmentAtIndex:1];
        [_segment setTitle:@"" forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/count forSegmentAtIndex:2];
//        [_segment setWidth:docWidth forSegmentAtIndex:3];
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]/4, shadowViewY, [self.segment widthForSegmentAtIndex:0]/2, 2);
        
        /*  如果文档在下，隐藏切换按钮   */
        if (!_isSmallDocView) {
            playerView.changeButton.hidden = YES;
            playerView.changeButton.tag = 1;
        }
    } else if (_templateType == 5) {
        CGFloat count = _isSmallDocView ? 3 : 4;
//        CGFloat docWidth = _isSmallDocView ? 0 : self.segment.frame.size.width / count;
        [_segment setWidth:self.segment.frame.size.width/count forSegmentAtIndex:0];
        [_segment setWidth:self.segment.frame.size.width/count forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/count forSegmentAtIndex:2];
//        [_segment setWidth:docWidth forSegmentAtIndex:3];
        _segment.selectedSegmentIndex = 0;
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]/4, shadowViewY, [self.segment widthForSegmentAtIndex:0]/2, 2);
        //聊天互动： 有 直播文档： 有 直播问答： 有
        
        /*  如果文档在下,隐藏切换按钮   */
        if (!_isSmallDocView) {
            playerView.changeButton.hidden = YES;
            playerView.changeButton.tag = 1;
        }
    }else if(_templateType == 6) {
        //聊天互动： 无 直播文档： 无 直播问答： 有
        _segment.selectedSegmentIndex = 1;
        [_segment setWidth:0.0f forSegmentAtIndex:0];
        [_segment setTitle:@"" forSegmentAtIndex:0];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:1];
        [_segment setWidth:self.segment.frame.size.width/2 forSegmentAtIndex:2];
//        [_segment setWidth:0.0f forSegmentAtIndex:3];
        _shadowView.frame = CGRectMake([self.segment widthForSegmentAtIndex:0]+[self.segment widthForSegmentAtIndex:1]/4, shadowViewY, [self.segment widthForSegmentAtIndex:1]/2, 2);
        int py = _scrollView.contentOffset.y;
        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 1, py)];
        
        
        /*    隐藏文档视图,隐藏切换按钮   */
        [self hiddenDocView:playerView.smallVideoView];
        playerView.changeButton.hidden = YES;
    }
}
#pragma mark- 聊天
/**
 *    @brief    解析本房间的历史聊天数据
 *    @param    chatArr [{  chatId          //聊天ID
                            content         //聊天内容
                            groupId         //聊天组ID
                            time            //时间
                            userId          //用户ID
                            userName        //用户名
                            userRole        //用户角色}]
 */
-(void)onParserChat:(NSArray *)chatArr{
    if (self.manager == nil || chatArr.count == 0) return;
//    [self.manager removeData];
    [self.manager initWithPlayBackChatArray:chatArr groupId:self.groupId];
    self.publicChatArray = self.manager.publicChatArray;
}
/* 自定义方法 */
/**
 *    @brief    通过传入时间获取聊天信息
 */
-(void)parseChatOnTime:(int)time{
    if ([self.publicChatArray count] == 0) {
        return;
    }
    long count = [self.publicChatArray count];
    int preIndex = self.currentChatIndex;
    if(time < self.currentChatTime) {
        for(int i = 0;i < count;i++) {
            Dialogue *dialogue = [self.publicChatArray objectAtIndex:i];
            if(i == 0 && [dialogue.time integerValue] > time) {
                _currentChatTime = 0;
                _currentChatIndex = -1;
            }
            if([dialogue.time integerValue] <= time) {
                self.currentChatIndex = i;
                if(self.currentChatIndex == count-1) {
                    NSArray *array = [self.publicChatArray subarrayWithRange:NSMakeRange(0, self.currentChatIndex + 1)];
                    [self.chatView reloadPublicChatArray:[NSMutableArray arrayWithArray:array]];
                    self.currentChatTime = time;
                }
            } else {
                NSArray *array = [self.publicChatArray subarrayWithRange:NSMakeRange(0, self.currentChatIndex + 1)];
                [self.chatView reloadPublicChatArray:[NSMutableArray arrayWithArray:array]];
                self.currentChatTime = time;
                break;
            }
        }
    } else if(time >= self.currentChatTime) {
        for(int i = preIndex + 1;i < count;i++) {
            Dialogue *dialogue = [self.publicChatArray objectAtIndex:i];
            if([dialogue.time integerValue] <= time) {
                self.currentChatIndex = i;
                if(self.currentChatIndex == count-1) {
                    NSArray *array = [self.publicChatArray subarrayWithRange:NSMakeRange(preIndex + 1, self.currentChatIndex - (preIndex + 1) + 1)];
                    [self.chatView addPublicChatArray:[NSMutableArray arrayWithArray:array]];
                    self.currentChatTime = time;
                }
            } else if(preIndex + 1 <= self.currentChatIndex){
                NSArray *array = [self.publicChatArray subarrayWithRange:NSMakeRange(preIndex + 1, self.currentChatIndex - (preIndex + 1) + 1)];
                [self.chatView addPublicChatArray:[NSMutableArray arrayWithArray:array]];
                self.currentChatTime = time;
                break;
            }
        }
    }
}
#pragma mark- 问答
/**
 *    @brief  收到提问&回答
 */
-(void)onParserQuestionArr:(NSArray *)questionArr onParserAnswerArr:(NSArray *)answerArr{
    if ([questionArr count] == 0 && [answerArr count] == 0) {
        return;
    }
    [self.QADic removeAllObjects];
    
    [self.allQuestions removeAllObjects];
    [self.allAnswers removeAllObjects];
    [self.allQuestions addObjectsFromArray:questionArr];
    [self.allAnswers addObjectsFromArray:answerArr];
    
    [self.QADicFlag removeAllObjects];
    for (int i = 0; i < answerArr.count; i++) {
        NSString *flagKey = [NSString stringWithFormat:@"%@%d",@"answer",i];
        [self.QADicFlag setObject:@(0) forKey:flagKey];
    }
    
    // 第一次加载数据
    int allQuestionsCount = (int)[_allQuestions count];
    if (allQuestionsCount > lowVersionDeviceLoadDataCount) {
        NSRange range = NSMakeRange(0, lowVersionDeviceLoadDataCount);
        NSArray *tempArr = [_allQuestions subarrayWithRange:range];
        [self loadQuestionData:tempArr answerData:_allAnswers];
    }else {
        _isDoneAllData = YES;
        [self loadQuestionData:_allQuestions answerData:_allAnswers];
    }
}

/**
 *   @brief 处理解析数据
 *
 *   @param questionDataArr  问题数组
 *   @param answerDataArr  回答数组
 */
- (void)loadQuestionData:(NSArray *)questionDataArr answerData:(NSArray *)answerDataArr
{
    dispatch_queue_t queue = dispatch_queue_create("Question", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
    
        for (NSDictionary *dic in questionDataArr) {
            if ([dic[@"isPublish"] intValue] == 1) {//解析已经发布的问答信息
                Dialogue *dialog = [[Dialogue alloc] init];
                //通过groupId过滤数据------
                NSString *msgGroupId = dic[@"groupId"];
                //判断是否自己or消息的groupId为空or是否是本组聊天信息
                if ([_groupId isEqualToString:@""] || [msgGroupId isEqualToString:@""] || [self.groupId isEqualToString:msgGroupId] || !msgGroupId) {
                    dialog.msg = dic[@"content"];
                    dialog.username = dic[@"questionUserName"];
                    dialog.fromuserid = dic[@"questionUserId"];
                    if ([dic.allKeys containsObject:@"time"]) {
                        dialog.time = [NSString stringWithFormat:@"%@",dic[@"time"]];
                    }
                    if ([dic.allKeys containsObject:@"triggerTime"]) {
                        dialog.targetTime = dic[@"triggerTime"];
                    }
                    dialog.encryptId = dic[@"encryptId"];
                    dialog.useravatar = dic[@"useravatar"];
                    dialog.dataType = NS_CONTENT_TYPE_QA_QUESTION;
                    dialog.isPublish = [dic[@"isPublish"] boolValue];
                    if ([dic.allKeys containsObject:@"extra"]) {
                        NSDictionary *extraDict = dic[@"extra"];
                        if ([extraDict.allKeys containsObject:@"img"]) {
                            dialog.images = extraDict[@"img"];
                        }
                    }
                    
                    //将过滤后的问答添加到问答数组
                    NSMutableArray *arr = [self.QADic objectForKey:dialog.encryptId];
                    if (arr == nil) {
                        arr = [[NSMutableArray alloc] init];
                        [self.QADic setObject:arr forKey:dialog.encryptId];
                    }
                    if(![self.keysArrAll containsObject:dialog.encryptId]) {
                        [self.keysArrAll addObject:dialog.encryptId];
                    }
                    [arr addObject:dialog];
                }
            }else{
                //没有发布的问答数据不需要解析.
            }
        }
        
//        for (NSDictionary *dic in answerDataArr) {
        for (int i = 0; i < answerDataArr.count; i++) {
            NSDictionary *dic = answerDataArr[i];
            Dialogue *dialog = [[Dialogue alloc] init];
            dialog.msg = dic[@"content"];
            dialog.username = dic[@"answerUserName"];
            dialog.fromuserid = dic[@"answerUserId"];
            dialog.encryptId = dic[@"encryptId"];
            dialog.useravatar = dic[@"useravatar"];
            dialog.dataType = NS_CONTENT_TYPE_QA_ANSWER;
            dialog.isPrivate = [dic[@"isPrivate"] boolValue];
            if ([dic.allKeys containsObject:@"time"]) {
                dialog.time = [NSString stringWithFormat:@"%@",dic[@"time"]];
            }
            if ([dic.allKeys containsObject:@"triggerTime"]) {
                dialog.targetTime = dic[@"triggerTime"];
            }
            if ([dic.allKeys containsObject:@"extra"]) {
                NSDictionary *extraDict = dic[@"extra"];
                if ([extraDict.allKeys containsObject:@"img"]) {
                    dialog.images = extraDict[@"img"];
                }
            }
            NSMutableArray *arr = [self.QADic objectForKey:dialog.encryptId];
            NSString *flagKey = [NSString stringWithFormat:@"%@%d",@"answer",i];
            NSInteger answerFlag = [[self.QADicFlag objectForKey:flagKey] integerValue];
            if (arr != nil) {
                if (answerFlag == 0) {
                    [arr addObject:dialog];
                    [self.QADicFlag setObject:@(1) forKey:flagKey];
                }
            }
        }
        [self.questionChatView reloadQADic:self.QADic keysArrAll:self.keysArrAll questionSourceType:QuestionSourceTypeFromReplay currentPage:_replayCurrentPage isDoneAllData:_isDoneAllData];
    });
}

/**
 *    @brief    回放问答代理事件
 *    @param    currentPage  当前页
 */
- (void)replayLoadMoreDataWithPage:(int)currentPage
{
    // 剩余数据count
    int resuideKeysCount = (int)_allQuestions.count - (currentPage + 1) *lowVersionDeviceLoadDataCount;
    // 最后一页数据 不够一整页数据时 计算剩余数据count
    if (_allQuestions.count < (currentPage + 1) *lowVersionDeviceLoadDataCount) {
        resuideKeysCount =  (int)_allQuestions.count - currentPage *lowVersionDeviceLoadDataCount;
        _isDoneAllData = YES;
    }
    if (resuideKeysCount <= 0){
        NSMutableArray *noDataArray = [NSMutableArray array];
        _isDoneAllData = YES;
        [self loadQuestionData:noDataArray answerData:noDataArray];
        return;
    }
    // 当前分页范围
    NSRange range = NSMakeRange(currentPage * lowVersionDeviceLoadDataCount, lowVersionDeviceLoadDataCount < resuideKeysCount ? lowVersionDeviceLoadDataCount : resuideKeysCount);
    NSMutableArray *tempArr = [NSMutableArray array];
    // 取出分页范围的数据
    [tempArr addObjectsFromArray:[_allQuestions subarrayWithRange:range]];
    self.replayCurrentPage = currentPage;
    
    [self loadQuestionData:tempArr answerData:_allAnswers];
}

#pragma mark - 切换底部功能
/**
 *    @brief    切换底部功能 如聊天,问答,简介等
 *    @param    segment   选中的segment
 */
-(void)segmentAction:(UISegmentedControl *)segment{
    NSInteger index = segment.selectedSegmentIndex;
    int py = _scrollView.contentOffset.y;
    CGFloat width0 = [segment widthForSegmentAtIndex:0];
    CGFloat width1 = [segment widthForSegmentAtIndex:1];
    CGFloat width2 = [segment widthForSegmentAtIndex:2];
    CGFloat width3 = 0;//[segment widthForSegmentAtIndex:3];
    CGFloat shadowViewY = segment.frame.origin.y + segment.frame.size.height - 2;
    switch(index){
        case 0: {
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0/4, shadowViewY, width0/2, 2);
            }];
        }
            [self.scrollView setContentOffset:CGPointMake(0, py)];
            break;
        case 1: {
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0+width1/4, shadowViewY, width1/2, 2);
            }];
        }
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, py)];
            //            [self.questionChatView becomeFirstResponder];
            break;
        case 2: {
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0 + width1+width2/4, shadowViewY, width2/2, 2);
            }];
        }
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 2, py)];
            break;
        case 3: {
            [UIView animateWithDuration:0.25 animations:^{
                self.shadowView.frame = CGRectMake(width0 + width1 + width2, shadowViewY, width3, 4);
            }];
        }
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 3, py)];
            break;
        default:
            break;
    }
}
#pragma mark - 懒加载
//创建聊天视图
-(CCChatBaseView *)chatView {
    if(!_chatView) {
        _chatView = [[CCChatBaseView alloc] initWithPublicChatBlock:^(NSString * _Nonnull msg){
        } isInput:NO];
        _chatView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _chatView;
}
//初始化数据处理
-(CCChatViewDataSourceManager *)manager{
    if (!_manager) {
        _manager = [CCChatViewDataSourceManager sharedManager];
        [_manager removeData];
        _manager.delegate = self;
    }
    return _manager;
}

//创建问答视图
-(CCQuestionView *)questionChatView {
    if(!_questionChatView) {
        _questionChatView = [[CCQuestionView alloc] initWithQuestionBlock:^(NSString *message) {
            
        } input:NO];
        _questionChatView.delegate = self;
        _questionChatView.backgroundColor =[UIColor grayColor];
    }
    return _questionChatView;
}
-(NSMutableDictionary *)QADic {
    if(!_QADic) {
        _QADic = [[NSMutableDictionary alloc] init];
    }
    return _QADic;
}

//存储已发布问答的回复关联标记
-(NSMutableDictionary *)QADicFlag {
   @synchronized (self) {
       if(!_QADicFlag) {
           _QADicFlag = [[NSMutableDictionary alloc] init];
       }
       return _QADicFlag;
   }
}
                   
-(NSMutableArray *)keysArrAll {
    if(!_keysArrAll) {
        _keysArrAll = [[NSMutableArray alloc] init];
    }
    return _keysArrAll;
}

- (NSMutableArray *)allQuestions
{
    if (!_allQuestions) {
        _allQuestions = [NSMutableArray array];
    }
    return _allQuestions;
}

- (NSMutableArray *)allAnswers
{
    if (!_allAnswers) {
        _allAnswers = [NSMutableArray array];
    }
    return _allAnswers;
}

//创建简介视图
-(CCIntroductionView *)introductionView {
    if(!_introductionView) {
        _introductionView = [[CCIntroductionView alloc] init];
        _introductionView.backgroundColor = CCRGBColor(250,250,250);
    }
    return _introductionView;
}
//创建聊天问答等功能选择
-(UISegmentedControl *)segment {
    if(!_segment) {
        NSArray *segmentedArray = [[NSArray alloc] initWithObjects:@"聊天",@"问答",@"简介", nil];
        _segment = [[UISegmentedControl alloc] initWithItems:segmentedArray];
        //文字设置
        NSMutableDictionary *attDicNormal = [NSMutableDictionary dictionary];
        attDicNormal[NSFontAttributeName] = [UIFont systemFontOfSize:FontSize_30];
        attDicNormal[NSForegroundColorAttributeName] = CCRGBColor(51,51,51);
        NSMutableDictionary *attDicSelected = [NSMutableDictionary dictionary];
        attDicSelected[NSFontAttributeName] = [UIFont systemFontOfSize:FontSize_30];
        attDicSelected[NSForegroundColorAttributeName] = CCRGBColor(51,51,51);
        [_segment setTitleTextAttributes:attDicNormal forState:UIControlStateNormal];
        [_segment setTitleTextAttributes:attDicSelected forState:UIControlStateSelected];
        _segment.selectedSegmentIndex = 0;
        _segment.backgroundColor = [UIColor whiteColor];
        
//        _segment.tintColor = [UIColor whiteColor];
        [_segment setBackgroundImage:[self imageWithColor:UIColor.whiteColor] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_segment setBackgroundImage:[self imageWithColor:UIColor.whiteColor] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [_segment setDividerImage:[self imageWithColor:UIColor.whiteColor] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        _segment.momentary = NO;
        [_segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _segment;
}
- (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}
-(UIView *)shadowView {
    if(!_shadowView) {
        _shadowView = [[UIView alloc] init];
        _shadowView.backgroundColor = CCRGBColor(255,102,51);
    }
    return _shadowView;
}
-(CCDocView *)docView{
    if (!_docView) {
        _docView = [[CCDocView alloc] initWithType:_isSmallDocView];
    }
    return _docView;
}
#pragma mark - CCChatDataSourceManager代理
//更新图片的位置
-(void)updateIndexPath:(NSIndexPath *)indexPath chatArr:(NSMutableArray *)chatArr{
    if ([self.chatView.publicChatArray count] == 0) {
        return;
    }
    if ([self.chatView.publicChatArray count] - 1 >= (long)indexPath.row) {
        id object = [chatArr objectAtIndex:indexPath.row];
        [self.chatView.publicChatArray replaceObjectAtIndex:indexPath.row withObject:object];
        [self.chatView reloadStatusWithIndexPath:indexPath publicArr:self.chatView.publicChatArray];
    }
}
#pragma mark - 移除数据(退出回放时调用)
-(void)removeData{
    if (_manager != nil) {
        [_manager removeData];
    }
}
@end
