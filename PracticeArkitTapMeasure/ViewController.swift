//
//  ViewController.swift
//  PracticeArkitTapMeasure
//
//  Created by Kenshiro on 2021/01/16.
//
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
@IBOutlet var sceneView: ARSCNView!
@IBOutlet var label: UILabel!
    
var centerPos = CGPoint(x: 0, y: 0)
var tapCount = 0
var startPos = float3(0,0,0)
var currentPos = float3(0,0,0)
    
    
override func viewDidLoad() {
    super.viewDidLoad()

    sceneView.delegate = self
    
    // シーンを作成
    sceneView.scene = SCNScene()
    
    // 画面中央の座標を保存
    centerPos = sceneView.center
    
    // セッションを開始する
    let configuration = ARWorldTrackingConfiguration()
    sceneView.session.run(configuration)
    }
    

//画面がタップされたときの処理
override func touchesBegan(_ touches: Set<UITouch>, with event:UIEvent?) {
    // 球の配置
    putSphere(at:currentPos)
    
    // タップが1回目の場合
    if tapCount == 0{
        startPos = currentPos
        tapCount = 1
        }
    
        //2回目のタップのとき
        else{
            tapCount = 0
        
            //線状のオブジェクトを配置（1度目のタップと2度目のタップの間に配置）
            let lineNode = drawLine(from:SCNVector3(startPos),to:SCNVector3(currentPos))
            
            sceneView.scene.rootNode.addChildNode(lineNode)
            }
    }
    
// 球を描画するメソッド
private func putSphere(at pos: float3) {
        
            let node = SCNNode()
            
            //geometryを設定（半径と配置位置を設定）
            node.geometry = SCNSphere(radius:0.003)
            node.position = SCNVector3(pos.x, pos.y, pos.z)
            
            self.sceneView.scene.rootNode.addChildNode(node)
            }
    
    
// 直線を描画するメソッド
func drawLine(from : SCNVector3, to : SCNVector3) -> SCNNode
{
    // 直線のGeometry を作成する
    let source = SCNGeometrySource(vertices: [from, to])
    let element = SCNGeometryElement(data: Data.init(bytes: [0, 1]),primitiveType: .line,primitiveCount:1,bytesPerIndex: 1)
    let geometry = SCNGeometry(sources: [source], elements:[element])
    
    // 直線ノードの作成
    let node = SCNNode()
    
    node.geometry = geometry
    node.geometry?.materials.first?.diffuse.contents = UIColor.white
    
    return node
    }
                                 
// 毎フレーム呼ばれる処理
func renderer(_ renderer: SCNSceneRenderer, updateAtTime time:TimeInterval) {
    
    // タップされた位置を取得する（特徴点との当たり判定。existingPlaneUsingExtentでやると面に変更できる）
    let hitResults = sceneView.hitTest(centerPos, types:[.featurePoint])
    
    // 結果取得に成功しているかどうか
    if !hitResults.isEmpty {
        if let hitTResult = hitResults.first {
            
            // 実世界の座標をSCNVector3で返す
            currentPos = float3(hitTResult.worldTransform.columns.3.x,hitTResult.worldTransform.columns.3.y,hitTResult.worldTransform.columns.3.z)
            
            //まだ一度しかタップされていない場合
            if tapCount == 1{
                //始点から現在の場所までの長さを計測
                let len = distance(startPos, currentPos)
                
                DispatchQueue.main.async {
                    // ラベルに反映する
                    self.label.text = String(format:"%.1f", len*100) + "cm"
                }
            }
        }
    }
}
}

                                 
