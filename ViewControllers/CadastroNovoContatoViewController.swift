//
//  CadastroNovoContatoViewController.swift
//  WhatsApp
//
//  Created by Gustavo Mendonca on 15/05/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class CadastroNovoContatoViewController: UIViewController {
    
    
        
    @IBOutlet weak var campoEmail: UITextField!
    @IBOutlet weak var mensagemErro: UILabel!
    
    var idUsuarioLogado: String!
    var emailUsuarioLogado: String!
    
    var db: Firestore!
    var auth: Auth!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        auth = Auth.auth()
        db = Firestore.firestore()
        
        //recuperar o id do usuario
        if let currentUser = auth.currentUser{
            self.idUsuarioLogado = currentUser.uid
            self.emailUsuarioLogado = currentUser.email
            
        }
      }
    
    
    
    @IBAction func adicionarContato(_ sender: Any) {
        
        if let emailDigitado = campoEmail.text {
            if emailDigitado == self.emailUsuarioLogado{
                
                mensagemErro.isHidden = false
                mensagemErro.text = "Você está adicionando seu próprio email"
                
                return
            }
            
            
            // verificar se o usuario existe no firebase
            
            db.collection("usuarios")
                .whereField("Email", isEqualTo: emailDigitado).getDocuments { snapshotResultado, erro in
                    
                    if let totalItens = snapshotResultado?.count{
                        
                        if totalItens == 0{
                            self.mensagemErro.text = "Usuario nao cadastrado"
                            self.mensagemErro.isHidden = false
                            return
                        }
                    }
                    
                    // salvar contato
                    
                    if let snapshot = snapshotResultado{
                        for document in snapshot.documents{
                            let dados = document.data()
                            
                            self.salvarContato(dadosContato: dados )
                            
                            
                            
                        }
                    }
                }
        }
        }
        
    func salvarContato(dadosContato: Dictionary<String, Any>){
        
        if let idUsuarioContato = dadosContato["id"]{
            db.collection("usuarios")
                .document(idUsuarioLogado)
                .collection("contatos")
                .document(String(describing: idUsuarioContato))
                .setData(dadosContato) { erro in
                    if erro == nil{
                        self.navigationController?.popViewController(animated: true)
                    }
                }
        }
   
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}
