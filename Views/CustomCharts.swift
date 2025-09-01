//
//  CustomCharts.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import SwiftUI
import CoreGraphics

// MARK: - KawaiiBarChart

/// A cute bar chart for displaying category or tag statistics
struct KawaiiBarChart: View {
    /// The data to display in the chart
    let data: [(name: String, value: Int, color: Color)]
    
    /// The theme color
    let themeColor: Color
    
    /// The maximum value for scaling
    private var maxValue: Int {
        data.max { $0.value < $1.value }?.value ?? 1
    }
    
    /// The width of each bar
    private var barWidth: CGFloat {
        60
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(data, id: \.name) {
                    item in
                    VStack {
                        BarView(
                            height: calculateBarHeight(value: item.value),
                            color: item.color,
                            maxValue: maxValue
                        )
                        Text(item.name)
                            .font(.kleeOne(size: 12))
                            .multilineTextAlignment(.center)
                            .frame(width: barWidth)
                    }
                }
            }
            .frame(height: 200)
            .padding()
        }
        .kawaiiBorder(colors: [themeColor, themeColor.opacity(0.5)], width: 2, cornerRadius: 15)
        .padding(5)
    }
    
    /// Calculate the height of a bar based on the value
    private func calculateBarHeight(value: Int) -> CGFloat {
        if maxValue == 0 { return 0 }
        let percentage = CGFloat(value) / CGFloat(maxValue)
        // Return between 20 and 180 to ensure visibility
        return max(20, min(180, percentage * 180))
    }
}

/// Individual bar view with cute design
struct BarView: View {
    /// The height of the bar
    let height: CGFloat
    
    /// The color of the bar
    let color: Color
    
    /// The maximum value for animation
    let maxValue: Int
    
    /// Animation state
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Background bar
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.2))
                .frame(width: 60, height: height)
            
            // Main bar with animation
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .frame(width: 50, height: animate ? height - 10 : 0)
                .offset(y: animate ? 0 : height - 10)
                .padding(5)
            
            // Sparkle effect on hover
            if maxValue > 0 {
                Circle()
                    .fill(Color.white)
                    .frame(width: 5, height: 5)
                    .position(x: 25, y: 10)
                    .opacity(0.8)
                    .floatAnimation(amplitude: 3, frequency: 2)
            }
        }
        .onAppear {
            // Start animation when view appears
            withAnimation(Animation.easeOut(duration: 0.8)) {
                animate = true
            }
        }
    }
}

// MARK: - KawaiiLineChart

/// A cute line chart for displaying diary count over time
struct KawaiiLineChart: View {
    /// The data to display in the chart
    let data: [(date: Date, count: Int)]
    
    /// The theme color
    let themeColor: Color
    
    /// The maximum value for scaling
    private var maxValue: Int {
        data.max { $0.count < $1.count }?.count ?? 1
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Grid lines
                GridLinesView()
                
                // Line and points
                Path {
                    path in
                    if data.isEmpty { return }
                    
                    // Move to first point
                    let startPoint = calculatePoint(date: data[0].date, count: data[0].count)
                    path.move(to: startPoint)
                    
                    // Add lines to other points
                    for point in data.dropFirst() {
                        let nextPoint = calculatePoint(date: point.date, count: point.count)
                        path.addLine(to: nextPoint)
                    }
                }
                .stroke(themeColor, lineWidth: 3)
                .shadow(color: themeColor.opacity(0.5), radius: 5)
                
                // Data points
                ForEach(data, id: \.date) {
                    point in
                    let position = calculatePoint(date: point.date, count: point.count)
                    Circle()
                        .fill(themeColor)
                        .frame(width: 10, height: 10)
                        .position(position)
                        .shadow(color: themeColor.opacity(0.5), radius: 3)
                        .floatAnimation(amplitude: 3, frequency: 2)
                        .sparkleAnimation(count: 3, color: themeColor, size: 2)
                }
            }
            .frame(height: 200)
            .padding()
            
            // X-axis labels
            HStack {
                if data.count >= 3 {
                    Text(formatDate(data[0].date))
                        .font(.kleeOne(size: 12))
                    Spacer()
                    Text(formatDate(data[data.count/2].date))
                        .font(.kleeOne(size: 12))
                    Spacer()
                    Text(formatDate(data.last!.date))
                        .font(.kleeOne(size: 12))
                }
            }
            .padding(.horizontal, 20)
        }
        .kawaiiBorder(colors: [themeColor, themeColor.opacity(0.5)], width: 2, cornerRadius: 15)
        .padding(5)
    }
    
    /// Calculate the position of a point in the chart
    private func calculatePoint(date: Date, count: Int) -> CGPoint {
        let chartWidth: CGFloat = 280
        let chartHeight: CGFloat = 180
        let margin: CGFloat = 20
        
        // Normalize date to x position
        let timeInterval = data.last!.date.timeIntervalSince(data[0].date)
        let pointInterval = date.timeIntervalSince(data[0].date)
        let x = margin + (pointInterval / timeInterval) * (chartWidth - 2 * margin)
        
        // Normalize count to y position
        let y = margin + chartHeight - (CGFloat(count) / CGFloat(maxValue)) * (chartHeight - 2 * margin)
        
        return CGPoint(x: x, y: y)
    }
    
    /// Format date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

