defmodule ElixirTestWeb.TodoLive do
  use ElixirTestWeb, :live_view
  alias ElixirTest.Todos
  alias ElixirTestWeb.CredentialsLive
  alias ElixirTest.Users
  alias ElixirTest.Tokens
  alias ElixirTest.Rooms
  alias ElixirTest.Rooms.Room
  alias ElixirTest.Userrooms.Userroom
  alias ElixirTest.Userrooms

  def mount(params, _session, socket) do
    Todos.subscribe()
    Users.subscribe()
    roomid = Map.get(params, "roomid")
    room_creator = Rooms.get_room!(elem(Integer.parse(roomid), 0))
    room_creator = Map.get(room_creator, :creator)

    socket =
      assign(socket,
        changeset: Todos.Todo.changeset(%Todos.Todo{}, %{}),
        room: roomid,
        modal_active: false,
        room_creator: room_creator
      )

    {:ok,
     socket
     |> fetch_todos()}
  end

  def handle_params(params, _, socket) do
    socket = elem(ElixirTestWeb.CredentialsLive.is_login_correct(params, socket), 1)
    roomid = Map.get(params, "roomid")
    roomid = elem(Integer.parse(roomid), 0)
    {:noreply, assign(socket, room: roomid)}
  end

  def handle_event("open_modal", _, socket) do
    {:noreply, assign(socket, modal_active: true)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, modal_active: false)}
  end

  def handle_event("add_todo", %{"todo" => todo}, socket) do
    todo = Map.put(todo, "room", socket.assigns.room)
    todo = Map.put(todo, "writer", socket.assigns.name)
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

  def handle_event("create_invitation", %{"todo" => %{"name" => name}}, socket) do
    Userrooms.create_userroom(%{
      "name" => name,
      "roomid" => socket.assigns.room,
      "accepted" => false
    })
    {:noreply, assign(socket, modal_active: false)}
  end

  def handle_info({Todos, [:todo | _], _}, socket) do
    {:noreply, fetch_todos(socket)}
  end

  defp fetch_todos(socket) do
    assign(socket, todos: Todos.list_todos_in_room(socket.assigns.room))
  end
end
