defmodule Dracula.Extractor do
  @moduledoc """
  Extracts metadata from Markdown files.
  """

  def extract_metadata(markdown) do
    {blocks, _context} = markdown |> Earmark.parse

    fetch_title([], blocks)
  end

  defp fetch_title(metadata, []), do: metadata
  defp fetch_title(metadata, [%Earmark.Block.Heading{content: title, level: 1}|_]) do
    Keyword.put(metadata, :title, title)
  end
  defp fetch_title(metadata, [_|tail]), do: fetch_title(metadata, tail)
end
