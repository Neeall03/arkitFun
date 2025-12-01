//
//  ViewController.swift
//  arkitFunny
//
//  Created by Nilaykumar Sevak on 28/12/24.
//

import UIKit
import ARKit
import SceneKit
import ReplayKit

class ViewController: UIViewController, ARSCNViewDelegate, RPPreviewViewControllerDelegate {
    //MARK: variables
    private var sceneView: ARSCNView!
    private var currentMustacheNode: SCNNode?
    private var selectedMustache: String = "mustache1.png" {
        didSet {
            updateMustache(selectedMustache: selectedMustache)
        }
    }
    private let mustaches = ["mustache1.png", "mustache2.png", "mustache4.png", "mustache5.png"]
    
    private var isRecording = false
    private var screenRecorder = RPScreenRecorder.shared()
    private var recordButton: UIButton!
    
    //MARK: lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup ARSCNView
        addSceneView()
        
        // Add mustache selection controls
        addMustcheselectionList()
        
        // Add Record Button
        addRecordButton()
    }
    //will disapper
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    //MARK: Local functions
    
    //setup arkit sceneView
    private func addSceneView() {
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.delegate = self
        sceneView.session.run(ARFaceTrackingConfiguration())
        sceneView.scene = SCNScene()
        self.view.addSubview(sceneView)
    }
    
    private func addMustcheselectionList() {
        //layout for collectionview
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = 10
        collectionViewLayout.itemSize = CGSize(width: 60, height: 60)
        //collectionView setup
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellColleactionImage.self, forCellWithReuseIdentifier: cellColleactionImage.identifier)
        collectionView.backgroundColor = .clear
        self.view.addSubview(collectionView)
        //collectionvie contstraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func updateMustache(selectedMustache: String) {
        currentMustacheNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: selectedMustache)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard anchor is ARFaceAnchor else { return nil }
        let parentNode = SCNNode()
        let childNode = SCNNode()
        let childGeometry = SCNPlane(width: 0.12, height: 0.06)
        childGeometry.firstMaterial?.diffuse.contents = UIImage(named: selectedMustache)
        childNode.geometry = childGeometry
        childNode.position = SCNVector3(0, -0.029, 0.10)
        childNode.eulerAngles.x = -.pi / 4
        parentNode.addChildNode(childNode)
        currentMustacheNode = childNode
        
        return parentNode
    }
    ///record functionality setup
    private func addRecordButton() {
        recordButton = UIButton(type: .system)
        recordButton.setImage(UIImage(named: "recordButton")?.withTintColor(.red), for: .normal)
        recordButton.frame.size = CGSize(width: 100, height: 100)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        
        self.view.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            
        ])
    }
    ///record  button action
    @objc private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        guard screenRecorder.isAvailable else {
            print("Screen recording is not available.")
            return
        }
        
        screenRecorder.isMicrophoneEnabled = true
        screenRecorder.startRecording { error in
            if let error = error {
                print("Error starting recording: \(error.localizedDescription)")
            } else {
                self.isRecording = true
                self.updateRecordButtonTitle()
                print("Recording started.")
            }
        }
    }
    
    private func stopRecording() {
        screenRecorder.stopRecording { previewViewController, error in
            if let error = error {
                print("Error stopping recording: \(error.localizedDescription)")
            } else {
                self.isRecording = false
                self.updateRecordButtonTitle()
                print("Recording stopped.")
                
                if let previewViewController = previewViewController {
                    // No need to set delegate, just present the preview
                    self.present(previewViewController, animated: true, completion: nil)
                }
            }
        }
    }
    ///upadte button state
    private func updateRecordButtonTitle() {
        if isRecording {
            recordButton.setImage(UIImage(named: "stopButton")?.withTintColor(.red), for: .normal)
        } else {
            recordButton.setImage(UIImage(named: "recordButton")?.withTintColor(.red), for: .normal)
        }
    }
    /// this will show preview of recorded screen record
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
}
//MARK: collectionview delegate
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mustaches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellColleactionImage.identifier, for: indexPath) as! cellColleactionImage
        cell.configure(with: mustaches[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMustache = mustaches[indexPath.item]
    }
}




//MARK: collectionview cell
class cellColleactionImage: UICollectionViewCell {
    static let identifier = "cellColleactionImage"
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with imageName: String) {
        imageView.image = UIImage(named: imageName)
    }
}
//temporary commit changes I've created here to check my key passwords

//212
//ere
//1
