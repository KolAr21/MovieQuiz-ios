//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Арина Колганова on 26.08.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    static func < (now: GameRecord, new: GameRecord) -> Bool {
        return now.correct < new.correct
    }
}
