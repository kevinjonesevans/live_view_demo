defmodule FrameworksShootoutWeb.PageController do
  use FrameworksShootoutWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
