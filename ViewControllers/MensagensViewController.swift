//
//  MensagensViewController.swift
//  WhatsApp
//
//  Created by Gustavo Mendonca on 16/05/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class MensagensViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    
    
    
    @IBOutlet weak var tableViewMensagens: UITableView!
    
  
    

    @IBOutlet weak var mensagemCampo: UITextField!
    
    
    
    
    
    
    var listaMensagem: [Dictionary<String, Any>]! = []
    var auth: Auth!
    var db: Firestore!
    var idUsuarioLogado: String!
    var contato : Dictionary<String, Any>!
    var mensagemListener : ListenerRegistration!
    var storage: Storage!
    var imagePicker = UIImagePickerController()
    var nomeContato: String!
    var urlFotoContato : String!
    var nomeUsuarioLogado: String!
    var urlFotoUsuarioLogado : String!
    
    
    
    
    func recuperarDadosUsuarioLogado(){
        
        
        
        let usuarios = db.collection("usuarios")
            .document(idUsuarioLogado)
            
        
        usuarios.getDocument { documentSnapshot, erro in
            if erro == nil{
                if let dados = documentSnapshot?.data(){
                    if let url = dados["urlImage"] as? String{
                        if let nome = dados["Nome"] as? String{
                            self.urlFotoUsuarioLogado = url
                            self.nomeUsuarioLogado = nome
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func enviarMensagem(_ sender: Any) {
        
        if let textoDigitado = mensagemCampo.text{
            if !textoDigitado.isEmpty{
                if let idUSuarioDestinatario = contato["id"] as? String{
                    
                    
                    let mensagem : Dictionary<String, Any> =  [
                        "idUsuario" : idUsuarioLogado!,
                        "texto" : textoDigitado,
                        "data" : FieldValue.serverTimestamp()
                    ]
                    salvarMensagem(idRemente: idUsuarioLogado, idDestinatario: idUSuarioDestinatario, mensagem: mensagem) // recuperando mensagem de um user pro outro
                    salvarMensagem(idRemente: idUSuarioDestinatario, idDestinatario: idUsuarioLogado, mensagem: mensagem)// recuperando mensagem de um user pro outro
                    
                    
                
                }
                
                
                
            }
        }
        
    }
  
   
    
    
    func salvarConversa(idRemetente: String, idDestinatario: String, conversa: Dictionary<String, Any>) {
        db.collection("conversas")
            .document(idRemetente)
            .collection("ultimas_conversas")
            .document(idDestinatario)
            .setData(conversa)
    }
    
    
    func salvarMensagem(idRemente: String, idDestinatario: String, mensagem: Dictionary<String, Any>){
        db.collection("mensagens")
            .document(idRemente)
            .collection(idDestinatario).addDocument(data: mensagem)
        
        
        //limpar caixa de texto
        mensagemCampo.text = ""
    }
    
    
    
    
    @IBAction func enviarImagem(_ sender: Any) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
    }
    
    
   
    
    
    
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imagemRecuperada = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        
        
        
        let imagens = storage.reference().child("Imagens")
        if let imagemUpload = imagemRecuperada.jpegData(compressionQuality: 0.5){
            
            let indentificadorUnico = UUID().uuidString
            let nomeImagem = "\(indentificadorUnico).jpg"
            let imagemMensagemRef = imagens.child("mensagens").child(nomeImagem)
            
            imagemMensagemRef.putData(imagemUpload, metadata: nil) { metaDate, erro in
                if erro == nil{
                    print("Sucesso")
                    imagemMensagemRef.downloadURL { url, erro in
                        if let urlImagem = url?.absoluteString{
                            if let idUSuarioDestinatario = self.contato["id"] as? String{
                                
                                let mensagem: Dictionary<String, Any> = [
                                    "idUsuario": self.idUsuarioLogado!,
                                    "urlImagem": urlImagem,
                                    "data": FieldValue.serverTimestamp()
                                    
                                ]
                                
                                // salvando os dados de quem recebe a mensage
                                
                                self.salvarMensagem(idRemente: self.idUsuarioLogado, idDestinatario: idUSuarioDestinatario, mensagem: mensagem)
                                
                                // dados de quem enviar a mensagem
                                self.salvarMensagem(idRemente: idUSuarioDestinatario, idDestinatario: self.idUsuarioLogado, mensagem: mensagem)
                            }
                        }
                    }
                }else{
                    print("Erro")
                }
            }
        }
        
        
        
        
        imagePicker.dismiss(animated: true)
    }
    
    
    func addListenerRecuperarMensagem() {
        
      
        if let idDestinatario = contato["id"] as? String{
            mensagemListener = db.collection("mensagens")
                .document(idUsuarioLogado).collection(idDestinatario)
                .order(by: "data", descending: false)
                .addSnapshotListener { QuerySnapshot, erro in
                    
                    //limpar lista
                    self.listaMensagem.removeAll()
                    
                    
                    
                    if let snapshot = QuerySnapshot{
                        for document in snapshot.documents{
                            let dados = document.data()
                            self.listaMensagem.append(dados)
                        }
                        self.tableViewMensagens.reloadData()
                    }
                }
                
                
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        db = Firestore.firestore()
        storage = Storage.storage()
        imagePicker.delegate = self


        tableViewMensagens.separatorStyle = .none
        tableViewMensagens.backgroundView = UIImageView(image: UIImage(named: "bg"))
        
        // recuperar ID do usuario logado
        if let id = auth.currentUser?.uid{
            self.idUsuarioLogado = id
            recuperarDadosUsuarioLogado()
        }
        
        //confirar o titulo da tela
        if let nome = contato["Nome"] as? String{
            nomeContato = nome
            self.navigationItem.title = nomeContato
        }
        
        if let url = contato["urlImage"] as? String{
            urlFotoContato = url
            
        }
    }
    
    // escondendo a tab bar quando entrar na conversa
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        addListenerRecuperarMensagem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        mensagemListener.remove()
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celulaDireita = tableView.dequeueReusableCell(withIdentifier: "celulaMensagensDireita", for: indexPath ) as! MensagensTableViewCell
        let celulaEsquerda = tableView.dequeueReusableCell(withIdentifier: "celulaMensagensEsquerda", for: indexPath ) as! MensagensTableViewCell
        let celulaImagemDireita = tableView.dequeueReusableCell(withIdentifier: "celulaImagemDireita", for: indexPath ) as! MensagensTableViewCell
        let celulaImagemEsquerda = tableView.dequeueReusableCell(withIdentifier: "celulaImagemEsquerda", for: indexPath ) as! MensagensTableViewCell
        
        
        
        let indice = indexPath.row
        let dados = self.listaMensagem[indice]
        let texto = dados["texto"] as? String
        let idUsuario = dados["idUsuario"] as? String
        let urlImagem = dados["urlImagem"] as? String
        
        if idUsuarioLogado == idUsuario{
            if urlImagem != nil{
                celulaImagemDireita.imagemDireita.sd_setImage(with: URL(string: urlImagem!))
                return celulaImagemDireita
            }
            celulaDireita.mensagemDireta.text = texto
            return celulaDireita
            
        }else{
            
            if urlImagem != nil{
                celulaImagemEsquerda.imagemEsquerda.sd_setImage(with: URL(string: urlImagem!))
                return celulaImagemEsquerda
            }
            
            celulaEsquerda.mensagemEsquerda.text = texto
            return celulaEsquerda
        }
         
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaMensagem.count
    }
}
