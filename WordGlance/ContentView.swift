import SwiftUI
import UserNotifications
import WidgetKit
import Foundation

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showsReview = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView(showsReview: $showsReview)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .onOpenURL { url in
            if url.scheme == "wordglance" && url.host == "study" {
                showsReview = true
            }
        }
    }
}

private struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var step = 0
    @State private var language = "Japanese"
    @State private var goal = "Travel"
    @State private var level = "N5"
    @State private var frequency = 1
    @State private var startHour = 9
    @State private var endHour = 17
    @State private var remindersOn = false

    private let languages = ["Japanese", "English"]
    private let goals = ["Travel", "Conversation", "Career", "School", "Just curious"]
    private let levels = ["N5", "N4", "N3", "N2", "N1"]
    private let frequencyNames = ["Every hour", "Every 2 hours", "Every 4 hours", "Once daily"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if step > 0 { Button { withAnimation { step -= 1 } } label: { Image(systemName: "chevron.left").fontWeight(.bold).padding(12).background(.thinMaterial, in: Circle()) } }
                else { Color.clear.frame(width: 48, height: 48) }
                Spacer()
                Text("WORDGLANCE").font(.caption.weight(.bold)).tracking(2).foregroundStyle(.secondary)
                Spacer()
                Text("\(step + 1)/7").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24).padding(.top, 14)
            ProgressView(value: Double(step + 1), total: 7).tint(.indigo).padding(.horizontal, 24).padding(.top, 10)

            TabView(selection: $step) {
                WelcomePage().tag(0)
                ChoicePage(title: "What language is calling you?", subtitle: "Start with one. You can add others later.", choices: languages, selection: $language).tag(1)
                ChoicePage(title: "What’s your reason?", subtitle: "A small goal makes a daily habit easier to keep.", choices: goals, selection: $goal).tag(2)
                ChoicePage(title: "Where are you starting?", subtitle: "Choose what feels useful, not perfect.", choices: levels, selection: $level).tag(3)
                FrequencyPage(frequency: $frequency, labels: frequencyNames).tag(4)
                QuietHoursPage(startHour: $startHour, endHour: $endHour).tag(5)
                NotificationsPage(remindersOn: $remindersOn).tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            Button(action: next) {
                Text(step == 6 ? "Start WordGlance" : "Continue")
                    .frame(maxWidth: .infinity).padding(.vertical, 17).fontWeight(.bold)
            }
            .buttonStyle(.borderedProminent).tint(.indigo).padding(24)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private func next() {
        if step < 6 { withAnimation { step += 1 }; return }
        let defaults = SharedStudySettings.defaults
        defaults.set(language, forKey: "language")
        defaults.set(goal, forKey: "goal")
        defaults.set(level, forKey: "level")
        defaults.set(frequency, forKey: "frequency")
        defaults.set(startHour, forKey: "startHour")
        defaults.set(endHour, forKey: "endHour")
        WidgetCenter.shared.reloadTimelines(ofKind: "WordGlanceWidget")
        hasCompletedOnboarding = true
    }
}

private struct WelcomePage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Image(systemName: "rectangle.on.rectangle.angled").font(.system(size: 54, weight: .medium)).foregroundStyle(.indigo)
            Text("Make your Lock Screen a little smarter.").font(.system(size: 36, weight: .bold, design: .rounded))
            Text("A useful word arrives during the part of your day you choose. Glance at it now; practice it when you have a moment.").font(.title3).foregroundStyle(.secondary)
            Spacer()
        }.padding(30)
    }
}

private struct ChoicePage: View {
    let title: String; let subtitle: String; let choices: [String]
    @Binding var selection: String
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.largeTitle.bold())
            Text(subtitle).font(.title3).foregroundStyle(.secondary)
            Spacer().frame(height: 16)
            ForEach(choices, id: \.self) { choice in
                Button { selection = choice } label: {
                        HStack { Text(choice).font(.body.weight(.semibold)); Spacer(); Image(systemName: selection == choice ? "checkmark.circle.fill" : "circle").foregroundStyle(selection == choice ? Color.indigo : Color.secondary) }
                        .padding(18).background(selection == choice ? Color.indigo.opacity(0.12) : Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
                }.buttonStyle(.plain)
            }
            Spacer()
        }.padding(30)
    }
}

