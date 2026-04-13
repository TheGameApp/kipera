//
//  KiperaWidget.swift
//  KiperaWidget
//
//  Kipera — Savings goals widget for iOS home screen
//  Clean, Apple-like design with couple/solo goal support
//

import WidgetKit
import SwiftUI

// MARK: - Data Keys (must match Flutter's WidgetService keys)

private enum WidgetKey {
    static let goalName     = "goal_name"
    static let goalProgress = "goal_progress"
    static let goalSaved    = "goal_saved"
    static let goalTarget   = "goal_target"
    static let goalColor    = "goal_color"
    static let goalIcon     = "goal_icon"
    static let goalStreak   = "goal_streak"
    static let goalIsCouple = "goal_is_couple"
    static let lastUpdated  = "last_updated"
}

private let appGroupId = "group.com.kipera.app"

// MARK: - Timeline Entry

struct KiperaEntry: TimelineEntry {
    let date: Date
    let goalName: String
    let progress: Double
    let saved: Double
    let target: Double
    let colorHex: String
    let iconName: String
    let streak: Int
    let isCoupleGoal: Bool
    let isEmpty: Bool
}

// MARK: - Timeline Provider

struct KiperaProvider: TimelineProvider {
    func placeholder(in context: Context) -> KiperaEntry {
        KiperaEntry(
            date: Date(),
            goalName: "Dream House 🏠",
            progress: 0.65,
            saved: 650,
            target: 1000,
            colorHex: "A855F7",
            iconName: "home",
            streak: 7,
            isCoupleGoal: true,
            isEmpty: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (KiperaEntry) -> ()) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = readEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func readEntry() -> KiperaEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let goalName  = defaults?.string(forKey: WidgetKey.goalName) ?? ""
        let progress  = defaults?.double(forKey: WidgetKey.goalProgress) ?? 0.0
        let saved     = defaults?.double(forKey: WidgetKey.goalSaved) ?? 0.0
        let target    = defaults?.double(forKey: WidgetKey.goalTarget) ?? 0.0
        let colorHex  = defaults?.string(forKey: WidgetKey.goalColor) ?? "A855F7"
        let iconName  = defaults?.string(forKey: WidgetKey.goalIcon) ?? "savings"
        let streak    = defaults?.integer(forKey: WidgetKey.goalStreak) ?? 0
        let isCouple  = defaults?.bool(forKey: WidgetKey.goalIsCouple) ?? false
        let isEmpty   = goalName.isEmpty

        return KiperaEntry(
            date: Date(),
            goalName: isEmpty ? "" : goalName,
            progress: progress,
            saved: saved,
            target: target,
            colorHex: colorHex,
            iconName: iconName,
            streak: streak,
            isCoupleGoal: isCouple,
            isEmpty: isEmpty
        )
    }
}

// MARK: - Color from hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (168, 85, 247)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: 1)
    }
}

// MARK: - Design Tokens

private struct KD {
    static let purple     = Color(hex: "A855F7")
    static let purpleLight = Color(hex: "E0CFFC")
    static let pink       = Color(hex: "EC4899")
    static let pinkLight  = Color(hex: "FCDCE1")

    // Adaptive backgrounds
    static func cardBg(_ scheme: ColorScheme) -> Color {
        scheme.colorScheme == .dark
            ? Color(hex: "1E1E1E")
            : Color.white
    }

    static func textPrimary(_ scheme: ColorScheme) -> Color {
        scheme.colorScheme == .dark
            ? Color(hex: "F0F0F0")
            : Color(hex: "1A1A2E")
    }

    static func textSecondary(_ scheme: ColorScheme) -> Color {
        scheme.colorScheme == .dark
            ? Color(hex: "9CA3AF")
            : Color(hex: "6B7280")
    }
}

extension ColorScheme {
    var colorScheme: ColorScheme { self }
    var isDark: Bool { self == .dark }
}

// MARK: - Currency formatter

