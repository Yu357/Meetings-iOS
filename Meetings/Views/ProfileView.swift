//
//  ProfileView.swift
//  Meetings
//
//  Created by Yu on 2022/07/23.
//

import SwiftUI

struct ProfileView: View {
    
    // User ID to show
    let userId: String
    
    // States
    @State private var user: User? = nil
    @State private var isLoadedUser = false
    
    @State private var selection = 0
    
    // Navigation
    @State private var isShowEditProfileView = false
    @State private var isShowAccountView = false
    @State private var isShowCreateReportView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Row
            HStack(alignment: .top) {
                
                // Icon Column
                UserIconImage(userId: userId, iconImageFamily: .medium)
                
                // DisplayName And UserTag Column
                VStack(alignment: .leading) {
                    UserDisplayNameText(userId: userId)
                    UserUserTagText(userId: userId)
                }
            }
            .padding(.horizontal)
            
            // User Reading Failed Row
            if isLoadedUser && user == nil {
                Text("user_reading_failed")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.secondary)
            }
            
            // Introduction Row
            Group {
                // Progress view
                if !isLoadedUser {
                    Color.secondary
                        .opacity(0.2)
                        .frame(width: 200, height: 16)
                }
                
                // Reading failed view
                if isLoadedUser && user == nil {
                    EmptyView()
                }
                
                // Introduction
                if isLoadedUser && user != nil {
                    Text(user!.introduction)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Tab Bar Row
            MyTabBar(tabBarItems: [Text("comments"), Text("likes")], selection: $selection)
            
            // Tab Body Row
            TabView(selection: $selection) {
                // Comments Page
                CommentRowList(userId: userId, commentRowListFamily: .posts)
                    .tag(0)
                
                // Likes Page
                CommentRowList(userId: userId, commentRowListFamily: .likes)
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.spring(), value: selection)
            .ignoresSafeArea()
        }
        
        .sheet(isPresented: $isShowEditProfileView) {
            EditProfileView()
        }
        
        .sheet(isPresented: $isShowAccountView) {
            AccountView()
        }
        
        .sheet(isPresented: $isShowCreateReportView) {
            CreateReportView(targetCategory: .user)
        }
        
        .navigationTitle("profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    // Edit Profile Button
                    if FireAuth.uid() == userId {
                        Button(action: {
                            isShowEditProfileView.toggle()
                        }) {
                            Label("edit_profile", systemImage: "person")
                        }
                    }
                    
                    // Account Button
                    if FireAuth.uid() == userId {
                        Button(action: {
                            isShowAccountView.toggle()
                        }) {
                            Label("account", systemImage: "person")
                        }
                    }
                    
                    // Report Button
                    if FireAuth.uid() != userId {
                        Button(action: {
                            isShowCreateReportView.toggle()
                        }) {
                            Label("report_user", systemImage: "flag")
                        }
                    }
                    
                    // Mute Button
                    if FireAuth.uid() != userId {
                        Button(action: {
                            
                        }) {
                            Label("mute_user", systemImage: "speaker.slash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
        }
        
        .onAppear(perform: load)
    }
    
    private func load() {
        // Userを読み取る
        if user == nil {
            FireUser.readUser(userId: userId) { user in
                self.user = user
                self.isLoadedUser = true
            }
        }
    }
}
