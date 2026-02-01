import { formatDateTime, formatDayLabel, getDayKey } from '../utils/date.js';
import { countWords } from '../utils/helpers.js';
import { MemoManager } from '../modules/MemoManager.js';

export const Renderer = {
  renderList(container, memos, template, callbacks = {}) {
    if (!container) return;
    container.innerHTML = '';

    if (!memos.length) {
      this.renderEmptyState(container, callbacks.isSearchActive, callbacks.onCompose);
      return;
    }

    // Grouping is handled by MemoManager, but we usually group the *page items*
    // So we rely on the caller to provide the ready-to-render list (paginated).
    const dayGroups = MemoManager.groupMemosByDay(memos);

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
        const node = this.createMemoNode(memo, template, callbacks);
        list.appendChild(node);
      }

      section.appendChild(list);
      container.appendChild(section);
    }
  },

  createMemoNode(memo, template, callbacks) {
    if (!template) {
       console.error("Template not found");
       return document.createElement('div');
    }
    
    const node = template.content.firstElementChild.cloneNode(true);
    node.dataset.memoId = memo.id;
    
    const titleEl = node.querySelector('.memo-title');
    const datetimeEl = node.querySelector('.memo-datetime');
    const textEl = node.querySelector('.memo-text');
    const tagsEl = node.querySelector('.memo-tags');
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
          if (callbacks.onTodoToggle) callbacks.onTodoToggle(memo.id, todoCheckbox.checked);
        });
      }
    } else if (todoCheckbox) {
      // Hide todo box if not a task
      // In strict CSS this might be handled by .todo class, but safer to hide manually if structure expects it
      const parent = todoCheckbox.closest('.memo-todo');
      if (parent) parent.style.visibility = 'hidden';
    }

    if (memo.isDone) {
      node.classList.add('todo-done');
    }

    if (titleEl) titleEl.textContent = memo.title || '(untitled)';
    
    if (datetimeEl) {
        const dt = memo.datetime || memo.createdAt;
        const wordCount = countWords(memo.text || '');
        const dateLabel = formatDateTime(dt) || 'No date';
        datetimeEl.textContent = wordCount > 0 ? `${dateLabel} · ${wordCount} word${wordCount === 1 ? '' : 's'}` : dateLabel;
    }
    
    if (textEl) textEl.textContent = memo.text || '';

    if (tagsEl) {
      tagsEl.innerHTML = '';
      const tags = Array.isArray(memo.tags) ? memo.tags : [];
      for (const tag of tags) {
        const chip = document.createElement('span');
        chip.className = 'memo-tag';
        chip.textContent = `#${tag}`;
        tagsEl.appendChild(chip);
      }
    }

    if (moodEl) {
      if (memo.mood === 'great') moodEl.textContent = '😊';
      else if (memo.mood === 'ok') moodEl.textContent = '😐';
      else if (memo.mood === 'bad') moodEl.textContent = '😞';
      else moodEl.textContent = '';
    }

    if (actionsEl && memo.location && typeof memo.location.lat === 'number') {
      const locIcon = document.createElement('button');
      locIcon.type = 'button';
      locIcon.className = 'icon-btn memo-location-icon';
      locIcon.title = 'View on map';
      locIcon.textContent = memo.location.symbol || '📍';
      locIcon.addEventListener('click', () => {
        if (callbacks.onLocationClick) callbacks.onLocationClick(memo);
      });
      actionsEl.insertBefore(locIcon, actionsEl.firstChild);
    }

    if (pinBtn) {
      pinBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        if (callbacks.onPin) callbacks.onPin(memo.id);
      });
    }

    if (editBtn) {
        editBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            if (callbacks.onEdit) callbacks.onEdit(memo.id);
        });
    }
    
    if (deleteBtn) {
        deleteBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            if (callbacks.onDelete) callbacks.onDelete(memo.id);
        });
    }

    return node;
  },

  renderEmptyState(container, isSearchActive, onCompose) {
    const wrapper = document.createElement('div');
    wrapper.className = 'empty-state';

    const message = document.createElement('p');
    message.textContent = isSearchActive
      ? 'No entries match your search.'
      : 'No entries yet. Start with your first reflection.';
    wrapper.appendChild(message);

    if (!isSearchActive && typeof onCompose === 'function') {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'btn primary empty-state-btn';
      button.textContent = 'Write your first entry';
      button.addEventListener('click', () => onCompose());
      wrapper.appendChild(button);
    }

    container.appendChild(wrapper);
  },

  updateStatsDOM(stats, elements, goal, { dailyFocus } = {}) {
    const { streakCountEl, weekCountEl, todayWordsEl, weekWordsEl, lastEntryLabelEl, dailyGoalLabel, dailyFocusLabel } = elements;
    
    if (streakCountEl) streakCountEl.textContent = `${stats.streak} day${stats.streak === 1 ? '' : 's'}`;
    if (weekCountEl) weekCountEl.textContent = `${stats.entriesThisWeek} entr${stats.entriesThisWeek === 1 ? 'y' : 'ies'}`;
    if (todayWordsEl) todayWordsEl.textContent = `${stats.wordsToday} word${stats.wordsToday === 1 ? '' : 's'}`;
    if (weekWordsEl) weekWordsEl.textContent = `${stats.wordsThisWeek} word${stats.wordsThisWeek === 1 ? '' : 's'}`;

    if (dailyGoalLabel) {
        if (!goal || goal <= 0) {
            dailyGoalLabel.textContent = 'Set a daily goal';
        } else {
            const remaining = Math.max(0, goal - stats.wordsToday);
            if (remaining === 0) {
                dailyGoalLabel.textContent = `Goal met (${goal} words)`;
            } else {
                dailyGoalLabel.textContent = `${stats.wordsToday}/${goal} words`;
            }
        }
    }

    if (lastEntryLabelEl) {
        if (stats.latestTimestamp) {
            lastEntryLabelEl.textContent = formatDateTime(stats.latestTimestamp);
        } else {
            lastEntryLabelEl.textContent = 'None yet';
        }
    }

    if (dailyFocusLabel) {
        if (dailyFocus && dailyFocus.trim()) {
            const trimmed = dailyFocus.trim();
            const maxLen = 80;
            dailyFocusLabel.textContent = trimmed.length > maxLen
              ? trimmed.slice(0, maxLen - 1) + '…'
              : trimmed;
        } else {
            dailyFocusLabel.textContent = "Set today's focus";
        }
    }
  },
  
  updatePagination(controls, { currentPage, totalPages }, onPageChange) {
      if (!controls) return;
      // We rely on main.js to show/hide controls based on totalItems > ITEMS_PER_PAGE.
      // But we can double check here or just focus on updating the state.
      
      const indicator = controls.querySelector('#pageIndicator');
      const prev = controls.querySelector('#prevPageBtn');
      const next = controls.querySelector('#nextPageBtn');

      if (indicator) indicator.textContent = `Page ${currentPage} of ${totalPages}`;
      if (prev) {
          prev.disabled = currentPage <= 1;
      }
      if (next) {
          next.disabled = currentPage >= totalPages;
      }
  }
};
