defmodule ElixirTestWeb.RoomLive do
  use ElixirTestWeb, :live_view
  alias ElixirTest.Tokens
  alias ElixirTest.Rooms
  alias ElixirTest.Userrooms
  alias ElixirTest.Rooms.Room

  def mount(params, _session, socket) do
    Rooms.subscribe()
    Userrooms.subscribe()

    try do
      %{"name" => name} = params

      socket =
        assign(socket,
          changeset: Room.input_changeset(%Room{}, %{}),
          rooms: fetch_rooms(socket),
          name: name,
          modal_active: false,
          room_invitations: []
        )

      {:ok,
       socket
       |> fetch_rooms()
       |> fetch_userrooms()}
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

  def handle_event("create_room", %{"room" => room}, socket) do
    room = Map.put(room, "creator", socket.assigns.name)
    Rooms.create_room(room)

    %{"name" => name} = room
    roomid = Rooms.get_room_by_name(name).id

    # TODO: you have to make this unique so it doens't crash on select when it gets more than one item
    Userrooms.create_userroom(%{"name" => socket.assigns.name, "roomid" => roomid})
    {:noreply, assign(socket, modal_active: false)}
  end

  def handle_event("open_modal", _, socket) do
    {:noreply, assign(socket, modal_active: true)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, modal_active: false)}
  end

  def handle_event("delete_room", %{"id" => id}, socket) do
    room = Rooms.get_room!(id)
    Rooms.delete_room(room)

    userroom = Userrooms.get_userroom!(id)
    Userrooms.delete_userroom(userroom)
    {:noreply, socket}
  end

  def handle_event("join_room", %{"id" => id}, socket) do
    todo = Rooms.get_room!(id)
    Rooms.delete_room(todo)
    {:noreply, socket}
  end

  def handle_info({Rooms, [:room | _], _}, socket) do
    IO.puts("INFOOOOOOOOOoo")
    {:noreply, fetch_rooms(socket)}
  end

  def handle_info({Userrooms, [:userroom | _], _}, socket) do
    IO.puts("INFOOOOOOOOOoo")
    {:noreply, fetch_userrooms(socket)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp fetch_rooms(socket) do
    assign(socket, rooms: Rooms.list_rooms())
  end

  defp fetch_userrooms(socket) do
    invitations = Userrooms.list_usersroom_by_name(socket.assigns.name)

    IO.puts("INVITATIONS")
    IO.inspect(invitations)

    if length(invitations) == 0 do
      assign(socket, room_invitations: invitations)
    else
      # This makes a new invitations with the roomname
      new_invitations = Enum.map(invitations, fn invitation ->
        userroom = Rooms.get_room!(invitation.roomid)
        new_invitation = Map.put(invitation, :roomname, userroom.name)
        IO.inspect(new_invitation)
        new_invitation
      end)

      assign(socket, room_invitations: new_invitations)
    end
  end
end
