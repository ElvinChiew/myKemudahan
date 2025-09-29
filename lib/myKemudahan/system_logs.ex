defmodule MyKemudahan.SystemLogs do
  @moduledoc """
  The SystemLogs context.
  """

  import Ecto.Query, warn: false
  alias MyKemudahan.Repo

  alias MyKemudahan.SystemLogs.SystemLog

  @doc """
  Returns the list of system_logs.

  ## Examples

      iex> list_system_logs()
      [%SystemLog{}, ...]

  """
  def list_system_logs do
    Repo.all(SystemLog)
    |> Repo.preload(:admin)
    |> Enum.sort_by(& &1.performed_at, {:desc, NaiveDateTime})
  end

  @doc """
  Gets a single system_log.

  Raises `Ecto.NoResultsError` if the System log does not exist.

  ## Examples

      iex> get_system_log!(123)
      %SystemLog{}

      iex> get_system_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_system_log!(id), do: Repo.get!(SystemLog, id) |> Repo.preload(:admin)

  @doc """
  Creates a system_log.

  ## Examples

      iex> create_system_log(%{field: value})
      {:ok, %SystemLog{}}

      iex> create_system_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_system_log(attrs \\ %{}) do
    %SystemLog{}
    |> SystemLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Logs an admin action for transparency.

  ## Examples

      iex> log_admin_action(admin_id, "approve_request", "Request", request_id, "Request approved")
      {:ok, %SystemLog{}}

  """
  def log_admin_action(admin_id, action, entity_type, entity_id, details \\ "") do
    create_system_log(%{
      admin_id: admin_id,
      action: action,
      entity_type: entity_type,
      entity_id: entity_id,
      details: details,
      performed_at: NaiveDateTime.utc_now()
    })
  end

  @doc """
  Updates a system_log.

  ## Examples

      iex> update_system_log(system_log, %{field: new_value})
      {:ok, %SystemLog{}}

      iex> update_system_log(system_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_system_log(%SystemLog{} = system_log, attrs) do
    system_log
    |> SystemLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a system_log.

  ## Examples

      iex> delete_system_log(system_log)
      {:ok, %SystemLog{}}

      iex> delete_system_log(system_log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_system_log(%SystemLog{} = system_log) do
    Repo.delete(system_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking system_log changes.

  ## Examples

      iex> change_system_log(system_log)
      %Ecto.Changeset{data: %SystemLog{}}

  """
  def change_system_log(%SystemLog{} = system_log, attrs \\ %{}) do
    SystemLog.changeset(system_log, attrs)
  end
end
