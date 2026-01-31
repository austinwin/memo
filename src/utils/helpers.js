export function countWords(text) {
  if (!text) return 0;
  const normalized = text.trim().replace(/\s+/g, ' ');
  if (!normalized) return 0;
  return normalized.split(' ').length;
}

export function isMobileView() {
  return window.innerWidth < 768;
}
