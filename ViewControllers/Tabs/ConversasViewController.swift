//
//  ConversasViewController.swift
//  WhatsApp
//
//  Created by Gustavo Mendonca on 22/05/23.
//

import UIKit
import FirebaseStorageUI
import FirebaseAuth
import FirebaseFirestore

class ConversasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableViewConversas: UITableView!
    var listaConversas: [Dictionary<String, Any>] = []
    var conversasListener : ListenerRegistration!
    
    
    var auth: Auth!
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        db = Firestore.firestore()

        
        tableViewConversas.separatorStyle = .none // retirando as linhas da tableView
    }
    
    
    func addListenerConverasas() {
        if let idUsuario = auth.currentUser?.uid{
            conversasListener = db.collection("conversas")
                .document(idUsuario)
                .collection("ultimas_conversas")
                .addSnapshotListener { querSnapshot, erro in
                    if erro == nil{
                        
                        
                        self.listaConversas.removeAll()
                        if let snapshot = querSnapshot{
                            for document in snapshot.documents{
                                let dados = document.data()
                                self.listaConversas.append(dados)
                            }
                            self.tableViewConversas.reloadData()
                        }
                    }
                }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaConversa", for: indexPath) as! ConversasTableViewCell
        
        
        let indice = indexPath.row
        let dados = self.listaConversas[indice]
        let nome = dados["nomeUsuario"] as? String
        let ultimaMensagem = dados["ultimaMensagem"] as? String
        
        celula.nomeConversa.text = "Gustavo Mendonca"
        celula.ultimaConversa.text = "Responde ai"

        if let urlFotoUsuario = dados["urlFotoUsuario"] as? String{
            celula.fotoConversa.sd_setImage(with: URL(string: urlFotoUsuario))
        }else{
            celula.fotoConversa.image = UIImage(named: "person")
        }
        
         
        
        
        return celula
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addListenerConverasas()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        conversasListener.remove()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaConversas.count
    }
    
    


}
