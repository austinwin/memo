const STORAGE_KEY = 'memo_diary_entries_v1';

let memos = [];
let editingId = null;

const memoForm = document.getElementById('memoForm');
const titleInput = document.getElementById('title');
const datetimeInput = document.getElementById('datetime');
const textInput = document.getElementById('text');
const memoList = document.getElementById('memoList');
const sortSelect = document.getElementById('sortSelect');
const toastEl = document.getElementById('toast');
const memoTemplate = document.getElementById('memoTemplate');
const exportBtn = document.getElementById('exportBtn');

function showToast(message) {
  if (!toastEl) return;
  toastEl.textContent = message;
  toastEl.hidden = false;
  clearTimeout(showToast._timeout);
  showToast._timeout = setTimeout(() => {
    toastEl.hidden = true;
  }, 2000);
}

function loadMemos() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    memos = raw ? JSON.parse(raw) : [];
  } catch (e) {
    console.error('Failed to load memos', e);
    memos = [];
  }
}

function saveMemos() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(memos));
  } catch (e) {
    console.error('Failed to save memos', e);
    showToast('Could not save memos (storage full?)');
  }
}

function formatDateTime(isoString) {
  if (!isoString) return '';
  const d = new Date(isoString);
  if (Number.isNaN(d.getTime())) return '';
  return d.toLocaleString(undefined, {
    year: 'numeric',
    month: 'short',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  });
}

function sortMemos(list) {
  const mode = sortSelect?.value || 'newest';
  const sorted = [...list];

  if (mode === 'title') {
    sorted.sort((a, b) => a.title.localeCompare(b.title));
  } else if (mode === 'oldest') {
    sorted.sort((a, b) => (a.createdAt || a.id) - (b.createdAt || b.id));
  } else {
    sorted.sort((a, b) => (b.createdAt || b.id) - (a.createdAt || a.id));
  }
  return sorted;
}

function renderMemos() {
  if (!memoList) return;
  memoList.innerHTML = '';

  const sorted = sortMemos(memos);

  if (!sorted.length) {
    const empty = document.createElement('p');
    empty.textContent = 'No memos yet. Start by writing your first one.';
    empty.style.fontSize = '0.85rem';
    empty.style.color = 'var(--muted)';
    memoList.appendChild(empty);
    return;
  }

  for (const memo of sorted) {
    const node = memoTemplate.content.firstElementChild.cloneNode(true);
    const titleEl = node.querySelector('.memo-title');
    const datetimeEl = node.querySelector('.memo-datetime');
    const textEl = node.querySelector('.memo-text');
    const editBtn = node.querySelector('.edit-btn');
    const deleteBtn = node.querySelector('.delete-btn');

    titleEl.textContent = memo.title || '(untitled)';
    const dt = memo.datetime || memo.createdAt;
    datetimeEl.textContent = formatDateTime(dt) || 'No date';
    textEl.textContent = memo.text || '';

    editBtn.addEventListener('click', () => startEditMemo(memo.id));
    deleteBtn.addEventListener('click', () => deleteMemo(memo.id));

    memoList.appendChild(node);
  }
}

function resetForm() {
  memoForm.reset();
  editingId = null;
}

function startEditMemo(id) {
  const memo = memos.find(m => m.id === id);
  if (!memo) return;

  editingId = id;
  titleInput.value = memo.title || '';
  textInput.value = memo.text || '';

  if (memo.datetime) {
    const d = new Date(memo.datetime);
    if (!Number.isNaN(d.getTime())) {
      const pad = n => String(n).padStart(2, '0');
      const local = new Date(d.getTime() - d.getTimezoneOffset() * 60000);
      const value = `${local.getFullYear()}-${pad(local.getMonth() + 1)}-${pad(local.getDate())}T${pad(local.getHours())}:${pad(local.getMinutes())}`;
      datetimeInput.value = value;
    }
  } else {
    datetimeInput.value = '';
  }

  showToast('Editing memo');
}

function deleteMemo(id) {
  const confirmed = window.confirm('Delete this memo? This cannot be undone.');
  if (!confirmed) return;

  memos = memos.filter(m => m.id !== id);
  saveMemos();
  renderMemos();
  showToast('Memo deleted');
}

function handleSubmit(e) {
  e.preventDefault();

  const title = titleInput.value.trim();
  const text = textInput.value.trim();
  const datetimeValue = datetimeInput.value;

  if (!text) {
    showToast('Text is required');
    return;
  }

  const now = new Date();
  let isoDatetime = null;
  if (datetimeValue) {
    const chosen = new Date(datetimeValue);
    if (!Number.isNaN(chosen.getTime())) {
      isoDatetime = chosen.toISOString();
    }
  }

  if (editingId != null) {
    const idx = memos.findIndex(m => m.id === editingId);
    if (idx !== -1) {
      memos[idx] = {
        ...memos[idx],
        title,
        text,
        datetime: isoDatetime,
      };
    }
    showToast('Memo updated');
  } else {
    const memo = {
      id: now.getTime(),
      createdAt: now.getTime(),
      title,
      text,
      datetime: isoDatetime,
    };
    memos.push(memo);
    showToast('Memo saved');
  }

  saveMemos();
  renderMemos();
  resetForm();
}

function exportMemosToFile() {
  const payload = {
    version: 1,
    exportedAt: new Date().toISOString(),
    memos,
  };

  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');

  const now = new Date();
  const pad = n => String(n).padStart(2, '0');
  const fileDate = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`;
  a.href = url;
  a.download = `memo-diary-backup-${fileDate}.json`;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);

  showToast('Exported memos');
}

function init() {
  if (!memoForm) return;
  loadMemos();
  renderMemos();

  memoForm.addEventListener('submit', handleSubmit);
  memoForm.addEventListener('reset', () => {
    editingId = null;
  });

  if (sortSelect) {
    sortSelect.addEventListener('change', renderMemos);
  }

  if (exportBtn) {
    exportBtn.addEventListener('click', exportMemosToFile);
  }
}

window.addEventListener('DOMContentLoaded', init);
