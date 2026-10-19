#!/usr/bin/env python3
"""Seva ya preview ya Hadithi Studio — static, threaded, yenye gzip.

Kwa nini seva maalum badala ya `python3 -m http.server`?

`http.server` ya kawaida ina matatizo mawili yanayoonekana moja kwa moja kwa
mtumiaji:

1. **Ni single-threaded.** Kivinjari hufungua maombi 6+ kwa wakati mmoja
   (HTML, JS, wasm, fonts, picha). Seva hiyo huyashughulikia moja baada ya
   mwingine — hivyo ukurasa huchukua dakika kadhaa kufunguka, na mtumiaji
   hudhani link imekufa.
2. **Haitumii gzip.** `main.dart.js` yetu ni ~3.1 MB. Kwa gzip inashuka
   hadi ~0.7 MB — mara nne zaidi kwa mtandao wa polepole.

Kwa hivyo: `ThreadingHTTPServer` + gzip, pamoja na MIME types sahihi
(`.wasm` ni `application/wasm`, si `text/plain` — CanvasKit haipaki bila
hiyo kwenye baadhi ya vivinjari).
"""

from __future__ import annotations

import gzip
import io
import os
import sys
import threading
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

# ---------------------------------------------------------------------------
# MIME types — nyongeza juu ya yale ya Python
# ---------------------------------------------------------------------------
EXTRA_MIME = {
    ".js": "application/javascript; charset=utf-8",
    ".mjs": "application/javascript; charset=utf-8",
    ".wasm": "application/wasm",
    ".json": "application/json; charset=utf-8",
    ".otf": "font/otf",
    ".ttf": "font/ttf",
    ".woff": "font/woff",
    ".woff2": "font/woff2",
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".webp": "image/webp",
    ".svg": "image/svg+xml",
    ".riv": "application/octet-stream",
    ".mp3": "audio/mpeg",
    ".wav": "audio/wav",
}

# Aina ambazo gzip huleta faida halisi. `.wasm` na fonts zimeachwa nje kwa
# sababu tayari zimebanwa, na gzip huongeza tu CPU bila kupunguza ukubwa.
COMPRESSIBLE = {
    ".js",
    ".mjs",
    ".json",
    ".html",
    ".css",
    ".svg",
    ".txt",
    ".map",
    ".xml",
}

MIN_GZIP_BYTES = 1024


class PreviewHandler(SimpleHTTPRequestHandler):
    """Hutumikia faili za build/web kwa gzip na headers rafiki."""

    protocol_version = "HTTP/1.1"  # keep-alive — muhimu kwa maombi mengi

    def guess_type(self, path):  # noqa: D102
        ext = os.path.splitext(str(path))[1].lower()
        if ext in EXTRA_MIME:
            return EXTRA_MIME[ext]
        return super().guess_type(path)

    def end_headers(self):  # noqa: D102
        # Hakuna caching kwenye preview: tunabadilisha build mara kwa mara,
        # na build ya zamani iliyohifadhiwa ni chanzo cha mkanganyiko.
        self.send_header("Cache-Control", "no-store, must-revalidate")
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()

    def _send_gzip(self, body: bytes, content_type: str) -> None:
        raw = io.BytesIO()
        with gzip.GzipFile(fileobj=raw, mode="wb", compresslevel=6) as gz:
            gz.write(body)
        compressed = raw.getvalue()
        # Hutuma gzip tu ikiwa imepunguza ukweli — la sivyo hutuma mbichi.
        if len(compressed) >= len(body):
            self._send_plain(body, content_type)
            return
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Encoding", "gzip")
        self.send_header("Content-Length", str(len(compressed)))
        self.send_header("Vary", "Accept-Encoding")
        self.end_headers()
        self.wfile.write(compressed)

    def _send_plain(self, body: bytes, content_type: str) -> None:
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):  # noqa: N802
        path = self.translate_path(self.path.split("?", 1)[0])
        if not os.path.isfile(path):
            return super().do_GET()

        ext = os.path.splitext(path)[1].lower()
        accepts_gzip = "gzip" in self.headers.get("Accept-Encoding", "")

        try:
            with open(path, "rb") as handle:
                body = handle.read()
        except OSError:
            return super().do_GET()

        content_type = self.guess_type(path)
        if (
            accepts_gzip
            and ext in COMPRESSIBLE
            and len(body) >= MIN_GZIP_BYTES
        ):
            self._send_gzip(body, content_type)
        else:
            self._send_plain(body, content_type)


def main() -> int:
    root = sys.argv[1] if len(sys.argv) > 1 else "build/web"
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 8080
    if not os.path.isdir(root):
        print(f"Kosa: saraka haipo — {root}", file=sys.stderr)
        return 1

    handler = partial(PreviewHandler, directory=root)
    server = ThreadingHTTPServer(("127.0.0.1", port), handler)
    server.daemon_threads = True

    print(f"Hadithi preview: http://127.0.0.1:{port}/  (root={root})")
    print("Threaded + gzip. Ctrl-C kusimamisha.")
    sys.stdout.flush()

    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    try:
        thread.join()
    except KeyboardInterrupt:
        pass
    finally:
        server.shutdown()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
