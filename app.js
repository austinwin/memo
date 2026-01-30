const STORAGE_KEY = 'memo_diary_entries_v1';

let memos = [];
let editingId = null;
let activeTab = 'all'; // 'all' | 'today' | 'pinned'

const memoForm = document.getElementById('memoForm');
const titleInput = document.getElementById('title');
const datetimeInput = document.getElementById('datetime');
const textInput = document.getElementById('text');
const memoList = document.getElementById('memoList');
const sortSelect = document.getElementById('sortSelect');
const searchInput = document.getElementById('searchInput');
const todayLabel = document.getElementById('todayLabel');
const streakCountEl = document.getElementById('streakCount');
const weekCountEl = document.getElementById('weekCount');
const lastEntryLabelEl = document.getElementById('lastEntryLabel');
const todayShortcutBtn = document.getElementById('todayShortcutBtn');
const toastEl = document.getElementById('toast');
const currentMood = { value: null };
const memoTemplate = document.getElementById('memoTemplate');
const exportBtn = document.getElementById('exportBtn');
const importBtn = document.getElementById('importBtn');
const importInput = document.getElementById('importInput');

function showToast(message) {
  if (!toastEl) return;
  toastEl.textContent = message;
  toastEl.hidden = false;
  clearTimeout(showToast._timeout);
  showToast._timeout = setTimeout(() => {
    toastEl.hidden = true;
  }, 2000);
}

function updateTodayLabel() {
  if (!todayLabel) return;
  const now = new Date();
  const formatted = now.toLocaleDateString(undefined, {
    weekday: 'short',
    month: 'short',
    day: '2-digit',
    year: 'numeric',
  });
  todayLabel.textContent = formatted;
}

function setDatetimeToNow() {
  if (!datetimeInput) return;
  const now = new Date();
  const pad = (n) => String(n).padStart(2, '0');
  const local = new Date(now.getTime() - now.getTimezoneOffset() * 60000);
  const value = `${local.getFullYear()}-${pad(local.getMonth() + 1)}-${pad(
    local.getDate()
  )}T${pad(local.getHours())}:${pad(local.getMinutes())}`;
  datetimeInput.value = value;
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

  // Pinned memos always come before non-pinned in the current view.
  sorted.sort((a, b) => {
    const aPinned = !!a.isPinned;
    const bPinned = !!b.isPinned;
    if (aPinned !== bPinned) {
      return aPinned ? -1 : 1;
    }
    return 0;
  });

  if (mode === 'title') {
    sorted.sort((a, b) => {
      const aPinned = !!a.isPinned;
      const bPinned = !!b.isPinned;
      if (aPinned !== bPinned) return aPinned ? -1 : 1;
      return (a.title || '').localeCompare(b.title || '');
    });
  } else if (mode === 'oldest') {
    sorted.sort((a, b) => {
      const aPinned = !!a.isPinned;
      const bPinned = !!b.isPinned;
      if (aPinned !== bPinned) return aPinned ? -1 : 1;
      return (a.createdAt || a.id) - (b.createdAt || b.id);
    });
  } else {
    sorted.sort((a, b) => {
      const aPinned = !!a.isPinned;
      const bPinned = !!b.isPinned;
      if (aPinned !== bPinned) return aPinned ? -1 : 1;
      return (b.createdAt || b.id) - (a.createdAt || a.id);
    });
  }

  return sorted;
}

function getSearchQuery() {
  return (searchInput?.value || '').trim().toLowerCase();
}

function isToday(isoString) {
  if (!isoString) return false;
  const d = new Date(isoString);
  if (Number.isNaN(d.getTime())) return false;

  const today = new Date();
  return (
    d.getFullYear() === today.getFullYear() &&
    d.getMonth() === today.getMonth() &&
    d.getDate() === today.getDate()
  );
}

function filterMemosByTab(list) {
  if (activeTab === 'pinned') {
    return list.filter((m) => m.isPinned);
  }
  if (activeTab === 'today') {
    return list.filter((m) => isToday(m.datetime || m.createdAt));
  }
  return list;
}

function filterMemos(list) {
  const query = getSearchQuery();
  const byTab = filterMemosByTab(list);
  if (!query) return byTab;

  return byTab.filter((memo) => {
    const inTitle = (memo.title || '').toLowerCase().includes(query);
    const inText = (memo.text || '').toLowerCase().includes(query);
    return inTitle || inText;
  });
}

