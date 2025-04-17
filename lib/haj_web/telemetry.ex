defmodule HajWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  require Logger

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    port = Application.get_env(:haj, :metrics_port, 9001)

    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000},
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
      {Peep, name: Haj.Peep, metrics: metrics()},
      {Plug.Cowboy,
       scheme: :http, plug: HajWeb.Telemetry.Plug, options: [ip: {0, 0, 0, 0}, port: port]}
    ]

    Logger.info("Starting telemetry on 0.0.0.0:#{port}, #{is_integer(port)}")

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      distribution("phoenix.endpoint.start.system_time",
        unit: {:native, :millisecond}
      ),
      distribution("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      distribution("phoenix.router_dispatch.start.system_time",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      distribution("phoenix.router_dispatch.exception.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      distribution("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      distribution("phoenix.socket_connected.duration",
        unit: {:native, :millisecond}
      ),
      distribution("phoenix.channel_join.duration",
        unit: {:native, :millisecond}
      ),
      distribution("phoenix.channel_handled_in.duration",
        tags: [:event],
        unit: {:native, :millisecond}
      ),

      # Database Metrics
      distribution("haj.repo.query.total_time",
        unit: {:native, :millisecond},
        description: "The sum of the other measurements"
      ),
      distribution("haj.repo.query.decode_time",
        unit: {:native, :millisecond},
        description: "The time spent decoding the data received from the database"
      ),
      distribution("haj.repo.query.query_time",
        unit: {:native, :millisecond},
        description: "The time spent executing the query"
      ),
      distribution("haj.repo.query.queue_time",
        unit: {:native, :millisecond},
        description: "The time spent waiting for a database connection"
      ),
      distribution("haj.repo.query.idle_time",
        unit: {:native, :millisecond},
        description:
          "The time the connection spent waiting before being checked out for the query"
      ),

      # VM Metrics
      last_value("vm.memory.total", unit: {:byte, :kilobyte}),
      last_value("vm.total_run_queue_lengths.total"),
      last_value("vm.total_run_queue_lengths.cpu"),
      last_value("vm.total_run_queue_lengths.io")
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {HajWeb, :count_users, []}
    ]
  end
end
