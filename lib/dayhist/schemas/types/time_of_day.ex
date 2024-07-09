defmodule Dayhist.TimeOfDay do
  use Ecto.Type

  @valid_times_of_day ~w(morning afternoon evening night)a

  def type, do: :string

  def cast(value) when value in @valid_times_of_day, do: {:ok, value}
  def cast(_), do: :error

  def load(value) when is_binary(value) and value in @valid_times_of_day,
    do: {:ok, String.to_atom(value)}

  def load(_), do: :error

  def dump(value) when is_atom(value) do
    string_value = Atom.to_string(value)

    if string_value in @valid_times_of_day do
      {:ok, string_value}
    else
      :error
    end
  end

  def dump(value) when is_binary(value) and value in @valid_times_of_day, do: {:ok, value}
  def dump(_), do: :error

  def embed_as(_format), do: :self

  def equal?(value1, value2), do: value1 == value2
end