function getDayKey(isoString) {
  const d = isoString ? new Date(isoString) : new Date();
  if (Number.isNaN(d.getTime())) return 'unknown';
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

function formatDayLabel(dayKey) {
  const [y, m, d] = dayKey.split('-').map(Number);
  if (!y || !m || !d) return dayKey;
  const date = new Date(y, m - 1, d);
  if (Number.isNaN(date.getTime())) return dayKey;

  const today = new Date();
  const yesterday = new Date();
  yesterday.setDate(today.getDate() - 1);

  const sameDay = (a, b) =>
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate();

  if (sameDay(date, today)) return 'Today';
  if (sameDay(date, yesterday)) return 'Yesterday';

  return date.toLocaleDateString(undefined, {
    weekday: 'short',
    month: 'short',
    day: '2-digit',
    year: 'numeric',
  });
}

function groupMemosByDay(list) {
  const groups = new Map();

  for (const memo of list) {
    const key = getDayKey(memo.datetime || memo.createdAt);
    if (!groups.has(key)) {
      groups.set(key, []);
    }
    groups.get(key).push(memo);
  }

  // Sort day keys descending (newest day first)
  const dayKeys = Array.from(groups.keys()).sort((a, b) =>
    a < b ? 1 : a > b ? -1 : 0
  );

  // Within each day, preserve existing sort order by reusing sortMemos
  return dayKeys.map((key) => ({ dayKey: key, memos: sortMemos(groups.get(key)) }));
}

function updateStats() {
  if (!streakCountEl || !weekCountEl || !lastEntryLabelEl) return;

  if (!memos.length) {
    streakCountEl.textContent = '0 days';
    weekCountEl.textContent = '0 entries';
    lastEntryLabelEl.textContent = 'None yet';
    return;
  }

  const now = new Date();
  const todayKey = getDayKey(now.toISOString());
  const dayKeys = new Set();

  let entriesThisWeek = 0;
  let latestTimestamp = 0;

  for (const memo of memos) {
    const timestamp = memo.datetime || memo.createdAt;
    if (!timestamp) continue;

    const date = new Date(timestamp);
    if (Number.isNaN(date.getTime())) continue;

    dayKeys.add(getDayKey(date.toISOString()));

    const diffMs = now - date;
    const diffDays = diffMs / (1000 * 60 * 60 * 24);
    if (diffDays >= 0 && diffDays < 7) {
      entriesThisWeek += 1;
    }

    if (date.getTime() > latestTimestamp) {
      latestTimestamp = date.getTime();
    }
  }

  // Compute streak from today backwards
  let streak = 0;
  let cursor = new Date();
  while (true) {
    const key = getDayKey(cursor.toISOString());
    if (!dayKeys.has(key)) break;
    streak += 1;
    cursor.setDate(cursor.getDate() - 1);
  }

  streakCountEl.textContent = `${streak} day${streak === 1 ? '' : 's'}`;
  weekCountEl.textContent = `${entriesThisWeek} entr${entriesThisWeek === 1 ? 'y' : 'ies'}`;

  if (latestTimestamp) {
    lastEntryLabelEl.textContent = formatDateTime(latestTimestamp);
  } else if (dayKeys.has(todayKey)) {
    lastEntryLabelEl.textContent = 'Today';
  } else {
    lastEntryLabelEl.textContent = 'None yet';
  }
}

function renderMemos() {
  if (!memoList) return;
  memoList.innerHTML = '';

  const filtered = filterMemos(memos);
  updateStats();

  if (!filtered.length) {
    const empty = document.createElement('p');
    empty.textContent = searchInput?.value
      ? 'No memos match your search.'
      : 'No memos yet. Start by writing your first one.';
    empty.style.fontSize = '0.85rem';
    empty.style.color = 'var(--muted)';
    memoList.appendChild(empty);
    return;
  }

  const dayGroups = groupMemosByDay(filtered);

  for (const { dayKey, memos: dayMemos } of dayGroups) {
    const section = document.createElement('section');
    section.className = 'memo-day-group';

    const header = document.createElement('header');
    header.className = 'memo-day-header';

    const title = document.createElement('h3');
    title.className = 'memo-day-title';
    title.textContent = formatDayLabel(dayKey);

    const count = document.createElement('p');
    count.className = 'memo-day-count';
    count.textContent = `${dayMemos.length} entr${dayMemos.length === 1 ? 'y' : 'ies'}`;

    header.appendChild(title);
    header.appendChild(count);
    section.appendChild(header);

    const list = document.createElement('div');
    list.className = 'memo-day-list';

    for (const memo of dayMemos) {
      const node = memoTemplate.content.firstElementChild.cloneNode(true);
      const titleEl = node.querySelector('.memo-title');
      const datetimeEl = node.querySelector('.memo-datetime');
      const textEl = node.querySelector('.memo-text');
      const moodEl = node.querySelector('.memo-mood');
      const pinBtn = node.querySelector('.pin-btn');
      const editBtn = node.querySelector('.edit-btn');
      const deleteBtn = node.querySelector('.delete-btn');

      if (memo.isPinned) {
        node.classList.add('pinned');
        if (pinBtn) pinBtn.classList.add('active');
      }

      titleEl.textContent = memo.title || '(untitled)';
      const dt = memo.datetime || memo.createdAt;
      datetimeEl.textContent = formatDateTime(dt) || 'No date';
      textEl.textContent = memo.text || '';

      if (moodEl) {
        if (memo.mood === 'great') moodEl.textContent = '😊';
        else if (memo.mood === 'ok') moodEl.textContent = '😐';
        else if (memo.mood === 'bad') moodEl.textContent = '😞';
        else moodEl.textContent = '';
      }

      if (pinBtn) {
        pinBtn.addEventListener('click', () => togglePinMemo(memo.id));
      }

      editBtn.addEventListener('click', () => startEditMemo(memo.id));
      deleteBtn.addEventListener('click', () => deleteMemo(memo.id));

      list.appendChild(node);
    }

    section.appendChild(list);
    memoList.appendChild(section);
  }
}

function resetForm() {
  memoForm.reset();
  editingId = null;
  currentMood.value = null;
  document.querySelectorAll('.mood-btn').forEach((btn) => {
    btn.classList.remove('active');
  });
}

function startEditMemo(id) {
  const memo = memos.find(m => m.id === id);
  if (!memo) return;

  editingId = id;
  titleInput.value = memo.title || '';
  textInput.value = memo.text || '';
  currentMood.value = memo.mood || null;
  document.querySelectorAll('.mood-btn').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.mood === currentMood.value);
  });

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

