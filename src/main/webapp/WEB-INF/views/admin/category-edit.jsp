
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Category" %>

<%
    Category category = (Category) request.getAttribute("category");
    String contextPath = request.getContextPath();
    String errorMessage = (String) request.getAttribute("errorMessage");

    if (category == null) {
        response.sendError(404);
        return;
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Edit Category - Light Ticket</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <link rel="stylesheet"
              href="<%= contextPath%>/css/admin.css?v=3">
    </head>

    <body>
        <div class="layout">


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

                            <a href="<%= contextPath%>/admin/categories">
                                Categories List
                            </a>

                            <a href="<%= contextPath%>/admin/category-detail?id=<%= category.getCategoryId()%>">
                                Category Detail
                            </a>

                            <a href="<%= contextPath%>/admin/category-edit?id=<%= category.getCategoryId()%>"
                               class="active">
                                Edit Category
                            </a>

                        </div>
                    </div>

                    <!-- Venues -->
                    <a href="<%= request.getContextPath()%>/admin/venues">
                        <i class="fa-solid fa-location-dot"></i>
                        Venues
                    </a>

                    <!-- Vouchers -->
                    <a href="<%= contextPath%>/admin/vouchers">
                        <i class="fa-solid fa-ticket"></i>
                        Vouchers
                    </a>

                    <!-- Reviews -->
                    <a href="#">
                        <i class="fa-solid fa-star"></i>
                        Reviews
                    </a>

                    <!-- My Profile -->
                    <a href="${pageContext.request.contextPath}/admin/profile">
                        <i class="fa-solid fa-user"></i>
                        My Profile
                    </a>

                </nav>

            </aside>

            <main class="main">
                <header class="topbar">
                    <input class="search" type="text" placeholder="⌕ Search...">
                    <a class="admin" href="<%= contextPath%>/admin/profile">
                        <img class="admin-avatar"
                             src="<%= contextPath%>/assets/icons/user_icon.png"
                             alt="Admin Avatar">
                        <span>Admin</span>
                    </a>
                </header>

                <section class="content">
                    <div class="page-heading">
                        <div>
                            <h1>Update Category</h1>
                            <p>Chỉnh sửa thông tin danh mục sự kiện</p>
                        </div>
                    </div>

                    <div class="edit-category-card">
                        <h2>
                            <i class="fa-solid fa-folder-open"></i>
                            Category Information
                        </h2>
                        <p class="subtitle">
                            Cập nhật thông tin danh mục bên dưới.
                        </p>

                        <% if (errorMessage != null) {%>
                        <div class="error-message">
                            <%= errorMessage%>
                        </div>
                        <% }%>

                        <form method="post"
                              action="<%= contextPath%>/admin/category-edit">

                            <input type="hidden" name="id"
                                   value="<%= category.getCategoryId()%>">

                            <div class="form-group">
                                <label for="categoryName">Category Name *</label>
                                <input id="categoryName"
                                       type="text"
                                       name="categoryName"
                                       maxlength="100"
                                       required
                                       value="<%= category.getCategoryName() == null
                                               ? "" : category.getCategoryName()
                                                       .replace("&", "&amp;")
                                                       .replace("\"", "&quot;")
                                                       .replace("<", "&lt;")
                                                       .replace(">", "&gt;")%>">
                            </div>

                            <div class="form-group">
                                <label for="description">Description</label>
                                <textarea id="description"
                                          name="description"
                                          maxlength="500"
                                          required><%= category.getDescription() == null
                                                  ? "" : category.getDescription()
                                                          .replace("&", "&amp;")
                                                          .replace("<", "&lt;")
                                                          .replace(">", "&gt;")%></textarea>
                            </div>

                            <div class="form-group">
                                <label for="status">Status *</label>
                                <select id="status" name="status" required>
                                    <option value="ACTIVE"
                                            <%= "ACTIVE".equalsIgnoreCase(category.getStatus())
                                                    ? "selected" : ""%>>
                                        Active
                                    </option>
                                    <option value="INACTIVE"
                                            <%= "INACTIVE".equalsIgnoreCase(category.getStatus())
                                                    ? "selected" : ""%>>
                                        Inactive
                                    </option>
                                </select>
                            </div>

                            <div class="form-actions">
                                <button class="save-button" type="submit">
                                    <i class="fa-solid fa-floppy-disk"></i>
                                    Save Changes
                                </button>

                                <a class="cancel-button"
                                   href="<%= contextPath%>/admin/category-detail?id=<%= category.getCategoryId()%>">
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