defmodule FrameworksShootoutWeb.GameLive do
  use Phoenix.LiveView
  alias FrameworksShootout.Game

  def render(assigns) do
    FrameworksShootoutWeb.GameView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    socket = assign(socket, game: Game.new())

    if connected?(socket) do
      {:ok, schedule_tick(socket)}
    else
      {:ok, socket}
    end
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, 50)
    socket
  end

  def handle_info(:tick, socket) do
    game = Game.update(socket.assigns.game)

    case game.state do
      :ok ->
        socket = schedule_tick(socket)
        {:noreply, assign(socket, game: game)}

      :end ->
        {:noreply, assign(socket, game: game)}
    end
  end

  def handle_event("keydown", "ArrowUp", socket) do
    game = Game.thrust(socket.assigns.game)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("keydown", "ArrowDown", socket) do
    game = Game.move_phoenix_down(socket.assigns.game)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("keydown", "ArrowLeft", socket) do
    game = Game.move_phoenix_left(socket.assigns.game)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("keydown", "ArrowRight", socket) do
    game = Game.move_phoenix_right(socket.assigns.game)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("keydown", " ", socket) do
    game = Game.phoenix_fire(socket.assigns.game)
    {:noreply, assign(socket, game: socket.assigns.game)}
  end

  def handle_event("keydown", _key, socket) do
    {:noreply, socket}
  end

  def handle_event("keyup", _key, socket) do
    game = socket.assigns.game
    game = %{game | phoenix: %{game.phoenix | thrust: false}}
    {:noreply, assign(socket, game: game)}
  end
end
