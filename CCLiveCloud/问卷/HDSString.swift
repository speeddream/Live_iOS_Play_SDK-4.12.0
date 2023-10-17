//
//  HDSString.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/5/5.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

extension String{
    
    /// 从某个位置开始截取：
    /// - Parameter index: 起始位置
    public func substring(from index: Int) -> String {
        if(self.count > index){
            let startIndex = self.index(self.startIndex,offsetBy: index)
            let subString = self[startIndex..<self.endIndex];
            return String(subString);
        }else{
            return ""
        }
    }
    
    /// 从零开始截取到某个位置：
    /// - Parameter index: 达到某个位置
    public func substring(to index: Int) -> String {
        if(self.count > index){
            let endindex = self.index(self.startIndex, offsetBy: index)
            let subString = self[self.startIndex..<endindex]
            return String(subString)
        }else{
            return self
        }
    }
    
    /// 某个范围内截取
    /// - Parameter rangs: 范围
    public func subString(rang rangs:NSRange) -> String{
        var string = String()
        if(rangs.location >= 0) && (self.count > (rangs.location + rangs.length)){
            let startIndex = self.index(self.startIndex,offsetBy: rangs.location)
            let endIndex = self.index(self.startIndex,offsetBy: (rangs.location + rangs.length))
            let subString = self[startIndex..<endIndex]
            string = String(subString)
        }
        return string
    }
}

