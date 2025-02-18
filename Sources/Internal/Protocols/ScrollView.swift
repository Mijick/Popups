//
//  ScrollView.swift
//  MijickPopupView
//
//  Created by 大江山岚 on 2025/2/18.
//

import UIKit

public protocol MijickScrollViewGesture: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
}

public extension MijickScrollViewGesture {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y < 0 {
            scrollView.setContentOffset(.zero, animated: false)
            if scrollView.contentOffset.y <= 0 {
                if PopupManager.shared.enable != true {
                    PopupManager.shared.enable = true
                }
            }
        } else {
            if PopupManager.shared.enable == true && PopupManager.shared.continueMove == true {
                scrollView.setContentOffset(.zero, animated: false)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if PopupManager.shared.enable != true {
            PopupManager.shared.enable = true
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            if PopupManager.shared.enable != false {
                PopupManager.shared.enable = false
            }
        }
    }
}
