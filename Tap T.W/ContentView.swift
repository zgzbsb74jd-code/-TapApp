
import SwiftUI

import Combine

// データ

struct TapRecord: Identifiable, Codable {
    
    var id = UUID()
    
    var date: Date
    
}

// 保存管理

class TapStore: ObservableObject {
    
    @Published var records: [TapRecord] = [] {
        
        didSet {
            
            save()
            
        }
        
    }
    
    
    
    let key = "tap_records"
    
    
    
    init() {
        
        load()
        
    }
    
    
    
    func addTap() {
        
        records.append(TapRecord(date: Date()))
        
    }
    
    
    
    func clearAll() {
        
        records.removeAll()
        
    }
    
    
    
    func save() {
        
        if let data = try? JSONEncoder().encode(records) {
            
            UserDefaults.standard.set(data, forKey: key)
            
        }
        
    }
    
    
    
    func load() {
        
        if let data = UserDefaults.standard.data(forKey: key),
           
            let decoded = try? JSONDecoder().decode([TapRecord].self, from: data) {
            
            records = decoded
            
        }
        
    }
    
    
    
    func dailyCounts() -> [String: Int] {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy年M月d日"
        
        
        
        var dict: [String: Int] = [:]
        
        
        
        for record in records {
            
            let key = formatter.string(from: record.date)
            
            dict[key, default: 0] += 1
            
        }
        
        return dict
        
    }
    
    
    
    func monthlyCounts() -> [String: Int] {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy年M月"
        
        
        
        var dict: [String: Int] = [:]
        
        
        
        for record in records {
            
            let key = formatter.string(from: record.date)
            
            dict[key, default: 0] += 1
            
        }
        
        return dict
        
    }
    
}

// メイン画面

struct ContentView: View {
    
    @StateObject var store = TapStore()
    
    @State private var tapped = false
    
    @State private var showAlert = false
    
    
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                // 背景
                
                LinearGradient(
                    
                    colors: [Color.blue, Color.cyan],
                    
                    startPoint: .top,
                    
                    endPoint: .bottom
                    
                )
                
                .ignoresSafeArea()
                
                
                
                VStack {
                    
                    
                    
                    // 上：回数
                    
                    Text("タップ回数: \(store.records.count)")
                    
                        .font(.largeTitle)
                    
                        .foregroundColor(.white)
                    
                        .padding(.top, 40)
                    
                    
                    
                    Spacer()
                    
                    
                    
                    // 👇 タップ（より濃い青）
                    
                    ZStack {
                        
                        Circle()
                        
                            .fill(tapped
                                  
                                  ? Color(red: 0.0, green: 0.2, blue: 0.8)   // タップ時（さらに濃い）
                                  
                                  : Color(red: 0.0, green: 0.4, blue: 1.0))  // 通常（鮮やか青）
                        
                            .frame(width: 180, height: 180)
                        
                            .shadow(radius: 12)
                        
                        
                        
                        Circle()
                        
                            .stroke(Color.white, lineWidth: 4)
                        
                            .frame(width: 120, height: 120)
                        
                        
                        
                        Text("TAP")
                        
                            .font(.largeTitle)
                        
                            .bold()
                        
                            .foregroundColor(.white)
                        
                    }
                    
                    .onTapGesture {
                        
                        store.addTap()
                        
                        tapped.toggle()
                        
                    }
                    
                    
                    
                    Spacer()
                    
                    
                    
                    // 下：ボタン
                    
                    VStack(spacing: 15) {
                        
                        NavigationLink("統計を見る") {
                            
                            StatsView(store: store)
                            
                        }
                        
                        .foregroundColor(.white)
                        
                        
                        
                        Button("全データ削除") {
                            
                            showAlert = true
                            
                        }
                        
                        .foregroundColor(.white)
                        
                        .padding()
                        
                        .background(Color.red)
                        
                        .cornerRadius(10)
                        
                        .alert(isPresented: $showAlert) {
                            
                            Alert(
                                
                                title: Text("確認"),
                                
                                message: Text("本当に削除しますか？"),
                                
                                primaryButton: .destructive(Text("削除")) {
                                    
                                    store.clearAll()
                                    
                                },
                                
                                secondaryButton: .cancel()
                                
                            )
                            
                        }
                        
                    }
                    
                    .padding(.bottom, 30)
                    
                }
                
                .padding()
                
            }
            
            .navigationTitle("タップ記録")
            
        }
        
    }
    
}

// 統計画面

struct StatsView: View {
    
    @ObservedObject var store: TapStore
    
    
    
    var body: some View {
        
        List {
            
            Section(header: Text("日別")) {
                
                ForEach(store.dailyCounts().sorted(by: {$0.key > $1.key}), id: \.key) { key, value in
                    
                    Text("\(key): \(value)回")
                    
                }
                
            }
            
            
            
            Section(header: Text("月別")) {
                
                ForEach(store.monthlyCounts().sorted(by: {$0.key > $1.key}), id: \.key) { key, value in
                    
                    Text("\(key): \(value)回")
                    
                }
                
            }
            
            
            
            Section(header: Text("履歴（分まで）")) {
                
                ForEach(store.records.sorted(by: {$0.date > $1.date})) { record in
                    
                    Text(formatDate(record.date))
                    
                }
                
            }
            
        }
        
        .navigationTitle("統計")
        
    }
    
}

// 日時フォーマット

func formatDate(_ date: Date) -> String {
    
    let formatter = DateFormatter()
    
    formatter.dateFormat = "yyyy年M月d日 HH:mm"
    
    return formatter.string(from: date)
    
}
