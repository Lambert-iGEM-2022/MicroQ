//
//  ContentView.swift
//  MicroQApp
//
//  Created by Ryan D on 9/16/22.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State var setupCode = ""
    @State var fluoresenceValue = 0.0
    @State var fluoresenceUpdated: String = ""
    
    @State var blankStatus = false
    @State var blankUpdated: String = ""
    
    @State var connected = false
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationView {
            VStack{
                Text("Enter the setup code located on your device to get started. ")
                    
                
                HStack {
                    TextField("setup code", text: $setupCode)
                        .padding().padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 12).foregroundColor(Color(hex: self.colorScheme == .dark ? "343a40" : "F5F5F5")))
                        .padding()
                    
                    Button(action: {
                        Task {
                            do {
                                self.connected = false
                                let ref = Firestore.firestore().collection("devices").document(self.setupCode)
                                let doc = try await ref.getDocument()

                                try await ref.updateData(["blankStatus": false])
                                guard let data = doc.data() else { return }
                                self.connected = true
                                
                                ref.addSnapshotListener{ snap, error in
                                    guard let snap = snap else { return }
                                    guard let data = snap.data() else { return }
                                    self.fluoresenceValue = data["lightInt"] as? Double ?? 0.0
                                    let fluoresenceUpdatedS = data["readTimeStamp"] as? String ?? ""
                                    self.fluoresenceUpdated = parseTimeString(str: fluoresenceUpdatedS)
                                    
                                    self.blankStatus = data["blankStatus"] as? Bool ?? false
                                    let blankUpdatedS = data["blankTimeStamp"] as? String ?? ""
                                    self.blankUpdated = parseTimeString(str: blankUpdatedS)
                                }
                            } catch {
                                print(error)
                            }
                        }

                    }) {
                        Text("Connect")
                            .foregroundColor(Color(hex: "F5F5F5"))
                            .padding()
                            .background(Capsule())
                            .padding()
                        
                    }
                }
                
                
                Spacer()
                
                Text("Value")
                    .font(.title2)
                
                Text(String(format: "%.2f", self.fluoresenceValue))
                    .font(.largeTitle)
                
                Text("Value last updated " + self.fluoresenceUpdated)
                    .fontWeight(.light)
                    .padding()
                
                Text(self.connected ? "Connected" : "Not Connected")
                    .foregroundColor(self.connected ? .green : .black)
                    .padding()
                
                Spacer()
                
                Text(self.blankStatus ? "Blanked" : "Not Blanked")
                    .font(.subheadline)
                    .foregroundColor(self.blankStatus ? .green : .black)
                
                Text("Blank last updated " + self.blankUpdated )
                    .font(.caption)
                    .fontWeight(.light)
                    .padding()

                

                
            }
            .navigationTitle("Micro-Q")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

func parseTimeString(str: String) -> String {
    let dsFormatter = DateFormatter()
    dsFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
    dsFormatter.timeZone = .autoupdatingCurrent
    guard let date = dsFormatter.date(from: str) else {
        print("Error with date formatter")
        return ""
    }
    let sdFormatter = DateFormatter()
    sdFormatter.dateFormat = "MM/dd/yyyy, HH:mm aa"
//    print("CURRENT TIME ZONE \("")")
//    sdFormatter.timeZone = TimeZone(identifier: "EST")
    let res = sdFormatter.string(from: date)
    return res
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
