//
//  NerdzOverlapScrollController.swift
//  ScrollContent
//
//  Created by new user on 29.06.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import UIKit

final class PassthroughScrollView: UIScrollView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}

public class NerdzOverlapScrollController: UIViewController {
    public enum ScrollingBehavior {
        case `static`
        case scaleOnBounce
    }
    
    public enum HeightType {
        case constant(CGFloat)
        case proportion(CGFloat)
        
        public func relativeValue(to innerValue: CGFloat) -> CGFloat {
            switch self {
            case .constant(let value):
                return value
                
            case .proportion(let value):
                return value * innerValue
            }
        }
    }
    
    public var scrollingBehavior: ScrollingBehavior = .static {
        didSet {
            resetChangableConstraints()
        }
    }
    
    public var topViewHeight: HeightType = .constant(0) {
        didSet {
            resetChangableConstraints()
        }
    }
    
    public var overlapHeight: HeightType = .constant(0) {
        didSet {
            resetChangableConstraints()
        }
    }
    
    public let topView: UIView
    public let contentView: UIView
    
    public let scrollView: UIScrollView = PassthroughScrollView()
    public let bottomBouncingView = UIView()
    
    private var changableConstraints: [NSLayoutConstraint] = []
    
    public init(topView: UIView, contentView: UIView) {
        self.topView = topView
        self.contentView = contentView
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        
        reloadContent()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateTopScrollInset()
        resetChangableConstraints()
    }
    
    private func reloadContent() {
        
        view.addSubview(topView)
        view.addSubview(bottomBouncingView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBouncingView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        topView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        bottomBouncingView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomBouncingView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomBouncingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomBouncingView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        let constraint = bottomBouncingView.topAnchor.constraint(equalTo: contentView.bottomAnchor)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        
        resetChangableConstraints()
    }
    
    private func updateTopScrollInset() {
        let topViewHeight = self.topViewHeight.relativeValue(to: view.bounds.width)
        let topInset = topViewHeight - overlapHeight.relativeValue(to: topViewHeight)
        
        scrollView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    }
    
    private func resetChangableConstraints() {
        for constraint in changableConstraints {
            constraint.isActive = false
        }
        
        let height = topViewHeight.relativeValue(to: view.bounds.width)
        
        if scrollingBehavior == .static {
            changableConstraints = [
                topView.widthAnchor.constraint(equalTo: view.widthAnchor),
                topView.heightAnchor.constraint(equalToConstant: height)
            ]
        }
        else if scrollingBehavior == .scaleOnBounce {
            changableConstraints = [
                topView.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor),
                topView.heightAnchor.constraint(equalTo: topView.widthAnchor, multiplier: topViewHeight.relativeValue(to: view.bounds.width) / view.bounds.height),
                topView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: overlapHeight.relativeValue(to: height))
            ]
        }
        
        for constraint in changableConstraints {
            constraint.isActive = true
        }
    }
}