private func fmtCurrency(_ value: Double) -> String {
    if value >= 1_000_000 {
        return String(format: "$%.1fM", value / 1_000_000)
    } else if value >= 10_000 {
        return String(format: "$%.1fK", value / 1_000)
    } else {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return formatter.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
    }
}

// MARK: - Semi-Arc Progress Shape

struct SemiArc: Shape {
    var progress: Double
    var startAngle: Double = 140  // degrees
    var endAngle: Double = 400    // degrees (140 + 260 sweep)

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let sweep = endAngle - startAngle
        let end = startAngle + sweep * progress
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: min(rect.width, rect.height) / 2,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(end),
            clockwise: false
        )
        return path
    }
}

struct SemiArcTrack: Shape {
    var startAngle: Double = 140
    var endAngle: Double = 400

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: min(rect.width, rect.height) / 2,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
        return path
    }
}

// MARK: - Journey Path (curved path from people → goal)

struct JourneyPath: Shape {
    var progress: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startX = rect.minX
        let startY = rect.maxY
        let endX = rect.maxX
        let endY = rect.minY

        // Curved path from bottom-left to top-right
        path.move(to: CGPoint(x: startX, y: startY))
        path.addCurve(
            to: CGPoint(x: endX, y: endY),
            control1: CGPoint(x: rect.midX * 0.6, y: startY * 0.3),
            control2: CGPoint(x: rect.midX * 1.4, y: endY + rect.height * 0.1)
        )
        return path
    }
}

// MARK: - Dotted Line (horizontal connector between figures and goal)

struct DottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

// MARK: - Couple Indicator (two overlapping circles)

struct CoupleIndicator: View {
    var size: CGFloat = 18

    var body: some View {
        HStack(spacing: -(size * 0.3)) {
            Circle()
                .fill(KD.purple.opacity(0.85))
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: size * 0.45))
                        .foregroundColor(.white)
                )

            Circle()
                .fill(KD.pink.opacity(0.85))
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: size * 0.45))
                        .foregroundColor(.white)
                )
        }
    }
}

// MARK: - Small Widget

struct KiperaSmallView: View {
    let entry: KiperaEntry
    @Environment(\.colorScheme) var colorScheme

    private var accentColor: Color {
        entry.isCoupleGoal ? KD.pink : KD.purple
    }

    var body: some View {
        ZStack {
            // Background
            containerBackground

            if entry.isEmpty {
                emptyState
            } else {
                mainContent
            }
        }
    }

    private var containerBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(colorScheme == .dark
                ? Color(hex: "1A1A1A")
                : Color(hex: "FAFAFA"))
            .overlay(
                // Subtle accent bar at top
                VStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: entry.isCoupleGoal
                                    ? [KD.purple.opacity(0.7), KD.pink.opacity(0.7)]
                                    : [KD.purple.opacity(0.5), KD.purple.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 3)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    Spacer()
                }
            )
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "plus.circle")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(KD.purple.opacity(0.5))

            Text("Add a Goal")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.5) : Color(hex: "6B7280"))

            Text("Open Kipera")
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.3) : Color(hex: "9CA3AF"))
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Goal name row
            HStack(spacing: 4) {
                Text(entry.goalName)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : Color(hex: "6B7280"))
                    .lineLimit(1)
                Spacer()
                if entry.isCoupleGoal {
                    CoupleIndicator(size: 14)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 18)

            Spacer()

            // Semi-arc progress
            ZStack {
                SemiArcTrack()
                    .stroke(
                        colorScheme == .dark ? Color.white.opacity(0.08) : Color(hex: "F3F4F6"),
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .frame(width: 72, height: 72)

                SemiArc(progress: entry.progress)
                    .stroke(
                        LinearGradient(
                            colors: entry.isCoupleGoal
                                ? [KD.purpleLight, KD.purple, KD.pink]
                                : [KD.purpleLight, KD.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .frame(width: 72, height: 72)

                VStack(spacing: -2) {
                    Text("\(Int(entry.progress * 100))")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "1A1A2E"))
                    Text("%")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.5) : Color(hex: "6B7280"))
                }
                .offset(y: -2)
            }

            Spacer()

            // Bottom: amount + streak
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(fmtCurrency(entry.saved))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "1A1A2E"))
                    Text("/ \(fmtCurrency(entry.target))")
                        .font(.system(size: 9, weight: .regular, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.4) : Color(hex: "9CA3AF"))
                }

                Spacer()

                if entry.streak > 0 {
                    HStack(spacing: 2) {
                        Text("🔥")
                            .font(.system(size: 9))
                        Text("\(entry.streak)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : Color(hex: "1A1A2E"))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark
                                ? Color.white.opacity(0.08)
                                : Color(hex: "F3F4F6"))
                    )
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
        }
    }
}

