import { ITEMS_PER_PAGE } from './config/constants.js';
import { Storage } from './services/Storage.js';
import { MemoManager } from './modules/MemoManager.js';
import { MapManager } from './modules/MapManager.js';
import { Renderer } from './ui/Renderer.js';
import { initToast, showToast, updateHeaderHeight } from './ui/Toast.js';
import { PWA } from './modules/PWA.js';
import { isMobileView } from './utils/helpers.js';

// --- State ---
const state = {
  memos: [],
  settings: {
    dailyWordGoal: null,
  },
  view: {
    activeTab: 'all', // 'all', 'today', 'pinned', 'tasks', 'map'
    activeMoodFilter: 'all',
    searchQuery: '',
    currentPage: 1,
  },
  map: {
    heatEnabled: false,
    timelineEnabled: false,
    timelineValue: 100,
    timelineMode: 'cumulative',
    markerStyle: 'pin',
    lastListTab: 'all', // to return from map
  },
  editing: {
    id: null,
    location: null,
  },
};

// --- DOM Elements ---
const elements = {
  memoList: document.getElementById('memoList'),
  memoTemplate: document.getElementById('memoTemplate'),
  paginationControls: document.getElementById('paginationControls'),
  pageIndicator: document.getElementById('pageIndicator'),
  prevPageBtn: document.getElementById('prevPageBtn'),
  nextPageBtn: document.getElementById('nextPageBtn'),
  
  // Inputs
  searchInput: document.getElementById('searchInput'),
  mapSearchInput: document.getElementById('mapSearchInput'),
  sortSelect: document.getElementById('sortSelect'),
  viewSelect: document.getElementById('viewSelect'),
  moodSelect: document.getElementById('moodSelect'),
  mapMoodSelect: document.getElementById('mapMoodSelect'),
  
  // Form
  memoForm: document.getElementById('memoForm'),
  titleInput: document.getElementById('title'),
  datetimeInput: document.getElementById('datetime'),
  textInput: document.getElementById('text'),
  isTodoInput: document.getElementById('isTodo'),
  formCloseBtn: document.getElementById('formCloseBtn'),
  locationSymbolInput: document.getElementById('locationSymbolInput'),
  
  // Stats
  streakCountEl: document.getElementById('streakCount'),
  weekCountEl: document.getElementById('weekCount'),
  lastEntryLabelEl: document.getElementById('lastEntryLabel'),
  todayWordsEl: document.getElementById('todayWords'),
  weekWordsEl: document.getElementById('weekWords'),
  dailyGoalLabel: document.getElementById('dailyGoalLabel'),
  
  // Map Timeline
  mapTimelineToggleBtn: document.getElementById('mapTimelineToggleBtn'),
  mapHeatToggleBtn: document.getElementById('mapHeatToggleBtn'),
  mapTimelineBar: document.getElementById('mapTimelineBar'),
  mapTimelineSlider: document.getElementById('mapTimelineSlider'),
  mapTimelineLabel: document.getElementById('mapTimelineLabel'),
  mapTimelineMode: document.getElementById('mapTimelineMode'),
  mapCountLabel: document.getElementById('mapCountLabel'),
  mapRecenterBtn: document.getElementById('mapRecenterBtn'),
  mapMarkerSelect: document.getElementById('mapMarkerSelect'),
  mapShell: document.getElementById('mapShell'),
  mapHeaderBtn: document.getElementById('mapHeaderBtn'),
  mapCloseBtn: document.getElementById('mapCloseBtn'),
  
  // Other
  composeFab: document.getElementById('composeFab'),
  composeSection: document.getElementById('composeSection'),
  bottomNav: document.getElementById('bottomNav'),
  exportBtn: document.getElementById('exportBtn'),
  importBtn: document.getElementById('importBtn'),
  importInput: document.getElementById('importInput'),
  appHeader: document.querySelector('.app-header'),
};

// --- Initialization ---

function init() {
  initToast();
  PWA.init();
  
  // Load Data
  state.memos = Storage.loadMemos().map(m => ({ 
    isTodo: false, isDone: false, ...m 
  })); // Basic normalization
  
  state.settings = Storage.loadSettings();

  // Init Map Manager
  MapManager.init({
    focusMemo: (id) => {
      // If we are in map view, we might want to edit or just view?
      // The original code: Focus usually meant panning to it? 
      // Actually `focusMemo` isn't fully defined in original `location.js` except setting view.
      // But if we want to EDIT from map:
      startEditMemo(id);
    },
    onLocationSelected: (loc) => {
      state.editing.location = loc;
    }
  });

  bindEvents();
  render();
  updateHeaderHeight(elements.appHeader);
  
  // Initial Sync
  if (state.settings.dailyWordGoal) {
      // potentially set input value if there was a settings UI
  }
}

// --- Core Actions ---

function save() {
  Storage.saveMemos(state.memos);
  render();
}

