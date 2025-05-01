defmodule ErrlyWeb.DashboardLive.IssuesLive do
  use ErrlyWeb, :live_view
  # Override the default layout defined in ErrlyWeb
  use Phoenix.LiveView, layout: {ErrlyWeb.Layouts, :dashboard}

  alias Errly.Issues

  @impl true
  def mount(_params, _session, socket) do
    # В будущем здесь будет загрузка реальных данных
    issues = [1, 2]
    # issues = Issues.list_issues()

    socket =
      assign(socket,
        issues: issues,
        page_title: "Issues"
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    # Обработка параметров для фильтрации, сортировки, пагинации в будущем
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Issues")

    # |> assign(:issues, Issues.list_issues()) # Загрузка реальных данных
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-4 md:p-8">
      <h1 class="text-2xl font-semibold mb-4">{@page_title}</h1>

      <div class="overflow-x-auto border border-base-300 rounded-md bg-base-100">
        <table class="table w-full">
          <thead>
            <tr class="">
              <th>
                <label>
                  <input type="checkbox" class="checkbox checkbox-sm" />
                </label>
              </th>
              <th>Issue</th>
              <th class="text-right">Events</th>
              <th class="text-right">Users</th>
              <th>Assignee</th>
              <th>Last Seen</th>
            </tr>
          </thead>
          <tbody>
            <%= if Enum.empty?(@issues) do %>
              <tr>
                <td colspan="6" class="text-center py-4">No issues found.</td>
              </tr>
            <% else %>
              <.issue_row :for={issue <- @issues} issue={issue} />
            <% end %>
          </tbody>
          <%!-- <tfoot>
            <tr class="bg-base-200">
              <th></th>
              <th>Issue</th>
              <th class="text-right">Events</th>
              <th class="text-right">Users</th>
              <th>Assignee</th>
              <th>Last Seen</th>
            </tr>
          </tfoot> --%>
        </table>
      </div>

      <div class="mt-4 flex justify-end">
        <div class="btn-group">
          <button class="btn btn-sm bg-base-100">«</button>
          <button class="btn btn-sm bg-base-100">Page 1</button>
          <button class="btn btn-sm bg-base-100">»</button>
        </div>
      </div>
    </div>
    """
  end

  defp issue_row(assigns) do
    ~H"""
    <tr>
      <td>
        <label>
          <input type="checkbox" class="checkbox checkbox-sm" />
        </label>
      </td>
      <td>
        <div class="flex items-center space-x-3">
          <div>
            <div class="font-bold">Placeholder Issue Title</div>
            <div class="text-sm opacity-50">Placeholder Project</div>
          </div>
        </div>
      </td>
      <td class="text-right">
        123
      </td>
      <td class="text-right">
        45
      </td>
      <td>
        <span class="badge badge-ghost badge-sm">Unassigned</span>
      </td>
      <td>
        <span class="text-sm opacity-70">about 2 hours ago</span>
      </td>
    </tr>
    """
  end
end
