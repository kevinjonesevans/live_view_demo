defmodule FrameworksShootout.Game do
  alias __MODULE__
  defstruct [:phoenix, :asteroids, :projectiles, :score, :state, :updated]
  @inertia 0.03
  @tick 100_000_000

  def new() do
    %Game{
      state: :ok,
      phoenix: %{x: 50, y: 50, thrust: false, velocity: 0, heading: 0, movement_heading: 0, movement_velocity: 0},
      asteroids: [],
      projectiles: [],
      score: 0.0,
      updated: System.monotonic_time() - @tick
    }
  end

  def update(%{state: :ok} = game) do
    time = System.monotonic_time()
    dt = (time - game.updated) / @tick

    game
    |> move_phoenix
    # |> move_asteroids
    # |> check_for_collisions
    # |> add_asteroid
    # |> Map.put(:score, game.score + 0.1 * dt)
    |> Map.put(:updated, time)
  end

  def update(game), do: game

  def thrust(game) do
    diff_heading = Kernel.abs(Integer.mod(game.phoenix.movement_heading, 180) - Integer.mod(game.phoenix.heading, 180))
    # calculate if the heading is within 90 degrees of the old heading
    # velocity factor is proportional to the heading
    velocity_ratio = 100 - diff_heading / 180
      # if it is, then add the weighted thrust to the velocity
      # if not, subtract the weighted thrust from the velocity
    game = %{game | phoenix: %{game.phoenix | velocity: game.phoenix.velocity + (0.8 * velocity_ratio)}}
    game = %{game | phoenix: %{game.phoenix | thrust: true}}
    # game = %{game | phoenix: %{game.phoenix | movement_velocity: :math.sqrt(:math.pow(game.phoenix.movement_velocity,2) + }}
    game = %{game | phoenix: %{game.phoenix | movement_heading: Integer.mod(Kernel.trunc((game.phoenix.heading + game.phoenix.movement_heading) / 2), 360)}}
    # game = %{game | phoenix: %{game.phoenix | movement_heading: game.phoenix.heading}}
    game
  end

  def move_phoenix_down(game) do
    game
  end

  def move_phoenix_left(game) do
    %{game | phoenix: %{game.phoenix | heading: Integer.mod(game.phoenix.heading - 10, 360)}}
  end

  def move_phoenix_right(game) do
    %{game | phoenix: %{game.phoenix | heading: Integer.mod(game.phoenix.heading + 10, 360)}}
  end

  def phoenix_fire(game) do
    new_projectile = %{
      phoenix: true,
      x: game.phoenix.x,
      y: game.phoenix.y,
      heading: game.phoenix.heading,
      velocity: game.phoenix.velocity
    }
    %{game | projectiles: game.projectiles ++ new_projectile}
  end

  defp move_object(object) do
    # IO.inspect(game)
    object =
      object
      # |> Map.put(:velocity, max(object.velocity - @inertia, 0))
      |> Map.put(:x, Integer.mod(Kernel.trunc(object.x + (:math.cos(object.movement_heading * :math.pi/180) * object.velocity)), 100))
      |> Map.put(:y, Integer.mod(Kernel.trunc(object.y + (:math.sin(object.movement_heading * :math.pi/180) * object.velocity)), 100))

    object
  end

  defp move_phoenix(game) do
    game = %{game | phoenix: move_object(game.phoenix)}
    %{game | phoenix: %{game.phoenix | thrust: false}}
  end

  defp move_asteroids(game) do
    asteroids =
      game.asteroids
      |> Enum.map(fn a -> move_object(a) end)

    %{game | asteroids: asteroids}
  end

  defp add_asteroid(game) do
    if Enum.count(game.asteroids) < 3 do
      new_asteroid = [
        %{
          x: Enum.random(Enum.to_list(0..Integer.mod(game.phoenix.x-12, 100)) ++ Enum.to_list(Integer.mod(game.phoenix.x+12, 100)..100)),
          y: Enum.random(Enum.to_list(0..Integer.mod(game.phoenix.y-12, 100)) ++ Enum.to_list(Integer.mod(game.phoenix.y+12, 100)..100)),
          size: Enum.random(['small']),
          velocity: Enum.random([2.1]),
          movement_heading: Enum.random(0..360),
          creation_time: System.monotonic_time()
        }
      ]
      %{game | asteroids: game.asteroids ++ new_asteroid}
    else
      game
    end
  end

  defp check_for_collisions(game) do
    game
    |> check_asteroid_collisions
  end

  defp check_asteroid_collisions(%{state: :ok} = game) do
    state =
      case Enum.find(game.asteroids, fn asteroid ->
             game.phoenix.x > asteroid.x - 25 && game.phoenix.x < asteroid.x + 25 &&
               (game.phoenix.y > asteroid.y and game.phoenix.y < asteroid.y + asteroid.height)
           end) do
        nil -> :ok
        _ -> :end
      end

    %{game | state: state}
  end

  defp check_asteroid_collisions(game), do: game
end
