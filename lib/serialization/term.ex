defmodule Http.Session.Serialization.Term do
  def encode(dict), do: term_to_binary(dict)
  def decode(binary), do: binary_to_term(binary)
end