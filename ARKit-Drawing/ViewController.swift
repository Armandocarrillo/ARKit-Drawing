import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    enum ObjectPlacementMode { // represents the the selection in the segmented control
        case freeform, plane, image
    }
    
    var objectMode: ObjectPlacementMode = .freeform
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadConfiguration()
        //sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { // detecting taps
        super.touchesBegan(touches, with: event)
        guard let node = selectedNode, let touch = touches.first else { return }
        switch objectMode {
        case .freeform:
            addNodeInFront(node)
        case .plane:
            break
        case . image:
            break
        }
    }
    
    func addNodeInFront(_ node: SCNNode){ // to add multiple copies of the node with multiple taps (20cm)
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        //set transform of node to be 20 cm in front of camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        node.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        addNodeToSceneRoot(node)
    }
     var placedNode = [SCNNode]()
     var planeNodes = [SCNNode]()
    
    func addNodeToSceneRoot(_ node: SCNNode)// the node that i create needs to be cloned and added to the scene
    {
        let cloneNode = node.clone()
        sceneView.scene.rootNode.addChildNode(cloneNode)
        placedNode.append(cloneNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) { //added as children od the node not as children of the root node
       /* if let imageAnchor = anchor as? ARImageAnchor{
        nodeAdded(node, for: imageAnchor)
        } else if let planeAnchor = anchor as? ARPlaneAnchor{
        nodeAdded(node, for: planeAnchor)
        }*/
        guard let planeAnchor = anchor as? ARPlaneAnchor, let planeNode = node.childNodes.first, let plane = planeNode.geometry as? SCNPlane
        else { return }
        planeNode.position = SCNVector3(planeAnchor.extent.x, 0, planeAnchor.extent.z)
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    
    var showPlaneOverlay = false {
        didSet{
        for node in planeNodes {
        node.isHidden = !showPlaneOverlay
        }
        }
    }
    
    func nodeAdded(_ node: SCNNode, for anchor :ARPlaneAnchor){
        let floor = createFloor(planeAnchor: anchor)
        floor.isHidden = !showPlaneOverlay
        node.addChildNode(floor)
        planeNodes.append(floor)
        
    }
    
    func nodeAdded(_ node: SCNNode, for anchor: ARImageAnchor){
       if let selectedNode = selectedNode{
        addNode(selectedNode, toImageUsingParentNode: node)
        }
        
    }
    func addNode(_ node: SCNNode, toImageUsingParentNode parentNode: SCNNode){
        let cloneNode = node.clone()
        parentNode.addChildNode(cloneNode)
        placedNode.append(cloneNode)
    }
    
    
    var objetMode: ObjectPlacementMode = .freeform{
        didSet {
        reloadConfiguration()
        }
    }
    
    func reloadConfiguration(){ // update the session configuration's detentionImage
        configuration.planeDetection = .horizontal
        configuration.detectionImages = (objectMode == .image) ? ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) : nil
        // if the app is in one of the other two modes, dectionImage should be nil
        sceneView.session.run(configuration)
    }
    
    func createFloor(planeAnchor : ARPlaneAnchor) -> SCNNode{
        let node = SCNNode()
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        node.geometry = geometry
        node.eulerAngles.x = -Float.pi/2
        node.opacity = 0.25
        return node
    }
    

    @IBAction func changeObjectMode(_ sender: UISegmentedControl) { // update objectMode to the proper value
        switch sender.selectedSegmentIndex {
        case 0:
            objectMode = .freeform
        case 1:
            objectMode = .plane
        case 2:
            objectMode = .image
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOptions" {
            let optionsViewController = segue.destination as! OptionsContainerViewController
            optionsViewController.delegate = self
        }
    }
}
var selectedNode: SCNNode?
extension ViewController: OptionsViewControllerDelegate {
    
    
    
    func objectSelected(node: SCNNode) { // is called after th user selects a shape, color and size
        dismiss(animated: true, completion: nil)
        selectedNode = node
    }
    
    func togglePlaneVisualization() { //is called when th user taps Enable/Disable plane
        dismiss(animated: true, completion: nil)
        showPlaneOverlay = !showPlaneOverlay
    }
    
    func undoLastObject() { // is called when the user taps Undo Last object
        
    }
    
    func resetScene() { // is called when the user taps reset scene
        dismiss(animated: true, completion: nil)
    }
    
    
}
