import WidgetKit
import SwiftUI

struct DayEntry: TimelineEntry {
    let date: Date
    private var planet: Planet { Planet.ruling(date) }
    var symbol: String { planet.symbol }
    var name: String { planet.dayAbbreviation }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry { DayEntry(date: .now) }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) {
        completion(DayEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        // One entry per midnight for the next week, so the symbol flips on time.
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let entries = (0..<7).map { offset in
            DayEntry(date: offset == 0 ? .now : cal.date(byAdding: .day, value: offset, to: today)!)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct PlanetDayView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DayEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            Text("\(entry.symbol) \(entry.name)")
        case .accessoryRectangular:
            HStack {
                Text(entry.symbol).font(.system(size: 40))
                Text(entry.name).font(.headline)
            }
        default: // circular, corner
            Text(entry.symbol)
                .font(.system(size: 32, weight: .regular))
                .minimumScaleFactor(0.5)
                .widgetLabel(entry.name)
        }
    }
}

struct PlanetDayWidget: Widget {
    let kind = "PlanetDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PlanetDayView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Planet of the Day")
        .description("Shows the planetary symbol for today's weekday.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular])
    }
}

@main
struct PlanetDayBundle: WidgetBundle {
    var body: some Widget { PlanetDayWidget() }
}
