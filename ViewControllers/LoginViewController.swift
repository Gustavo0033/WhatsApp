//
//  LoginViewController.swift
//  WhatsApp
//
//  Created by Gustavo Mendonca on 10/05/23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var campoEmail: UITextField!
    
    @IBOutlet weak var campoSenha: UITextField!
    
    var handler: AuthStateDidChangeListenerHandle!
    
    var auth: Auth!
    
    
    
    @IBAction func btnEntrar(_ sender: Any) {
        
        if let emailEntrarR = self.campoEmail.text{
            if let senhaEntrarR = self.campoSenha.text{
                
                // autenticar
                let autenticacao = Auth.auth()
                autenticacao.signIn(withEmail: emailEntrarR, password: senhaEntrarR) { usuario, erro in
                    
                    if erro == nil{
                        
                        if usuario == nil{
                            
                            let alerta = Alerta(titulo: "Erro ao entrar", mensagem: "Erro ao entrar na conta, tente novamente")
                            self.present(alerta.getAlerta(), animated: true)
                            
                            
                        }else{
                            // mandando o user para a tela principal do app quando se logar
                            
                            self.performSegue(withIdentifier: "loginSegue", sender: nil)
                            
                        }
                        
                    }else{
                        let alerta = Alerta(titulo: "Usuário não encontrado", mensagem: "Reveja seus dados, usuário não encontrado")
                        self.present(alerta.getAlerta(), animated: true)
                    }
                }
                
            }
        }
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        handler = auth.addStateDidChangeListener{ autenticacao, usuario in
            if usuario != nil{
                self.performSegue(withIdentifier: "loginAutomatico", sender: nil)
            }
        }

       
        
    }
 
    
    override func viewWillDisappear(_ animated: Bool) {
        //auth.removeStateDidChangeListener(handler)
    }
    
    
   

    @IBAction func unwindToLogin(_ unwindSegue: UIStoryboardSegue) {
    }

}



