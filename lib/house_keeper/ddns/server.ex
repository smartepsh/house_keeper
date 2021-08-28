defmodule Keeper.DDNS.Server do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, %{wan_ip: nil, updated_at: nil, requested_at: nil, error_code: nil, error_reason: nil}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:set_ip, ip}, _from, %{wan_ip: ip} = state) do
    new_state = %{state | requested_at: DateTime.utc_now()}
    {:reply, :ok, new_state}
  end

  def handle_call({:set_ip, new_ip}, _from, state) do
    case mod(:aliyun).call(new_ip) do
      :ok ->
        {:reply, :ok,
         %{
           state
           | wan_ip: new_ip,
             updated_at: DateTime.utc_now(),
             requested_at: DateTime.utc_now(),
             error_code: nil,
             error_reason: nil
         }}

      {:error, code, reason} ->
        {:reply, :ok, %{state | error_code: code, error_reason: reason}}
    end
  end

  defp mod(:aliyun) do
    Keeper.DDNS.Aliyun
  end
end
