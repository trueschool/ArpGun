# ArpGun for Renoise

**ArpGun** is a powerful chord and arpeggio generation tool for [Renoise](https://www.renoise.com/), built upon the foundation of the legendary **ChordGun**. It allows you to quickly insert complex chords into your patterns and instantly transform them into a variety of arpeggiated and Euclidean rhythmic patterns across successive lines.

---

## Background

ArpGun is an evolution of **ChordGun**, originally developed by pandabot. While ChordGun focused on rapid chord entry on a single line via OSC, ArpGun extends this functionality natively to support rhythmic "spacing", melodic movement, and polyrhythmic Euclidean generation, making it a complete tool for both harmony and rhythm.

*   **Original Predecessor:** [ChordGun on Renoise Forums](https://forum.renoise.com/t/new-tool-chordgun/50005)

---

## Key Features

-   **Native Note Auditioning:** Uses the Renoise 6.2 native note triggering API to audition instruments directly without any messy OSC local-server setup!
-   **Scale-Aware Chord Entry:** Select a key and scale, and ArpGun provides a custom interface of valid chords for that scale.
-   **Integrated Arpeggiator:** Transform any chord into a rhythmic sequence.
    -   **Patterns:** Up, Down, Up/Down, Down/Up, Up/Down/Up, Down/Up/Down, Strum Up, Strum Down, and Dyads.
    -   **Standard Step Timing:** Control the rhythmic spacing with fixed step sizes (1, 2, 3, 4, 6, 8, 12, 16, or 32 lines).
    -   **Euclidean Rhythms:** Switch the Timing mode to "Euclidean" to distribute notes using complex polyrhythms based on Hits, Length, and Shift.
-   **Multiple Write Modes:**
    -   *Merge:* Adds notes without clearing surrounding column data.
    -   *Overwrite:* Replaces existing notes in the target range by clearing relevant columns first.
-   **Inversion Control:** Easily cycle through chord inversions.
-   **Custom Keybinding Support:** Fully optimized for keyboard-heavy workflows with customizable shortcuts.

---

## Installation

**Requirements:** Renoise 3.4.0 or newer (requires API Version 6.2 for native note playing).

1.  Download the `ArpGun_v1.0.xrnx` file.
2.  Drag and drop the file onto the Renoise window.
3.  Access the tool via **Tools -> ArpGun** or by assigning a keyboard shortcut.

---

## Usage Documentation

### Basic Chord Entry
1.  Open the ArpGun interface.
2.  Choose your **Tonic** (Key) and **Scale Type**.
3.  Click any of the chord buttons to insert that chord at the current cursor position in the pattern editor.
4.  Toggle **Edit Mode** in Renoise to either *write* the notes into the pattern (Edit Mode ON) or just *audition* them using the selected instrument (Edit Mode OFF).

### Using the Arpeggiator
1.  Set the **Arp Mode** to "merge" or "overwrite".
2.  Choose an **Arp Pattern** (e.g., "Up" or "Dyads").
3.  Choose your **Timing Mode**:
    *   **Standard:** Use the **Arp Step** dropdown to choose a fixed line gap between notes (e.g., every 4 lines).
    *   **Euclidean:** Define a polyrhythm.
        *   **Hits:** The number of notes to play.
        *   **Len:** The total number of lines in the sequence loop.
        *   **Shift:** Offsets the starting position of the rhythm.
4.  Select a chord. ArpGun will now automatically spread the notes of that chord across the pattern track based on your pattern and timing settings.

### Keyboard Shortcuts
ArpGun is designed to be used without a mouse. You can bind these in **Edit -> Preferences -> Keys** (search for "ArpGun").

The default "power-user" bindings included in the plugin package (and used by the developer) are:
-   `Shift + Option + 1-7`: Insert Scale Chord
-   `Shift + Option + [` / `]`: Change Chord Inversion
-   `Shift + Option + -` / `=`: Change Chord Type
-   `Shift + Option + 9` / `0`: Change Scale Tonic
-   `Shift + Option + ,` / `.`: Change Arp Pattern
-   `Shift + Option + ;` / `'`: Change Arp Step

*Note: On Windows/Linux, the "Option" key corresponds to the "Alt" key.*

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Credits

-   **Original ChordGun Logic:** pandabot
-   **Arpeggiator Extensions & UI:** TrueSchool