private struct FrequencyPage: View {
    @Binding var frequency: Int; let labels: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How often should a word find you?").font(.largeTitle.bold())
            Text("Choose a pace that feels pleasantly noticeable—not noisy.").font(.title3).foregroundStyle(.secondary)
            Spacer()
            Image(systemName: "clock.badge.checkmark").font(.system(size: 76)).foregroundStyle(.indigo).frame(maxWidth: .infinity)
            Text(labels[frequency]).font(.system(size: 34, weight: .bold, design: .rounded)).frame(maxWidth: .infinity)
            Picker("Word frequency", selection: $frequency) { ForEach(labels.indices, id: \.self) { Text(labels[$0]).tag($0) } }.pickerStyle(.segmented)
            Text(frequency == 0 ? "A new word at the top of each active hour." : "Words arrive during your active hours.").font(.subheadline).foregroundStyle(.secondary).frame(maxWidth: .infinity)
            Spacer()
        }.padding(30)
    }
}

private struct QuietHoursPage: View {
    @Binding var startHour: Int; @Binding var endHour: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Set your active hours.").font(.largeTitle.bold())
            Text("WordGlance will only schedule words during this window.").font(.title3).foregroundStyle(.secondary)
            Spacer()
            VStack(spacing: 0) {
                Picker("Start", selection: $startHour) { ForEach(5...18, id: \.self) { Text(time($0)).tag($0) } }
                Divider()
                Picker("End", selection: $endHour) { ForEach(6...23, id: \.self) { Text(time($0)).tag($0) } }
            }.padding(.vertical, 6).background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
            Text("Quiet outside \(time(startHour))–\(time(endHour)).").font(.headline).foregroundStyle(.indigo)
            Spacer()
        }.padding(30)
    }
    private func time(_ hour: Int) -> String { (Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now).formatted(date: .omitted, time: .shortened) }
}

private struct NotificationsPage: View {
    @Binding var remindersOn: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Image(systemName: "bell.badge").font(.system(size: 54)).foregroundStyle(.indigo)
            Text("Let words come to you.").font(.largeTitle.bold())
            Text("Get a calm reminder when a new word is ready. No streak pressure and no marketing alerts.").font(.title3).foregroundStyle(.secondary)
            Toggle("Remind me about new words", isOn: $remindersOn).font(.headline).padding().background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
            Text("You can change this any time in Settings.").font(.footnote).foregroundStyle(.secondary)
            Spacer()
        }.padding(30)
        .onChange(of: remindersOn) { _, enabled in if enabled { UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in } } }
    }
}

private struct MainTabView: View {
    @Binding var showsReview: Bool
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            TodayView(showsReview: $showsReview)
                .tabItem { Label("Today", systemImage: "house.fill") }
                .tag(0)
            PracticeView()
                .tabItem { Label("Practice", systemImage: "rectangle.stack.fill") }
                .tag(1)
            CollectionView()
                .tabItem { Label("Collection", systemImage: "books.vertical.fill") }
                .tag(2)
            ProfileView()
                .tabItem { Label("Profile", systemImage: "chart.dots.scatter") }
                .tag(3)
        }
        .tint(.indigo)
        .onChange(of: showsReview) { _, isShowing in
            if isShowing { selection = 0 }
        }
    }
}

private struct TodayView: View {
    @Binding var showsReview: Bool
    @AppStorage("language", store: SharedStudySettings.defaults) private var language = "Japanese"
    @AppStorage("level", store: SharedStudySettings.defaults) private var level = "N5"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showsResetConfirmation = false
    private var currentJapaneseWord: StudyWord { JapaneseWordBank.word(for: level) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("WORDGLANCE")
                        .font(.caption.weight(.bold)).tracking(2).foregroundStyle(.secondary)
                        .onLongPressGesture { showsResetConfirmation = true }
                    Text(language == "Japanese" ? "Your \(level) word is ready." : "English is coming soon.").font(.largeTitle.bold())
                    if language == "Japanese" {
                        Text("TODAY'S WORD")
                            .font(.caption.weight(.bold)).tracking(1.4).foregroundStyle(.indigo)
                            .padding(.top, 4)
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("JLPT \(level)").font(.caption.weight(.bold)).foregroundStyle(.indigo)
                                Spacer()
                                Image(systemName: "sparkle").foregroundStyle(.indigo)
                            }
                            Text(currentJapaneseWord.kanji)
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .minimumScaleFactor(0.55).lineLimit(1)
                            Text(currentJapaneseWord.kana).font(.title2.weight(.bold)).foregroundStyle(.indigo)
                            Text(currentJapaneseWord.romaji).font(.body).foregroundStyle(.secondary)
                            Text("Recall its meaning, then open the card to check yourself.")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        .padding(22)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            LinearGradient(colors: [Color.indigo.opacity(0.16), Color.indigo.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 26)
                        )
                        Button {
                            showsReview = true
                        } label: {
                            Label("Review today's word", systemImage: "arrow.right")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent).tint(.indigo)
                    } else {
                        Text("serendipity").font(.system(size: 43, weight: .bold, design: .rounded))
                        Text("A happy discovery made by chance.").font(.title2).foregroundStyle(.secondary)
                    }
                    Label("To add your widget, press and hold your Home or Lock Screen.", systemImage: "rectangle.on.rectangle")
                        .font(.subheadline).foregroundStyle(.secondary)
                        .padding(.top, 8)
                    Link("Vocabulary data: OpenJLPT · CC BY-SA 4.0", destination: URL(string: "https://github.com/evanclan/OpenJLPT")!)
                        .font(.footnote).foregroundStyle(.secondary)
                }
                .padding(24)
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showsReview) {
                WordReviewView(word: currentJapaneseWord)
            }
            .onAppear { WidgetCenter.shared.reloadTimelines(ofKind: "WordGlanceWidget") }
            .confirmationDialog("Reset setup?", isPresented: $showsResetConfirmation, titleVisibility: .visible) {
                Button("Reset onboarding", role: .destructive) {
                    let defaults = SharedStudySettings.defaults
                    defaults.removeObject(forKey: "language")
                    defaults.removeObject(forKey: "goal")
                    defaults.removeObject(forKey: "level")
                    defaults.removeObject(forKey: "frequency")
                    defaults.removeObject(forKey: "startHour")
                    defaults.removeObject(forKey: "endHour")
                    hasCompletedOnboarding = false
                }
            } message: {
                Text("This clears your setup choices and takes you back to the beginning.")
            }
        }
    }
}