function togglePinMemo(id) {
  const idx = memos.findIndex((m) => m.id === id);
  if (idx === -1) return;

  const current = memos[idx];
  const next = { ...current, isPinned: !current.isPinned };
  memos[idx] = next;

  saveMemos();
  renderMemos();
  showToast(next.isPinned ? 'Memo pinned' : 'Memo unpinned');
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

  const mood = currentMood.value || null;

  if (editingId != null) {
    const idx = memos.findIndex(m => m.id === editingId);
    if (idx !== -1) {
      memos[idx] = {
        ...memos[idx],
        title,
        text,
        datetime: isoDatetime,
        mood,
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
      mood,
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

function handleImportedMemos(imported) {
  if (!Array.isArray(imported)) {
    showToast('Invalid backup file');
    return;
  }

  const hasExisting = memos.length > 0;
  let next = [];

  if (hasExisting) {
    const replace = window.confirm('Replace all existing memos with this backup?');
    if (replace) {
      next = imported;
    } else {
      const byId = new Map();
      for (const m of memos) {
        if (!m || typeof m !== 'object') continue;
        byId.set(m.id, m);
      }
      for (const m of imported) {
        if (!m || typeof m !== 'object') continue;
        if (m.id == null) continue;
        byId.set(m.id, m);
      }
      next = Array.from(byId.values());
    }
  } else {
    next = imported;
  }

  memos = next;
  saveMemos();
  renderMemos();
  showToast('Imported memos');
}

function importMemosFromFile(file) {
  if (!file) return;

  const reader = new FileReader();
  reader.onload = (event) => {
    try {
      const text = event.target.result;
      const data = JSON.parse(text);
      if (!data || typeof data !== 'object') {
        showToast('Invalid backup file');
        return;
      }

      // Support both current and potential future formats
      const imported = Array.isArray(data.memos) ? data.memos : Array.isArray(data) ? data : null;
      if (!imported) {
        showToast('Invalid backup file');
        return;
      }

      handleImportedMemos(imported);
    } catch (e) {
      console.error('Failed to import memos', e);
      showToast('Could not read backup file');
    }
  };
  reader.onerror = () => {
    showToast('Could not read backup file');
  };
  reader.readAsText(file);
}

function init() {
  if (!memoForm) return;
  loadMemos();
  updateTodayLabel();
  setDatetimeToNow();
  renderMemos();
  updateStats();

  // Wire up tab buttons
  document.querySelectorAll('.memo-tab').forEach((btn) => {
    btn.addEventListener('click', () => {
      const tab = btn.getAttribute('data-tab');
      if (!tab) return;
      activeTab = tab;

      document.querySelectorAll('.memo-tab').forEach((b) => {
        b.classList.toggle('active', b === btn);
      });

      renderMemos();
    });
  });

  memoForm.addEventListener('submit', handleSubmit);
  memoForm.addEventListener('reset', () => {
    editingId = null;
    currentMood.value = null;
    document.querySelectorAll('.mood-btn').forEach((btn) => {
      btn.classList.remove('active');
    });
  });

  if (sortSelect) {
    sortSelect.addEventListener('change', renderMemos);
  }

  if (searchInput) {
    searchInput.addEventListener('input', () => {
      renderMemos();
    });
  }

  if (todayShortcutBtn) {
    todayShortcutBtn.addEventListener('click', () => {
      setDatetimeToNow();
      titleInput.focus();
    });
  }

  // Mood picker
  document.querySelectorAll('.mood-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      const mood = btn.dataset.mood;
      currentMood.value = currentMood.value === mood ? null : mood;
      document.querySelectorAll('.mood-btn').forEach((b) => {
        b.classList.toggle('active', b === btn && currentMood.value != null);
      });
    });
  });

  if (exportBtn) {
    exportBtn.addEventListener('click', exportMemosToFile);
  }

  if (importBtn && importInput) {
    importBtn.addEventListener('click', () => {
      importInput.value = '';
      importInput.click();
    });

    importInput.addEventListener('change', () => {
      const [file] = importInput.files || [];
      if (file) {
        importMemosFromFile(file);
      }
    });
  }
}

window.addEventListener('DOMContentLoaded', init);
