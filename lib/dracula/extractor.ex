defmodule Dracula.Extractor do
  @moduledoc """
  Extracts metadata from Markdown files.
  """

  def extract_metadata(markdown) do
    {blocks, _context} = markdown |> Earmark.parse

    [title: fetch_title(blocks)]
  end

  defp fetch_title([]), do: nil
  defp fetch_title([%Earmark.Block.Heading{content: title, level: 1}|_]), do: title
  defp fetch_title([_|tail]), do: fetch_title(tail)
end
