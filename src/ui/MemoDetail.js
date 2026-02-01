import { formatDateTime } from '../utils/date.js';
import { countWords, escapeHtml } from '../utils/helpers.js';

function el(tag, className, text) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text != null) node.textContent = text;
  return node;
}

export const MemoDetail = {
  render(container, memo, { onClose, onEdit, onDelete, onPin, onOpenMap } = {}) {
    if (!container) return;
    container.innerHTML = '';

    if (!memo) {
      container.hidden = true;
      return;
    }

    const header = el('header', 'detail-header');

    const closeBtn = el('button', 'detail-close-btn', 'Back');
    closeBtn.type = 'button';
    closeBtn.addEventListener('click', () => onClose?.());

    const titleWrap = el('div', 'detail-title-wrap');
    const title = el('h2', 'detail-title', memo.title || '(untitled)');

    const meta = el('p', 'detail-meta');
    const dt = memo.datetime || memo.createdAt;
    const wc = countWords(memo.text || '');
    meta.textContent = `${formatDateTime(dt)}${wc ? ` · ${wc} word${wc === 1 ? '' : 's'}` : ''}`;

    titleWrap.appendChild(title);
    titleWrap.appendChild(meta);

    const actions = el('div', 'detail-actions');

    const pinBtn = el('button', 'detail-icon-btn', memo.isPinned ? 'Unpin' : 'Pin');
    pinBtn.type = 'button';
    pinBtn.addEventListener('click', () => onPin?.(memo.id));

    const editBtn = el('button', 'detail-icon-btn', 'Edit');
    editBtn.type = 'button';
    editBtn.addEventListener('click', () => onEdit?.(memo.id));

    const deleteBtn = el('button', 'detail-icon-btn danger', 'Delete');
    deleteBtn.type = 'button';
    deleteBtn.addEventListener('click', () => onDelete?.(memo.id));

    actions.appendChild(pinBtn);
    actions.appendChild(editBtn);
    actions.appendChild(deleteBtn);

    header.appendChild(closeBtn);
    header.appendChild(titleWrap);
    header.appendChild(actions);

    const content = el('div', 'detail-content');

    // Mood + Tags row
    const chipsRow = el('div', 'detail-chips');

    const mood = memo.mood === 'great' ? '😊 Great' : memo.mood === 'ok' ? '😐 Okay' : memo.mood === 'bad' ? '😞 Not great' : null;
    if (mood) chipsRow.appendChild(el('span', 'detail-chip', mood));

    if (memo.isTodo) {
      chipsRow.appendChild(el('span', `detail-chip ${memo.isDone ? 'success' : ''}`, memo.isDone ? '✅ Done' : '☐ Task'));
    }

    const tags = Array.isArray(memo.tags) ? memo.tags : [];
    for (const tag of tags) chipsRow.appendChild(el('span', 'detail-chip', `#${tag}`));

    if (chipsRow.childElementCount) content.appendChild(chipsRow);

    if (memo.location && typeof memo.location.lat === 'number' && typeof memo.location.lng === 'number') {
      const locRow = el('div', 'detail-location');
      const locLabel = memo.location.label ? memo.location.label : `${memo.location.lat.toFixed(5)}, ${memo.location.lng.toFixed(5)}`;
      const locBtn = el('button', 'detail-link-btn', `${memo.location.symbol || '📍'} ${locLabel}`);
      locBtn.type = 'button';
      locBtn.addEventListener('click', () => onOpenMap?.(memo.id));
      locRow.appendChild(locBtn);
      content.appendChild(locRow);
    }

    const text = el('div', 'detail-text');
    // Keep it safe and simple: no rich text yet.
    text.innerHTML = escapeHtml(memo.text || '').replace(/\n/g, '<br />');
    content.appendChild(text);

    container.appendChild(header);
    container.appendChild(content);
    container.hidden = false;
  },
};
