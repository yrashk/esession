defmodule Http.Session.Time do
  def seconds(n), do: n
  def minutes(n), do: seconds(n * 60)
  def hours(n), do: minutes(n * 60)
  def days(n), do: hours(n * 24)
end
