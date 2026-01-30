// Lightweight helpers for task-style memos.
// A memo can be marked as a "task" (isTodo) and toggled done (isDone).

/**
 * Normalize older stored memos that predate the task feature so they
 * always have explicit isTodo / isDone flags.
 */
export function withTodoDefaults(memos) {
  if (!Array.isArray(memos)) return [];
  return memos.map((m) => {
    if (!m || typeof m !== 'object') return m;
    if (typeof m.isTodo === 'boolean' && typeof m.isDone === 'boolean') return m;
    return {
      isTodo: false,
      isDone: false,
      ...m,
    };
  });
}

/**
 * Count open tasks (memos that are marked as tasks but not yet done).
 */
export function countOpenTasks(memos) {
  return (memos || []).filter((m) => m && m.isTodo && !m.isDone).length;
}
