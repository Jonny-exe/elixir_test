defmodule ElixirTestWeb.LoginLive do
  use ElixirTestWeb, :live_view
  alias ElixirTest.Todos
  alias ElixirTest.Login
  alias Plug.Conn
  use Plug.Test

  def login(conn, params) do
    IO.puts "CALLLLLLLLLLllllll"
    # Phoenix.LiveView.Controller.live_render(conn, ElixirTestWeb.TodoLive, session: %{})

    # conn
    # |> Plug.Conn.resp(404, "Not found")
  end

  def mount(_params, _session, socket) do
    # Todos.subscribe()
    {:ok, assign(socket, changeset: Login.changeset(%Login{}, %{}))}
  end

  def handle_event("validate", %{"login" => post}, socket) do
    changeset =
      %Login{}
      |> Login.changeset(post)
      |> Map.put(:action, :validate)

    # errors = elem(has_errors(changeset), 0)
    # IO.inspect(errors)

    # if errors === :ok do
    #   IO.puts("NO ERRORS")
    #   redirect(socket, to: "/oogle")
    # end

    {:noreply, assign(socket, changeset: changeset)}
  end

  def has_errors(changeset) do
    if Enum.at(elem(Map.fetch(changeset, :errors), 1), 0) === nil do
      {:ok}
    else
      {:error}
    end
  end
end
