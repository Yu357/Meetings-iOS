//
//  MyTabBar.swift
//  Meetings
//
//  Created by Yu on 2022/07/25.
//

import SwiftUI

struct SimpleTabBar: View {
    
    // TabBar items
    let tabBarItems: [Text]
    
    // States
    @Binding var selection: Int
    @Environment(\.colorScheme) var colorScheme
    
    // Namespace
    @Namespace private var namespace
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            // Button Row
            HStack(spacing: 0) {
                ForEach(0 ..< tabBarItems.count, id: \.self) { index in
                    Button(action: {
                        self.selection = index
                    }) {
                        VStack {
                            
                            // Label
                            tabBarItems[index]
                                .foregroundColor(self.selection == index ? .blue : .primary)
                            
                            // Underline when selected
                            if self.selection == index {
                                Color.blue
                                    .frame(height: 2)
                                    .padding(.horizontal)
                            }
                            
                            // Underline when unselected
                            if self.selection != index {
                                Color.clear
                                    .frame(height: 2)
                                    .padding(.horizontal)
                            }
                        }
                        .background(colorScheme == .dark ? Color.black : Color.white)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top)
            
            // Underline Row
            Divider()
        }
    }
}
