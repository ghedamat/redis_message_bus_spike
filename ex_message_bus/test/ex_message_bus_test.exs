defmodule ExMessageBusTest do
  use ExUnit.Case
  doctest ExMessageBus

  test "greets the world" do
    assert ExMessageBus.hello() == :world
  end
end
