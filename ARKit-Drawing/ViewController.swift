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
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    
    func addNodeInFront(_ node: SCNNode){
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        //set transform of node to be 20 cm in front of camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        node.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        let cloneNode = node.clone()
        sceneView.scene.rootNode.addChildNode(cloneNode)
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
    }
    
    func undoLastObject() { // is called when the user taps Undo Last object
        
    }
    
    func resetScene() { // is called when the user taps reset scene
        dismiss(animated: true, completion: nil)
    }
    
    
}
