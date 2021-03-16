defmodule ElixirTestWeb.RegisterLive do
  use ElixirTestWeb, :live_view
  alias ElixirTest.Users.User
  alias ElixirTest.Users
  use Plug.Test

  def mount(_params, _session, socket) do
    # Todos.subscribe()
    {:ok, assign(socket, changeset: User.changeset(%User{}, %{}))}
  end

  def handle_event("register", %{"user" => user}, socket) do
    try do
      Users.create_user(user)

      {:noreply,
       push_redirect(socket,
         to: "/?hello=v"
       )}
    rescue
      Ecto.ConstraintError ->
        changeset =
          %User{}
          |> User.changeset(user)
          |> Map.put(:action, :validate)

        IO.inspect(is_map(changeset))
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
end
