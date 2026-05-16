defmodule KiteEdgeWeb.Reports.ODataController do
  @moduledoc "T177: OData v4 feed endpoint for BI tools."
  use KiteEdgeWeb, :controller

  alias KiteEdge.Portfolio.HoldingsQuery

  def index(conn, _params) do
    %{data: holdings} = HoldingsQuery.list()

    # OData v4 JSON format
    json(conn, %{
      "@odata.context" => "$metadata#Holdings",
      "value" => holdings
    })
  end

  def metadata(conn, _params) do
    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, odata_metadata_xml())
  end

  defp odata_metadata_xml do
    """
    <?xml version="1.0" encoding="utf-8"?>
    <edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
      <edmx:DataServices>
        <Schema Namespace="KiteEdge" xmlns="http://docs.oasis-open.org/odata/ns/edm">
          <EntityType Name="Holding">
            <Key><PropertyRef Name="tradingsymbol"/></Key>
            <Property Name="tradingsymbol" Type="Edm.String"/>
            <Property Name="exchange" Type="Edm.String"/>
            <Property Name="quantity" Type="Edm.Int32"/>
            <Property Name="average_price" Type="Edm.Decimal"/>
            <Property Name="last_price" Type="Edm.Decimal"/>
            <Property Name="pnl" Type="Edm.Decimal"/>
            <Property Name="sector" Type="Edm.String"/>
          </EntityType>
        </Schema>
      </edmx:DataServices>
    </edmx:Edmx>
    """
  end
end
