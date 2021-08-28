defmodule Keeper.DDNS do
  alias Keeper.DDNS.Server

  def get_state do
    GenServer.call(Server, :get_state)
  end

  def set_ip(new_ip) do
    GenServer.call(Server, {:set_ip, new_ip})
  end
end
