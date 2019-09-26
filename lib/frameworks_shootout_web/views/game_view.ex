defmodule FrameworksShootoutWeb.GameView do
  use FrameworksShootoutWeb, :view

  def format_score(score) do
    score |> Float.round(1)
  end
end
