defmodule FrameworksShootout.Game do
  alias __MODULE__
  defstruct [:phoenix, :enemies, :projectiles, :score, :state, :updated]
  @inertia 0.05
  @tick 100_000_000

  def new() do
    %Game{
      state: :ok,
      phoenix: %{x: 50, y: 50, thrust: false, velocity: 0, heading: 0},
      enemies: [],
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
    |> move_enemies
    # |> check_for_collisions
    # |> add_enemies
    # |> Map.put(:score, game.score + 0.1 * dt)
    |> Map.put(:updated, time)
  end

  def update(game), do: game

  def thrust(game) do
    # %{game | phoenix: %{game.phoenix | y: game.phoenix.y - 2}}
    game = %{game | phoenix: %{game.phoenix | velocity: game.phoenix.velocity + 0.8}}
    game = %{game | phoenix: %{game.phoenix | thrust: false}}
    game
  end

  def move_phoenix_down(game) do
    # %{game | phoenix: %{game.phoenix | y: game.phoenix.y + 2}}
    game
  end

  def move_phoenix_left(game) do
    # %{game | phoenix: %{game.phoenix | x: game.phoenix.x - 2}}
    %{game | phoenix: %{game.phoenix | heading: Integer.mod(game.phoenix.heading - 10, 360)}}
  end

  def move_phoenix_right(game) do
    # %{game | phoenix: %{game.phoenix | x: game.phoenix.x + 2}}
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

  defp move_phoenix(game) do
    IO.inspect(game)
    # IO.puts(":math.cos(game.phoenix.heading):#{:math.cos(game.phoenix.heading)}")
    # IO.puts(":math.sin(game.phoenix.heading):#{:math.sin(game.phoenix.heading)}")
    # IO.puts("Combined cos:#{(:math.cos(game.phoenix.heading) * game.phoenix.velocity)}")
    # IO.puts("Combined sin:#{(:math.sin(game.phoenix.heading) * game.phoenix.velocity)}")
    # case game.phoenix.heading do
    #   0 < game.phoenix.heading and game.phoenix.heading <= 90 ->
    #     changeX = game.phoenix.x + (:math.cos(game.phoenix.heading) * game.phoenix.velocity)
    #     changeY = game.phoenix.y + (:math.sin(game.phoenix.heading) * game.phoenix.velocity)
    #   90 < game.phoenix.heading and game.phoenix.heading <= 180 ->
    #     changeX = game.phoenix.x + (:math.cos(game.phoenix.heading) * game.phoenix.velocity)
    #     changeY =
    #   {,
    #     game.phoenix.y + (:math.sin(180 - game.phoenix.heading) * game.phoenix.velocity)}
    #     when
    #   {game.phoenix.x + (:math.cos(game.phoenix.heading) * game.phoenix.velocity),
    #     game.phoenix.y + (:math.sin(game.phoenix.heading) * game.phoenix.velocity)}
    #     when 180 < game.phoenix.heading and game.phoenix.heading <= 270
    #   {game.phoenix.x + (:math.cos(game.phoenix.heading) * game.phoenix.velocity),
    #     game.phoenix.y + (:math.sin(game.phoenix.heading) * game.phoenix.velocity)}
    #     when 270 < game.phoenix.heading and game.phoenix.heading <= 360
    # end
    phoenix =
      game.phoenix
      # |> Map.put(:wings, "left")
      |> Map.put(:velocity, max(game.phoenix.velocity - @inertia, 0))
      |> Map.put(:x, Integer.mod(Kernel.trunc(game.phoenix.x + (:math.cos(game.phoenix.heading * :math.pi/180) * game.phoenix.velocity)), 100))
      |> Map.put(:y, Integer.mod(Kernel.trunc(game.phoenix.y + (:math.sin(game.phoenix.heading * :math.pi/180) * game.phoenix.velocity)), 100))

    %{game | phoenix: phoenix}
  end

  defp move_enemies(game) do
    enemies =
      game.enemies
      |> Enum.map(fn p -> move_enemy(p) end)
      |> Enum.filter(fn p -> p.x > -10 end)

    %{game | enemies: enemies}
  end

  defp add_enemies(game) do
    case Enum.find(game.enemies, fn p -> p.x > 50 end) do
      nil ->
        enemies = [
          %{x: 100, y: Enum.random(-30..0), height: 45, dir: :down},
          %{x: 100, y: Enum.random(40..80), height: 45, dir: :up}
        ]

        %{game | enemies: game.enemies ++ enemies}

      _ ->
        game
    end
  end

  defp move_enemy(enemy) do
    %{enemy | x: enemy.x - 2}
  end

  defp check_for_collisions(game) do
    game
    |> check_enemy_collisions
  end

  defp check_enemy_collisions(%{state: :ok} = game) do
    state =
      case Enum.find(game.enemies, fn p ->
             game.phoenix.x > p.x - 2.5 && game.phoenix.x < p.x + 2.5 &&
               (game.phoenix.y > p.y and game.phoenix.y < p.y + p.height)
           end) do
        nil -> :ok
        _ -> :end
      end

    %{game | state: state}
  end

  defp check_enemy_collisions(game), do: game
end
