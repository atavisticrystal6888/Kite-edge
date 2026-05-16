defmodule KiteEdge.Portfolio.SectorClassification do
  @moduledoc """
  Enriches instrument rows with sector metadata.

  Sector data is sourced from the instrument_masters.sector column which is
  populated by an offline enrichment job. When the column is null the
  classifier returns "Unclassified" so downstream charts never render a
  blank slice.
  """

  @spec classify(%{optional(:sector) => String.t() | nil}) :: String.t()
  def classify(%{sector: nil}), do: "Unclassified"
  def classify(%{sector: ""}), do: "Unclassified"
  def classify(%{sector: sector}), do: sector
  def classify(_), do: "Unclassified"
end
