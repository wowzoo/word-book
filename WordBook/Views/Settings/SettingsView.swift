import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [UserSettings]

    @State private var newCardsPerDay: Int = 20
    @State private var maxReviewsPerDay: Int = 200
    @State private var showPronunciation: Bool = true

    var settings: UserSettings? {
        settingsList.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                // Study Settings
                settingsSection(title: "Study Settings") {
                    VStack(alignment: .leading, spacing: 16) {
                        // New Cards Per Day
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("New Cards Per Day")
                                    .font(.subheadline)

                                Spacer()

                                TextField("", value: $newCardsPerDay, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 60)
                                    .multilineTextAlignment(.trailing)
                            }

                            Text("Maximum number of new cards to introduce each day")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Divider()

                        // Max Reviews Per Day
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Max Reviews Per Day")
                                    .font(.subheadline)

                                Spacer()

                                TextField("", value: $maxReviewsPerDay, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 60)
                                    .multilineTextAlignment(.trailing)
                            }

                            Text("Maximum number of cards to review each day")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Divider()

                        // Show Pronunciation
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Show Pronunciation")
                                    .font(.subheadline)

                                Text("Display pronunciation guide on flashcards")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $showPronunciation)
                                .labelsHidden()
                        }
                    }
                }

                // About
                settingsSection(title: "About") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Version")
                                .font(.subheadline)
                            Spacer()
                            Text("1.0.0")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Divider()

                        HStack {
                            Text("Algorithm")
                                .font(.subheadline)
                            Spacer()
                            Text("SM-2 (Spaced Repetition)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Save Button
                Button(action: saveSettings) {
                    Text("Save Settings")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Settings")
        .onAppear(perform: loadSettings)
    }

    // MARK: - Settings Section

    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                content()
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }

    // MARK: - Settings Management

    private func loadSettings() {
        if let settings = settings {
            newCardsPerDay = settings.newCardsPerDay
            maxReviewsPerDay = settings.maxReviewsPerDay
            showPronunciation = settings.showPronunciation
        } else {
            // Create default settings
            let defaultSettings = UserSettings()
            modelContext.insert(defaultSettings)
            try? modelContext.save()
        }
    }

    private func saveSettings() {
        if let settings = settings {
            settings.newCardsPerDay = newCardsPerDay
            settings.maxReviewsPerDay = maxReviewsPerDay
            settings.showPronunciation = showPronunciation
        } else {
            let newSettings = UserSettings(
                newCardsPerDay: newCardsPerDay,
                maxReviewsPerDay: maxReviewsPerDay,
                showPronunciation: showPronunciation
            )
            modelContext.insert(newSettings)
        }

        try? modelContext.save()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserSettings.self], inMemory: true)
}
