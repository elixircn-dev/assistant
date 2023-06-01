defmodule Assistant.PubSub do
  @moduledoc false

  alias Phoenix.PubSub

  defmacro __using__(_) do
    quote do
      alias Phoenix.PubSub

      import unquote(__MODULE__)
    end
  end

  def subscribe(topic, opts \\ []) do
    PubSub.subscribe(__MODULE__, topic, opts)
  end

  def broadcast(topic, message) do
    PubSub.broadcast(__MODULE__, topic, message)
  end
end
