# Drift on Web — prerequisites

Drift uses a WebAssembly build of sqlite3 plus a drift worker.

## Required files
Place these in `apps/mobile/web/`:
- `sqlite3.wasm`
- `drift_worker.js`

These **must match the versions** used by pub packages (check `pubspec.lock`):
- `sqlite3.wasm` from sqlite3.dart release matching `sqlite3` major version (drift 2.x requires sqlite3 2.x)
- `drift_worker.js` from drift release matching your `drift` version

## Content-Type
Your server must serve `.wasm` files with:
- `Content-Type: application/wasm`

## Optional headers (recommended)
For best performance/storage (OPFS + shared memory), serve with:
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Embedder-Policy: require-corp`

During dev:
```bash
flutter run -d web-server \
  --web-header=Cross-Origin-Opener-Policy=same-origin \
  --web-header=Cross-Origin-Embedder-Policy=require-corp
```
