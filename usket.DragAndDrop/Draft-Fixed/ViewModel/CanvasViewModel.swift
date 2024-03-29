//
//  ViewModel.swift
//  usket.DragAndDrop
//
//  Created by Luxrobo on 2022/05/04.
//

import UIKit

enum MenuStatus {
    case open
    case closed
}

final class CanvasViewModel {
    
    static var status: MenuStatus = .open
    static var rate: CGFloat = 0
    static var included = [[Bool]](repeating: Array(repeating: false, count: 30),count: 12)
    
    var storedModules: [ModuleType : [Module]] = [:]
    var col: Int = 0
    var row: Int = 0

    func addModule(module: Module) -> Bool{
        
        if storedModules[module.type] == nil {
            storedModules[module.type] = [module]
            module.index = 0
            return true
        } else {
            if module.type.max <= storedModules[module.type]!.count {
                return false
            }
            storedModules[module.type]!.append(module)
            module.index = findIndex(module: module)
            return true
        }
    }
    
    func findIndex(module: Module) -> Int {
        
        var flag : Int = 0
        for index in 0 ... module.type.max - 1 {
            flag = 0
            for item in storedModules[module.type]! {
                if index == item.index {
                    flag += 1
                }
            }
            if flag == 0 {
                return index
            }
        }
        return 0
    }
    
    func removeModule(module: Module, index: Int){
        
        var position : Int = 0
        for item in storedModules[module.type]! {
            if item.index == index {
                storedModules[module.type]?.remove(at: position)
            }
            position += 1
        }
    }
    
    func setLocation(_ startPoint: (Int,Int),_ module: Module, parentVC: UIViewController) {
        
        var moduleVC = ModuleViewController(module: module)
        
        switch module.type {
        case .buttonModule:
            moduleVC = ButtonModuleViewContoller(module: module)
        case .sendModule:
            moduleVC = SendModuleViewContoller(module: module)
        case .dialModule:
            moduleVC = DialModuleViewContoller(module: module)
        case .timerModule:
            moduleVC = TimerModuleViewContoller(module: module)
        }
        
        addChildVC(parentVC, moduleVC, container: parentVC.view)
        
        moduleVC.view.frame = CGRect(x: CGFloat(startPoint.0) * CanvasViewModel.rate, y: CGFloat(startPoint.1) * CanvasViewModel.rate, width: module.type.size.width, height: module.type.size.height)
        
        setPosition(startPoint, module)
    }
    
    func checkPosition(_ start: (Int,Int), width: Int, height: Int) -> Bool {
        
        let xPoint = start.1
        let yPoint = start.0
        
        let xEndPoint = Int(CGFloat(width)/CanvasViewModel.rate)
        let yEndPoint = Int(CGFloat(height)/CanvasViewModel.rate)

        for y in yPoint...yPoint + yEndPoint{
            for x in xPoint...xPoint + xEndPoint{
                if y >= 12 || x >= 30 { return false }
                else if y < 0 || x < 0 { return false }
                if CanvasViewModel.included[y][x] {
                    return false
                }
            }
        }
        return true
    }
    
    func setPosition(_ startPoint: (Int,Int),_ module: Module){
        
        let xPoint = startPoint.0
        let yPoint = startPoint.1
        
        let xEndPoint = Int(module.type.size.width / CGFloat(CanvasViewModel.rate))
        let yEndPoint = Int(module.type.size.height / CGFloat(CanvasViewModel.rate))
        
        for y in yPoint...yPoint + yEndPoint {
            for x in xPoint ... xPoint + xEndPoint {
                if y >= 12 || x >= 30 {
                    return
                }
                CanvasViewModel.included[y][x] = true
            }
        }
    }
    
    func addChildVC(_ parentVC : UIViewController,_ childVC : UIViewController,container: UIView) {
        parentVC.addChild(childVC)
        childVC.view.frame = container.bounds
        container.addSubview(childVC.view)
        childVC.willMove(toParent: parentVC)
        childVC.didMove(toParent: parentVC)
    }
}

//MARK: - MainViewController
extension CanvasViewModel {

    func getGridPoint(_ xPosition: CGFloat,_ yPosition: CGFloat){
        let shadowX = Int(xPosition / CanvasViewModel.rate)
        let shadowY = Int(yPosition / CanvasViewModel.rate)
        
        col = Int(shadowX)
        row = Int(shadowY)
        
        if row < 0 { row = 0 }
        else if row >= 12 { row = 11 }
        else if col < 0 { col = 0 }
        else if col >= 30 { col = 29 }
    }
    
    func setShadow(location : CGPoint) -> CGRect{
        
        getGridPoint(location.x, location.y)
    
        return CGRect(x: CGFloat(col) * CanvasViewModel.rate, y: CGFloat(row) * CanvasViewModel.rate, width: Module.current.width, height: Module.current.height)
    }
    
    func setShadowColor() -> UIColor{
        if checkPosition((row,col), width: Int(Module.current.width), height: Int(Module.current.height)) {
            return UIColor.black.withAlphaComponent(0.35)
        } else {
            return UIColor.red.withAlphaComponent(0.35)
        }
    }
    
    func dropModule(location: CGPoint, module: Module, parentVC: UIViewController){
        getGridPoint(location.x, location.y)
        
        if module.index == nil {
            if addModule(module: module) {
                self.setLocation((col, row), module, parentVC: parentVC)
                module.startPoint = CGPoint(x: col, y: row)
            } else {
                parentVC.view.superview?.findViewController()?.alert(message: "중복 불가능한 모듈입니다.", title: "중복 불가")
            }
        } else {
            self.setLocation((col, row), module, parentVC: parentVC)
            module.startPoint = CGPoint(x: col, y: row)
        }
    }
}
