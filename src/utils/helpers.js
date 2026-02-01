export function countWords(text) {
  if (!text) return 0;
  const normalized = text.trim().replace(/\s+/g, ' ');
  if (!normalized) return 0;
  return normalized.split(' ').length;
}

export function escapeHtml(input) {
  const str = String(input ?? '');
  return str
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

export function isMobileView() {
  return window.innerWidth < 768;
}
