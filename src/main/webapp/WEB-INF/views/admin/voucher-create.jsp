
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Create Voucher - Light Ticket</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/admin.css?v=3">
    </head>

    <body>

        <%
            String contextPath = request.getContextPath();
            String error = (String) request.getAttribute("error");
        %>

        <div class="layout">

            <!-- Sidebar -->
            <aside class="sidebar">

                <div class="brand">
                    🎟 Light Ticket
                </div>

                <nav class="menu">

                    <a href="<%= contextPath%>/admin">
                        <i class="fa-solid fa-chart-line"></i>
                        Dashboard
                    </a>

                    <div class="menu-group">
                        <a href="<%= contextPath%>/admin/users">
                            <i class="fa-solid fa-users"></i>
                            Users
                        </a>
                    </div>

                    <a href="#">
                        <i class="fa-solid fa-calendar-days"></i>
                        Events
                    </a>

                    <!-- Categories -->
                    <div class="menu-group">
                        <a href="<%= contextPath%>/admin/categories">
                            <span>
                                <i class="fa-solid fa-folder"></i>
                                Categories
                            </span>
                        </a>
                    </div>

                    <!-- Venues -->
                    <a href="<%= contextPath%>/admin/venues">
                        <i class="fa-solid fa-location-dot"></i>
                        Venues
                    </a>

                    <!-- Vouchers -->
                    <div class="menu-group">
                        <a href="<%= contextPath%>/admin/vouchers?action=create"
                           class="menu-parent open">
                            <span>
                                <i class="fa-solid fa-ticket"></i>
                                Vouchers
                            </span>
                            <span class="arrow">▼</span>
                        </a>

                        <div class="submenu">
                            <a href="<%= contextPath%>/admin/vouchers">
                                Voucher List
                            </a>

                            <a href="<%= contextPath%>/admin/vouchers?action=create"
                               class="active">
                                Create Voucher
                            </a>
                        </div>
                    </div>

                    <!-- Reviews -->
                    <a href="#">
                        <i class="fa-solid fa-star"></i>
                        Reviews
                    </a>

                    <!-- My Profile -->
                    <a href="<%= contextPath%>/admin/profile">
                        <i class="fa-solid fa-user"></i>
                        My Profile
                    </a>

                </nav>

            </aside>

            <!-- Main -->
            <main class="main">

                <!-- Topbar -->
                <header class="topbar">

                    <input class="search"
                           type="text"
                           placeholder="Search...">

                    <a class="admin"
                       href="<%= contextPath%>/admin/profile">

                        <img class="admin-avatar"
                             src="<%= contextPath%>/assets/icons/user_icon.png"
                             alt="Admin Avatar">

                        <span>Admin</span>
                    </a>

                </header>

                <!-- Content -->
                <section class="content">

                    <!-- Page Heading -->
                    <div class="page-heading">
                        <div>
                            <h1>Create Voucher</h1>

                            <p>
                                Thêm mã giảm giá mới vào hệ thống
                                Light Ticket
                            </p>
                        </div>
                    </div>

                    <!-- Form -->
                    <div class="category-form-panel">

                        <% if (error != null) {%>
                        <div class="error-message">
                            <%= error%>
                        </div>
                        <% }%>

                        <form method="post"
                              action="<%= contextPath%>/admin/vouchers">

                            <input type="hidden"
                                   name="action"
                                   value="create">

                            <!-- Voucher Code -->
                            <div class="category-form-group">
                                <label for="voucherCode">
                                    Voucher Code
                                </label>

                                <input type="text"
                                       id="voucherCode"
                                       name="voucherCode"
                                       maxlength="50"
                                       placeholder="Example: EARLYBIRD10"
                                       pattern="[A-Za-z0-9_-]+"
                                       title="Only letters, numbers, underscores and hyphens"
                                       required>
                            </div>

                            <!-- Voucher Name -->
                            <div class="category-form-group">
                                <label for="voucherName">
                                    Voucher Name
                                </label>

                                <input type="text"
                                       id="voucherName"
                                       name="voucherName"
                                       maxlength="150"
                                       placeholder="Enter voucher name"
                                       required>
                            </div>

                            <!-- Discount Type -->
                            <div class="category-form-group">
                                <label for="discountType">
                                    Discount Type
                                </label>

                                <select id="discountType"
                                        name="discountType"
                                        required>
                                    <option value="Percentage">
                                        Percentage (%)
                                    </option>

                                    <option value="Fixed">
                                        Fixed Amount (VND)
                                    </option>
                                </select>
                            </div>

                            <!-- Discount Value -->
                            <div class="category-form-group">
                                <label for="discountValue">
                                    Discount Value
                                </label>

                                <input type="number"
                                       id="discountValue"
                                       name="discountValue"
                                       min="0.01"
                                       step="0.01"
                                       placeholder="Enter discount value"
                                       required>
                            </div>

                            <!-- Minimum Order Amount -->
                            <div class="category-form-group">
                                <label for="minOrderAmount">
                                    Minimum Order Amount (VND)
                                </label>

                                <input type="number"
                                       id="minOrderAmount"
                                       name="minOrderAmount"
                                       min="0"
                                       step="0.01"
                                       value="0"
                                       required>
                            </div>

                            <!-- Maximum Discount Amount -->
                            <div class="category-form-group">
                                <label for="maxDiscountAmount">
                                    Maximum Discount Amount (VND)
                                </label>

                                <input type="number"
                                       id="maxDiscountAmount"
                                       name="maxDiscountAmount"
                                       min="0"
                                       step="0.01"
                                       placeholder="Leave empty if unlimited">
                            </div>

                            <!-- Start Time -->
                            <div class="category-form-group">
                                <label for="startTime">
                                    Start Time
                                </label>

                                <input type="datetime-local"
                                       id="startTime"
                                       name="startTime"
                                       required>
                            </div>

                            <!-- End Time -->
                            <div class="category-form-group">
                                <label for="endTime">
                                    End Time
                                </label>

                                <input type="datetime-local"
                                       id="endTime"
                                       name="endTime"
                                       required>
                            </div>

                            <!-- Usage Limit -->
                            <div class="category-form-group">
                                <label for="usageLimit">
                                    Usage Limit
                                </label>

                                <input type="number"
                                       id="usageLimit"
                                       name="usageLimit"
                                       min="1"
                                       step="1"
                                       placeholder="Enter maximum usage"
                                       required>
                            </div>

                            <!-- Status -->
                            <div class="category-form-group">
                                <label for="status">
                                    Status
                                </label>

                                <select id="status"
                                        name="status"
                                        required>
                                    <option value="ACTIVE">
                                        ACTIVE
                                    </option>

                                    <option value="INACTIVE">
                                        INACTIVE
                                    </option>
                                </select>
                            </div>

                            <!-- Buttons -->
                            <div class="category-form-actions">

                                <button type="submit"
                                        class="create-button">
                                    Create Voucher
                                </button>

                                <a href="<%= contextPath%>/admin/vouchers"
                                   class="category-cancel-button">
                                    Cancel
                                </a>

                            </div>

                        </form>

                    </div>

                </section>

            </main>

        </div>

    </body>
</html>
