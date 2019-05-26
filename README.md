# CYLRefreshPageManager
分页管理
使用 pod "CYLRefreshPageManager" 导入项目

tableView.setRefresh(header: { [weak self] page in
    [self  loadData]
}, footer: { [weak self] page in
    [self  loadData]
})

func loadData() {
    request(url, page: self.tableView.l_page, success: { _ result
        //...
    })
}
