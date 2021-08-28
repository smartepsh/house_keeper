defmodule KeeperWeb.DDNSController do
  use KeeperWeb, :controller

  alias Keeper.DDNS

  def show(conn, _) do
    render(conn, "show.html", DDNS.get_state())
  end

  def update(conn, %{"new_ip" => new_ip}) do
    DDNS.set_ip(new_ip)
    send_resp(conn, 204, "")
  end
end