// MARK: - Medium Widget

struct KiperaMediumView: View {
    let entry: KiperaEntry
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            containerBackground

            if entry.isEmpty {
                emptyStateMedium
            } else {
                mainContentMedium
            }
        }
    }

    private var containerBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(colorScheme == .dark
                ? Color(hex: "1A1A1A")
                : Color(hex: "FAFAFA"))
            .overlay(
                VStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: entry.isCoupleGoal
                                    ? [KD.purple.opacity(0.7), KD.pink.opacity(0.7)]
                                    : [KD.purple.opacity(0.5), KD.purple.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 3)
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                    Spacer()
                }
            )
    }

    private var emptyStateMedium: some View {
        HStack(spacing: 14) {
            Image(systemName: "plus.circle")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(KD.purple.opacity(0.4))

            VStack(alignment: .leading, spacing: 3) {
                Text("No Goal Selected")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : Color(hex: "6B7280"))
                Text("Open Kipera to choose a goal")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.3) : Color(hex: "9CA3AF"))
            }
        }
    }

    private var mainContentMedium: some View {
        VStack(spacing: 0) {
            // Top row: Goal name + streak
            HStack(alignment: .center) {
                Text(entry.goalName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "1A1A2E"))
                    .lineLimit(1)

                Spacer()

                if entry.streak > 0 {
                    HStack(spacing: 2) {
                        Text("🔥")
                            .font(.system(size: 9))
                        Text("\(entry.streak)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : Color(hex: "1A1A2E"))
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark
                                ? Color.white.opacity(0.1)
                                : Color(hex: "F3F4F6"))
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Middle: Journey illustration — people approaching goal from both sides
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let centerX = w * 0.5
                let centerY = h * 0.45
                let p = CGFloat(entry.progress)

                ZStack {
                    if entry.isCoupleGoal {
                        // === COUPLE GOAL: two people approach from both sides ===

                        // Left person position: moves from 0.08 → 0.38 based on progress
                        let leftX = w * (0.08 + p * 0.30)
                        // Right person position: moves from 0.92 → 0.62 based on progress
                        let rightX = w * (0.92 - p * 0.30)

                        // Dotted path: left person → center
                        DottedLine()
                            .stroke(
                                KD.purple.opacity(0.25),
                                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
                            )
                            .frame(width: max(centerX - leftX - 20, 1), height: 1)
                            .position(x: (leftX + centerX) / 2, y: centerY)

                        // Dotted path: right person → center
                        DottedLine()
                            .stroke(
                                KD.pink.opacity(0.25),
                                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
                            )
                            .frame(width: max(rightX - centerX - 20, 1), height: 1)
                            .position(x: (rightX + centerX) / 2, y: centerY)

                        // Left person (purple)
                        Image(systemName: "figure.walk")
                            .font(.system(size: 26, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [KD.purple, KD.purple.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .position(x: leftX, y: centerY)

                        // Right person (pink) — mirrored
                        Image(systemName: "figure.walk")
                            .font(.system(size: 24, weight: .light))
                            .scaleEffect(x: -1, y: 1)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [KD.pink, KD.pink.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .position(x: rightX, y: centerY)

                    } else {
                        // === SOLO GOAL: one person approaches from left ===

                        let personX = w * (0.08 + p * 0.32)

                        // Dotted path: person → goal
                        DottedLine()
                            .stroke(
                                KD.purple.opacity(0.25),
                                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
                            )
                            .frame(width: max(centerX - personX - 20, 1), height: 1)
                            .position(x: (personX + centerX + 14) / 2, y: centerY)

                        // Person
                        Image(systemName: "figure.walk")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [KD.purple, KD.purple.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .position(x: personX, y: centerY)
                    }

                    // === Central Goal Icon ===
                    ZStack {
                        // Outer glow ring
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        KD.purple.opacity(0.12),
                                        KD.purple.opacity(0.04),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 12,
                                    endRadius: 28
                                )
                            )
                            .frame(width: 56, height: 56)

                        // Glass circle
                        Circle()
                            .fill(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.08)
                                    : Color.white
                            )
                            .frame(width: 36, height: 36)
                            .shadow(color: KD.purple.opacity(0.15), radius: 6, x: 0, y: 2)

                        // Star icon
                        Image(systemName: "star.fill")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        // Sparkle accents
                        Image(systemName: "sparkle")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(KD.purple.opacity(0.5))
                            .offset(x: 18, y: -14)

                        Image(systemName: "sparkle")
                            .font(.system(size: 5, weight: .bold))
                            .foregroundColor(KD.pink.opacity(0.4))
                            .offset(x: -16, y: -16)
                    }
                    .position(x: centerX, y: centerY)

                    // Percentage label below goal icon
                    Text("\(Int(entry.progress * 100))%")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.5) : Color(hex: "9CA3AF"))
                        .position(x: centerX, y: centerY + 28)
                }
            }

            // Bottom: Amount + progress bar
            VStack(spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(fmtCurrency(entry.saved))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "1A1A2E"))
                    Text("/ \(fmtCurrency(entry.target))")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.4) : Color(hex: "9CA3AF"))
                    Spacer()
                }

                // Thin progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(colorScheme == .dark
                                ? Color.white.opacity(0.08)
                                : Color(hex: "F0F0F0"))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(
                                LinearGradient(
                                    colors: entry.isCoupleGoal
                                        ? [KD.purple, KD.pink]
                                        : [KD.purpleLight, KD.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geo.size.width * CGFloat(entry.progress), 4), height: 4)
                    }
                }
                .frame(height: 4)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }
}

