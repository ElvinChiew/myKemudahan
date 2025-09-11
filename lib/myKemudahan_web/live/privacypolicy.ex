defmodule MyKemudahanWeb.Privacypolicy do
  use MyKemudahanWeb, :live_view
  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
      <div class="bg-gray-50 text-gray-800 font-sans leading-relaxed">

        <div class="max-w-4xl mx-auto px-6 py-12">
          <h1 class="text-4xl font-bold mb-4 text-blue-800">Privacy Policy</h1>
          <p class="text-sm text-gray-500 mb-8">Effective Date: <span class="font-semibold">1 August 2025</span></p>

          <p class="mb-6">
            Welcome to <strong>MyKemudahan</strong>, an asset and facility booking and management system. Your privacy is important to us.
            This Privacy Policy explains how we collect, use, disclose, and protect your personal data in accordance with the
            <strong>Personal Data Protection Act 2010 (PDPA) of Malaysia</strong>.
          </p>

          <!-- Section 1 -->
          <h2 class="text-2xl font-semibold text-blue-700 mb-2">1. Definition of Personal Data</h2>
          <p class="mb-6">
            "Personal Data" refers to any information that relates directly or indirectly to an individual, who is identified or identifiable from that information.
            Examples include:
          </p>
          <ul class="list-disc list-inside mb-6 space-y-1">
            <li>Name</li>
            <li>Identification number (e.g., NRIC/passport)</li>
            <li>Email address and phone number</li>
            <li>Job title and organization</li>
            <li>Booking records and usage activity</li>
            <li>IP address and browser/device information</li>
          </ul>

          <!-- Section 2 -->
          <h2 class="text-2xl font-semibold text-blue-700 mb-2">2. Collection of Personal Data</h2>
          <p class="mb-6">
            We collect your personal data through registration, booking activities, communications, feedback submissions, and cookies or other tracking tools. By using MyKemudahan, you consent to the collection and processing of your personal data.
          </p>

          <!-- Section 3 -->
          <h2 class="text-2xl font-semibold text-blue-700 mb-2">3. Purpose of Collecting Personal Data</h2>
          <p class="mb-6">We use your data for the following purposes:</p>
          <ul class="list-disc list-inside mb-6 space-y-1">
            <li>To create and manage user accounts</li>
            <li>To handle bookings and manage asset/facility usage</li>
            <li>To provide updates, alerts, or support</li>
            <li>To improve system performance and services</li>
            <li>To comply with legal or regulatory requirements</li>
          </ul>

          <!-- Section 4 -->
          <h2 class="text-2xl font-semibold text-blue-700 mb-2">4. Disclosure of Personal Data</h2>
          <p class="mb-6">
            We do <strong>not</strong> sell your personal data. We may disclose it:
          </p>
          <ul class="list-disc list-inside mb-6 space-y-1">
            <li>To internal administrators or your organization</li>
            <li>To third-party vendors providing system support (under NDA)</li>
            <li>If legally required by authorities or court orders</li>
          </ul>

          <!-- Section 5 -->
          <h2 class="text-2xl font-semibold text-blue-700 mb-2">5. Security of Your Personal Data</h2>
          <p class="mb-6">
            We use industry-standard security measures such as encrypted data transmission, secure access controls, and routine system monitoring.
            However, no method of online transmission is completely secure.
          </p>

          <!-- Section 6 -->
          <h2 class="text-2xl font-semibold text-blue-700 mb-2">6. Retention of Personal Data</h2>
          <p class="mb-6">
            We retain personal data only for as long as necessary to fulfill the purposes outlined here or to comply with legal obligations.
            When no longer needed, your data will be safely deleted or anonymized.
          </p>

          <!-- Section 7 -->
          <h2 class="text-2xl font-semibold text-blue-700 mb-2">7. Access, Correction & Consent Withdrawal</h2>
          <p class="mb-6">
            Under PDPA, you have the right to:
          </p>
          <ul class="list-disc list-inside mb-6 space-y-1">
            <li>Access your personal data</li>
            <li>Correct inaccurate or outdated information</li>
            <li>Withdraw consent (subject to conditions)</li>
          </ul>
          <p class="mb-6">
            To exercise your rights, please contact us:
          </p>
          <div class="bg-gray-100 border border-gray-300 p-4 rounded mb-6">
            <p><strong>Email:</strong> support@mykemudahan.com</p>
            <p><strong>Phone:</strong> 088 - 788 9638</p>
            <p><strong>Address:</strong> Lorong 123, Jalan Kg Baru, Putatan, 87006, Sabah, Malaysia</p>
          </div>

          <!-- Section 8 -->
          <h2 class="text-2xl font-semibold text-blue-700 mb-2">8. Your Obligations</h2>
          <p class="mb-6">
            You are responsible for ensuring that any data you provide is accurate and current. If you submit third-party personal data, you must have their consent.
          </p>

          <!-- Section 9 -->
          <h2 class="text-2xl font-semibold text-blue-700 mb-2">9. Use of Cookies</h2>
          <p class="mb-6">
            We may use cookies to improve user experience, remember preferences, and track usage. You may disable cookies in your browser settings,
            but some features may not work correctly.
          </p>

          <!-- Section 10 -->
          <h2 class="text-2xl font-semibold text-blue-700 mb-2">10. Changes to This Policy</h2>
          <p class="mb-6">
            This Privacy Policy may be updated occasionally. All changes will be published on this page with the updated effective date.
            Continued use of our platform indicates your acceptance of the changes.
          </p>

          <div class="mt-10 p-4 bg-blue-50 border border-blue-300 rounded text-blue-800 text-sm">
            ✅ <strong>By using MyKemudahan, you agree to this Privacy Policy and consent to the collection and processing of your personal data in accordance with the PDPA.</strong>
          </div>
        </div>

      </div>
    """
  end
end