function startEditMemo(id) {
  const memo = state.memos.find(m => m.id === id);
  if (!memo) return;

  state.editing.id = id;
  state.editing.location = memo.location ? { ...memo.location } : null;

  elements.titleInput.value = memo.title || '';
  
  const dt = memo.datetime || memo.createdAt;
  const d = new Date(dt);
  const pad = (n) => String(n).padStart(2, '0');
  const local = new Date(d.getTime() - d.getTimezoneOffset() * 60000);
  elements.datetimeInput.value = `${local.getFullYear()}-${pad(local.getMonth() + 1)}-${pad(local.getDate())}T${pad(local.getHours())}:${pad(local.getMinutes())}`;
  
  elements.textInput.value = memo.text || '';
  if (elements.isTodoInput) elements.isTodoInput.checked = !!memo.isTodo;
  if (elements.locationSymbolInput && memo.location?.symbol) {
      elements.locationSymbolInput.value = memo.location.symbol;
  }
  
  // Set mood in UI if exists (custom mood radio handling required?)
  // Assuming basic form for now.
  const moodRadio = elements.memoForm.querySelector(`input[name="mood"][value="${memo.mood || ''}"]`);
  if (moodRadio) moodRadio.checked = true;
  else {
     const allRadios = elements.memoForm.querySelectorAll('input[name="mood"]');
     if(allRadios) allRadios.forEach(r => r.checked = false);
  }

  MapManager.setCurrentEditingLocation(state.editing.location);
  
  showComposeForm();
}

function deleteMemo(id) {
  if (!confirm('Delete this memo?')) return;
  state.memos = state.memos.filter(m => m.id !== id);
  save();
  showToast('Memo deleted');
}

function togglePinMemo(id) {
  const memo = state.memos.find(m => m.id === id);
  if (memo) {
    memo.isPinned = !memo.isPinned;
    save();
    showToast(memo.isPinned ? 'Pinned' : 'Unpinned');
  }
}

function toggleTodoDone(id, isDone) {
  const memo = state.memos.find(m => m.id === id);
  if (memo) {
    memo.isDone = isDone;
    save();
  }
}

function showComposeForm() {
    if (elements.composeSection) {
        elements.composeSection.classList.add('visible');
        if (!state.editing.id) {
            resetForm();
            setDatetimeToNow();
        }
        setTimeout(() => elements.titleInput?.focus(), 100);
    }
}

function hideComposeForm() {
    if (elements.composeSection) {
        elements.composeSection.classList.remove('visible');
    }
    resetForm();
}

function resetForm() {
    state.editing.id = null;
    state.editing.location = null;
    elements.memoForm.reset();
    MapManager.setCurrentEditingLocation(null);
    if(elements.locationSymbolInput) elements.locationSymbolInput.value = '📍';
}

function setDatetimeToNow() {
    if (!elements.datetimeInput) return;
    const now = new Date();
    const pad = (n) => String(n).padStart(2, '0');
    const local = new Date(now.getTime() - now.getTimezoneOffset() * 60000);
    const value = `${local.getFullYear()}-${pad(local.getMonth() + 1)}-${pad(local.getDate())}T${pad(local.getHours())}:${pad(local.getMinutes())}`;
    elements.datetimeInput.value = value;
}

// --- Rendering ---

function render() {
  document.body.classList.toggle('map-mode', state.view.activeTab === 'map');
  if (elements.mapShell) elements.mapShell.hidden = state.view.activeTab !== 'map';
  if (elements.memoList) elements.memoList.hidden = state.view.activeTab === 'map';

  // 1. Filter & Sort
  const filtered = MemoManager.filterMemos(state.memos, {
    tab: state.view.activeTab,
    mood: state.view.activeMoodFilter,
    query: state.view.searchQuery
  });
  
  const sortMode = elements.sortSelect?.value || 'newest';
  const sorted = MemoManager.sortMemos(filtered, sortMode);

  // 2. Stats
  const stats = MemoManager.calculateStats(state.memos);
  Renderer.updateStatsDOM(stats, elements, state.settings.dailyWordGoal);

  // 3. Map Rendering
  if (state.view.activeTab === 'map') {
      const mapList = MemoManager.filterByTimeline(sorted, {
          enabled: state.map.timelineEnabled,
          value: state.map.timelineValue,
          mode: state.map.timelineMode
      });
      
      MapManager.renderMapView(mapList, {
          markerStyle: state.map.markerStyle,
          heat: state.map.heatEnabled
      });
      
      // Update Map Counts
      // Should probably move getMapCounts to MapManager or MemoManager
      // For now, doing it here or simple calculation
      if (elements.mapCountLabel) {
         const count = mapList.filter(m => m.location && m.location.lat).length;
         elements.mapCountLabel.textContent = `${count} locations`;
      }
      return;
  }

  // 4. List Rendering (Pagination)
  const totalItems = sorted.length;
  const totalPages = Math.ceil(totalItems / ITEMS_PER_PAGE) || 1;
  
  if (state.view.currentPage > totalPages) state.view.currentPage = totalPages;
  if (state.view.currentPage < 1) state.view.currentPage = 1;

  const start = (state.view.currentPage - 1) * ITEMS_PER_PAGE;
  const end = start + ITEMS_PER_PAGE;
  const pageItems = sorted.slice(start, end);

  Renderer.renderList(elements.memoList, pageItems, elements.memoTemplate, {
      onEdit: startEditMemo,
      onDelete: deleteMemo,
      onPin: togglePinMemo,
      onTodoToggle: toggleTodoDone,
      onLocationClick: (memo) => {
          state.map.lastListTab = state.view.activeTab;
          state.view.activeTab = 'map';
          if(elements.viewSelect) elements.viewSelect.value = 'map';
          updateBottomNav('map');
          render();
          MapManager.focusMemo(memo.id); // Or MapManager.setView ...
      },
      isSearchActive: !!state.view.searchQuery
  });

  Renderer.updatePagination(elements.paginationControls, {
      currentPage: state.view.currentPage,
      totalPages
  });
}

