defmodule ElixirTestWeb.TodoLive do
  use ElixirTestWeb, :live_view
  alias ElixirTest.Todos
  alias ElixirTest.Users
  alias ElixirTest.Tokens
  alias ElixirTest.Rooms

  def mount(_params, _session, socket) do
    Todos.subscribe()
    Users.subscribe()

    {:ok,
     socket
     |> fetch_todos()
     |> fetch_rooms()}
  end

  def handle_params(params, _, socket) do
    IO.puts("TODO")
    IO.inspect(params)

    try do
      %{"access_token" => token, "name" => name} = params
      userinfo = Tokens.get_token(name)

      if userinfo == nil do
        raise MatchError, message: "Incorrect access not found"
      end

      if Map.get(userinfo, :token) == token do
        Tokens.delete_token(userinfo)
        {:noreply, assign(socket, name: name)}
      else
        raise MatchError, message: "Error with userinfo"
      end
    rescue
      MatchError -> redirect_to_login(socket)
    catch
      _value -> redirect_to_login(socket)
    end
  end

  defp redirect_to_login(socket) do
    IO.puts("Redirect")

    {:noreply,
     push_redirect(socket,
       to: "/credentials/register"
     )}
  end

  def handle_event("add", %{"todo" => todo}, socket) do
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

  defp fetch_rooms(socket) do
    assign(socket, rooms: Rooms.list_rooms())
  end
end
