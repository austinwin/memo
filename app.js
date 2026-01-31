const STORAGE_KEY = 'memo_diary_entries_v1';

let memos = [];
let editingId = null;
let activeTab = 'all'; // 'all' | 'today' | 'pinned' | 'tasks' | 'map'
let activeMoodFilter = 'all'; // 'all' | 'great' | 'ok' | 'bad'
let lastListTab = 'all';
let mapMarkerStyle = 'pin';
let editingLocation = null;
let currentPage = 1;
const ITEMS_PER_PAGE = 10;

const memoForm = document.getElementById('memoForm');
const titleInput = document.getElementById('title');
const datetimeInput = document.getElementById('datetime');
const textInput = document.getElementById('text');
const memoList = document.getElementById('memoList');
const isTodoInput = document.getElementById('isTodo');
const sortSelect = document.getElementById('sortSelect');
const searchInput = document.getElementById('searchInput');
const todayLabel = document.getElementById('todayLabel');
const streakCountEl = document.getElementById('streakCount');
const weekCountEl = document.getElementById('weekCount');
const lastEntryLabelEl = document.getElementById('lastEntryLabel');
const todayWordsEl = document.getElementById('todayWords');
const weekWordsEl = document.getElementById('weekWords');
const todayShortcutBtn = document.getElementById('todayShortcutBtn');
const toastEl = document.getElementById('toast');
const currentMood = { value: null };
const memoTemplate = document.getElementById('memoTemplate');
const exportBtn = document.getElementById('exportBtn');
const importBtn = document.getElementById('importBtn');
const importInput = document.getElementById('importInput');
const mapHeaderBtn = document.getElementById('mapHeaderBtn');
const installBtn = document.getElementById('installBtn');
const locationSummaryEl = document.getElementById('locationSummary');
const mapShell = document.getElementById('mapShell');
const mapCloseBtn = document.getElementById('mapCloseBtn');
const mapSearchInput = document.getElementById('mapSearchInput');
const mapMarkerSelect = document.getElementById('mapMarkerSelect');
const mapMoodSelect = document.getElementById('mapMoodSelect');
const moodSelect = document.getElementById('moodSelect');
const prevPageBtn = document.getElementById('prevPageBtn');
const nextPageBtn = document.getElementById('nextPageBtn');
const pageIndicator = document.getElementById('pageIndicator');
const paginationControls = document.getElementById('paginationControls');
const mapRecenterBtn = document.getElementById('mapRecenterBtn');
const mapCountLabel = document.getElementById('mapCountLabel');
const locationSymbolInput = document.getElementById('locationSymbolInput');
const appHeader = document.querySelector('.app-header');
const composeFab = document.getElementById('composeFab');
const composeSection = document.getElementById('composeSection');
const formCloseBtn = document.getElementById('formCloseBtn');
const bottomNav = document.getElementById('bottomNav');

function showToast(message) {
  if (!toastEl) return;
  toastEl.textContent = message;
  toastEl.hidden = false;
  clearTimeout(showToast._timeout);
  showToast._timeout = setTimeout(() => {
    toastEl.hidden = true;
  }, 2000);
}

function isMobileView() {
  return window.innerWidth < 768;
}

function showComposeForm() {
  if (composeSection) {
    composeSection.classList.add('visible');
    setDatetimeToNow();
    setTimeout(() => {
      if (titleInput) titleInput.focus();
    }, 100);
  }
}

function hideComposeForm() {
  if (composeSection) {
    composeSection.classList.remove('visible');
    resetForm();
  }
}

