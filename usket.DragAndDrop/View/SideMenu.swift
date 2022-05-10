//
//  SideMenu.swift
//  usket.DragAndDrop
//
//  Created by Luxrobo on 2022/04/27.
//

import UIKit
import SnapKit

final class SideMenu: UIView {

    static var sizeOfItem = ModuleSize(0, 0)
    
    var tableView = UITableView()
    let viewModel = ViewModel()
    var moduleList = [Module(type: .buttonModule), Module(type: .dialModule), Module(type: .sendModule), Module(type: .timerModule)]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setConfig()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        addSubview(tableView)
    }
    
    private func setConfig() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SideMenuTableViewCell.self, forCellReuseIdentifier: SideMenuTableViewCell.identifier)
        
        tableView.dragDelegate = self
        // Drop: Module -> TableView -> Delete Module
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.separatorStyle = .none
    }
    
    private func setConstraints(){
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
extension SideMenu: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moduleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuTableViewCell.identifier, for: indexPath) as? SideMenuTableViewCell else {
            return UITableViewCell()
        }
        
        cell.initialModule(moduleType: moduleList[indexPath.row].type)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
extension SideMenu: UITableViewDragDelegate,UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        print(#function)
        
        let module = moduleList[indexPath.row]
        let index = viewModel.getModuleIndex(module: module)
        module.setIndex(index: index)
        
        let provider = NSItemProvider(object: module)
        let dragItem = UIDragItem(itemProvider: provider)
        let preview = UIImageView(image: UIImage(named: module.type.rawValue))
        
        switch module.type {
        case .buttonModule:
            SideMenu.sizeOfItem = ModuleSize(128, 128)
        case .sendModule:
            SideMenu.sizeOfItem = ModuleSize(272, 176)
        case .dialModule:
            SideMenu.sizeOfItem = ModuleSize(128, 128)
        case .timerModule:
            SideMenu.sizeOfItem = ModuleSize(128,224)
        }
    
        dragItem.previewProvider = {
          return UIDragPreview(view: preview)
        }
        
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        print(#function)
        return session.canLoadObjects(ofClass: Module.self)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        print(#function)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        print(#function)
        return UITableViewDropProposal(operation: .cancel)
    }
}
