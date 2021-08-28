defmodule Keeper.DDNS.Aliyun do
  alias Keeper.Utils

  @action "GET"
  @record_id Utils.env!(:aliyun, :record_id)
  @domain Utils.env!(:aliyun, :domain)
  @access_key Utils.env!(:aliyun, :access_key)
  @access_secret Utils.env!(:aliyun, :access_secret)
  @api_host Utils.env!(:aliyun, :api_host)

  @spec call(new_ip :: binary()) :: :ok | {:error, code :: binary(), reason :: binary()}
  def call(new_ip) do
    params = gen_params(new_ip) |> combine_params()

    case HTTPoison.get!(@api_host <> "/?" <> params) do
      %{status_code: 200} ->
        :ok

      %{status_code: 400, body: body} ->
        json = Jason.decode!(body)
        {:error, json["Code"], json["Message"]}
    end
  rescue
    _ -> {:error, :ddns_exception, ""}
  end

  def gen_params(new_ip) do
    params = [
      {"Action", "UpdateDomainRecord"},
      {"Format", "json"},
      {"Version", "2015-01-09"},
      {"AccessKeyId", @access_key},
      {"Timestamp", time_str()},
      {"SignatureVersion", "1.0"},
      {"SignatureMethod", "HMAC-SHA1"},
      {"SignatureNonce", random()},
      {"RecordId", @record_id},
      {"RR", @domain},
      {"Type", "A"},
      {"Value", new_ip}
    ]

    [{"Signature", sign(params)} | params]
  end

  def sign(params) do
    sign_str =
      params
      |> combine_params(&encode/1)
      |> encode()

    str = "#{@action}&%2F&" <> sign_str

    key = @access_secret <> "&"

    :crypto.mac(:hmac, :sha, key, str) |> Base.encode64()
  end

  defp combine_params(params, value_func \\ & &1) do
    params
    |> Enum.sort_by(fn {key, _} -> key end)
    |> Enum.map(fn {key, val} -> "#{key}=#{value_func.(val)}" end)
    |> Enum.join("&")
  end

  def time_str do
    DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601()
  end

  def random, do: Ecto.UUID.generate()
  def encode(str), do: URI.encode(str, &URI.char_unreserved?/1)
end
