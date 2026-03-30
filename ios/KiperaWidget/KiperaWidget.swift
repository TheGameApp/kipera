// =============================================================================
// KiperaWidget — iOS Home Screen Widget (SwiftUI)
// =============================================================================
//
// HOW TO SET UP IN XCODE:
// 1. Open ios/Runner.xcworkspace in Xcode
// 2. File > New > Target > Widget Extension
// 3. Name it "KiperaWidget"
// 4. Under "Signing & Capabilities" for both Runner and KiperaWidget:
//    a. Add "App Groups" capability
//    b. Add group: "group.com.kipera.app"
// 5. Replace the auto-generated Swift file with the content below
// 6. In the widget's Info.plist, set the App Group:
//    <key>HomeWidgetAppGroupId</key>
//    <string>group.com.kipera.app</string>
//
// SHARED DATA KEYS (from Flutter WidgetService):
//   - goal_name      : String — goal display name
//   - goal_progress  : Double — 0.0 to 1.0
//   - goal_saved     : Double — total saved amount
//   - goal_target    : Double — target amount
//   - goal_color     : String — hex color (e.g., "FFD700")
//   - goal_icon      : String — icon name
//   - goal_streak    : Int    — current streak
//   - goal_is_couple : Bool   — couple goal flag
//   - last_updated   : String — ISO8601 timestamp
// =============================================================================

/*
import WidgetKit
import SwiftUI

// MARK: - Data Provider

struct KiperaEntry: TimelineEntry {
    let date: Date
    let goalName: String
    let progress: Double
    let saved: Double
    let target: Double
    let colorHex: String
    let streak: Int
    let isCoupleGoal: Bool
}

struct KiperaProvider: TimelineProvider {
    let appGroupId = "group.com.kipera.app"

    func placeholder(in context: Context) -> KiperaEntry {
        KiperaEntry(
            date: Date(),
            goalName: "My Goal",
            progress: 0.65,
            saved: 325,
            target: 500,
            colorHex: "A855F7",
            streak: 7,
            isCoupleGoal: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (KiperaEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<KiperaEntry>) -> Void) {
        let entry = loadEntry()
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> KiperaEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        return KiperaEntry(
            date: Date(),
            goalName: defaults?.string(forKey: "goal_name") ?? "No Goal Selected",
            progress: defaults?.double(forKey: "goal_progress") ?? 0.0,
            saved: defaults?.double(forKey: "goal_saved") ?? 0.0,
            target: defaults?.double(forKey: "goal_target") ?? 0.0,
            colorHex: defaults?.string(forKey: "goal_color") ?? "A855F7",
            streak: defaults?.integer(forKey: "goal_streak") ?? 0,
            isCoupleGoal: defaults?.bool(forKey: "goal_is_couple") ?? false
        )
    }
}

// MARK: - Widget View

struct KiperaWidgetView: View {
    let entry: KiperaEntry

    var goalColor: Color {
        Color(hex: entry.colorHex) ?? .purple
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(entry.goalName)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)

                Spacer()

                if entry.isCoupleGoal {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.pink)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(goalColor)
                        .frame(width: geometry.size.width * entry.progress, height: 8)
                }
            }
            .frame(height: 8)

            // Stats
            HStack {
                Text("$\(Int(entry.saved))")
                    .font(.system(size: 16, weight: .bold))

                Text("/ $\(Int(entry.target))")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Spacer()

                // Streak badge
                if entry.streak > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        Text("\(entry.streak)")
                            .font(.system(size: 11, weight: .medium))
                    }
                }
            }

            // Percentage
            Text("\(Int(entry.progress * 100))% complete")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(12)
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            return nil
        }
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Widget Configuration

@main
struct KiperaWidget: Widget {
    let kind: String = "KiperaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KiperaProvider()) { entry in
            KiperaWidgetView(entry: entry)
        }
        .configurationDisplayName("Kipera Savings")
        .description("Track your savings goal progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
*/
