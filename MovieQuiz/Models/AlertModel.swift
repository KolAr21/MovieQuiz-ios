//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Арина Колганова on 26.08.2023.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> ()
}
