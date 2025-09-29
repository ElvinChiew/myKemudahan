defmodule MyKemudahanWeb.AdminSidebar do
  use Phoenix.Component

  def sidebar(assigns) do
    ~H"""
        <div>
          <div id="mobile-sidebar-overlay" class="fixed inset-0 bg-gray-900 bg-opacity-50 z-50 hidden"
              onclick="closeMobileSidebar()"></div>
            <button onclick="toggleMobileSidebar()" class="fixed top-4 left-4 z-50 p-2 bg-slate-700 text-white rounded-md lg:hidden">
              <i class="fa fa-bars text-xl"></i>
            </button>
          </div>

        <aside id="sidebar"
              class="fixed lg:sticky top-0 left-0 h-screen bg-slate-700 text-white shadow-md overflow-y-auto z-50 transition-all duration-300 w-64 transform -translate-x-full lg:translate-x-0">
          <div class="p-4 flex items-center justify-end lg:hidden">
            <button onclick="closeMobileSidebar()" class="text-white focus:outline-none">
              <i class="fa fa-times text-xl"></i>
            </button>
          </div>

          <nav class="space-y-6 px-2 py-4" id="sidebar-menu">
            <!-- Section: Overview -->
            <div>
              <h2 class="px-3 mb-2 text-sm font-semibold uppercase tracking-wide text-slate-400">Requests</h2>
              <a href="/request_list"
                class="flex items-center space-x-3 px-3 py-2 rounded-md hover:bg-slate-600"
                aria-current="page"
                onclick="closeMobileSidebar()">
                <i class="fa fa-bar-chart w-5 text-center" aria-hidden="true"></i>
                <span>Requests Management</span>
              </a>

              <a href="/return-requests"
              class="flex items-center space-x-3 px-3 py-2 rounded-md hover:bg-slate-600"
              aria-current="page"
              onclick="closeMobileSidebar()">
              <i class="fa fa-truck" aria-hidden="true"></i>
              <span>Asset Return</span>
            </a>
            </div>

            <!-- Section: Asset Management -->
            <div>
              <h2 class="px-3 mb-2 text-sm font-semibold uppercase tracking-wide text-slate-400 sidebar-heading cursor-pointer select-none" onclick="toggleCollapse('asset-group')">
                <span class="sidebar-label">Asset Management</span>
                <i id="asset-group-arrow" class="fa fa-chevron-down ml-auto transition-transform duration-300"></i>
              </h2>
              <div id="asset-group" class="space-y-1 px-3">
                <a href="/assets" class="flex items-center space-x-3 py-2 rounded-md hover:bg-slate-600 transition" title="Asset Overview">
                  <i class="fa fa-home" aria-hidden="true"></i>
                  <span class="sidebar-label">Asset</span>
                </a>
                <a href="/categories" class="flex items-center space-x-3 py-2 rounded-md hover:bg-slate-600 transition" title="Asset Category">
                  <i class="fa fa-tags" aria-hidden="true"></i>
                  <span class="sidebar-label">Asset Category</span>
                </a>
                <a href="/asset_tags" class="flex items-center space-x-3 py-2 rounded-md hover:bg-slate-600 transition" title="Asset Units">
                  <i class="fa fa-cubes" aria-hidden="true"></i>
                  <span class="sidebar-label">Asset Units Lists</span>
                </a>
              </div>
            </div>

            <!-- Section: Report -->
            <div>
              <h2 class="px-3 mb-2 text-sm font-semibold uppercase tracking-wide text-slate-400 sidebar-heading">System Users</h2>
              <a href="/reports" class="flex items-center space-x-3 px-3 py-2 rounded-md hover:bg-slate-600 transition" title="Manage System Users">
                <i class="fa fa-flag" aria-hidden="true"></i>
                <span class="sidebar-label">Incident Report</span>
              </a>
            </div>

            <!-- Section: System Logs -->
            <div>
              <h2 class="px-3 mb-2 text-sm font-semibold uppercase tracking-wide text-slate-400 sidebar-heading">System</h2>
              <a href="/system-logs" class="flex items-center space-x-3 px-3 py-2 rounded-md hover:bg-slate-600 transition" title="View System Logs">
                <i class="fa fa-history" aria-hidden="true"></i>
                <span class="sidebar-label">System Logs</span>
              </a>
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
              function toggleMobileSidebar() {
                const sidebar = document.getElementById('sidebar');
                const overlay = document.getElementById('mobile-sidebar-overlay');
                sidebar.classList.toggle('-translate-x-full');
                overlay.classList.toggle('hidden');
                document.body.classList.toggle('overflow-hidden');
              }

              function closeMobileSidebar() {
                const sidebar = document.getElementById('sidebar');
                const overlay = document.getElementById('mobile-sidebar-overlay');
                sidebar.classList.add('-translate-x-full');
                overlay.classList.add('hidden');
                document.body.classList.remove('overflow-hidden');
              }

              // Close sidebar when a link is clicked (on mobile)
              document.addEventListener('DOMContentLoaded', () => {
                const links = document.querySelectorAll('#sidebar-menu a');
                links.forEach(link => {
                  link.addEventListener('click', () => {
                    if (window.innerWidth < 1024) { // lg breakpoint
                      closeMobileSidebar();
                    }
                  });
                });
              });
            </script>
        """
  end
end
