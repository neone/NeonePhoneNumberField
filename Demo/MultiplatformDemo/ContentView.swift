//
//  ContentView.swift
//  Demo
//
//  Created by Seyed Mojtaba Hosseini Zeidabadi on 8/8/22.
//

import SwiftUI
import iPhoneNumberField

struct ContentView: View {
    @State var text = ""
    @State var isEditing = false
    
    var body: some View {
        ZStack {
            Color
                .yellow
                .ignoresSafeArea()
                .onTapGesture { isEditing = false }
            VStack {
                iPhoneNumberField(
                    "Title",
                    text: $text,
                    isEditing: $isEditing,
                    formatted: true
                ) {
                    $0.numberPlaceholderColor = .red
                    $0.textColor = .label
                    $0.numberPlaceholderColor = .label
                }
                .defaultRegion("EG")
                .onEdit(perform: {
                    print("onEdit \($0.phoneNumber)")
                })
                .onEditingEnded(perform: {
                    print("onEditingEnded \($0.phoneNumber)")
                })
                .onNumberChange(perform: {_ in 
                    print("onNumberCHange")
                })
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
                .padding()
            }
            .onAppear {
                text = "+201111112255"
            }
            Button {
                text = "+201111112255"
            } label: {
                Text("set phone number")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
