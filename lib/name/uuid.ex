defmodule Http.Session.Name.UUID do
  alias :ossp_uuid, as: G
  def generate do
     G.make(:v4, :text)
  end
  def generate_raw do
     G.make(:v4, :binary)
  end

end