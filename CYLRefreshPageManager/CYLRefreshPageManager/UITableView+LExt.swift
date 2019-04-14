//
//  UIKitExtensions
//  Nice_swift
//
//  Created by L on 2017/10/13.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import MJRefresh

public class CYLRefreshPageManager {
    
    public static let share = CYLRefreshPageManager()
    //配置默认起始页
    public var first_page: Int = 1;
    
}

public enum LRefreshStatus {
    case none
    case success
    case noMoreData
    case error
}

public typealias LRefreshActionType = ((_ page: Int) -> Void)?

public typealias LRefreshResult<T> = ((_ dataSource: [T], _ status: LRefreshStatus) -> Void)?

public protocol LRefresh {
    ///首页
    var l_first_page: Int {get set}
    ///页码
    var l_page: Int {get set}
    ///记录失败时页数
    var l_lastPage: Int {get set}
    
    //    var mj_header: MJRefreshHeader! {get set}
    //    var mj_footer: MJRefreshFooter! {get set}
    
    ///数据刷新方法
    func reloadData()
    
    /// 头尾刷新时调用
    var refreshAction: LRefreshActionType {get set}
    
    /// 设置刷新头和尾
    ///
    /// - Parameters:
    ///   - header: 下拉刷新block
    ///   - headerType: 刷新头类型
    ///   - footer: 上拉刷新block
    ///   - footerType: 刷新尾类型
    mutating func setRefresh(header: ((_ page: Int) -> Void)?, headerType: MJRefreshHeader.Type, footer: ((_ page: Int) -> Void)?, footerType: MJRefreshFooter.Type)
    
    mutating func setRefresh(header: ((_ page: Int) -> Void)?, headerType: MJRefreshHeader.Type)
    
    mutating func setRefresh(footer: ((_ page: Int) -> Void)?, footerType: MJRefreshFooter.Type)
    
    func footerHasmore(_ hasmore: Bool)
    
    ///刷新成功
    mutating func refreshSuccess()
    ///刷新失败
    mutating func refreshError()
    
    /// 自动管理刷新
    ///
    /// - Parameters:
    ///   - dataSource: 数据源数组
    ///   - hasmore: 是否更多
    ///   - newData: 新数据
    ///   - result: 数据源处理结果 通常需要 self.dataSource = dataSource
    mutating func refresh <T>(dataSource: [T]?, hasmore: Bool, newData: [T]?, result: LRefreshResult<T>)
}

///LRefresh RuntimeKey
private struct AssociatedKeys {
    static var page: Void?
    static var lastPage: Void?
    static var firstPage: Void?
    static var refreshAction: Void?
}

public extension LRefresh where Self: UIScrollView {
    
    
    var l_first_page: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.firstPage) as? Int ?? CYLRefreshPageManager.share.first_page
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.firstPage, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    ///页码
    var l_page: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.page) as? Int ?? self.l_first_page
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.page, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    ///记录失败时页数
    var l_lastPage: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.lastPage) as? Int ?? 1
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.lastPage, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 头尾刷新时调用
    var refreshAction: LRefreshActionType {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.refreshAction) as? LRefreshActionType ?? { _ in}
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.refreshAction, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    /// 设置刷新头和尾
    ///
    /// - Parameters:
    ///   - header: 下拉刷新block
    ///   - headerType: 刷新头类型
    ///   - footer: 上拉刷新block
    ///   - footerType: 刷新尾类型
    mutating func setRefresh(header: ((Int) -> Void)?, headerType: MJRefreshHeader.Type = MJRefreshNormalHeader.self, footer: ((Int) -> Void)?, footerType: MJRefreshFooter.Type = MJRefreshAutoNormalFooter.self) {
        self.setRefresh(header: header, headerType: headerType)
        self.setRefresh(footer: footer, footerType: footerType)
    }
    
    mutating func setRefresh(header: ((_ page: Int) -> Void)?, headerType: MJRefreshHeader.Type) {
        if let header = header {
            self.mj_header = headerType.init(refreshingBlock: { [weak self] in
                guard var weakSelf = self else {
                    return
                }
                weakSelf.l_page = weakSelf.l_first_page
                header(weakSelf.l_page)
                if let refreshAction = weakSelf.refreshAction {
                    refreshAction(weakSelf.l_page)
                }
            })
        }
    }
    
    mutating func setRefresh(footer: ((_ page: Int) -> Void)?, footerType: MJRefreshFooter.Type) {
        if let footer = footer {
            self.mj_footer = footerType.init(refreshingBlock: { [weak self] in
                guard var weakSelf = self else {
                    return
                }
                weakSelf.l_page += 1
                footer(weakSelf.l_page)
                if let refreshAction = weakSelf.refreshAction {
                    refreshAction(weakSelf.l_page)
                }
            })
            self.mj_footer.isAutomaticallyChangeAlpha = true
        }
    }
    
    
    ///更多数据
    func footerHasmore(_ hasmore: Bool) {
        guard self.mj_footer != nil else {
            return
        }
        if hasmore {
            self.mj_footer.resetNoMoreData()
        } else {
            self.mj_footer.endRefreshingWithNoMoreData()
        }
    }
    ///刷新成功
    mutating func refreshSuccess() {
        if self.l_page == CYLRefreshPageManager.share.first_page {
            if self.mj_header != nil {
                self.mj_header.endRefreshing()
            }
        } else {
            if self.mj_footer != nil {
                self.mj_footer.endRefreshing()
            }
        }
        self.l_lastPage = self.l_page
        self.reloadData()
    }
    ///刷新失败
    mutating func refreshError() {
        if self.mj_header != nil {
            self.mj_header.endRefreshing()
        }
        if self.mj_footer != nil {
            self.mj_footer.endRefreshing()
        }
        if self.l_page == self.l_first_page {
            self.l_page = self.l_first_page
        } else {
            self.l_page = self.l_lastPage
        }
        self.l_lastPage = self.l_page
        self.reloadData()
    }
    
    ///自动管理刷新
    mutating func refresh <T>(dataSource: [T]?, hasmore: Bool, newData: [T]?, result: LRefreshResult<T>) {
        guard var dataSource = dataSource else {
            result?([T](), .error)
            self.refreshError()
            return
        }
        
        if self.l_page == self.l_first_page {
            dataSource.removeAll()
        }
        
        guard let newData = newData else {
            result?(dataSource, .error)
            self.refreshError()
            return
        }
        dataSource += newData
        result?(dataSource, hasmore ? .success : .noMoreData)
        self.refreshSuccess()
        self.footerHasmore(hasmore)
    }
    
}

extension UITableView: LRefresh {}
extension UICollectionView: LRefresh {}

