import UIKit

//ShadowColor -> 적용안될시에는 RED

enum MenuStatus {
    case open
    case closed
}

final class CanvasViewController: UIViewController {
    
    //Sidemenu, Menu Status
    private let backgroundGrid = CanvasView(frame: .zero)
    private let sideMenu = SideMenu()
    private let openButton = UIButton()
    private var status: MenuStatus = .open
    private var currentType: CustomModuleType = .button
    
    //Item into Grid
    private let shadowView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    // delegate + addtarget(openButton)
    private func setUp(){
        
        view.addInteraction(UIDragInteraction(delegate: self))
        view.addInteraction(UIDropInteraction(delegate: self))
        
        view.addSubview(backgroundGrid)
        view.addSubview(sideMenu)
        view.addSubview(openButton)
        
        backgroundGrid.isUserInteractionEnabled = true
        backgroundGrid.frame = CGRect(x: UIScreen.main.bounds.midX - 352, y: UIScreen.main.bounds.midY - 118, width: 704, height: 272)
        
        openButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        openButton.addTarget(self, action: #selector(changeImage), for: .touchUpInside)
        openButton.frame = CGRect(x: view.frame.maxX - 155, y: 0, width: 55, height: 55)
        sideMenu.frame = CGRect(x: view.frame.maxX - 100, y: 0, width: 100, height: view.frame.height)
        
        openButton.backgroundColor = .white
        openButton.layer.cornerRadius = 10
        openButton.tintColor = .black
        openButton.setTitleColor(.black, for: .normal)
    }
    
    @objc
    private func changeImage(){
        animateView(status: status)
        status = status == .open ? .closed : .open
    }
    
    private func animateView(status: MenuStatus) {
        switch status {
        case .open:
            // 닫기
            UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
                self.openButton.imageView?.image == UIImage(systemName: "arrow.right") ? self.openButton.setImage(UIImage(systemName: "arrow.left"), for: .normal) : self.openButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
                
                self.sideMenu.frame = CGRect(x: self.view.frame.maxX, y: 0, width: 0, height: self.view.frame.height)
                self.openButton.frame = CGRect(x: self.view.frame.maxX - 55, y: 0, width: 55, height: 55)
            }, completion: { completed in
                
            })
        case .closed:
            // 열기
            UIView.animate(withDuration: 0.5    , delay: 0.1, options: .curveEaseInOut, animations: {
                self.openButton.imageView?.image == UIImage(systemName: "arrow.right") ? self.openButton.setImage(UIImage(systemName: "arrow.left"), for: .normal) : self.openButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
                
                self.sideMenu.frame = CGRect(x: self.view.frame.maxX - 100, y: 0, width: 100, height: self.view.frame.height)
                self.openButton.frame = CGRect(x: self.view.frame.maxX - 155, y: 0, width: 55, height: 55)
            }, completion: { completed in
                print(completed)
            })
        }
    }
}
extension CanvasViewController: UIDragInteractionDelegate {
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        print(#function)
        
        let location = session.location(in: view)
        let moduleView = view.hitTest(location, with: nil)
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        
        return [dragItem]
    }

    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        print(#function)
        
        let target = UIDragPreviewTarget(container: interaction.view!, center: session.location(in: interaction.view!))
        
        return UITargetedDragPreview(view: makePreviewImage() , parameters: UIDragPreviewParameters(), target: target)
    }
    
    func makePreviewImage() -> UIImageView {
        print(#function)
        let dragImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SideMenu.sizeOfItem.width, height: SideMenu.sizeOfItem.height))
        let dragImage = UIImage(named: "\(SideMenu.kindOfModule).png")
        dragImageView.image = dragImage
        return dragImageView
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, sessionDidMove session: UIDragSession) {
        print(#function)
    }
    
    func getShadowPosition(_ xPosition: CGFloat,_ yPosition: CGFloat) -> CGPoint {
        let shadowX = Int(xPosition / 24) * 24
        let shadowY = Int(yPosition / 24) * 24
        
        return CGPoint(x: shadowX, y: shadowY)
    }
}
extension CanvasViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        print(#function)
        return session.canLoadObjects(ofClass: CustomModule.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        print(#function)
        
        let locationPoint = session.location(in: backgroundGrid)
        backgroundGrid.addSubview(shadowView)
        shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let points = self.getShadowPosition(locationPoint.x, locationPoint.y)
            var col = Int(points.x / 24)
            var row = Int(points.y / 24)
            
            if row < 0 { row = 0 }
            else if col < 0 { col = 0 }
            
            if self.backgroundGrid.checkPosition((row,col), width: 128, height: 128) {
                // 새로운 위치에 그림자 넣어줘야함
                
                // x포지션의 이동으로 가능한경우 함수로 가능한 포인트 찾아서 반환 + setFrame
                
                // y포지션의 이동으로 가능한 경우 함수로 가능한 포인트 찾아서 반환 + setFrame
                
                // x,y 둘다 변경하면서 찾아야하는 경우 함수로 찾고 반환 + setFrame
                
            } else {
                print(SideMenu.sizeOfItem)
                self.shadowView.frame = CGRect(x: points.x, y: points.y, width: SideMenu.sizeOfItem.width, height: SideMenu.sizeOfItem.height)
                self.shadowView.layer.cornerRadius = 10
            }
        }
        
        if self.sideMenu.tableView.hasActiveDrag {
            if shadowView.frame.minX < 0 || shadowView.frame.maxX > backgroundGrid.frame.width {
                DispatchQueue.main.async {
                    self.shadowView.removeFromSuperview()
                }
                return UIDropProposal(operation: .cancel)
            } else if shadowView.frame.minY < 0 || shadowView.frame.maxY > backgroundGrid.frame.height {
                DispatchQueue.main.async {
                    self.shadowView.removeFromSuperview()
                }
                return UIDropProposal(operation: .cancel)
            }
            return UIDropProposal(operation: .copy)
        } else {
            if shadowView.frame.minX < 0 || shadowView.frame.maxX > backgroundGrid.frame.width {
                DispatchQueue.main.async {
                    self.shadowView.removeFromSuperview()
                }
                return UIDropProposal(operation: .cancel)
            } else if shadowView.frame.minY < 0 || shadowView.frame.maxY > backgroundGrid.frame.height {
                DispatchQueue.main.async {
                    self.shadowView.removeFromSuperview()
                }
                return UIDropProposal(operation: .cancel)
            }
            return UIDropProposal(operation: .move)
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        print(#function)
        
        self.shadowView.removeFromSuperview()
        
        session.loadObjects(ofClass: CustomModule.self) { item in
            
            guard let customModule = item.first as? CustomModule else {
                return
            }
            
            DispatchQueue.main.async {
                let points = self.getShadowPosition(self.shadowView.frame.minX, self.shadowView.frame.minY)
                self.backgroundGrid.setLocation((Int(points.x) / 24, Int(points.y) / 24), customModule.type)
            }
        }
    }
}
