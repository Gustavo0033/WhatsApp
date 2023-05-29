//
//  AjustesViewController.swift
//  WhatsApp
//
//  Created by Gustavo Mendonca on 11/05/23.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseStorageUI




class AjustesViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var imagemPerfil: UIImageView!
    
    
    
    var auth: Auth!
    var storage: Storage!
    var imagePicker = UIImagePickerController()
    var  idImage = NSUUID().uuidString
    var idUsuario: String!
    var firestore: Firestore!
    
    @IBAction func deslogar(_ sender: Any) {
        
        do {
            try auth.signOut()
        } catch {
            print("erro ao deslogar")
        }
    }
    
    
    //escolhendo imagem do perfil do usuario
    @IBAction func escolherImagem(_ sender: Any) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let imagemRecuperada = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        self.imagemPerfil.image = imagemRecuperada
        imagePicker.dismiss(animated: true)
        
        
        // upload da imagem no firebase
        let imagens = storage.reference().child("Imagens")
        
        
        // configurando image pro upload
        if let imagemUpload = imagemRecuperada.jpegData(compressionQuality: 0.5){
            
            
            let imagemPerfilRef =  imagens.child("Perfil").child("\(self.idImage).jpg")
            imagemPerfilRef.putData(imagemUpload) { metaData, erro in
                if erro == nil{
                    
                    imagemPerfilRef.downloadURL { url, erro in
                        
                        if let urlImagem = url?.absoluteString{
                            self.firestore
                                .collection("usuarios").document(self.idUsuario).updateData(["urlImage": urlImagem])
                        }
                        
                    }
                    print("sucesso ao fazer o upload")
                }else{
                    print("erro ao fazer o upload")
                }
            }
        }
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()
        
        
        //configurando o image picker
        imagePicker.delegate = self
        
        
        if let id = auth.currentUser?.uid{
            self.idUsuario = id
        }
        recuperarDadosUsuario()
        
        
    }
    
    
    
    func recuperarDadosUsuario(){
        
        let usuariosRef = self.firestore.collection("usuarios").document(self.idUsuario)
        
        
        usuariosRef.getDocument { snapshot, erro in
            
            if let dados = snapshot?.data(){
                
                
                let nomeUsuario = dados["Nome"] as? String
                let emailUsuario = dados["Email"] as? String
                
                
                self.nome.text = nomeUsuario
                self.email.text = emailUsuario
                
                
                if let urlImagem = dados["urlImage"] as? String{
                    
                    self.imagemPerfil.sd_setImage(with: URL(string: urlImagem))
                    
                }
                
                
            }
            
            
            
        }
        
        
    }


}
