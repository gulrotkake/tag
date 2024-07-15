# Tag

## What is Tag

Tag is a small utility to track working hours. Entries are stored in `~/.tag/tag.csv`. The CSV is used to generate [summary reports](https://github.com/gulrotkake/tag-report). 

## Usage

- Shift-Command-Space is the hotkey that triggeres the task dialog, allowing quickly starting/modifying/finishing tasks.

- Typing a string starts working on a task from the current time. If the string is prefixed with a timestamp, start is set to the prefixed timestamp:

<img width="337" alt="prefix-timestamp" src="https://github.com/gulrotkake/tag/assets/539077/cd64efe8-350b-4a56-a718-8a7526c139e5">

- When typing `#` a tag is created, a string can contain multiple tags and these are stored separately in the CSV-file. `#` in the UI will trigger completion on known tags:

<img width="332" alt="completion" src="https://github.com/gulrotkake/tag/assets/539077/30f99bd3-2298-400d-bc1b-8267844a8af2">

- Entering an empty string will sign you at the current timestamp. If just a timestamp is entered, and no description string, you will be signed out at that timestamp:

<img width="340" alt="signout" src="https://github.com/gulrotkake/tag/assets/539077/f8d2d09e-5347-48fc-93f9-fca914908369">

- Right-clicking (or option-click) triggers a menu. Use this to quit Tag:

<img width="129" alt="quit" src="https://github.com/gulrotkake/tag/assets/539077/bc1de7af-11c3-44fd-bd0f-f471e85c7b8f">

## CSV Format

The CSV format is:

```
UTC start, UTC stop, tags, description
```

Each start timestamp must be greater than or equal to the previous stop timestamp. The last line can leave the stop timestamp blank to indicate an ongoing task. When the UI is used to complete or change a task, the stop is written. 

## History

Tag is a program that I wrote a long time ago. It was initially abandoned, without being released, as I didn't need it, but work circumstances changed and now I'm working on resurrecting it. See [https://tightloop.io/resurrection/index.html](https://tightloop.io/resurrection/index.html) for a more in-depth story.

## Video

https://github.com/gulrotkake/tag/assets/539077/5978def3-9136-432f-a8d6-66c67b78ffd5
