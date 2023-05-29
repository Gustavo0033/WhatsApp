//
//  Alerta.swift
//  WhatsApp
//
//  Created by Gustavo Mendonca on 10/05/23.
//

import UIKit

class Alerta{
    var titulo: String
    var mensagem: String
    init(titulo: String, mensagem: String) {
        self.titulo = titulo
        self.mensagem = mensagem
    }
    
    func getAlerta() -> UIAlertController{
        
        
        let alerta = UIAlertController(title: titulo, message: mensagem, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel)
        
        
        alerta.addAction(ok)
        return alerta
        
    }
}
