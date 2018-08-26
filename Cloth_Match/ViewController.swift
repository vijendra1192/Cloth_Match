//
//  ViewController.swift
//  Cloth_Match
//
//  Created by Vijendra  on 22/08/18.
//  Copyright © 2018 Vijendra . All rights reserved.
//

import UIKit
import CoreData
import GameplayKit
import Photos
import PhotosUI
import AssetsLibrary


var supportPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

enum ImageSourceType {
    case imageCamera
    case imageGallery
};

struct Shirt {
    var fileImage : UIImage
    var uniqueFileName : String = ""
    
    init(fileName:String,image:UIImage) {
        fileImage = image
        uniqueFileName = fileName
    }
}


class ViewController: UIViewController,UINavigationControllerDelegate {
    
    //MARK: IBOutlet
    
    @IBOutlet weak var favouriteBtnOutlet: UIButton!
    @IBOutlet weak var addShirtOutlet: UIButton!
    @IBOutlet weak var shirtCollectionView: UICollectionView!
    @IBOutlet weak var shirtPageControl: UIPageControl!
    @IBOutlet weak var shirtFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var addTrouserOutlet: UIButton!
    @IBOutlet weak var trouserCollectionView: UICollectionView!
    @IBOutlet weak var trouserPageControl: UIPageControl!
    @IBOutlet weak var trouserFlowLayout: UICollectionViewFlowLayout!
    
    //MARK: Property
    var favouriteDataArr = [[String:String]]()
    var shirtArrayData : [Shirt] = []
    var trouserArrayData : [Shirt] = []
    var shirtStruct : Shirt!
    
    
    var isShirtType : Bool = true
    var sourceType : ImageSourceType?
    let imagePicker = UIImagePickerController()
    var result : [NSManagedObject]?
    
    // Create Context
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDelegate()
        isShirtType = false
        
        
        
        
        if let shirtImg = self.fetchImageData(entity: "ShirtImage")
        {
            if shirtImg.count > 0
            {
                for img in shirtImg
                {
                    shirtStruct = Shirt(fileName: img.value(forKey: "shirtImagePath") as! String, image: self.doesFileWithNameExist(fileName: img.value(forKey: "shirtImagePath")! as! String)!)
                    
                    shirtArrayData.append(shirtStruct)
                }
            }
        }
        if let trouserImg = self.fetchImageData(entity: "TrouserImage")
        {
            if trouserImg.count > 0
            {
                for img in trouserImg
                {
                    shirtStruct = Shirt(fileName: img.value(forKey: "trouserImagePath") as! String, image: self.doesFileWithNameExist(fileName: img.value(forKey: "trouserImagePath")! as! String)!)
                    
                    trouserArrayData.append(shirtStruct)
                }
            }
        }
        self.setPageContrller()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set Delegate
    func setDelegate() {
        
        shirtCollectionView.delegate = self
        shirtCollectionView.dataSource = self
        trouserCollectionView.delegate = self
        trouserCollectionView.dataSource = self
        imagePicker.delegate = self
        
    }
    //MARK: Set PageContrller
    func setPageContrller()  {
        shirtPageControl.currentPage = 0
        trouserPageControl.currentPage = 0
        shirtPageControl.numberOfPages = shirtArrayData.count
        trouserPageControl.numberOfPages = trouserArrayData.count
        self.reloadCollectioView()
    }
    
    func reloadCollectioView()  {
        shirtCollectionView.reloadData()
        trouserCollectionView.reloadData()
    }
    
    
    //MARK: Action
    @IBAction func addShirtPressed(_ sender: Any) {
        isShirtType = true
        alertController()
    }
    
    @IBAction func addTrouserPressed(_ sender: Any) {
        isShirtType = false
        alertController()
    }
    
