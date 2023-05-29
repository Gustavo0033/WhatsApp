//
//  MensagensTableViewCell.swift
//  WhatsApp
//
//  Created by Gustavo Mendonca on 16/05/23.
//

import UIKit

class MensagensTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var  mensagemDireta: UILabel!
    @IBOutlet weak var mensagemEsquerda: UILabel!
    
   
    
    @IBOutlet weak var imagemDireita: UIImageView!
    @IBOutlet weak var imagemEsquerda: UIImageView!
    
    
   
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
