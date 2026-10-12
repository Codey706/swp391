<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>

<html>
    <head>
        <meta charset="UTF-8">
        <title>Create Category - Light Ticket</title>

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

                    <!-- Dashboard -->
                    <a href="<%= contextPath%>/admin">
                        <i class="fa-solid fa-chart-line"></i>
                        Dashboard
                    </a>

                    <!-- Users -->
                    <div class="menu-group">
                        <a href="<%= contextPath%>/admin/users">
                            <i class="fa-solid fa-users"></i>
                            Users
                        </a>
                    </div>

                    <!-- Events -->
                    <a href="#">
                        <i class="fa-solid fa-calendar-days"></i>
                        Events
                    </a>

                    <!-- Categories -->
                    <div class="menu-group">

                        <a href="<%= contextPath%>/admin/categories"
                           class="menu-parent open">

                            <span>
                                <i class="fa-solid fa-folder"></i>
                                Categories
                            </span>

                            <span class="arrow">▼</span>
                        </a>

                        <div class="submenu">

                            <a href="<%= contextPath%>/admin/categories">
                                Category List
                            </a>

                            <a href="<%= contextPath%>/admin/category-create"
                               class="active">
                                Create Category
                            </a>

                        </div>
                    </div>

                    <!-- Venues -->
                    <a href="#">
                        <i class="fa-solid fa-location-dot"></i>
                        Venues
                    </a>

                    <!-- Vouchers -->
                    <a href="#">
                        <i class="fa-solid fa-ticket"></i>
                        Vouchers
                    </a>

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
                            <h1>Create Category</h1>

                            <p>
                                Thêm danh mục sự kiện mới vào hệ thống
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
                              action="<%= contextPath%>/admin/category-create">

                            <!-- Category Name -->
                            <div class="category-form-group">

                                <label for="categoryName">
                                    Category Name
                                </label>

                                <input type="text"
                                       id="categoryName"
                                       name="categoryName"
                                       maxlength="100"
                                       placeholder="Enter category name"
                                       required>

                            </div>

                            <!-- Description -->
                            <div class="category-form-group">

                                <label for="description">
                                    Description
                                </label>

                                <textarea id="description"
                                          name="description"
                                          maxlength="500"
                                          placeholder="Enter category description"
                                          required></textarea>

                            </div>

                            <!-- Status -->
                            <div class="category-form-group">

                                <label for="status">
                                    Status
                                </label>

                                <select id="status"
                                        name="status">

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
                                    Create Category
                                </button>

                                <a href="<%= contextPath%>/admin/categories"
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
