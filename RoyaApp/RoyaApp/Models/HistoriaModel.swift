//
//  HistoriaModel.swift
//  RoyaApp
//
//  Created by Alumno on 11/09/25.
//

import Foundation

struct Historial: Codable, Identifiable {
    var id = UUID()              // default, no necesita ser pasado
    let date: String
    let images: [String]

    enum CodingKeys: String, CodingKey {
        case date
        case images
    }
}
