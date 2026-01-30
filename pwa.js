let deferredPrompt;
const installBtn = document.getElementById('installBtn');

window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  deferredPrompt = e;
  if (installBtn) {
    installBtn.hidden = false;
  }
});

if (installBtn) {
  installBtn.addEventListener('click', async () => {
    if (!deferredPrompt) return;
    deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    if (outcome === 'accepted') {
      console.log('User accepted A2HS');
    }
    deferredPrompt = null;
    installBtn.hidden = true;
  });
}

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker
      .register('service-worker.js')
      .then((registration) => {
        console.log('Service worker registered');

        // Listen for updates to the service worker.
        registration.addEventListener('updatefound', () => {
          const newWorker = registration.installing;
          if (!newWorker) return;

          newWorker.addEventListener('statechange', () => {
            // When the new worker is installed and there's an existing controller,
            // it means an updated version is ready.
            if (
              newWorker.state === 'installed' &&
              navigator.serviceWorker.controller
            ) {
              // Simple strategy for now: log and force a reload so users get the
              // latest version without having to kill the app manually.
              console.log('New Memo Diary version available; reloading...');
              newWorker.postMessage({ type: 'SKIP_WAITING' });
            }
          });
        });

        // When the new worker takes control, reload once to pick up fresh assets.
        navigator.serviceWorker.addEventListener('controllerchange', () => {
          window.location.reload();
        });
      })
      .catch((err) => console.error('SW registration failed', err));
  });
}
