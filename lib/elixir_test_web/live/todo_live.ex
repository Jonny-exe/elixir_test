defmodule ElixirTestWeb.TodoLive do
  use ElixirTestWeb, :live_view
  alias ElixirTest.Todos

  def mount(_params, _session, socket) do
    Todos.subscribe()
    {:ok, fetch(socket)}
  end

  def handle_event("add", %{"todo" => todo}, socket) do
    Todos.create_todo(todo)
    {:noreply, fetch(socket)}
  end

  def handle_info({Todos, [:todo | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, todos: Todos.list_todos())
  end
end
