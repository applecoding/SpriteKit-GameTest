//
//  Helper.swift
//  GameTest
//
//  Created by Julio César Fernández Muñoz on 6/1/21.
//

import SpriteKit
import GameplayKit

enum EstadoAventurera {
    case quieta, ataca, salta, corre
}

struct Cuerpos {
    static let nada:UInt32 = 0
    static let aventurera:UInt32 = 0b1
    static let zombie:UInt32 = 0b10
    static let todo:UInt32 = .max
}
