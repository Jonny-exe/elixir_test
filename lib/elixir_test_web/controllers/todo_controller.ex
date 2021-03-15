defmodule ElixirTestWeb.TodoController do
  def call(conn, params) do
    # IO.puts("SHOWWWWWW")

    conn
    |> Plug.Conn.resp(200, "HELLO")


    Phoenix.LiveView.Controller.live_render(conn, ElixirTestWeb.TodoLive, session: %{})
  end

  def show(call, expr) do
    IO.puts("SHOWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWw")
    {:ok}
  end

  def init(opts) do
    IO.puts("OPTSTSTST")
  end
end
