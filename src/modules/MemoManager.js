import { isToday, getMemoDate, getDayKey } from '../utils/date.js';
import { countWords } from '../utils/helpers.js';

export const MemoManager = {
  sortMemos(list, sortMode = 'newest') {
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

    if (sortMode === 'title') {
      sorted.sort((a, b) => {
        const aPinned = !!a.isPinned;
        const bPinned = !!b.isPinned;
        if (aPinned !== bPinned) return aPinned ? -1 : 1;
        return (a.title || '').localeCompare(b.title || '');
      });
    } else if (sortMode === 'oldest') {
      sorted.sort((a, b) => {
        const aPinned = !!a.isPinned;
        const bPinned = !!b.isPinned;
        if (aPinned !== bPinned) return aPinned ? -1 : 1;
        return (a.createdAt || a.id) - (b.createdAt || b.id);
      });
    } else {
      // newest
      sorted.sort((a, b) => {
        const aPinned = !!a.isPinned;
        const bPinned = !!b.isPinned;
        if (aPinned !== bPinned) return aPinned ? -1 : 1;
        return (b.createdAt || b.id) - (a.createdAt || a.id);
      });
    }

    return sorted;
  },

  filterMemos(list, { tab = 'all', mood = 'all', tag = 'all', query = '' } = {}) {
    // 1. Filter by Tab
    let filtered = list;
    if (tab === 'pinned') {
      filtered = list.filter((m) => m.isPinned);
    } else if (tab === 'today') {
      filtered = list.filter((m) => isToday(m.datetime || m.createdAt));
    } else if (tab === 'tasks') {
      filtered = list.filter((m) => m.isTodo && !m.isDone);
    }
    // 'map' tab usually shows all lists or handled separately, but let's assume 'map' uses a separate list pipeline or just 'all' here. 
    // If 'map' logic filters differently (like only with location), we can add it. 
    // In original code: if (activeTab === 'map') return list; (it seemed to bypass filters essentially or relies on map specific filters)

    // 2. Filter by Mood
    if (mood !== 'all') {
      filtered = filtered.filter((memo) => (memo.mood || null) === mood);
    }

    // 3. Filter by Tag
    if (tag !== 'all') {
      filtered = filtered.filter((memo) => {
        const tags = Array.isArray(memo.tags) ? memo.tags : [];
        return tags.includes(tag);
      });
    }

    // 4. Filter by Search Query (title, text, or tags)
    const normalizedQuery = (query || '').trim().toLowerCase();
    if (normalizedQuery) {
      filtered = filtered.filter((memo) => {
        const inTitle = (memo.title || '').toLowerCase().includes(normalizedQuery);
        const inText = (memo.text || '').toLowerCase().includes(normalizedQuery);
        const tags = Array.isArray(memo.tags) ? memo.tags : [];
        const inTags = tags.some((t) => t.includes(normalizedQuery));
        return inTitle || inText || inTags;
      });
    }

    return filtered;
  },

  filterByTimeline(list, { enabled, value, mode = 'cumulative' } = {}) {
    if (!enabled || typeof value !== 'number') return list;
    
    // value is 0-100 from slider
    if (value >= 100 && mode === 'cumulative') return list;

    const dated = list
      .map((m) => ({ memo: m, date: getMemoDate(m) }))
      .filter((item) => item.date != null)
      .sort((a, b) => a.date - b.date);

    if (!dated.length) return list;

    const idx = Math.min(
      Math.round(((dated.length - 1) * value) / 100),
      dated.length - 1
    );
    
    const targetDate = dated[idx].date;
    
    if (mode === 'cumulative') {
      return list.filter((m) => {
        const d = getMemoDate(m);
        if (!d) return true; // keep undated
        return d.getTime() <= targetDate.getTime();
      });
    }
    
    // Slice modes
    return list.filter((m) => {
      const d = getMemoDate(m);
      if (!d) return false; 
      
      if (mode === 'daily') {
        return d.toDateString() === targetDate.toDateString();
      }
      if (mode === 'weekly') {
        const diffTime = Math.abs(d.getTime() - targetDate.getTime());
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)); 
        return diffDays <= 3;
      }
      if (mode === 'monthly') {
        return d.getMonth() === targetDate.getMonth() && d.getFullYear() === targetDate.getFullYear();
      }
      return false;
    });
  },

  getTimelineDate(list, value) {
    if (typeof value !== 'number') return null;
    const dated = list
      .map((m) => ({ memo: m, date: getMemoDate(m) }))
      .filter((item) => item.date != null)
      .sort((a, b) => a.date - b.date);

    if (!dated.length) return null;

    const idx = Math.min(
      Math.round(((dated.length - 1) * value) / 100),
      dated.length - 1
    );
    return dated[idx].date;
  },

  groupMemosByDay(list, sortMode = 'newest') {
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

    // Within each day, preserve existing sort order (passed in list is typically already sorted, but if we need strict sorting we can re-sort)
    // We'll reuse the class's sortMemos to be safe or assume 'list' is sorted.
    // The original code re-sorted: sortMemos(groups.get(key))
    return dayKeys.map((key) => ({ 
      dayKey: key, 
      memos: this.sortMemos(groups.get(key), sortMode) 
    }));
  },

  calculateStats(memos) {
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

    // Compute streak
    let streak = 0;
    let cursor = new Date();
    // Safety break to prevent infinite loops if something goes wrong
    for(let i=0; i<3650; i++) {
        const key = getDayKey(cursor.toISOString());
        if (!dayKeys.has(key)) break;
        streak += 1;
        cursor.setDate(cursor.getDate() - 1);
    }

    return {
      streak,
      entriesThisWeek,
      wordsToday,
      wordsThisWeek,
      latestTimestamp
    };
  }
};
