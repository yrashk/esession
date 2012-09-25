defmodule Esession.Mixfile do
  use Mix.Project

  def project do
    [ app: :esession,
      version: "0.0.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:crypto]]
  end

  defp deps, do: deps(Mix.env)

  defp deps(:test) do
    [
     { :genx, %r(.*), github: "yrashk/genx"},
     { :ossp_uuid, %r(.*), github: "yrashk/erlang-ossp-uuid"},
     { :ranch, %r(.*), github: "extend/ranch"},
     { :cowboy, %r(.*), github: "extend/cowboy"},
    ] ++ deps(:dev)
  end
  defp deps(_), do: []
  
end