// MARK: - Widget Config

struct KiperaWidget: Widget {
    let kind: String = "KiperaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KiperaProvider()) { entry in
            if #available(iOS 17.0, *) {
                KiperaWidgetEntryView(entry: entry)
                    .containerBackground(.clear, for: .widget)
            } else {
                KiperaWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Kipera Savings")
        .description("Track your savings goal progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Entry View Router

struct KiperaWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: KiperaEntry

    var body: some View {
        switch family {
        case .systemMedium:
            KiperaMediumView(entry: entry)
        default:
            KiperaSmallView(entry: entry)
        }
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    KiperaWidget()
} timeline: {
    KiperaEntry(date: .now, goalName: "Dream House 🏠", progress: 0.65, saved: 650, target: 1000, colorHex: "A855F7", iconName: "home", streak: 7, isCoupleGoal: true, isEmpty: false)
    KiperaEntry(date: .now, goalName: "New Laptop 💻", progress: 0.30, saved: 450, target: 1500, colorHex: "7C3AED", iconName: "laptop", streak: 3, isCoupleGoal: false, isEmpty: false)
    KiperaEntry(date: .now, goalName: "", progress: 0, saved: 0, target: 0, colorHex: "", iconName: "", streak: 0, isCoupleGoal: false, isEmpty: true)
}

#Preview(as: .systemMedium) {
    KiperaWidget()
} timeline: {
    KiperaEntry(date: .now, goalName: "Dream House 🏠", progress: 0.42, saved: 12600, target: 30000, colorHex: "A855F7", iconName: "home", streak: 14, isCoupleGoal: true, isEmpty: false)
    KiperaEntry(date: .now, goalName: "Emergency Fund 🛡️", progress: 0.88, saved: 4400, target: 5000, colorHex: "7C3AED", iconName: "savings", streak: 21, isCoupleGoal: false, isEmpty: false)
}
