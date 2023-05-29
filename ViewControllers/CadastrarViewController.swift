//
//  CadastrarViewController.swift
//  WhatsApp
//
//  Created by Gustavo Mendonca on 10/05/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

class CadastrarViewController: UIViewController {
    
    
    
    @IBOutlet weak var campoNome: UITextField!
    
    
    @IBOutlet weak var campoEmail: UITextField!
    
    @IBOutlet weak var campoSenha: UITextField!
    
    @IBOutlet weak var confirmarSenha: UITextField!
    
    var firestore: Firestore!
    
    
    
    @IBAction func btnCadastrar(_ sender: Any) {
        
        if let nomeR = self.campoNome.text{
            if let emailR = self.campoEmail.text{
                if let senhaR = self.campoSenha.text{
                    if let confirmarSenha = self.confirmarSenha.text{
                        
                        
                        // validar nome
                        if nomeR != ""{
                            
                            if senhaR == confirmarSenha{
                                
                                
                                //criar a conta do usuario
                                
                                let autenticado = Auth.auth()
                                autenticado.createUser(withEmail: emailR, password: senhaR) {dadosResultado, error in
                                    if error == nil{
                                        
                                        // salvar dados do user no firebase
                                        if let idUsuario = dadosResultado?.user.uid{
                                            self.firestore.collection("usuarios").document(idUsuario).setData(["Nome": nomeR, "Email": emailR, "id":idUsuario])
                                            
                                        }
                                        
                                        
                                        
                                        if dadosResultado == nil{
                                            
                                            let alerta = Alerta(titulo: "Erro ao autenticar", mensagem: "Problema ao realizar a aunteticação, tente novamente.")
                                            self.present(alerta.getAlerta(),animated: true)
                                        }else{
                                            // salvar os dados do user no firebase
                                            let database = Database.database().reference()
                                            let usuarios = database.child("Usuarios")
                                            
                                            let usuariosDados = ["Nome": nomeR, "Email": emailR]
                                            usuarios.child(dadosResultado!.user.uid).setValue(usuariosDados)
                                            
                                            self.performSegue(withIdentifier: "cadastroLogin", sender: nil)
                                        }
                                    }else{
                                        
                                        let alertaContaErro = Alerta(titulo: "Reveja seus dados", mensagem: "Alguns dados estão incorretos")
                                        
                                        self.present(alertaContaErro.getAlerta(), animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }


}
