
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Category" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Category Detail - Light Ticket</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/admin.css?v=3">
    </head>

    <body>

        <%
            Category category = (Category) request.getAttribute("category");
            String contextPath = request.getContextPath();
        %>

        <div class="layout">

            <!-- Sidebar -->
            <aside class="sidebar">

                <div class="brand">🎟 Light Ticket</div>

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
                                Categories List
                            </a>

                            <a href="<%= contextPath%>/admin/category-detail?id=<%= category.getCategoryId()%>"
                               class="active">
                                Category Detail
                            </a>

                        </div>
                    </div>

                    <a href="<%= request.getContextPath()%>/admin/venues">
                        <i class="fa-solid fa-location-dot"></i>
                        Venues
                    </a>

                    <a href="#">
                        <i class="fa-solid fa-ticket"></i>
                        Vouchers
                    </a>

                    <a href="#">
                        <i class="fa-solid fa-star"></i>
                        Reviews
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/profile">
                        <i class="fa-solid fa-user"></i>
                        My Profile
                    </a>

                </nav>
            </aside>

            <main class="main">

                <!-- Topbar -->
                <header class="topbar">

                    <input class="search"
                           type="text"
                           placeholder="⌕  Search...">

                    <div class="admin">
                        🔔 &nbsp; Admin &nbsp;⌄
                    </div>

                </header>

                <section class="content">

                    <div class="detail-container">

                        <!-- Page Heading -->
                        <div class="page-heading">
                            <div>
                                <h1>Category Detail</h1>
                                <p>
                                    Thông tin chi tiết danh mục sự kiện
                                    trong Light Ticket
                                </p>
                            </div>
                        </div>

                        <!-- Detail Card -->
                        <div class="detail-card">

                            <!-- Category Profile -->
                            <div class="profile-header">

                                <div class="avatar">
                                    <i class="fa-solid fa-folder-open"></i>
                                </div>

                                <div class="profile-info">

                                    <h2>
                                        <%= category.getCategoryName() != null
                                                ? category.getCategoryName() : ""%>
                                    </h2>

                                    <p>
                                        Category ID: #<%= category.getCategoryId()%>
                                    </p>

                                    <span class="status <%= category.getStatus() != null
                                            ? category.getStatus().toLowerCase() : ""%>">
                                        <%= category.getStatus() != null
                                                ? category.getStatus() : "Unknown"%>
                                    </span>

                                </div>
                            </div>

                            <!-- Category Information -->
                            <h3 class="section-title">
                                <i class="fa-solid fa-circle-info"></i>
                                Category Information
                            </h3>

                            <div class="detail-grid">

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Category ID
                                    </span>

                                    <div class="detail-value">
                                        #<%= category.getCategoryId()%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Category Name
                                    </span>

                                    <div class="detail-value">
                                        <%= category.getCategoryName() != null
                                                ? category.getCategoryName() : ""%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Status
                                    </span>

                                    <div class="detail-value">
                                        <span class="status <%= category.getStatus() != null
                                                ? category.getStatus().toLowerCase() : ""%>">
                                            <%= category.getStatus() != null
                                                    ? category.getStatus() : "Unknown"%>
                                        </span>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Description
                                    </span>

                                    <div class="detail-value">
                                        <%= category.getDescription() != null
                                                && !category.getDescription().trim().isEmpty()
                                                ? category.getDescription()
                                                : "No description provided"%>
                                    </div>
                                </div>

                            </div>

                            <!-- System Information -->
                            <h3 class="section-title account-section-title">
                                <i class="fa-solid fa-clock"></i>
                                System Information
                            </h3>

                            <div class="detail-grid">

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Created At
                                    </span>

                                    <div class="detail-value">
                                        <%= category.getCreatedAt() != null
                                                ? category.getCreatedAt()
                                                : "Not available"%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Updated At
                                    </span>

                                    <div class="detail-value">
                                        <%= category.getUpdatedAt() != null
                                                ? category.getUpdatedAt()
                                                : "Not available"%>
                                    </div>
                                </div>

                            </div>

                            <!-- Actions -->



                            <div class="detail-actions">
                                <a class="back-button"
                                   href="<%= contextPath%>/admin/categories">
                                    <i class="fa-solid fa-arrow-left"></i>
                                    Back to Categories
                                </a>

                                <!-- Delete nằm bên trái Update -->
                                <form method="post"
                                      action="<%= contextPath%>/admin/category-delete"
                                      style="display: inline;">
                                    <input type="hidden" name="id"
                                           value="<%= category.getCategoryId()%>">

                                    <button type="submit" class="delete-button">
                                        <i class="fa-solid fa-trash"></i>
                                        Delete Category
                                    </button>
                                </form>

                                <a class="back-button"
                                   href="<%= contextPath%>/admin/category-edit?id=<%= category.getCategoryId()%>"
                                   style="background: #FF7043; color: white;">
                                    <i class="fa-solid fa-pen-to-square"></i>
                                    Update Category
                                </a>
                            </div>

                        </div>

                    </div>

                </section>

            </main>

        </div>

    </body>
</html>