defmodule HajWeb.LiveComponents.Table do
  # From https://gist.github.com/bratsche/30fe2c2f89756edc33b0793f9b9f8c3e
  use Phoenix.Component

  def table(assigns) do
    ~H"""
    <table class="w-full divide-y divide-gray-200">
      <thead>
        <tr class="text-md font-semibold text-left text-left bg-gray-100 uppercase">
          <%= for col <- @col do %>
            <th class="px-4 py-3">
              <%= if col[:label] == nil, do: "", else: col.label %>
            </th>
          <% end %>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= if @rows == [] do %>
          <td class="pl-6 py-4 whitespace-nowrap text-sm font-medium">Här var det tomt.</td>
        <% else %>
          <%= for {row, i} <- Enum.with_index(@rows) do %>
            <tr class={if rem(i, 2) == 0, do: "bg-white hover:bg-gray-100", else: "bg-gray-50 hover:bg-gray-100"}>
              <%= for col <- @col do %>
                <td class="px-4 py-3 border">
                  <%= render_slot(col, row) %>
                </td>
              <% end %>
            </tr>
          <% end %>
        <% end %>
      </tbody>
    </table>
    """
  end

  def striped(assigns) do
    ~H"""
    <table class="min-w-full divide-y divide-gray-200">
      <thead class="bg-gray-50">
        <tr>
          <%= for col <- @col do %>
            <%= if col[:visible] != false do %>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                <%= if col[:label] != nil, do: col.label, else: "" %>
              </th>
            <% end %>
          <% end %>
        </tr>
      </thead>
      <tbody>
        <%= if @rows == [] do %>
          <tr class="bg-white">
            <td class="pl-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">Här var det tomt.</td>
            <%= for col <- Enum.drop(@col, 0) do %>
              <%= if col[:visible] != false do %>
                <td></td>
              <% end %>
            <% end %>
          </tr>
        <% else %>
          <%= for {row, i} <- Enum.with_index(@rows) do %>
            <tr id={if assigns[:row_id_prefix] != nil, do: "#{@row_id_prefix}-#{row.id}"} class={if rem(i, 2) == 0, do: "bg-white", else: "bg-gray-50"}>
              <%= for col <- @col do %>
                <%= if col[:visible] != false do %>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <%= render_slot(col, row) %>
                  </td>
                <% end %>
              <% end %>
            </tr>
          <% end %>
        <% end %>
      </tbody>
    </table>
    """
  end
end
