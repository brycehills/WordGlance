import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WordEntry { .sample }

    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        completion(word(for: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let nextHour = calendar.nextDate(after: now, matching: DateComponents(minute: 0, second: 0), matchingPolicy: .nextTime) ?? now
        let dates = [now] + (0..<12).compactMap { calendar.date(byAdding: .hour, value: $0, to: nextHour) }
        let entries = dates.map { date -> WordEntry in
            word(for: date)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func word(for date: Date) -> WordEntry {
        let level = SharedStudySettings.defaults.string(forKey: "level") ?? "N5"
        let word = JapaneseWordBank.word(for: level, at: date)
        return WordEntry(date: date, word: word.kanji, definition: "\(word.kana)  •  \(word.meaning)")
    }
}

struct WordEntry: TimelineEntry {
    let date: Date
    let word: String
    let definition: String
    static let sample = WordEntry(date: .now, word: "会う", definition: "あう  •  to meet")
}

struct WordGlanceWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family

    private var reading: String {
        entry.definition.components(separatedBy: "  •  ").first ?? entry.definition
    }

    private var meaning: String {
        entry.definition.components(separatedBy: "  •  ").dropFirst().first ?? ""
    }

    // A Lock Screen slot can be much narrower than the Home Screen widget.
    // Keep longer Japanese words on one compact, predictable line there.
    private var lockScreenWordSize: CGFloat {
        switch entry.word.count {
        case ...2: 27
        case 3...4: 22
        default: 18
        }
    }

    var body: some View {
        Group {
            if family == .accessoryRectangular {
                VStack(alignment: .leading, spacing: 1) {
                    Text(entry.word)
                        .font(.system(size: lockScreenWordSize, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                        .allowsTightening(true)
                        .layoutPriority(1)
                    Text(reading)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(meaning)
                        .font(.caption2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("WORDGLANCE").font(.caption2.weight(.bold)).tracking(1).foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                    Text(entry.word).font(.title2.bold()).minimumScaleFactor(0.7).lineLimit(1)
                    Text(entry.definition).font(.caption).foregroundStyle(.secondary).lineLimit(3)
                }
            }
        }
        .widgetURL(URL(string: "wordglance://study"))
        .containerBackground(for: .widget) { Color.clear }
    }
}

struct WordGlanceWidget: Widget {
    let kind = "WordGlanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WordGlanceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WordGlance")
        .description("See a new word throughout your day.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) { WordGlanceWidget() } timeline: { WordEntry.sample }
