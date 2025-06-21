# 🚀 Fully Automated Video-to-Text Transcriber

> Go from a video URL to a full text transcript in minutes, completely hands-free.

This tool streamlines the entire process of transcribing web videos. Forget tedious clicking, copying, and pasting. Just provide a URL, and the script handles the rest—from downloading the audio to running the AI model—delivering a clean text file automatically.

---

## ✨ Features

* **Fully Automated**: Zero manual intervention required after pasting the URL.
* **Configuration-Driven**: All settings (model, language, etc.) are managed in a simple `config.json` file. No need to edit the script.
* **Smart GPU Selection**: Automatically detects and uses your dedicated GPU (NVIDIA/AMD) for maximum performance, with a manual override option.
* **Powerful In-Terminal Commands**: Quickly switch languages or copy the latest transcript to your clipboard without ever leaving the terminal.

---

## ⚙️ Quick Setup

Get up and running with two simple steps.

### 1. 📥 Download an AI Model

* If your `models` folder is empty, download a model from [Whisper.cpp on HuggingFace](https://huggingface.co/ggerganov/whisper.cpp/tree/main).
* **Recommended Model**: [`ggml-small.bin`](https://huggingface.co/ggerganov/whisper.cpp/blob/main/ggml-small.bin) (A great balance of performance and accuracy).
* Place the downloaded `.bin` file into the `models` directory.

### 2. ✍️ Edit the Configuration

* Open the `config.json` file located in the root directory.
* Update the `model_path` to point to the model you just downloaded.
* Set the default `language` you will be transcribing most often (e.g., `"en"` for English, `"ja"` for Japanese).

```json
{
  "model_path": "models/ggml-small.bin",
  "language": "en",
  "gpu_index": null
}
```

> **Tip**: Leave `gpu_index` as `null` to enable automatic GPU selection. Only change it to a number (like `0` or `1`) if you need to manually specify which GPU to use.

---

## ▶️ Workflow

Once configured, using the tool is effortless:

1. Double-click `run.bat` to start the script.
2. At the `>>` prompt, paste a video URL and press **Enter**.
3. That's it! Watch as the script automates the entire process.

---

## ⚡️ In-Terminal Commands

While the script is running, you can use these commands at the `>>` prompt:

* **`v`** + Enter: **📋 Copy Transcript**
  * Instantly finds the most recently generated `.txt` file and copies its entire content to your clipboard.
* **`l`** + Enter: **🌐 Change Language**
  * Displays a list of all available languages and prompts you to enter a new language code for on-the-fly switching.
* **Just Press Enter** (on an empty line): **👋 Exit**
  * Safely terminates the program.

---

> **Note**: On its first run, Windows may show a security warning because the script is unsigned. Click “More info” and then “Run anyway” to proceed.
