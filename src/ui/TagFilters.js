// TagFilters UI helper: builds tag options and quick chips for fast filtering.
// This stays UI-only; pure memo logic lives in MemoManager.

function getTagStats(memos) {
  const counts = new Map();
  for (const memo of memos || []) {
    const tags = Array.isArray(memo.tags) ? memo.tags : [];
    for (const raw of tags) {
      const tag = (raw || '').trim();
      if (!tag) continue;
      counts.set(tag, (counts.get(tag) || 0) + 1);
    }
  }

  return Array.from(counts.entries())
    .map(([tag, count]) => ({ tag, count }))
    .sort((a, b) => {
      if (b.count !== a.count) return b.count - a.count;
      return a.tag.localeCompare(b.tag);
    });
}

function updateTagSelect(selectEl, tagStats, activeTag) {
  if (!selectEl) return;

  // Remember scroll position to avoid jank on mobile.
  const scrollTop = selectEl.scrollTop;

  // Rebuild options: "all" + each tag.
  selectEl.innerHTML = '';
  const allOption = document.createElement('option');
  allOption.value = 'all';
  allOption.textContent = 'Tag: All';
  selectEl.appendChild(allOption);

  for (const { tag, count } of tagStats) {
    const opt = document.createElement('option');
    opt.value = tag;
    opt.textContent = `#${tag} (${count})`;
    selectEl.appendChild(opt);
  }

  // Restore selection if the active tag still exists.
  const desired = activeTag && activeTag !== 'all'
    ? activeTag
    : 'all';

  if ([...selectEl.options].some(o => o.value === desired)) {
    selectEl.value = desired;
  } else {
    selectEl.value = 'all';
  }

  selectEl.scrollTop = scrollTop;
}

function renderTagChips(containerEl, tagStats, activeTag, onTagSelected) {
  if (!containerEl) return;

  containerEl.innerHTML = '';

  if (!tagStats.length) {
    containerEl.hidden = true;
    return;
  }

  containerEl.hidden = false;

  const label = document.createElement('span');
  label.className = 'tag-chips-label';
  label.textContent = 'Quick tags:';
  containerEl.appendChild(label);

  const list = document.createElement('div');
  list.className = 'tag-chips-list';

  const MAX_CHIPS = 6;
  const chips = tagStats.slice(0, MAX_CHIPS);

  for (const { tag, count } of chips) {
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'tag-chip';
    if (tag === activeTag) btn.classList.add('active');
    btn.textContent = `#${tag} · ${count}`;
    btn.addEventListener('click', () => {
      if (typeof onTagSelected === 'function') {
        onTagSelected(tag === activeTag ? 'all' : tag);
      }
    });
    list.appendChild(btn);
  }

  containerEl.appendChild(list);
}

export const TagFilters = {
  /**
   * Synchronize tag select options + quick chips from memos.
   */
  updateTagFilters({ selectEl, chipsContainer, memos, activeTag, onTagSelected }) {
    const tagStats = getTagStats(memos);
    updateTagSelect(selectEl, tagStats, activeTag);
    renderTagChips(chipsContainer, tagStats, activeTag, onTagSelected);
  },
};
