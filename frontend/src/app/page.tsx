import { Suspense, use } from "react";
import { getTodo } from "./queries/todo";
import { Todo } from "./todo";

export default function Home() {
  const todoPromise = getTodo();

  return (
    <Suspense fallback={<div>Loading...</div>}>
      <Todo todoPromise={todoPromise} />
    </Suspense>
  );
}