function updateBottomNav(tab) {
    if (!elements.bottomNav) return;
    elements.bottomNav.querySelectorAll('.nav-item').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.nav === tab);
    });
}


// --- Event Wiring ---

function bindEvents() {
    // Form
    elements.memoForm?.addEventListener('submit', (e) => {
        e.preventDefault();
        const title = elements.titleInput.value.trim();
        const text = elements.textInput.value.trim();
        const datetime = elements.datetimeInput.value || new Date().toISOString();
        const moodRadio = elements.memoForm.querySelector('input[name="mood"]:checked');
        const mood = moodRadio ? moodRadio.value : null;
        const isTodo = elements.isTodoInput?.checked || false;
        
        const newItem = {
            id: state.editing.id || Date.now(),
            title,
            text,
            datetime, // ISO string or whatever input gives, usually YYYY-MM-DDTHH:mm
            createdAt: state.editing.id ? (state.memos.find(m=>m.id === state.editing.id)?.createdAt) : Date.now(),
            mood,
            location: state.editing.location,
            isTodo,
            isDone: state.editing.id ? (state.memos.find(m=>m.id === state.editing.id)?.isDone) : false,
            isPinned: state.editing.id ? (state.memos.find(m=>m.id === state.editing.id)?.isPinned) : false,
        };
        
        // Fix datetime to ISO if needed
        try { newItem.datetime = new Date(datetime).toISOString(); } catch(e){}

        if (state.editing.id) {
            const index = state.memos.findIndex(m => m.id === state.editing.id);
            if (index !== -1) state.memos[index] = newItem;
        } else {
            state.memos.unshift(newItem);
        }
        
        save();
        hideComposeForm();
        showToast(state.editing.id ? 'Memo updated' : 'Memo created');
    });

    elements.composeFab?.addEventListener('click', showComposeForm);
    elements.formCloseBtn?.addEventListener('click', hideComposeForm);

    // Navigation & Filters
    elements.viewSelect?.addEventListener('change', (e) => {
        state.view.activeTab = e.target.value;
        state.view.currentPage = 1;
        render();
    });

    elements.bottomNav?.querySelectorAll('.nav-item').forEach(btn => {
        btn.addEventListener('click', () => {
             const nav = btn.dataset.nav;
             state.view.activeTab = nav;
             state.view.currentPage = 1;
             updateBottomNav(nav);
             render();
        });
    });

    elements.searchInput?.addEventListener('input', (e) => {
        state.view.searchQuery = e.target.value;
        state.view.currentPage = 1;
        render();
    });

    elements.moodSelect?.addEventListener('change', (e) => {
        state.view.activeMoodFilter = e.target.value;
        state.view.currentPage = 1;
        render();
    });
    
    elements.sortSelect?.addEventListener('change', () => render());

    // Pagination
    elements.prevPageBtn?.addEventListener('click', () => {
        state.view.currentPage--;
        render();
    });
    
    elements.nextPageBtn?.addEventListener('click', () => {
        state.view.currentPage++;
        render();
    });

    // Map Specifics
    elements.mapTimelineToggleBtn?.addEventListener('click', () => {
        state.map.timelineEnabled = !state.map.timelineEnabled;
        if(elements.mapTimelineBar) elements.mapTimelineBar.hidden = !state.map.timelineEnabled;
        render(); // triggers map update
    });
    
    elements.mapTimelineSlider?.addEventListener('input', (e) => {
        state.map.timelineValue = Number(e.target.value);
        render();
    });
    
    // Export/Import
    elements.exportBtn?.addEventListener('click', () => {
        Storage.exportMemosToFile(state.memos);
    });
    
    elements.importBtn?.addEventListener('click', () => {
        elements.importInput?.click();
    });
    
    elements.importInput?.addEventListener('change', (e) => {
        const file = e.target.files[0];
        Storage.importMemosFromFile(file, state.memos, (newMemos) => {
            state.memos = newMemos;
            save();
            showToast('Import successful');
        });
    });
}

// Start
document.addEventListener('DOMContentLoaded', init);
