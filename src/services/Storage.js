import { STORAGE_KEY, SETTINGS_KEY } from '../config/constants.js';
import { showToast } from '../ui/Toast.js';

export const Storage = {
  loadMemos() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch (e) {
      console.error('Failed to load memos', e);
      return [];
    }
  },

  saveMemos(memos) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(memos));
    } catch (e) {
      console.error('Failed to save memos', e);
      showToast('Could not save memos (storage full?)');
    }
  },

  loadSettings() {
    try {
      const settingsRaw = localStorage.getItem(SETTINGS_KEY);
      const parsed = settingsRaw ? JSON.parse(settingsRaw) : null;
      if (parsed && typeof parsed === 'object') {
        return {
          dailyWordGoal: parsed.dailyWordGoal ?? null,
          dailyFocusByDate: parsed.dailyFocusByDate ?? {},
          theme: parsed.theme ?? 'system',
        };
      }
    } catch (e) {
      console.error('Failed to load settings', e);
    }
    return { dailyWordGoal: null, dailyFocusByDate: {}, theme: 'system' };
  },

  saveSettings(settings) {
    try {
      localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
    } catch (e) {
      console.error('Failed to save settings', e);
    }
  },

  exportMemosToFile(memos) {
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
  },

  importMemosFromFile(file, currentMemos, onImportCallback) {
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

        this.handleImportedMemos(imported, currentMemos, onImportCallback);
      } catch (e) {
        console.error('Failed to import memos', e);
        showToast('Could not read backup file');
      }
    };
    reader.onerror = () => {
      showToast('Could not read backup file');
    };
    reader.readAsText(file);
  },

  handleImportedMemos(imported, currentMemos, callback) {
    if (!Array.isArray(imported)) {
      showToast('Invalid backup file');
      return;
    }

    const hasExisting = currentMemos.length > 0;
    let next = [];

    if (hasExisting) {
      const replace = window.confirm('Replace all existing memos with this backup?');
      if (replace) {
        next = imported;
      } else {
        const byId = new Map();
        for (const m of currentMemos) {
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

    callback(next);
    showToast('Imported memos');
  }
};
