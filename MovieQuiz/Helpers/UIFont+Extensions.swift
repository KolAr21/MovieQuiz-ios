//
//  UIFont+Extensions.swift
//  MovieQuiz
//
//  Created by Арина Колганова on 17.08.2023.
//

import UIKit

extension UIFont {
    static func medium(with fontSize: CGFloat) -> UIFont {
        UIFont(name: "YSDisplay-Medium", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: .medium)
    }
    static func bold(with fontSize: CGFloat) -> UIFont {
        UIFont(name: "YSDisplay-Bold", size: fontSize) ?? .boldSystemFont(ofSize: fontSize)
    }
}
