// Simple Toast implementation
let toastEl = document.getElementById('toast');
let toastTimeout;

export function initToast() {
  toastEl = document.getElementById('toast');
}

export function showToast(message) {
  if (!toastEl) return;
  toastEl.textContent = message;
  toastEl.hidden = false;
  clearTimeout(toastTimeout);
  toastTimeout = setTimeout(() => {
    toastEl.hidden = true;
  }, 2000);
}

export function updateHeaderHeight(appHeader) {
  if (appHeader) {
    document.documentElement.style.setProperty('--header-height', `${appHeader.offsetHeight}px`);
  }
}
