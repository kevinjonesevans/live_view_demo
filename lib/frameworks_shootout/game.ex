defmodule FrameworksShootout.Game do
  alias __MODULE__
  defstruct [:phoenix, :enemies, :score, :state, :updated]
  @gravity 0
  @tick 100_000_000

  def new() do
    %Game{
      state: :ok,
      phoenix: %{x: 50, y: 250, direction: "left", velocity: 0, heading: 0},
      enemies: [],
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
    # |> Map.put(:updated, time)
  end

  def update(game), do: game

  # def flap(%{state: :ok} = game) do
  #   %{game | phoenix: %{game.phoenix | velocity: 3}}
  # end
  #
  # def flap(game), do: game

  def move_phoenix_up(game) do
    %{game | phoenix: %{game.phoenix | y: game.phoenix.y - 2}}
  end

  def move_phoenix_down(game) do
    %{game | phoenix: %{game.phoenix | y: game.phoenix.y + 2}}
  end

  def move_phoenix_left(game) do
    %{game | phoenix: %{game.phoenix | x: game.phoenix.x - 2}}
  end

  def move_phoenix_right(game) do
    %{game | phoenix: %{game.phoenix | direction: 'right'}}
  end

  defp move_phoenix(game) do
    phoenix =
      game.phoenix
      # TODO: Game Logic for changing direction of Phoenix
      |> Map.put(:wings, "left")
      |> Map.put(:velocity, game.phoenix.velocity - @gravity)
      |> Map.put(:y, min(game.phoenix.y - 1.5 * game.phoenix.velocity, 81))

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
