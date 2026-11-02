import SwiftUI

@main
struct PlanetDayApp: App {
    var body: some Scene {
        WindowGroup {
            TodayView()
        }
    }
}

struct TodayView: View {
    private let heroSymbolSize: CGFloat = 64
    private let symbolColumnWidth: CGFloat = 24

    var body: some View {
        // Re-evaluate every minute so the view flips at midnight while open.
        TimelineView(.everyMinute) { context in
            let today = Planet.ruling(context.date)
            ScrollView {
                VStack(spacing: 6) {
                    Text(today.symbol)
                        .font(.system(size: heroSymbolSize))
                        .accessibilityLabel(today.name)
                    Text(today.name)
                        .font(.headline)
                    Divider()
                    ForEach(Planet.all) { planet in
                        WeekRow(planet: planet, isToday: planet == today, symbolWidth: symbolColumnWidth)
                    }
                    Text("Add the Planet of the Day complication from the watch face editor.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct WeekRow: View {
    let planet: Planet
    let isToday: Bool
    let symbolWidth: CGFloat

    var body: some View {
        HStack {
            Text(planet.symbol).frame(width: symbolWidth)
            Text(planet.dayAbbreviation)
            Spacer()
            Text(planet.name).foregroundStyle(isToday ? .primary : .secondary)
        }
        .fontWeight(isToday ? .bold : .regular)
        .accessibilityElement(children: .combine)
    }
}
