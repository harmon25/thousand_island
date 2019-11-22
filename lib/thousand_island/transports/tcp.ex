defmodule ThousandIsland.Transports.TCP do
  alias ThousandIsland.Transport

  @behaviour Transport

  @impl Transport
  def listen(opts) do
    port = Keyword.get(opts, :port, 4000)

    default_options = [
      backlog: 1024,
      nodelay: true,
      linger: {true, 30},
      send_timeout: 30000,
      send_timeout_close: true,
      reuseaddr: true
    ]

    user_options = Keyword.get(opts, :transport_options, [])
    hardcoded_options = [mode: :binary, active: false]

    resolved_options =
      default_options |> Keyword.merge(user_options) |> Keyword.merge(hardcoded_options)

    :gen_tcp.listen(port, resolved_options)
  end

  @impl Transport
  defdelegate accept(listener_socket), to: :gen_tcp

  @impl Transport
  defdelegate recv(socket, length, timeout), to: :gen_tcp

  @impl Transport
  defdelegate send(socket, data), to: :gen_tcp

  @impl Transport
  defdelegate shutdown(socket, way), to: :gen_tcp

  @impl Transport
  defdelegate close(socket), to: :gen_tcp

  @impl Transport
  def local_info(socket) do
    {:ok, {ip_tuple, port}} = :inet.sockname(socket)
    ip = ip_tuple |> :inet.ntoa() |> to_string()
    %{address: ip, port: port, ssl_cert: nil}
  end

  @impl Transport
  def peer_info(socket) do
    {:ok, {ip_tuple, port}} = :inet.peername(socket)
    ip = ip_tuple |> :inet.ntoa() |> to_string()
    %{address: ip, port: port, ssl_cert: nil}
  end
end
