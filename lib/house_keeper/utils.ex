defmodule Keeper.Utils do
  def env!(key) do
    Application.fetch_env!(:house_keeper, key)
  end

  def env!(key, sub_key) do
    Application.fetch_env!(:house_keeper, key)
    |> Keyword.fetch!(sub_key)
  end
end