private struct PracticeView: View {
    @AppStorage("level", store: SharedStudySettings.defaults) private var level = "N5"
    @State private var questionOffset = 1
    @State private var selectedAnswer: String?

    private var word: StudyWord {
        let deck = JapaneseWordBank.words(for: level)
        let day = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        let hour = Calendar.current.component(.hour, from: .now)
        return deck[(day * 24 + hour + questionOffset) % deck.count]
    }

    private var choices: [String] {
        let distractors = JapaneseWordBank.words(for: level)
            .filter { $0.id != word.id && $0.meaning != word.meaning }
            .prefix(3)
            .map(\.meaning)
        return (distractors + [word.meaning]).sorted()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("PRACTICE").font(.caption.weight(.bold)).tracking(1.8).foregroundStyle(.indigo)
                    Text("Test your recall.").font(.largeTitle.bold())
                    Text("No definition until after you choose.").font(.body).foregroundStyle(.secondary)

                    VStack(spacing: 10) {
                        Text(word.kanji)
                            .font(.system(size: 66, weight: .bold, design: .rounded))
                            .minimumScaleFactor(0.55).lineLimit(1)
                        Text(word.kana).font(.title2.weight(.bold)).foregroundStyle(.indigo)
                        Text(word.romaji).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 34)
                    .background(Color.indigo.opacity(0.10), in: RoundedRectangle(cornerRadius: 26))

                    Text("What does this mean?").font(.title3.weight(.bold))
                    ForEach(choices, id: \.self) { choice in
                        Button {
                            selectedAnswer = choice
                            StudyProgress.recordPractice()
                        } label: {
                            HStack(spacing: 12) {
                                Text(choice).multilineTextAlignment(.leading)
                                Spacer()
                                answerIcon(for: choice)
                            }
                            .padding(17)
                            .frame(maxWidth: .infinity)
                            .background(answerBackground(for: choice), in: RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .disabled(selectedAnswer != nil)
                    }

                    if let selectedAnswer {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(selectedAnswer == word.meaning ? "Correct" : "The answer")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(selectedAnswer == word.meaning ? .green : .orange)
                            Text(word.meaning).font(.title3.weight(.bold))
                            if !word.exampleJapanese.isEmpty {
                                Text(word.exampleJapanese).font(.subheadline)
                                Text(word.exampleEnglish).font(.footnote).foregroundStyle(.secondary)
                            }
                        }
                        .padding(18)
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
                        Button("Next question") {
                            questionOffset += 1
                            self.selectedAnswer = nil
                        }
                        .buttonStyle(.borderedProminent).tint(.indigo)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(24)
            }
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder private func answerIcon(for choice: String) -> some View {
        if let selectedAnswer {
            Image(systemName: choice == word.meaning ? "checkmark.circle.fill" : (choice == selectedAnswer ? "xmark.circle.fill" : "circle"))
                .foregroundStyle(choice == word.meaning ? .green : (choice == selectedAnswer ? .red : .secondary))
        } else {
            Image(systemName: "circle").foregroundStyle(.secondary)
        }
    }

    private func answerBackground(for choice: String) -> Color {
        guard let selectedAnswer else { return Color(uiColor: .secondarySystemGroupedBackground) }
        if choice == word.meaning { return .green.opacity(0.14) }
        if choice == selectedAnswer { return .red.opacity(0.14) }
        return Color(uiColor: .secondarySystemGroupedBackground)
    }
}

private struct CollectionView: View {
    @AppStorage("level", store: SharedStudySettings.defaults) private var level = "N5"

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Your current \(level) deck").font(.headline)
                    Text("Browse every word currently available to your widget and practice sessions.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                ForEach(JapaneseWordBank.words(for: level)) { word in
                    NavigationLink {
                        WordReviewView(word: word)
                    } label: {
                        HStack(spacing: 14) {
                            Text(word.kanji).font(.title2.weight(.bold)).frame(minWidth: 46, alignment: .leading)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(word.kana).font(.headline)
                                Text(word.meaning).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Collection")
        }
    }
}

private struct ProfileView: View {
    @State private var snapshot = StudyProgress.snapshot()

    private var dots: [Bool] {
        let calendar = Calendar.current
        return (0..<28).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: .now) ?? .now
            return snapshot.activeDays.contains(StudyProgress.key(for: date))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("PROFILE").font(.caption.weight(.bold)).tracking(1.8).foregroundStyle(.indigo)
                    Text("Your learning rhythm.").font(.largeTitle.bold())
                    HStack(spacing: 14) {
                        stat(title: "Current streak", value: "\(snapshot.streak)", detail: snapshot.streak == 1 ? "day" : "days")
                        stat(title: "Today", value: "\(snapshot.wordsToday)", detail: snapshot.wordsToday == 1 ? "practice" : "practices")
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("LAST 4 WEEKS").font(.caption.weight(.bold)).tracking(1.4).foregroundStyle(.secondary)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 10) {
                            ForEach(Array(dots.enumerated()), id: \.offset) { _, active in
                                Circle().fill(active ? Color.indigo : Color(uiColor: .tertiarySystemFill)).frame(height: 18)
                            }
                        }
                        HStack { Text("Less"); Spacer(); Text("More") }
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))

                    Text("A day lights up when you answer a Practice question. Keep the habit gentle and consistent.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(24)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { snapshot = StudyProgress.snapshot() }
        }
    }

