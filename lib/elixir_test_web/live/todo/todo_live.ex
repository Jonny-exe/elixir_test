defmodule ElixirTestWeb.TodoLive do
  use ElixirTestWeb, :live_view
  alias ElixirTest.Todos
  alias ElixirTestWeb.CredentialsLive
  alias ElixirTest.Users
  alias ElixirTest.Tokens
  alias ElixirTest.Rooms
  alias ElixirTest.Rooms.Room

  def mount(_params, _session, socket) do
    Todos.subscribe()
    Users.subscribe()
    socket = assign(socket, changeset: Todos.Todo.changeset(%Todos.Todo{}, %{}))

    {:ok,
     socket
     |> fetch_todos()}
  end

  def handle_params(params, _, socket) do
    ElixirTestWeb.CredentialsLive.is_login_correct(params, socket)
  end

  def handle_event("add_todo", %{"todo" => todo}, socket) do
    Todos.create_todo(todo)
    {:noreply, socket}
  end

  def handle_event("toggle_done", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    Todos.update_todo(todo, %{done: !todo.done})
    {:noreply, socket}
  end

  def handle_event("delete_todo", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    Todos.delete_todo(todo)
    {:noreply, socket}
  end

  def handle_info({Todos, [:todo | _], _}, socket) do
    {:noreply, fetch_todos(socket)}
  end

  defp fetch_todos(socket) do
    assign(socket, todos: Todos.list_todos())
  end
end