/// Grid lines for the chart background
struct GridLinesView: View {
    var body: some View {
        VStack(spacing: 40) {
            ForEach(0..<5) {
                _ in
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 1)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - KawaiiPieChart

/// A cute pie chart for displaying category proportions
struct KawaiiPieChart: View {
    /// The data to display in the chart
    let data: [(name: String, value: Int, color: Color)]
    
    /// The theme color
    let themeColor: Color
    
    /// The total value for calculating percentages
    private var totalValue: Int {
        data.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        VStack {
            // Pie chart with cute design
            ZStack {
                PieChartView(data: data, totalValue: totalValue)
                    .frame(width: 200, height: 200)
                    
                // Center circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .shadow(radius: 2)
                    
                // Total count in the center
                Text("\(totalValue)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(themeColor)
            }
            
            // Legend
            HStack {
                ForEach(data.prefix(3)) {
                    item in
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 12, height: 12)
                        Text(item.name)
                            .font(.kleeOne(size: 12))
                    }
                    Spacer()
                }
                if data.count > 3 {
                    Text("+\(data.count - 3)")
                        .font(.kleeOne(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 40)
        }
        .kawaiiBorder(colors: [themeColor, themeColor.opacity(0.5)], width: 2, cornerRadius: 15)
        .padding(5)
    }
}

/// The actual pie chart drawing
struct PieChartView: View {
    /// The data to display in the chart
    let data: [(name: String, value: Int, color: Color)]
    
    /// The total value for calculating percentages
    let totalValue: Int
    
    var body: some View {
        GeometryReader {
            geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size / 2 - 10
            
            ZStack {
                var startAngle: Double = -90
                
                ForEach(data, id: \.name) {
                    item in
                    let angle = totalValue > 0 ? (Double(item.value) / Double(totalValue)) * 360 : 0
                    let endAngle = startAngle + angle
                    
                    // Draw slice
                    PieSlice(
                        startAngle: Angle(degrees: startAngle),
                        endAngle: Angle(degrees: endAngle),
                        radius: radius
                    )
                    .fill(item.color)
                    .shadow(color: .black.opacity(0.1), radius: 2)
                    
                    // Update start angle for next slice
                    startAngle = endAngle
                }
            }
            .frame(width: size, height: size)
        }
    }
}

/// A slice of the pie chart
struct PieSlice: Shape {
    /// The start angle of the slice
    let startAngle: Angle
    
    /// The end angle of the slice
    let endAngle: Angle
    
    /// The radius of the pie chart
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Chart Data Preparation Extensions

/// Extensions to prepare data for charts
extension DiaryViewModel {
    /// Prepare data for category bar chart
    func prepareCategoryChartData() -> [(name: String, value: Int, color: Color)] {
        // Get top 5 categories by count
        let topCategories = categories
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
            .prefix(5)
            
        // Map to chart data format
        return topCategories.map {
            category in
            let color = getCategoryColor(name: category.name)
            return (name: category.name, value: category.count, color: color)
        }
    }
    
    /// Prepare data for tag bar chart
    func prepareTagChartData() -> [(name: String, value: Int, color: Color)] {
        // Get top 5 tags by count
        let topTags = tags
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
            .prefix(5)
        
        // Map to chart data format with random colors
        return topTags.enumerated().map {
            index, tag in
            let colors: [Color] = [.pink, .purple, .blue, .green, .yellow]
            let color = colors[index % colors.count]
            return (name: tag.name, value: tag.count, color: color)
        }
    }
    
    /// Prepare data for monthly trend line chart
    func prepareMonthlyTrendData() -> [(date: Date, count: Int)] {
        guard !diaries.isEmpty else { return [] }
        
        // Group diaries by month
        var monthlyCount: [Date: Int] = [:]
        let calendar = Calendar.current
        
        for diary in diaries {
            let monthStart = calendar.startOfMonth(for: diary.date)
            monthlyCount[monthStart, default: 0] += 1
        }
        
        // Convert to array and sort by date
        var result: [(date: Date, count: Int)] = []
        for (date, count) in monthlyCount.sorted(by: { $0.key < $1.key }) {
            result.append((date: date, count: count))
        }
        
        // Only include the last 12 months
        if result.count > 12 {
            result = Array(result.suffix(12))
        }
        
        return result
    }
    
    /// Prepare data for category pie chart
    func prepareCategoryPieData() -> [(name: String, value: Int, color: Color)] {
        // Get all categories with count > 0
        let categoriesWithCount = categories.filter { $0.count > 0 }
        
        // Map to pie chart data format
        return categoriesWithCount.map {
            category in
            let color = getCategoryColor(name: category.name)
            return (name: category.name, value: category.count, color: color)
        }
    }
    
    /// Helper method to get color for a category
    private func getCategoryColor(name: String) -> Color {
        switch name {
        case "未分類": return .gray
        case "日常": return .blue
        case "仕事": return .indigo
        case "勉強": return .green
        case "趣味": return .purple
        case "思考": return .amber
        case "旅行": return .orange
        case "健康": return .red
        case "創作": return .pink
        case "読書": return .brown
        case "料理": return .yellow
        case "夢": return .violet
        case "目標": return .teal
        case "映画": return .cyan
        case "ゲーム": return .mint
        case "音楽": return .indigo
        default: return .gray
        }
    }
}

/// Extension to get the start of the month
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = self.dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}