# Meet Transcriber — v2a

Single self-contained web app: capture a **live meeting tab's audio** (Google Meet, Zoom on web, any
tab), your microphone, or both, and watch a transcript build in real time — with a clickable timeline,
auto summary, and action items. Everything runs **in the browser** with OpenAI Whisper via
[transformers.js](https://github.com/huggingface/transformers.js).

**No upload · no account · no API key · no Google OAuth · 100% private.**

## What's in v2a (new vs v0)

1. **Live tab / system-audio capture** — `getDisplayMedia({ audio: true, video: true })`. Pick the Meet
   tab and tick "Share tab audio". No OAuth — pure browser screen-share audio.
2. **Mic / Tab / Both** — source selector. "Both" mixes mic + tab via the Web Audio graph.
3. **Streaming transcription** — incoming audio is sliced into ~20 s windows and fed to the in-browser
   Whisper pipeline, so the transcript + timeline grow live during the meeting. If the CPU falls behind,
   the oldest backlog is skipped (with a visible marker) to stay near real time.
4. **Client-side summary + action items** — extractive summary + PT/EN cue-based action items &
   decisions run on every update. An optional **✨ AI summary** button loads a small in-browser LLM
   (`Xenova/distilbart-cnn-6-6`, WebGPU when available) for an abstractive summary, with graceful
   fallback to the extractive one if it's unavailable.
5. **Export** — transcript + summary as `.txt`, `.md`, `.srt`, `.vtt`. History saved on-device
   (transcript only — audio is never stored).

Carried over from v0: file upload + whole-file transcription, model picker (tiny/base/small),
language/task selectors, search, clickable timeline, on-device history.

## Browser support

- **Live tab capture:** Chrome / Edge desktop (WebGPU = fast; WASM/CPU works, pick the **Tiny** model).
- Degrades gracefully where WebGPU is missing (CPU transcription + extractive summary).
- Mic capture and file upload work in any modern browser.

## Files

- `index.html` — the entire app (HTML + CSS + ESM JS, no build step).
- `200.html` — identical copy, for the surge SPA fallback.

## Deploy (static, surge — same as v0)

No build step. Publish the folder as-is:

```sh
surge ./ meet-transcriber-spa.surge.sh
```

(`index.html` + `200.html` only.) Any static host works too.
