//
//  PhotoModel.swift
//  RoyaApp
//
//  Created by Alumno on 11/09/25.
//

import Foundation

class Photo {
    var id = UUID()
    var etapa : String
    var img : String
    var date : Date?
    var comentario : String?
    
    
    init(etapa: String, img: String) {
        self.etapa = etapa
        self.img = img
    }
}
