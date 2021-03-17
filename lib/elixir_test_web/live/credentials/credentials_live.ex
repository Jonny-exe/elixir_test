defmodule ElixirTestWeb.CredentialsLive do
  use ElixirTestWeb, :live_view
  alias ElixirTest.Users.User
  alias ElixirTest.Users
  alias ElixirTest.Tokens
  use Plug.Test

  def mount(_params, _session, socket) do
    socket = assign(socket, type: "register")
    {:ok, assign(socket, changeset: User.changeset(%User{}, %{}))}
  end

  def handle_params(params, _, socket) do
    try do
      %{"type" => type} = params

      if type != "register" and type != "login" do
        raise MatchError, message: "Error matching"
      end

      {:noreply, assign(socket, type: type)}
    rescue
      MatchError ->
        {:noreply,
         push_redirect(socket,
           to: "/credentials/register"
         )}
    end
  end

  def handle_event("register", %{"user" => user}, socket) do

    try do
      Users.create_user(user)
      name = user["name"]
      token = elem(add_token(name), 1)

      {:noreply,
       push_redirect(socket,
         to: "/?access_token=#{token}&name=#{name}"
       )}
    rescue
      Ecto.ConstraintError ->
        changeset =
          %User{}
          |> User.changeset(user)
          |> Map.put(:action, :validate)

        error_message = [name: {"name is already in use", []}]
        changeset = Map.put(changeset, :errors, error_message)
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp add_token(name) do
    token = create_random_token(16)
    Tokens.create_token(%{"token" => token, "name" => name})
    {:ok, token}
  end

  defp create_random_token(bytes_count) do
    bytes_count
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end

  def handle_event("login", %{"user" => user}, socket) do
    # TODO: handle login
    {:noreply, socket}
  end

  def handle_event("validate", %{"user" => post}, socket) do
    changeset =
      %User{}
      |> User.changeset(post)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end
end
