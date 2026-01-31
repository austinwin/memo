export const PWA = {
  elements: {
    installBtn: null
  },
  
  deferredPrompt: null,

  init() {
    this.elements.installBtn = document.getElementById('installBtn');
    
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault();
      this.deferredPrompt = e;
      if (this.elements.installBtn) {
        this.elements.installBtn.hidden = false;
      }
    });

    if (this.elements.installBtn) {
      this.elements.installBtn.addEventListener('click', async () => {
        if (!this.deferredPrompt) return;
        this.deferredPrompt.prompt();
        const { outcome } = await this.deferredPrompt.userChoice;
        if (outcome === 'accepted') {
          console.log('User accepted A2HS');
        }
        this.deferredPrompt = null;
        this.elements.installBtn.hidden = true;
      });
    }

    this.registerServiceWorker();
  },

  registerServiceWorker() {
    if ('serviceWorker' in navigator) {
      // If we are already loaded, register now, otherwise wait for load
      if (document.readyState === 'complete') {
          this.doRegister();
      } else {
          window.addEventListener('load', () => this.doRegister());
      }
    }
  },
  
  doRegister() {
    navigator.serviceWorker
      .register('service-worker.js') // Expecting SW in root
      .then((registration) => {
        console.log('Service worker registered');
        registration.addEventListener('updatefound', () => {
          const newWorker = registration.installing;
          if (!newWorker) return;
          newWorker.addEventListener('statechange', () => {
            if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
              console.log('New version available; reloading...');
              newWorker.postMessage({ type: 'SKIP_WAITING' });
            }
          });
        });
        navigator.serviceWorker.addEventListener('controllerchange', () => {
           // Reload logic only if we actually detected an update and swapped controllers
           // Preventing infinite loops if something goes wrong
           window.location.reload();
        });
      })
      .catch((err) => console.error('SW registration failed', err));
  }
};
