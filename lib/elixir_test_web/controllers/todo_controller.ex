defmodule ElixirTestWeb.TodoController do
  def call(conn, params) do
    IO.inspect(params)
    conn
    |> Plug.Conn.resp(200, "OK")

    Phoenix.LiveView.Controller.live_render(conn, ElixirTestWeb.TodoLive, session: %{})
  end

  def init(_opts) do
  end
end
