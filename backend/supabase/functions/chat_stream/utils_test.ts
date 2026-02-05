import { assertEquals } from "std/testing/asserts.ts";
import { formatChatContext } from "./utils.ts";

Deno.test("formatChatContext formats messages correctly", () => {
  const messages = [
    { role: "user", content: "Hello" },
    { role: "assistant", content: "Hi there!" },
  ];
  const expected = "USER: Hello\nASSISTANT: Hi there!";
  assertEquals(formatChatContext(messages), expected);
});

Deno.test("formatChatContext handles empty array", () => {
  assertEquals(formatChatContext([]), "");
});