function updateHeaderHeight() {
  if (appHeader) {
    document.documentElement.style.setProperty('--header-height', `${appHeader.offsetHeight}px`);
  }
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

function getMapCounts(list) {
  let entries = 0;
  const places = new Set();
  for (const memo of list) {
    const loc = memo.location;
    if (!loc || typeof loc.lat !== 'number' || typeof loc.lng !== 'number') continue;
    entries += 1;
    places.add(`${loc.lat.toFixed(4)},${loc.lng.toFixed(4)}`);
  }
  return { entries, places: places.size };
}

function syncSearchInputs(value) {
  if (searchInput && searchInput.value !== value) {
    searchInput.value = value;
  }
  if (mapSearchInput && mapSearchInput.value !== value) {
    mapSearchInput.value = value;
  }
}

function setMoodFilter(mood) {
  activeMoodFilter = mood || 'all';
  
  if (moodSelect) {
    moodSelect.value = activeMoodFilter;
  }
  if (mapMoodSelect) {
    mapMoodSelect.value = activeMoodFilter;
  }

  document.querySelectorAll('[data-filter=\"mood\"]').forEach((btn) => {
    const isActive = (btn.dataset.mood || 'all') === activeMoodFilter;
    btn.classList.toggle('active', isActive);
    btn.setAttribute('aria-pressed', isActive ? 'true' : 'false');
  });
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
  if (activeTab === 'tasks') {
    return list.filter((m) => m.isTodo && !m.isDone);
  }
  if (activeTab === 'map') {
    // Map view uses all memos; filtering happens separately
    return list;
  }
  return list;
}

function filterMemos(list) {
  const query = getSearchQuery();
  const byTab = filterMemosByTab(list);

  const byMood = activeMoodFilter === 'all'
    ? byTab
    : byTab.filter((memo) => (memo.mood || null) === activeMoodFilter);

  if (!query) return byMood;

  return byMood.filter((memo) => {
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

function countWords(text) {
  if (!text) return 0;
  const normalized = text.trim().replace(/\s+/g, ' ');
  if (!normalized) return 0;
  return normalized.split(' ').length;
}

function updateStats() {
  if (!streakCountEl || !weekCountEl || !lastEntryLabelEl) return;

  if (!memos.length) {
    streakCountEl.textContent = '0 days';
    weekCountEl.textContent = '0 entries';
    lastEntryLabelEl.textContent = 'None yet';
    if (todayWordsEl) todayWordsEl.textContent = '0 words';
    if (weekWordsEl) weekWordsEl.textContent = '0 words';
    return;
  }

  const now = new Date();
  const todayKey = getDayKey(now.toISOString());
  const dayKeys = new Set();

  let entriesThisWeek = 0;
  let latestTimestamp = 0;
  let wordsToday = 0;
  let wordsThisWeek = 0;

  for (const memo of memos) {
    const timestamp = memo.datetime || memo.createdAt;
    if (!timestamp) continue;

    const date = new Date(timestamp);
    if (Number.isNaN(date.getTime())) continue;

    const dayKey = getDayKey(date.toISOString());
    dayKeys.add(dayKey);

    const diffMs = now - date;
    const diffDays = diffMs / (1000 * 60 * 60 * 24);
    if (diffDays >= 0 && diffDays < 7) {
      entriesThisWeek += 1;
    }

    const words = countWords(memo.text || '');

    if (dayKey === todayKey) {
      wordsToday += words;
    }

    if (diffDays >= 0 && diffDays < 7) {
      wordsThisWeek += words;
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

  if (todayWordsEl) {
    todayWordsEl.textContent = `${wordsToday} word${wordsToday === 1 ? '' : 's'}`;
  }
  if (weekWordsEl) {
    weekWordsEl.textContent = `${wordsThisWeek} word${wordsThisWeek === 1 ? '' : 's'}`;
  }

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

  const searchValue = searchInput?.value || mapSearchInput?.value || '';
  syncSearchInputs(searchValue);
  document.body.classList.toggle('map-mode', activeTab === 'map');
  if (mapShell) {
    mapShell.hidden = activeTab !== 'map';
  }
  updateHeaderHeight();

  const filtered = filterMemos(memos);
  updateStats();
  
  if (activeTab === 'map') {
    if (paginationControls) paginationControls.hidden = true;
    if (window.memoLocation && typeof window.memoLocation.renderMapView === 'function') {
      window.memoLocation.renderMapView(filtered, { markerStyle: mapMarkerStyle });
    }
    if (mapCountLabel) {
      const counts = getMapCounts(filtered);
      if (!counts.entries) {
        mapCountLabel.textContent = 'No locations';
      } else {
        const placeLabel = `${counts.places} place${counts.places === 1 ? '' : 's'}`;
        const entryLabel = `${counts.entries} entr${counts.entries === 1 ? 'y' : 'ies'}`;
        mapCountLabel.textContent = `${placeLabel} · ${entryLabel}`;
      }
    }
    return;
  }

  memoList.hidden = false;
  if (mapShell) mapShell.hidden = true;
  memoList.innerHTML = '';

  if (!filtered.length) {
    if (paginationControls) paginationControls.hidden = true;
    const empty = document.createElement('p');
    empty.textContent = searchInput?.value
      ? 'No memos match your search.'
      : 'No memos yet. Start by writing your first one.';
    empty.style.fontSize = '0.85rem';
    empty.style.color = 'var(--muted)';
    memoList.appendChild(empty);
    return;
  }

  // Pagination Logic
  const totalItems = filtered.length;
  const totalPages = Math.ceil(totalItems / ITEMS_PER_PAGE) || 1;
  
  if (currentPage > totalPages) currentPage = totalPages;
  if (currentPage < 1) currentPage = 1;

  const start = (currentPage - 1) * ITEMS_PER_PAGE;
  const end = start + ITEMS_PER_PAGE;
  const pageItems = filtered.slice(start, end);

  if (paginationControls) {
    paginationControls.hidden = false;
    if (pageIndicator) pageIndicator.textContent = `Page ${currentPage} of ${totalPages}`;
    if (prevPageBtn) prevPageBtn.disabled = currentPage <= 1;
    if (nextPageBtn) nextPageBtn.disabled = currentPage >= totalPages;
  }

  const dayGroups = groupMemosByDay(pageItems);

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
      node.dataset.memoId = memo.id;
      const titleEl = node.querySelector('.memo-title');
      const datetimeEl = node.querySelector('.memo-datetime');
      const textEl = node.querySelector('.memo-text');
      const moodEl = node.querySelector('.memo-mood');
      const pinBtn = node.querySelector('.pin-btn');
      const actionsEl = node.querySelector('.memo-card-actions');
      const editBtn = node.querySelector('.edit-btn');
      const deleteBtn = node.querySelector('.delete-btn');
      const todoCheckbox = node.querySelector('.memo-todo-checkbox');

      if (memo.isPinned) {
        node.classList.add('pinned');
        if (pinBtn) pinBtn.classList.add('active');
      }

      if (memo.isTodo) {
        node.classList.add('todo');
        if (todoCheckbox) {
          todoCheckbox.checked = !!memo.isDone;
          todoCheckbox.addEventListener('change', () => {
            toggleTodoDone(memo.id, todoCheckbox.checked);
          });
        }
      } else if (todoCheckbox) {
        todoCheckbox.closest('.memo-todo').style.visibility = 'hidden';
      }

      if (memo.isDone) {
        node.classList.add('todo-done');
      }

      titleEl.textContent = memo.title || '(untitled)';
      const dt = memo.datetime || memo.createdAt;
      const wordCount = countWords(memo.text || '');
      const dateLabel = formatDateTime(dt) || 'No date';
      datetimeEl.textContent = wordCount > 0 ? `${dateLabel} · ${wordCount} word${wordCount === 1 ? '' : 's'}` : dateLabel;
      textEl.textContent = memo.text || '';

      if (moodEl) {
        if (memo.mood === 'great') moodEl.textContent = '😊';
        else if (memo.mood === 'ok') moodEl.textContent = '😐';
        else if (memo.mood === 'bad') moodEl.textContent = '😞';
        else moodEl.textContent = '';
      }

      if (actionsEl && memo.location && typeof memo.location.lat === 'number' && typeof memo.location.lng === 'number') {
        const locIcon = document.createElement('button');
        locIcon.type = 'button';
        locIcon.className = 'icon-btn memo-location-icon';
        locIcon.title = 'View on map';
        locIcon.textContent = memo.location.symbol || '📍';
        locIcon.addEventListener('click', () => {
          if (activeTab !== 'map') {
            lastListTab = activeTab;
          }
          activeTab = 'map';
          document.querySelectorAll('.memo-tab').forEach((b) => {
            b.classList.toggle('active', b.getAttribute('data-tab') === 'map');
          });
          renderMemos();
          if (window.memoLocation && typeof window.memoLocation.focusMemo === 'function') {
            window.memoLocation.focusMemo(memo.id);
          }
        });
        actionsEl.insertBefore(locIcon, actionsEl.firstChild);
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
  if (isTodoInput) {
    isTodoInput.checked = false;
  }
  editingLocation = null;
  if (locationSummaryEl) {
    locationSummaryEl.hidden = true;
    locationSummaryEl.textContent = '';
  }
  if (locationSymbolInput) {
    locationSymbolInput.value = '📍';
  }
  if (window.memoLocation && typeof window.memoLocation.setCurrentEditingLocation === 'function') {
    window.memoLocation.setCurrentEditingLocation(null);
  }
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
  if (isTodoInput) {
    isTodoInput.checked = !!memo.isTodo;
  }
  editingLocation = memo.location || null;
  if (locationSymbolInput) {
    locationSymbolInput.value = memo.location?.symbol || '📍';
  }
  if (window.memoLocation && typeof window.memoLocation.setCurrentEditingLocation === 'function') {
    window.memoLocation.setCurrentEditingLocation(editingLocation);
  }
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

  // Show compose form on mobile when editing
  if (isMobileView()) {
    showComposeForm();
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

function toggleTodoDone(id, isDone) {
  const idx = memos.findIndex((m) => m.id === id);
  if (idx === -1) return;

  const current = memos[idx];
  const next = {
    ...current,
    isTodo: true,
    isDone: !!isDone,
  };
  memos[idx] = next;
  saveMemos();
  renderMemos();
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
  const isTodo = isTodoInput ? isTodoInput.checked : false;

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
  const symbol = locationSymbolInput ? locationSymbolInput.value : '📍';

  if (editingLocation) {
    editingLocation.symbol = symbol;
  }

  if (editingId != null) {
    const idx = memos.findIndex(m => m.id === editingId);
    if (idx !== -1) {
      memos[idx] = {
        ...memos[idx],
        title,
        text,
        datetime: isoDatetime,
        mood,
        isTodo,
        location: editingLocation || null,
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
      isTodo,
      isDone: false,
      location: editingLocation || null,
    };
    memos.push(memo);
    showToast('Memo saved');
  }

  saveMemos();
  renderMemos();
  resetForm();
  
  // Close compose form on mobile after saving
  if (isMobileView()) {
    hideComposeForm();
  }
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
  updateHeaderHeight();
  updateTodayLabel();
  setDatetimeToNow();
  renderMemos();
  updateStats();

  function setActiveTab(tab) {
    if (!tab) return;
    activeTab = tab;
    if (tab !== 'map') {
      lastListTab = tab;
    }
    document.querySelectorAll('.memo-tab').forEach((b) => {
      b.classList.toggle('active', b.getAttribute('data-tab') === tab);
    });
    currentPage = 1;
    renderMemos();
  }

  // Wire up tab buttons
  document.querySelectorAll('.memo-tab').forEach((btn) => {
    btn.addEventListener('click', () => {
      const tab = btn.getAttribute('data-tab');
      setActiveTab(tab);
    });
  });

  memoForm.addEventListener('submit', handleSubmit);
  memoForm.addEventListener('reset', () => {
    resetForm();
  });

  if (sortSelect) {
    sortSelect.addEventListener('change', () => {
      currentPage = 1;
      renderMemos();
    });
  }

  if (searchInput) {
    searchInput.addEventListener('input', () => {
      syncSearchInputs(searchInput.value);
      currentPage = 1;
      renderMemos();
    });
  }

  if (mapSearchInput) {
    mapSearchInput.addEventListener('input', () => {
      syncSearchInputs(mapSearchInput.value);
      renderMemos();
    });
  }

  if (todayShortcutBtn) {
    todayShortcutBtn.addEventListener('click', () => {
      setDatetimeToNow();
      titleInput.focus();
    });
  }

  // Mood picker for new/edit form
  document.querySelectorAll('.mood-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      const mood = btn.dataset.mood;
      currentMood.value = currentMood.value === mood ? null : mood;
      document.querySelectorAll('.mood-btn').forEach((b) => {
        b.classList.toggle('active', b === btn && currentMood.value != null);
      });
    });
  });

  // Mood filter chips for list and map
  document.querySelectorAll('[data-filter=\"mood\"]').forEach((btn) => {
    btn.addEventListener('click', () => {
      const mood = btn.dataset.mood;
      setMoodFilter(mood);
      renderMemos();
    });
  });

  if (exportBtn) {
    exportBtn.addEventListener('click', exportMemosToFile);
  }

  function goToMapView() {
    setActiveTab('map');
  }

  if (mapMoodSelect) {
    mapMoodSelect.addEventListener('change', () => {
      setMoodFilter(mapMoodSelect.value);
      renderMemos();
    });
  }

  if (moodSelect) {
    moodSelect.addEventListener('change', () => {
      setMoodFilter(moodSelect.value);
      currentPage = 1;
      renderMemos();
    });
  }

  if (prevPageBtn) {
    prevPageBtn.addEventListener('click', () => {
      if (currentPage > 1) {
        currentPage--;
        renderMemos();
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }
    });
  }

  if (nextPageBtn) {
    nextPageBtn.addEventListener('click', () => { // Ensure logic handles max pages properly inside renderMemos
       currentPage++;
       renderMemos();
       window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  if (mapHeaderBtn) {
    mapHeaderBtn.addEventListener('click', goToMapView);
  }

  if (installBtn) {
    installBtn.hidden = false;
    installBtn.textContent = 'Map view';
    installBtn.addEventListener('click', goToMapView);
  }

  if (mapCloseBtn) {
    mapCloseBtn.addEventListener('click', () => {
      setActiveTab(lastListTab || 'all');
    });
  }

  if (mapMarkerSelect) {
    mapMarkerSelect.addEventListener('change', () => {
      mapMarkerStyle = mapMarkerSelect.value || 'pin';
      if (window.memoLocation && typeof window.memoLocation.setMapMarkerStyle === 'function') {
        window.memoLocation.setMapMarkerStyle(mapMarkerStyle);
      }
      if (activeTab === 'map') {
        renderMemos();
      }
    });
  }

  if (mapRecenterBtn) {
    mapRecenterBtn.addEventListener('click', () => {
      if (window.memoLocation && typeof window.memoLocation.fitToMarkers === 'function') {
        window.memoLocation.fitToMarkers();
      }
    });
  }

  setMoodFilter(activeMoodFilter);

  if (window.memoLocation) {
    window.memoLocation.formatDateTime = formatDateTime;
    window.memoLocation.focusMemo = (id) => {
      const el = document.querySelector(`[data-memo-id="${id}"]`);
      if (el) {
        el.scrollIntoView({ behavior: 'smooth', block: 'center' });
        el.classList.add('highlight');
        setTimeout(() => el.classList.remove('highlight'), 1000);
      }
    };
    window.memoLocation.getCurrentEditingLocation = () => editingLocation;
    window.memoLocation.onLocationSelected = (loc) => {
      editingLocation = loc || null;
      if (editingLocation && locationSymbolInput) {
        editingLocation.symbol = locationSymbolInput.value;
      }
    };
    if (typeof window.memoLocation.initLocationPicker === 'function') {
      window.memoLocation.initLocationPicker();
    }
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

  // Mobile compose FAB
  if (composeFab) {
    composeFab.addEventListener('click', () => {
      showComposeForm();
    });
  }

  // Mobile form close button
  if (formCloseBtn) {
    formCloseBtn.addEventListener('click', () => {
      hideComposeForm();
    });
  }

  // Bottom navigation
  if (bottomNav) {
    bottomNav.querySelectorAll('.nav-item').forEach((btn) => {
      btn.addEventListener('click', () => {
        const nav = btn.getAttribute('data-nav');
        
        // Update active state
        bottomNav.querySelectorAll('.nav-item').forEach((b) => {
          b.classList.toggle('active', b === btn);
        });
        
        if (nav === 'map') {
          setActiveTab('map');
        } else if (nav === 'entries') {
          setActiveTab(lastListTab || 'all');
        }
      });
    });
  }

  // Update bottom nav when map tab is activated via other means
  function updateBottomNavState() {
    if (!bottomNav) return;
    const isMap = activeTab === 'map';
    bottomNav.querySelectorAll('.nav-item').forEach((btn) => {
      const nav = btn.getAttribute('data-nav');
      btn.classList.toggle('active', (isMap && nav === 'map') || (!isMap && nav === 'entries'));
    });
  }

  // Override setActiveTab to also update bottom nav
  const originalSetActiveTab = setActiveTab;
  setActiveTab = function(tab) {
    originalSetActiveTab(tab);
    updateBottomNavState();
  };

  window.addEventListener('resize', updateHeaderHeight);
}

window.addEventListener('DOMContentLoaded', init);
