# Auto Script: Watch Web Videos FAST

Get the most out of online videos in minutes, not hours.

For a detailed video guide, visit [your-link-here].

---

## Quick Setup

1. **Download Model**
    - If your `models` folder is empty, download a model from [Whisper.cpp on HuggingFace](https://huggingface.co/ggerganov/whisper.cpp/tree/main).
    - **Recommended:** [`ggml-small.bin`](https://huggingface.co/ggerganov/whisper.cpp/blob/main/ggml-small.bin)
    - Place the downloaded file into the `models` directory.
2. **Run the Script**
    - Double-click `run.bat`.
    - Two windows will open: a terminal (“Freevian Downloader”) and `WhisperDesktop.exe`.
3. **Select the Model**
    - In WhisperDesktop, paste the full path to the model file you just downloaded. Click OK.
4. **Download Audio**
    - In the terminal window, paste the video URL (YouTube or other supported sites). Press Enter.
5. **Transcribe Audio**
    - Once download is complete, the audio file path is copied to your clipboard.
    - In WhisperDesktop, click the “Transcribe File” field, paste (`Ctrl+V`) the path, and confirm.
    - On the next page, select output as “Text file” and check “Place that file to the input folder”.
6. **Finish**
    - Close all windows. Your transcript will be saved in the target folder.

---

## Efficient Workflow

1. **Open `run.bat`.**
2. **Paste a video URL** into the terminal.
3. **Minimize windows.** The script will alert you when the audio is ready.
4. **Paste the audio path** (auto-copied to clipboard) into WhisperDesktop’s “Transcribe File” input.
    - Use `Ctrl+A` to select, `Ctrl+V` to paste.
5. **Set the language**, click `Transcribe`.
    - Minimize and wait; you’ll get a notification sound when done.
6. **Get the transcript:**
    - In the terminal, type `v` (or `V`). The entire transcript is copied to your clipboard.
    - Paste it into any LLM or tool to analyze the content instantly.

---

**Tip:**

You only need to set up the model once. After that, the workflow is almost fully automated.