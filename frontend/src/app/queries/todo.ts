export async function getTodo() {
  try {
    const response = await fetch(
      "https://jsonplaceholder.typicode.com/todos/1"
    );

    await new Promise((resolve) => setTimeout(resolve, 10000));
    const data = await response.json();

    return data;
  } catch (error) {
    console.error(error);
  }
}
