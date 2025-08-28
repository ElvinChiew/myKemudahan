defmodule MyKemudahanWeb.AdminSidebar do
  use Phoenix.Component

  def sidebar(assigns) do
    ~H"""
    <aside id="sidebar"
          class="bg-slate-700 text-white shadow-md sticky left-0 overflow-y-auto z-60 transition-all duration-300 w-64 h-auto"
          data-collapsed="false">
      <div class="p-4 flex items-center justify-between">
        <span class="sidebar-label text-lg font-bold" id="sidebar-title">My App</span>
        <!-- Hamburger Button -->
        <button onclick="toggleSidebar()" class="text-white focus:outline-none block">
          <i class="fa fa-bars text-xl"></i>
        </button>
      </div>

      <nav class="space-y-6 px-2" id="sidebar-menu">
        <!-- Section: Overview -->
        <div>
          <h2 class="px-3 mb-2 text-sm font-semibold uppercase tracking-wide text-slate-400 sidebar-heading">Overview</h2>
          <a href="/request_list"
            class="flex items-center space-x-3 px-3 py-2 rounded-md hover:bg-slate-600 transition bg-slate-800"
            aria-current="page"
            title="Dashboard Overview">
            <i class="fa fa-bar-chart" aria-hidden="true"></i>
            <span class="sidebar-label">Overview</span>
          </a>
        </div>

        <!-- Section: Asset Management -->
        <div>
          <h2 class="px-3 mb-2 text-sm font-semibold uppercase tracking-wide text-slate-400 sidebar-heading cursor-pointer select-none" onclick="toggleCollapse('asset-group')">
            <span class="sidebar-label">Asset Management</span>
            <i id="asset-group-arrow" class="fa fa-chevron-down ml-auto transition-transform duration-300"></i>
          </h2>
          <div id="asset-group" class="space-y-1 px-3">
            <a href="#asset" class="flex items-center space-x-3 py-2 rounded-md hover:bg-slate-600 transition" title="Asset Overview">
              <i class="fa fa-home" aria-hidden="true"></i>
              <span class="sidebar-label">Asset</span>
            </a>
            <a href="/categories" class="flex items-center space-x-3 py-2 rounded-md hover:bg-slate-600 transition" title="Asset Category">
              <i class="fa fa-tags" aria-hidden="true"></i>
              <span class="sidebar-label">Asset Category</span>
            </a>
            <a href="/assets" class="flex items-center space-x-3 py-2 rounded-md hover:bg-slate-600 transition" title="Asset Lists">
              <i class="fa fa-list" aria-hidden="true"></i>
              <span class="sidebar-label">Asset Lists</span>
            </a>
            <a href="/asset_tags" class="flex items-center space-x-3 py-2 rounded-md hover:bg-slate-600 transition" title="Asset Units">
              <i class="fa fa-cubes" aria-hidden="true"></i>
              <span class="sidebar-label">Asset Units Lists</span>
            </a>
          </div>
        </div>

        <!-- Section: Users -->
        <div>
          <h2 class="px-3 mb-2 text-sm font-semibold uppercase tracking-wide text-slate-400 sidebar-heading">System Users</h2>
          <a href="/users" class="flex items-center space-x-3 px-3 py-2 rounded-md hover:bg-slate-600 transition" title="Manage System Users">
            <i class="fa fa-user" aria-hidden="true"></i>
            <span class="sidebar-label">System User</span>
          </a>
        </div>
      </nav>
    </aside>

    <script>
        function toggleSidebar() {
          const sidebar = document.getElementById('sidebar');
          const collapsed = sidebar.getAttribute('data-collapsed') === 'true';

          // Toggle width
          sidebar.classList.toggle('w-64', !collapsed);
          sidebar.classList.toggle('w-20', collapsed);

          // Toggle visibility of labels and headings
          document.querySelectorAll('.sidebar-label, .sidebar-heading').forEach(el => {
            el.classList.toggle('hidden', collapsed);
          });

          sidebar.setAttribute('data-collapsed', !collapsed);
        }

        function toggleCollapse(id) {
          const group = document.getElementById(id);
          const arrow = document.getElementById(id + '-arrow');
          if (group.style.display === 'none' || !group.style.display) {
            group.style.display = 'block';
            arrow.classList.remove('rotate-180');
          } else {
            group.style.display = 'none';
            arrow.classList.add('rotate-180');
          }
        }

        // Initialize collapsed groups on page load
        document.addEventListener('DOMContentLoaded', () => {
          const currentPath = window.location.pathname;
          const links = document.querySelectorAll('.sidebar a');

          links.forEach(link => {
            if (link.getAttribute('href') === currentPath) {
              link.classList.add('bg-slate-700', 'text-white'); // Add highlight styles
            }

          toggleCollapse('asset-group');
        });
    </script>

    """
  end
end
