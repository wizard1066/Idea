  //
  //  ContentView.swift
  //  Idea
  //
  //  Created by localadmin on 25.04.20.
  //  Copyright © 2020 Mark Lucking. All rights reserved.
  //
  
  import SwiftUI
  import Darwin
  import Combine
  
  struct Fonts {
  static func futuraCondensedMedium(size:CGFloat) -> Font{
    return Font.custom("Futura-CondensedMedium",size: size)
  }
}
  
  let fireRate = 0.25
  let fontSize:CGFloat = 64.0
  let fire = PassthroughSubject<Void,Never>()
  
  class TimerHolder : ObservableObject {
    var timer : Timer!
    @Published var count = 0
    func start() {
      self.timer?.invalidate()
      self.count = 0
      self.timer = Timer.scheduledTimer(withTimeInterval: fireRate, repeats: true) {
        _ in
        self.count += 1
        print(self.count)
        fire.send()
      }
    }
  }
  
  
  struct ContentView: View {
    @State var word = "Hello,World"
    @State var gate:Int = 1
    @State var isReady = false
    @State var code:String = ""
    
    @ObservedObject var durationTimer = TimerHolder()

    
    var body: some View {
      let letter = word.map( { String($0) } )
    return VStack {
      Text("").onReceive(fire) { (_) in
            self.isReady.toggle()
            self.gate += 1
          }.onAppear {
            self.durationTimer.start()
          }
      HStack(spacing:0) {
            ForEach((0 ..< letter.count), id: \.self) { column in
              Text(letter[column])
                .foregroundColor(colorCode(gate: Int(self.gate), no: column) ? Color.black: Color.red)
                .font(Fonts.futuraCondensedMedium(size: fontSize))
                
            }
          }
        }
      }
    }
  
 
  
  func colorCode(gate:Int, no:Int) -> Bool {

    let bgr = String(gate, radix:2).pad(with: "0", toLength: 16)
    let bcr = String(no, radix:2).pad(with: "0", toLength: 16)
    let binaryColumn = 1 << no - 1
    
    let value = UInt64(gate) & UInt64(binaryColumn)
    let vr = String(value, radix:2).pad(with: "0", toLength: 16)
    
    print("bg ",bgr," bc ",bcr,vr)
    return value > 0 ? true:false
  }
  
  struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      ContentView()
    }
  }
  
  extension String {
    func pad(with character: String, toLength length: Int) -> String {
        let padCount = length - self.count
        guard padCount > 0 else { return self }

        return String(repeating: character, count: padCount) + self
    }
}
