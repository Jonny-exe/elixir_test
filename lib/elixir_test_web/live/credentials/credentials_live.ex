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

  def add_token(name) do
    token = create_random_token(16)
    Tokens.create_token(%{"token" => token, "name" => name})
    {:ok, token}
  end

  defp redirect_with_token(name, socket) do
    token = elem(add_token(name), 1)

    {:noreply,
     push_redirect(socket,
       to: "/?access_token=#{token}&name=#{name}"
     )}
  end

  defp create_random_token(bytes_count) do
    bytes_count
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end

  def handle_event("login", %{"user" => user}, socket) do
    try do
      %{"name" => input_name, "password" => input_password} = user
      user = Users.get_user!(input_name)
      password = Map.get(user, :password)

      if input_password == password do
        redirect_with_token(input_name, socket)
      else
        raise Ecto.NoResultsError, message: "incorrect password"
      end
    rescue
      Ecto.NoResultsError ->
        error_message = [name: {"username or password are incorrect", []}]

        changeset =
          %User{}
          |> User.changeset(user)
          |> Map.put(:action, :validate)

        changeset = Map.put(changeset, :errors, error_message)
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("register", %{"user" => user}, socket) do
    try do
      Users.create_user(user)
      name = user["name"]
      redirect_with_token(name, socket)
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

  def handle_event("validate", %{"user" => post}, socket) do
    changeset =
      %User{}
      |> User.changeset(post)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def is_login_correct(params, socket) do
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
       to: "/credentials/login"
     )}
  end
end
