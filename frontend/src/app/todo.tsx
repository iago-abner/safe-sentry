import { use } from "react";

export function Todo({ todoPromise }: { todoPromise: Promise<any> }) {
  const todo = use(todoPromise);

  return <pre>{JSON.stringify(todo, null, 2)}</pre>;
}
