# Live_iOS_Play_SDK-4.12.0
获得场景云直播SDK
## 在官方Demo的基础上改动内容如下：
- 去除pch文件内的所有引用，并将其引用添加到相应的头文件中。
- 视频加文档的直播形式改动，小窗播放改为底部交互区域展示文档或者视频，并兼容小窗模式。
- 移除关于全景视频VR相关的内容。
- 竖屏直播相关的内容不导入的目标项目。

## 导入到基于 Swift 创建的项目中
### 文件顺序错乱
Swift 项目中拖入很多OC的文件，.h和.m文件顺序乱了，这是一个很常见的问题，在使用Xcode进行混编时经常会遇到。其原因主要是 Xcode 并没有强制排序 .h 和 .m 文件。
下面有几种方法可以解决这个问题：
1. 人工拖动调整：在左侧的Project Navigator中，你可以手动拖动文件来排序。请记住展开每一个需要重新排序的文件夹并逐一调整它们的顺序。
2. 按类型排序: 点击Xcode左侧导航栏的"Sort by Name"选项（通过右键点击），再选择"Type"选项，可以实现按照类型对文件进行自动排序。
3. 命名规范：在创建文件的过程中保持良好的命名习惯和风格也可以帮助管理你的文件，例如用前缀来区分不同的功能模块。(例子: LoginViewController.h、LoginManager.m) 这样就算他们被乱序排序了，你也能迅速找到你正在寻找的文件。
推荐使用方案二，但即便如此还得手动排序内部所有的文件目录。

### 报错1
暂时不需要问卷调查功能
在 `XXX-Bridging-Header.h` 中注释掉 `#import "UIView+YYHCB_Extension.h"`
因为该类中实现了 `UIGestureRecognizerDelegate` 协议 `@interface UIView (YYHCB_KeyboardCover)<UIGestureRecognizerDelegate>` ，导入到目标项目中，有很多遵循该协议的类重复遵循该协议导致报错。

### 报错2
Swift 项目的 AppDelegate 修改，移除 `#import "AppDelegate.h"` ，导入 `#import "XXX-Swift.h` 即可

## Swift 和 OC 的相互调用
### OC 调用 Swift
将 `#import "CCLiveCloud-Swift.h` 改为要导入项目的 `#import "XXX-Swift.h` 
OC 调用 Swift 时，如访问不到类或者属性，需添加 `@objc`
### Swift 调用 OC
将 `CCLiveCloud-Bridging-Header.h` 所需引用，复制到要导入项目的 `XXX-Bridging-Header.h`


# Live_iOS_Play_SDK
CC视频云直播 iOS平台播放SDK和Demo

[iOS-升级文档SDK开发指南](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-升级文档SDK开发指南)

[iOS-直播回放SDK开发指南](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-直播回放SDK开发指南)

[iOS-直播离线回放SDK开发指南](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-直播离线回放SDK开发指南)

[iOS-直播观看SDK开发指南](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-直播观看SDK开发指南)

[iOS-合规指南---云直播](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-合规指南---云直播)

[iOS-观看端-4.0.0-SDK升级文档](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-观看端-4.0.0-SDK升级文档)

[iOS-云直播点赞功能接入文档](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-云直播点赞功能接入文档)

[iOS-云直播打赏功能接入文档](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-云直播打赏功能接入文档)

[iOS-云直播投票功能接入文档](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-云直播投票功能接入文档)

[iOS-云直播红包雨功能接入文档](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-云直播红包雨功能接入文档)

[iOS-云直播邀请卡功能接入文档](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-云直播邀请卡功能接入文档)

[iOS-云直播问卷功能接入文档](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-云直播问卷功能接入文档)

[iOS-云直播直播带货功能接入文档](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-云直播直播带货功能接入文档)

[iOS-VR接入文档](https://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK/-/wikis/iOS-VR功能接入文档)
