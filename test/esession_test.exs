Code.require_file "../test_helper.exs", __FILE__

defmodule Http.Session.Test.Storage.Basic do
  use ExUnit.Case

  test "secure cookie storage" do 
    test_storage(Http.Session.Storage.Secure.new key: "26skV8PjTfd9xpaVtzXCmMEaAkefXgUu")
  end

  test "ETS storage" do 
    test_storage(Http.Session.Storage.ETS.new)
  end

  defp test_storage(storage) do
    # No session identifier
    session = Http.Session.Storage.get storage, ""
    session = session.put :value, 1
    assert session.get(:value) == 1
    dump = Http.Session.Storage.dump storage, session
    session = Http.Session.Storage.get storage, dump
    assert session.get(:value) == 1
  end
end
