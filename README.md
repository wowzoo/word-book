# WordBook

A native macOS vocabulary learning application with Spaced Repetition System (SRS) for efficient language learning.

## Features

### 📚 Deck & Card Management
- Create and organize multiple vocabulary decks
- Add cards with word, definition, examples, and notes
- Edit and delete cards easily
- Search and filter cards by learning state

### 🧠 Spaced Repetition System (SRS)
- SM-2 algorithm implementation for optimal learning intervals
- Automatic scheduling based on your performance
- Four difficulty ratings: Again, Hard, Good, Easy
- Track learning progress with detailed statistics

### 🎴 Interactive Flashcards
- Beautiful 3D flip animation
- Front view shows the word
- Back view displays definition, examples, and notes
- Integrated Naver Dictionary search link

### 📤 Export & Import
- Export decks to JSON format (`.json`)
- Import decks with full SRS progress preservation
- Share decks between multiple Macs
- Automatic UUID regeneration to prevent conflicts

### 📊 Learning Statistics
- Track total reviews and accuracy
- Monitor learning states (New, Learning, Mastered)
- View upcoming review schedule
- Card-level statistics (interval, ease factor, etc.)

### 🔗 Dictionary Integration
- One-click Naver Dictionary search
- Direct browser link from card view
- Real-time URL generation as you type

## Screenshots

<!-- Add screenshots here -->
Coming soon...

## Tech Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Persistence**: SwiftData
- **Minimum macOS**: 15.0 (Sequoia)
- **Architecture**: MVVM

## Installation

### Requirements
- macOS 15.0 (Sequoia) or later
- Xcode 15.0 or later

### Build from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/WordBook.git
cd WordBook
```

2. Open the project in Xcode:
```bash
open WordBook.xcodeproj
```

3. Build and run (⌘R)

### Install App

1. Build Archive in Xcode:
   - Product → Archive
   - Distribute App → Copy App
   - Export to desired location

2. Copy to Applications folder:
```bash
cp -R WordBook.app /Applications/
```

## Usage

### Creating a Deck
1. Click "New Deck" in the Deck List
2. Enter deck name, description, and choose a color
3. Click "Create"

### Adding Cards
1. Select a deck
2. Click "Add Card"
3. Fill in:
   - **Word**: The vocabulary word
   - **Definition**: Meaning or translation
   - **Example** (optional): Sample sentence
   - **Notes** (optional): Additional information
4. Click "Add"

### Studying
1. Select a deck with due cards
2. Click "Study Now"
3. Review the word, click "Show Answer"
4. Rate your recall:
   - **Again**: Restart learning
   - **Hard**: Review sooner
   - **Good**: Normal interval
   - **Easy**: Longer interval

### Export/Import
**Export:**
1. Right-click a deck
2. Select "Export..."
3. Choose save location
4. Saves as `DeckName_YYYY-MM-DD.json`

**Import:**
1. Click "Import" button
2. Select JSON file
3. Deck automatically imported with all progress

## File Format

Exported decks use JSON format:

```json
{
  "version": "1.0",
  "exportedAt": "2025-12-23T10:30:00Z",
  "deck": {
    "name": "English Vocabulary",
    "cards": [
      {
        "front": "abandon",
        "back": "to give up completely",
        "example": "He abandoned his car.",
        "learningState": "learning",
        "easeFactor": 2.5,
        "interval": 6,
        "nextReviewDate": "2025-12-29T00:00:00Z"
      }
    ]
  }
}
```

## Learning Algorithm

WordBook uses the **SM-2 (SuperMemo 2)** algorithm:

- **Ease Factor**: Adjusts based on performance (default: 2.5)
- **Intervals**: Gradually increase with successful reviews
- **States**: New → Learning → Mastered → Relearning (if needed)

## Project Structure

```
WordBook/
├── Models/
│   ├── Deck.swift
│   ├── Card.swift
│   ├── StudySession.swift
│   └── DeckExportDTO.swift
├── ViewModels/
│   ├── DeckListViewModel.swift
│   ├── CardManagementViewModel.swift
│   └── StudyViewModel.swift
├── Views/
│   ├── DeckList/
│   ├── CardManagement/
│   ├── Study/
│   └── Statistics/
├── Services/
│   ├── StudySessionManager.swift
│   └── DeckExportImportService.swift
└── DesignSystem/
    ├── Typography.swift
    ├── ColorTheme.swift
    └── VisualEffects.swift
```

## Keyboard Shortcuts

### Study Mode
- `Space` - Show Answer
- `1` - Again
- `2` - Hard
- `3` - Good
- `4` - Easy

### General
- `⌘N` - New Deck/Card
- `⌘W` - Close Window
- `Esc` - Cancel/Close

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by Anki and other SRS-based learning tools
- SM-2 algorithm by Piotr Woźniak
- Built with SwiftUI and SwiftData

## Contact

- GitHub: [@yourusername](https://github.com/yourusername)
- Issues: [GitHub Issues](https://github.com/yourusername/WordBook/issues)

## Roadmap

- [ ] Statistics dashboard with charts
- [ ] Custom card templates
- [ ] Image support for cards
- [ ] Audio pronunciation (TTS)
- [ ] iOS companion app
- [ ] Cloud sync
- [ ] Dark mode customization
- [ ] Multiple dictionary integrations

---

Made with ❤️ for language learners
