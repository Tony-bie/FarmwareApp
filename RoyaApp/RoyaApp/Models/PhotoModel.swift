//
//  PhotoModel.swift
//  RoyaApp
//
//  Created by Alumno on 11/09/25.
//

import Foundation

struct Photo: Codable, Identifiable {
    var id = UUID()
    var etapa: String
    var img_url: String
    var date: Date?
    var comentario: String?
    
    init(etapa: String, img_url: String, date: Date? = nil, comentario: String? = nil) {
        self.etapa = etapa
        self.img_url = img_url
        self.date = date
        self.comentario = comentario
    }
}
