defmodule Assistant do
  @moduledoc false

  def data_dir do
    Application.get_env(:assistant, :data_dir)
  end
end
