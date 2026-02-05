/**
 * Formats chat messages into a string for LLM context
 */
export function formatChatContext(messages: { role: string; content: string }[]): string {
  return messages
    .map((m) => `${m.role.toUpperCase()}: ${m.content}`)
    .join("\n");
}