    private func stat(title: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            Text(value).font(.system(size: 34, weight: .bold, design: .rounded))
            Text(detail).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.indigo.opacity(0.10), in: RoundedRectangle(cornerRadius: 20))
    }
}

private enum StudyProgress {
    private static let daysKey = "wordglance.activeDays"
    private static let countPrefix = "wordglance.practice."

    static func key(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func recordPractice() {
        let today = key(for: .now)
        var days = UserDefaults.standard.stringArray(forKey: daysKey) ?? []
        if !days.contains(today) {
            days.append(today)
            UserDefaults.standard.set(days, forKey: daysKey)
        }
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: countPrefix + today) + 1, forKey: countPrefix + today)
    }

    static func snapshot() -> (activeDays: Set<String>, streak: Int, wordsToday: Int) {
        let activeDays = Set(UserDefaults.standard.stringArray(forKey: daysKey) ?? [])
        let calendar = Calendar.current
        var streak = 0
        var date = calendar.startOfDay(for: .now)
        while activeDays.contains(key(for: date)) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }
        let today = key(for: .now)
        return (activeDays, streak, UserDefaults.standard.integer(forKey: countPrefix + today))
    }
}

private struct WordReviewView: View {
    let word: StudyWord
    @State private var showsMeaning = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        Text("WORD REVIEW")
                            .font(.caption.weight(.bold))
                            .tracking(1.8)
                            .foregroundStyle(.indigo)
                        Spacer()
                        Text("JLPT \(word.level)")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.indigo.opacity(0.12), in: Capsule())
                    }

                    VStack(spacing: 10) {
                        Text(word.kanji)
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .minimumScaleFactor(0.55)
                            .lineLimit(1)
                        Text(word.kana)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.indigo)
                        Text(word.romaji)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 38)
                    .background(
                        LinearGradient(colors: [Color.indigo.opacity(0.14), Color.indigo.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 28)
                    )

                    Text(showsMeaning ? "Meaning" : "Can you recall it?")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { showsMeaning.toggle() }
                    } label: {
                        HStack {
                            Text(showsMeaning ? word.meaning : "Tap to reveal the meaning")
                                .font(.title3.weight(.bold))
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: showsMeaning ? "eye.slash" : "eye")
                                .fontWeight(.semibold)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)

                    if showsMeaning, !word.exampleJapanese.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("IN CONTEXT")
                                .font(.caption.weight(.bold)).tracking(1.4).foregroundStyle(.secondary)
                            Text(word.exampleJapanese).font(.body.weight(.medium))
                            Text(word.exampleEnglish).font(.subheadline).foregroundStyle(.secondary)
                        }
                        .padding(18)
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding(.top, 82)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.bold))
                        .frame(width: 42, height: 42)
                        .background(.thinMaterial, in: Circle())
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview { ContentView() }
