defmodule ElixirTestWeb.RoomLive do
  use ElixirTestWeb, :live_view
  alias ElixirTest.Tokens
  alias ElixirTest.Rooms
  alias ElixirTest.Userrooms
  alias ElixirTestWeb.CredentialsLive
  alias ElixirTest.Rooms.Room

  def mount(params, _session, socket) do
    Rooms.subscribe()

    try do
      %{"name" => name} = params
      IO.puts(name)

      socket =
        assign(socket,
          changeset: Room.input_changeset(%Room{}, %{}),
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
    CredentialsLive.is_login_correct(params, socket)
  end

  def handle_event("validate", %{"room" => room}, socket) do
    changeset =
      %Room{}
      |> Room.input_changeset(room)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("open_modal", _, socket) do
    {:noreply, assign(socket, modal_active: true)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, modal_active: false)}
  end

  def handle_event("create_room", %{"room" => room}, socket) do
    room = Map.put(room, "creator", socket.assigns.name)

    Rooms.create_room(room)

    %{"name" => name} = room
    roomid = Rooms.get_room_by_name(name).id

    # TODO: you have to make this unique so it doens't crash on select when it gets more than one item
    Userrooms.create_userroom(%{
      "name" => socket.assigns.name,
      "roomid" => roomid,
      "accepted" => true
    })

    {:noreply, assign(fetch_rooms(socket), modal_active: false)}
  end

  def handle_event("delete_room", %{"id" => id}, socket) do
    room = Rooms.get_room!(id)
    Rooms.delete_room(room)

    userroom = Userrooms.get_userroom!(id)
    Userrooms.delete_userroom(userroom)
    {:noreply, fetch_rooms(socket)}
  end

  def handle_event("goto_room", %{"id" => id}, socket) do
    name = socket.assigns.name
    {:ok, token} = CredentialsLive.add_token(name)
    {:noreply,
     push_redirect(socket,
       to: "/room/#{id}?access_token=#{token}&name=#{name}"
     )}
  end

  def handle_event("accept_invitation", %{"id" => id}, socket) do
    userroom = Userrooms.get_userroom!(id)
    Userrooms.update_userroom(userroom, %{accepted: true})
    {:noreply, fetch_rooms(socket)}
  end

  def handle_event("decline_invitation", %{"id" => id}, socket) do
    userroom = Userrooms.get_userroom!(id)
    Userrooms.delete_userroom(userroom)
    {:noreply, fetch_userrooms(socket)}
  end

  def handle_info({Userrooms, [:userroom | _], _}, socket) do
    {:noreply, fetch_userrooms(socket)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp get_rooms_from_userroom(userrooms) do
    # This makes a new invitations with the roomname
    rooms =
      Enum.map(userrooms, fn userroom ->
        room = Rooms.get_room!(userroom.roomid)
        new_userroom = Map.put(userroom, :roomname, room.name)
        new_userroom
      end)

    rooms
  end

  defp fetch_rooms(socket) do
    userrooms = Userrooms.list_usersroom_by_name(socket.assigns.name, true)
    new_userrooms = get_rooms_from_userroom(userrooms)
    assign(socket, rooms: new_userrooms)
  end

  defp fetch_userrooms(socket) do
    invitations = Userrooms.list_usersroom_by_name(socket.assigns.name, false)

    if length(invitations) == 0 do
      assign(socket, room_invitations: invitations)
    else
      new_invitations = get_rooms_from_userroom(invitations)

      assign(socket, room_invitations: new_invitations)
    end
  end
end
