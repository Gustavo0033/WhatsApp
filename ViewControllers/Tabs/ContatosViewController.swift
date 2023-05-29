//
//  ContatosViewController.swift
//  WhatsApp
//
//  Created by Gustavo Mendonca on 15/05/23.
//

import UIKit
import FirebaseStorageUI
import FirebaseAuth
import FirebaseFirestore

class ContatosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    
    @IBOutlet weak var tableViewContatos: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var auth: Auth!
    var storage: Storage!
    var db: Firestore!
    var idUsuarioLogado: String!
    var listaContatos: [Dictionary<String, Any>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        db = Firestore.firestore()
        
        
        if let id = auth.currentUser?.uid{
            self.idUsuarioLogado = id
        }

        searchBar.delegate = self
        
        // retirando as linhas da tableview
        tableViewContatos.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        recuperarContato()
    }
    
    //metoda para recupar na search bar o que foi digitado, pega letra por letra
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            recuperarContato()
        }
    }
    
    //metodo para quando clicar para pesquisar, ira capturar so quando clicar em pesquisar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let textoResultado = searchBar.text{
            if textoResultado != ""{
                pesquisarContatos(texto: textoResultado)
            }
        }
    }
    
    // metodo responsavel por fazer a pesquisa
    func pesquisarContatos(texto: String){
        
        var listaFiltro: [Dictionary<String, Any>] = self.listaContatos
        
        self.listaContatos.removeAll()
        
        for item in listaFiltro{
            if let nome = item["Nome"] as? String {
                if nome.lowercased().contains(texto.lowercased()){
                    self.listaContatos.append(item)
                }
            }
        }
        self.tableViewContatos.reloadData()
        
    }
    
    // recuperando os dados dos contatos
    func recuperarContato(){
        
        self.listaContatos.removeAll()
        db.collection("usuarios")
            .document(idUsuarioLogado)
            .collection("contatos")
            .getDocuments { snapshotResultado, erro in
                if let snapshot = snapshotResultado{
                    for document in snapshot.documents{
                        let dadosContato = document.data()
                        self.listaContatos.append(dadosContato)
                    }
                    self.tableViewContatos.reloadData()
                }
            }
    }
    
// metodo para listagem na tabela
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       let totalContato = self.listaContatos.count
        
        if totalContato == 0{
            return 1
        }
        
        return totalContato
    }

    //listando os contatos na table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaContatos", for: indexPath) as! ContatoTableViewCell
        let totalContato = self.listaContatos.count
         
        
        celula.fotoContato.isHidden = false
        if self.listaContatos.count == 0{
            celula.textoNome.text = "Nenhum contato cadastrado"
            celula.textoEmail.text = ""
            celula.fotoContato.isHidden = true
            
             return celula
         }
        
        
        let indice = indexPath.row
        let dadosContato = self.listaContatos[indice]
        
        
        
        
        celula.textoNome.text = dadosContato["Nome"] as? String
        celula.textoEmail.text = dadosContato["Email"] as? String
        
        if let foto = dadosContato["urlImage"] as? String{
            celula.fotoContato.sd_setImage(with: URL(string: foto),completed: nil)
        }else{
            celula.fotoContato.image = UIImage(named: "person")
        }
        
        return celula

    }

    // abrir uma tela no table view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewContatos.deselectRow(at: indexPath, animated: true)
        
        let indice = indexPath.row
        let contato = self.listaContatos[indice]
        
        
        self.performSegue(withIdentifier: "inicarConversaContato", sender: contato)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "inicarConversaContato"{
            let viewDestino = segue.destination as! MensagensViewController
            viewDestino.contato = sender as? Dictionary
            
        }
    }
    
    
    
}
