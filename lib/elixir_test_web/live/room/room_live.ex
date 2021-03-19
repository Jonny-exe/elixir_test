defmodule ElixirTestWeb.RoomLive do
  use ElixirTestWeb, :live_view
  alias ElixirTest.Tokens
  alias ElixirTest.Rooms
  alias ElixirTest.Rooms.Room

  def mount(params, _session, socket) do
    Rooms.subscribe()
    try do
      %{"name" => name} = params

      socket =
        assign(socket,
          changeset: Room.input_changeset(%Room{}, %{}),
          rooms: fetch_rooms(socket),
          name: name,
          modal_active: false
        )

      {:ok,
       socket
       |> fetch_rooms()}
    rescue
      MatchError ->
        nil
        {:ok, socket}
    end
  end

  def handle_params(params, _, socket) do
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
    {:noreply,
     push_redirect(socket,
       to: "/credentials/register"
     )}
  end

  def handle_event("validate", %{"room" => room}, socket) do
    changeset =
      %Room{}
      |> Room.input_changeset(room)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("add", %{"room" => room}, socket) do
    room = Map.put(room, "creator", socket.assigns.name)
    Rooms.create_room(room)
    {:noreply, assign(socket, modal_active: false)}
  end

  def handle_event("open_modal", _, socket) do
    {:noreply, assign(socket, modal_active: true)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, modal_active: false)}
  end

  def handle_event("delete_room", %{"id" => id}, socket) do
    todo = Rooms.get_room!(id)
    Rooms.delete_room(todo)
    {:noreply, socket}
  end

  def handle_event("join_room", %{"id" => id}, socket) do
    todo = Rooms.get_room!(id)
    Rooms.delete_room(todo)
    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg)
    {:noreply, fetch_rooms(socket)}
  end

  defp fetch_rooms(socket) do
    assign(socket, rooms: Rooms.list_rooms())
  end
end