    @IBAction func shufflePressed(_ sender: Any)
    {
        shirtArrayData = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: shirtArrayData) as! [Shirt]
        trouserArrayData = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: trouserArrayData) as! [Shirt]
        
        shirtPageControl.currentPage = 0
        trouserPageControl.currentPage = 0
        
        self.reloadCollectioView()
    }
    
    @IBAction func favouriteBtnPressed(_ sender: Any) {
        
        if shirtArrayData.count <= 0 || trouserArrayData.count <= 0
        {
            print("count is zero")
            return
        }
        var dict_ = [String:String]()
        dict_["shirtKey"] = shirtArrayData[shirtPageControl.currentPage].uniqueFileName
        dict_["trouserKey"] = trouserArrayData[trouserPageControl.currentPage].uniqueFileName
        
        if favouriteDataArr.count > 0
        {
            let isContains = favouriteDataArr.contains(dict_)
            
            if !isContains
            {
                favouriteDataArr.append(dict_)
                self.saveFavData(shirtIndex: shirtPageControl.currentPage, trouserIndex: trouserPageControl.currentPage)
                favouriteBtnOutlet.setImage(UIImage(named: "fillheart.png"), for: .normal)
            }
            else
            {}
        }
        else
        {
            favouriteBtnOutlet.setImage(UIImage(named: "fillheart.png"), for: .normal)
            self.saveFavData(shirtIndex: shirtPageControl.currentPage, trouserIndex: trouserPageControl.currentPage)
            favouriteDataArr.append(dict_)
        }
    }
    
    //MARK: Alert Controller
    func alertController() {
        
        let cameraClicked = UIAlertAction.init(title: "Camera", style: .default) { (action) in
            print("Camera clicked")
            self.sourceType = ImageSourceType.imageCamera
            self.cameraorImagePressed()
        }
        let galleryClicked = UIAlertAction.init(title: "Gallery", style: .default) { (action) in
            print("Gallery clicked")
            self.sourceType = ImageSourceType.imageGallery
            self.cameraorImagePressed()
        }
        let cancelClicked = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            print("Cancel clicked")
        }
        
        let alertCont_ = UIAlertController.init(title: nil, message: "Choose option", preferredStyle: .actionSheet)
        
        alertCont_.addAction(cameraClicked)
        alertCont_.addAction(galleryClicked)
        alertCont_.addAction(cancelClicked)
        
        self.present(alertCont_, animated: true, completion: nil)
    }
    
    func cameraorImagePressed() {
        
        imagePicker.sourceType = self.sourceType == ImageSourceType.imageCamera ? .camera : .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    //MARK: Core Data Part
    func imageSaveInDB(entityName:String,valueImagePath:String,keyName:String)
    {
        let context = self.appDelegate.persistentContainer.viewContext
        // Create entity and new record
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(valueImagePath, forKey: keyName)
        
        do
        {
            try context.save()
        }
        catch
        {
            print("image save error \(error.localizedDescription)")
        }
    }
    
    
    func witeImageToPath(imageName:String,pickedImage:UIImage) {
        DispatchQueue.global().async
            {
                var trouserImagePath = self.createDirectoryPath()
                trouserImagePath = trouserImagePath.appendingPathComponent(imageName)
                let imgData = UIImageJPEGRepresentation(pickedImage, 0.5)
                do
                {
                    try imgData?.write(to: trouserImagePath)
                }
                catch
                {
                    print("trouser error is \(error.localizedDescription)")
                }
        }
    }
    
    func saveFavData(shirtIndex:Int,trouserIndex:Int)
    {
        
        let context = self.appDelegate.persistentContainer.viewContext
        // Create entity and new record
        let entity = NSEntityDescription.entity(forEntityName: "Favourite", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(shirtPageControl.currentPage, forKey: "indexOfShirtImage")
        newUser.setValue(trouserPageControl.currentPage, forKey: "indexOfTrouserImage")
        
        do
        {
            try context.save()
        }
        catch
        {
            print("image save error \(error.localizedDescription)")
        }
        
    }
    
    
    func fetchImageData(entity:String) -> [NSManagedObject]?
    {
        let context = self.appDelegate.persistentContainer.viewContext
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        request.returnsDistinctResults = true
        do
        {
            self.result = try context.fetch(request) as? [NSManagedObject]
        }
        catch
        {
            print("fetching error \(error.localizedDescription)")
        }
        return self.result
    }
    
    func createDirectoryPath() -> URL {
        let directoryPath =  supportPath?.appendingPathComponent("Images/")
        
        do
        {
            if !FileManager.default.fileExists(atPath: "\(String(describing: directoryPath))")
            {
                try FileManager.default.createDirectory(at: (directoryPath?.absoluteURL)!, withIntermediateDirectories: false, attributes: nil)
            }
        }
        catch
        {
            
        }
        return directoryPath!
    }
    
    //MARK: Return Image Path
    func doesFileWithNameExist(fileName:String) -> UIImage?
    {
        let path_ = supportPath?.appendingPathComponent("\(fileName)")
        
        if FileManager.default.fileExists(atPath: (path_?.path)!)
        {
            print("yes exist")
            do
            {
                let data = try Data(contentsOf: path_!)
                let image_ = UIImage(data: data)
                return image_
            }
            catch
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
}

extension ViewController : UIImagePickerControllerDelegate
{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("User Cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print("in image cotnrller \(info)")
        let imageUniqueName : Int64 = Int64(NSDate().timeIntervalSince1970 * 1000);
        
//        if sourceType == ImageSourceType.imageGallery
//        {
            do
            {
//                let imageName =  info[UIImagePickerControllerImageURL] as! URL
                if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
                {
                    if isShirtType
                    {
                        shirtStruct = Shirt(fileName: "Images/\(imageUniqueName).jpg", image: pickedImage)
                        shirtArrayData.append(shirtStruct)
                        
                        self.imageSaveInDB(entityName: "ShirtImage", valueImagePath: "Images/\(imageUniqueName).jpg", keyName: "shirtImagePath")
                        
                        self.witeImageToPath(imageName: "\(imageUniqueName).jpg", pickedImage: pickedImage)
                        
                        
                        shirtPageControl.numberOfPages = shirtArrayData.count
                        shirtCollectionView.reloadData()
                    }
                    else // trouserArrayData
                    {
                        shirtStruct = Shirt(fileName: "Images/\(imageUniqueName).jpg", image: pickedImage)
                        trouserArrayData.append(shirtStruct)
                        
                        self.imageSaveInDB(entityName: "TrouserImage", valueImagePath: "Images/\(imageUniqueName).jpg", keyName: "trouserImagePath")
                        
                        self.witeImageToPath(imageName: "\(imageUniqueName).jpg", pickedImage: pickedImage)
                        
                        trouserPageControl.numberOfPages = trouserArrayData.count
                        trouserCollectionView.reloadData()
                    }
                }
            }
//        }
//        else if sourceType == ImageSourceType.imageCamera
//        {
//            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
//            {
//                if isShirtType
//                {
//                    shirtStruct = Shirt(fileName: "Images/\(imageUniqueName).jpg", image: pickedImage)
//                    shirtArrayData.append(shirtStruct)
//                    
//                    self.imageSaveInDB(entityName: "ShirtImage", valueImagePath: "Images/\(imageUniqueName).jpg", keyName: "shirtImagePath")
//                    
//                    self.witeImageToPath(imageName: "\(imageUniqueName).jpg", pickedImage: pickedImage)
//                    
//                    
//                    shirtPageControl.numberOfPages = shirtArrayData.count
//                    shirtCollectionView.reloadData()
//                }
//                else // trouserArrayData
//                {
//                    shirtStruct = Shirt(fileName: "Images/\(imageUniqueName).jpg", image: pickedImage)
//                    trouserArrayData.append(shirtStruct)
//                    
//                    self.imageSaveInDB(entityName: "TrouserImage", valueImagePath: "Images/\(imageUniqueName).jpg", keyName: "trouserImagePath")
//                    
//                    self.witeImageToPath(imageName: "\(imageUniqueName).jpg", pickedImage: pickedImage)
//                    
//                    trouserPageControl.numberOfPages = trouserArrayData.count
//                    trouserCollectionView.reloadData()
//                }
//            }
//        }
        self.dismiss(animated: true, completion: nil)
    }
}


extension ViewController : UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == shirtCollectionView
        {
            shirtPageControl.currentPage = indexPath.section
        }
        else if collectionView == trouserCollectionView
        {
            trouserPageControl.currentPage = indexPath.section
        }
        
    }
}
extension ViewController : UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == shirtCollectionView
        {
            
            return shirtArrayData.count
        }
        else if collectionView == trouserCollectionView
        {
            
            return trouserArrayData.count
        }
        else
        {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == shirtCollectionView
        {
            isShirtType = true
            let cell_ = collectionView.dequeueReusableCell(withReuseIdentifier: "ShirtCollectionViewCell", for: indexPath) as? ShirtCollectionViewCell
            
            let imgData =
                UIImageJPEGRepresentation(self.shirtArrayData[indexPath.row].fileImage , 0.5)
            cell_?.shirtImageView.image = UIImage(data: imgData!)
            
            return cell_!
        }
        else if collectionView == trouserCollectionView
        {
            isShirtType = false
            let cell_ = collectionView.dequeueReusableCell(withReuseIdentifier: "TrouserCollectionViewCell", for: indexPath) as? TrouserCollectionViewCell
            
            let imgData = UIImageJPEGRepresentation(self.trouserArrayData[indexPath.row].fileImage , 0.5)
            cell_?.trouserImageView.image = UIImage(data: imgData!)
            
            return cell_!
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
    
}

extension ViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width-10, height: collectionView.frame.size.height-20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 5, 0, 5)
    }
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        
        if shirtArrayData.count > 0 && trouserArrayData.count > 0
        {
            if scrollView == shirtCollectionView
            {
                let pageWidth : CGFloat = self.shirtCollectionView.frame.size.width
                shirtPageControl.currentPage = Int((self.shirtCollectionView.contentOffset.x/pageWidth).rounded(.up))
            }
            else
            {
                let pageWidth : CGFloat = self.trouserCollectionView.frame.size.width
                trouserPageControl.currentPage = Int((self.trouserCollectionView.contentOffset.x/pageWidth).rounded(.up))
            }
            print("current page shirt \(shirtPageControl.currentPage) and current page trouser \(trouserPageControl.currentPage)")
            
            
            var tempDic = [String:String]()
            
            tempDic["shirtKey"] = shirtArrayData[shirtPageControl.currentPage].uniqueFileName
            tempDic["trouserKey"] = trouserArrayData[trouserPageControl.currentPage].uniqueFileName
            
            let isContains = favouriteDataArr.contains(tempDic)
            print("bool value is-->> \(isContains)")
            
            if isContains
            {
                favouriteBtnOutlet.setImage(UIImage(named: "fillheart.png"), for: .normal)
            }
            else
            {
                favouriteBtnOutlet.setImage(UIImage(named: "withoutfillheart.png"), for: .normal)
            }
        }
        else
        {
            
        }
        
        
        
    }
}
