defmodule ElixirTestWeb.CredentialsController do
  use ElixirTestWeb, :controller

  def show(conn, _) do
    # conn = Plug.Conn.put_resp
    # IO.inspect(conn)
    # Phoenix.LiveView.Controller.live_render(conn, ElixirTestWeb.CredentialsLive)
  end

  def call(conn, _opts) do
    conn
    |> Plug.Conn.resp(200, "HELLO")
    |> Plug.Conn.put_resp_cookie("HELLO", "HELLO")
    # |> redirect(to: "/credentials/register")

    Phoenix.LiveView.Controller.live_render(conn, ElixirTestWeb.CredentialsLive, session: %{})
  end
end
