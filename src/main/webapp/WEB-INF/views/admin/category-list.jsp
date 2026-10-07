<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Category" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Category Management - Light Ticket</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/css/admin.css">
    </head>

    <body>

        <%
            List<Category> categories
                    = (List<Category>) request.getAttribute("categories");

            int totalCategories = categories != null
                    ? categories.size() : 0;

            int activeCategories = 0;
            int inactiveCategories = 0;

            if (categories != null) {
                for (Category category : categories) {

                    if ("ACTIVE".equalsIgnoreCase(category.getStatus())) {
                        activeCategories++;
                    } else {
                        inactiveCategories++;
                    }
                }
            }

            String contextPath = request.getContextPath();
        %>

        <div class="layout">

            <!-- Sidebar -->
            <aside class="sidebar">

                <div class="brand">🎟 Light Ticket</div>

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

                            <a href="<%= contextPath%>/admin/categories"
                               class="active">
                                Categories List
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
                    <a href="#">
                        <i class="fa-solid fa-user"></i>
                        My Profile
                    </a>

                </nav>

            </aside>

            <main class="main">

                <!-- Topbar -->
                <header class="topbar">

                    <input class="search" type="text"
                           placeholder="⌕  Search...">

                    <div class="admin">🔔 &nbsp; Admin &nbsp;⌄</div>

                </header>

                <section class="content">

                    <!-- Page Heading -->
                    <div class="page-heading">

                        <div>
                            <h1>Category Management</h1>

                            <p>
                                Quản lý danh mục sự kiện trong hệ thống
                                Light Ticket
                            </p>
                        </div>

                    </div>

                    <!-- Statistics -->
                    <div class="stats">

                        <div class="stat-card total">
                            <p>Total Categories</p>
                            <h2><%= totalCategories%></h2>
                        </div>

                        <div class="stat-card active">
                            <p>Active Categories</p>
                            <h2><%= activeCategories%></h2>
                        </div>

                        <div class="stat-card inactive">
                            <p>Inactive Categories</p>
                            <h2><%= inactiveCategories%></h2>
                        </div>

                    </div>

                    <!-- Category List -->
                    <div class="user-panel">

                        <div class="panel-heading">

                            <div>
                                <h2>Categories List</h2>

                                <p>
                                    Danh sách tất cả danh mục sự kiện
                                    trong hệ thống
                                </p>
                            </div>

                            <button class="add-button"
                                    type="button"
                                    onclick="window.location.href = '<%= contextPath%>/admin/category-create'">
                                + &nbsp; Add New Category
                            </button>   

                        </div>

                        <div class="table-wrapper">

                            <table>

                                <thead>

                                    <tr>
                                        <th>ID</th>
                                        <th>Category Name</th>
                                        <th>Description</th>
                                        <th>Status</th>
                                        <th>Created At</th>
                                        <th>Updated At</th>
                                        <th>Action</th>
                                    </tr>

                                </thead>

                                <tbody>

                                    <%
                                        if (categories != null
                                                && !categories.isEmpty()) {

                                            for (Category category : categories) {
                                    %>

                                    <tr>

                                        <td>
                                            <%= category.getCategoryId()%>
                                        </td>

                                        <td>
                                            <%= category.getCategoryName()%>
                                        </td>

                                        <td>
                                            <%= category.getDescription() != null
                                                    ? category.getDescription()
                                                    : ""%>
                                        </td>

                                        <td>

                                            <span class="status <%= category.getStatus().toLowerCase()%>">
                                                <%= category.getStatus()%>
                                            </span>

                                        </td>

                                        <td>
                                            <%= category.getCreatedAt() != null
                                                    ? category.getCreatedAt()
                                                    : ""%>
                                        </td>

                                        <td>
                                            <%= category.getUpdatedAt() != null
                                                    ? category.getUpdatedAt()
                                                    : ""%>
                                        </td>

                                        <td>

                                            <button class="view-button"
                                                    type="button">
                                                View
                                            </button>

                                        </td>

                                    </tr>

                                    <%
                                        }

                                    } else {
                                    %>

                                    <tr>

                                        <td colspan="7" class="empty">
                                            No categories found.
                                        </td>

                                    </tr>

                                    <%
                                        }
                                    %>

                                </tbody>

                            </table>

                        </div>

                    </div>

                </section>

            </main>

        </div>

    </body>
</html>