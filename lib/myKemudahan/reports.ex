defmodule MyKemudahan.Reports do
  alias MyKemudahan.Repo
  alias MyKemudahan.Reports.Report

  # Make sure this is def (not defp)
  def create_report(attrs \\ %{}) do
    %Report{}
    |> Report.changeset(attrs)
    |> Repo.insert()
  end

  def list_report() do
    Report
    |> Repo.all()
    |> Repo.preload([:reporter , :asset, :request])
  end

  def get_report!(id) do
    Report
    |> Repo.get!(id)
    |> Repo.preload([:reporter, :asset, :request])
  end

  def update_report(%Report{} = report, attrs) do
    report
    |> Report.changeset(attrs)
    |> Repo.update()
  end

end
