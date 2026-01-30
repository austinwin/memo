// Memo Diary service worker
// - Uses explicit cache versioning for safe PWA updates
// - Cleans up old caches on activate so users get fresh code after deploys

const CACHE_VERSION = 'v2'; // bump this on each deploy that changes assets
const CACHE_NAME = `memo-diary-cache-${CACHE_VERSION}`;

const OFFLINE_URLS = [
  './',
  './index.html',
  './styles.css',
  './app.js',
  './pwa.js',
  './manifest.json',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(OFFLINE_URLS))
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys
            .filter(
              (key) =>
                key.startsWith('memo-diary-cache-') && key !== CACHE_NAME
            )
            .map((key) => caches.delete(key))
        )
      )
      .then(() => self.clients.claim())
  );
});

self.addEventListener('message', (event) => {
  if (!event.data) return;
  if (event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET') return;

  event.respondWith(
    caches.match(request).then((cached) => {
      if (cached) return cached;
      return fetch(request).catch(() => caches.match('./index.html'));
    })
  );
});
