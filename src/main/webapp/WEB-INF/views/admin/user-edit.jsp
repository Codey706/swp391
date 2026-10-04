<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>

<!DOCTYPE html>
<html>

    <head>

        <meta charset="UTF-8">

        <title>Update User - Light Ticket</title>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/css/admin.css">

        <style>

            .edit-container {
                max-width: 1050px;
                margin: auto;
            }

            .breadcrumb {
                color: #8290A7;
                font-size: 13px;
                margin-bottom: 22px;
            }

            .edit-card {
                background: #FFFFFF;
                border: 1px solid #E9EDF6;
                border-radius: 16px;
                padding: 30px;
                box-shadow: 0 5px 20px rgba(40, 55, 90, 0.04);
            }

            .section-title {
                font-size: 17px;
                margin: 0 0 20px;
            }

            .form-grid {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 20px;
            }

            .form-group {
                display: flex;
                flex-direction: column;
            }

            .form-group.full {
                grid-column: 1 / -1;
            }

            .form-label {
                color: #596579;
                font-size: 13px;
                font-weight: 600;
                margin-bottom: 8px;
            }

            .form-input,
            .form-select {
                width: 100%;
                box-sizing: border-box;
                padding: 12px 13px;
                border: 1px solid #DDE3EE;
                border-radius: 9px;
                background: #FFFFFF;
                color: #202B3C;
                font-size: 14px;
                outline: none;
            }

            .form-input:focus,
            .form-select:focus {
                border-color: #FF7043;
                box-shadow: 0 0 0 3px rgba(255, 112, 67, 0.12);
            }

            .form-input.readonly {
                background: #F4F6FA;
                color: #8290A7;
                cursor: not-allowed;
            }

            .form-actions {
                display: flex;
                justify-content: flex-end;
                gap: 10px;
                margin-top: 30px;
                padding-top: 22px;
                border-top: 1px solid #EDF0F7;
            }

            .cancel-button,
            .save-button {
                text-decoration: none;
                border: none;
                padding: 12px 20px;
                border-radius: 9px;
                font-size: 13px;
                font-weight: bold;
                cursor: pointer;
            }

            .cancel-button {
                background: #F1F3F8;
                color: #596579;
            }

            .cancel-button:hover {
                background: #E5E8EF;
                color: #202B3C;
            }

            .save-button {
                background: #FF7043;
                color: #FFFFFF;
            }

            .save-button:hover {
                background: #E95427;
            }

            @media (max-width: 650px) {

                .edit-card {
                    padding: 18px;
                }

                .form-grid {
                    grid-template-columns: 1fr;
                    gap: 15px;
                }

                .form-group.full {
                    grid-column: auto;
                }

                .form-actions {
                    flex-direction: column;
                }

                .cancel-button,
                .save-button {
                    text-align: center;
                    width: 100%;
                }
            }

        </style>

    </head>

    <body>

        <%
            User user = (User) request.getAttribute("user");
        %>

        <div class="layout">

            <!-- Sidebar -->
            <aside class="sidebar">

                <div class="brand">
                    🎟 Light Ticket
                </div>

                <nav class="menu">

                    <a href="#">
                        ⌂ &nbsp; Dashboard
                    </a>

                    <div class="menu-group">

                        <a href="<%= request.getContextPath()%>/admin/users"
                           class="menu-parent open">

                            <span>
                                ♟ &nbsp; Users
                            </span>

                            <span class="arrow">
                                ▼
                            </span>

                        </a>

                        <div class="submenu">

                            <a href="<%= request.getContextPath()%>/admin/users">
                                ▪ &nbsp; Users List
                            </a>

                            <a href="<%= request.getContextPath()%>/admin/user-detail?id=<%= user.getUserId()%>"
                               class="active">
                                ▪ &nbsp; User Detail
                            </a>

                        </div>

                    </div>

                    <a href="#">
                        ▣ &nbsp; Events
                    </a>

                    <a href="#">
                        ▤ &nbsp; Categories
                    </a>

                    <a href="#">
                        ⌖ &nbsp; Venues
                    </a>

                    <a href="#">
                        🎟 &nbsp; Vouchers
                    </a>

                    <a href="#">
                        ☆ &nbsp; Reviews
                    </a>

                    <a href="#">
                        ♙ &nbsp; My Profile
                    </a>

                </nav>

            </aside>

            <main class="main">

                <header class="topbar">

                    <input class="search"
                           type="text"
                           placeholder="⌕  Search...">

                    <div class="admin">
                        🔔 &nbsp; Admin &nbsp;⌄
                    </div>

                </header>

                <section class="content">

                    <div class="edit-container">

                        <div class="breadcrumb">
                            Home &nbsp; / &nbsp; User Management
                            &nbsp; / &nbsp; Update User
                        </div>

                        <div class="page-heading">

                            <div>

                                <h1>
                                    Update User Information
                                </h1>

                                <p>
                                    Chỉnh sửa thông tin người dùng
                                </p>

                            </div>

                        </div>

                        <div class="edit-card">

                            <h3 class="section-title">
                                User Information
                            </h3>

                            <form method="post"
                                  action="<%= request.getContextPath()%>/admin/user-edit">

                                <input type="hidden"
                                       name="userId"
                                       value="<%= user.getUserId()%>">

                                <div class="form-grid">

                                    <!-- Username -->
                                    <div class="form-group">

                                        <label class="form-label">
                                            Username
                                        </label>

                                        <input class="form-input readonly"
                                               type="text"
                                               value="<%= user.getUsername()%>"
                                               readonly>

                                    </div>

                                    <!-- Full Name -->
                                    <div class="form-group">

                                        <label class="form-label">
                                            Full Name
                                        </label>

                                        <input class="form-input"
                                               type="text"
                                               name="fullName"
                                               value="<%= user.getFullName() != null
                                                       ? user.getFullName()
                                                       : ""%>"
                                               required>

                                    </div>

                                    <!-- Email -->
                                    <div class="form-group">

                                        <label class="form-label">
                                            Email Address
                                        </label>

                                        <input class="form-input readonly"
                                               type="email"
                                               value="<%= user.getEmail() != null
                                                       ? user.getEmail()
                                                       : ""%>"
                                               readonly>

                                    </div>

                                    <!-- Phone -->
                                    <div class="form-group">

                                        <label class="form-label">
                                            Phone Number
                                        </label>

                                        <input class="form-input"
                                               type="text"
                                               name="phone"
                                               value="<%= user.getPhone() != null
                                                       ? user.getPhone()
                                                       : ""%>">

                                    </div>

                                    <!-- Address -->
                                    <div class="form-group full">

                                        <label class="form-label">
                                            Address
                                        </label>

                                        <input class="form-input"
                                               type="text"
                                               name="address"
                                               value="<%= user.getAddress() != null
                                                       ? user.getAddress()
                                                       : ""%>">

                                    </div>

                                    <!-- Role -->
                                    <div class="form-group">

                                        <label class="form-label">
                                            Role
                                        </label>

                                        <select class="form-select"
                                                name="role">

                                            <option value="CUSTOMER"
                                                    <%= "CUSTOMER".equalsIgnoreCase(user.getRole())
                                                            ? "selected" : ""%>>
                                                Customer
                                            </option>

                                            <option value="ORGANIZER"
                                                    <%= "ORGANIZER".equalsIgnoreCase(user.getRole())
                                                            ? "selected" : ""%>>
                                                Organizer
                                            </option>

                                            <option value="STAFF"
                                                    <%= "STAFF".equalsIgnoreCase(user.getRole())
                                                            ? "selected" : ""%>>
                                                Staff
                                            </option>

                                            <option value="ADMIN"
                                                    <%= "ADMIN".equalsIgnoreCase(user.getRole())
                                                            ? "selected" : ""%>>
                                                Admin
                                            </option>

                                        </select>

                                    </div>

                                    <!-- Status -->
                                    <div class="form-group">

                                        <label class="form-label">
                                            Account Status
                                        </label>

                                        <select class="form-select"
                                                name="status">

                                            <option value="ACTIVE"
                                                    <%= "ACTIVE".equalsIgnoreCase(user.getStatus())
                                                            ? "selected" : ""%>>
                                                Active
                                            </option>

                                            <option value="INACTIVE"
                                                    <%= "INACTIVE".equalsIgnoreCase(user.getStatus())
                                                            ? "selected" : ""%>>
                                                Inactive
                                            </option>

                                        </select>

                                    </div>

                                </div>

                                <div class="form-actions">

                                    <a class="cancel-button"
                                       href="<%= request.getContextPath()%>/admin/user-detail?id=<%= user.getUserId()%>">
                                        Cancel
                                    </a>

                                    <button class="save-button"
                                            type="submit">
                                        Update Information
                                    </button>

                                </div>

                            </form>

                        </div>

                    </div>

                </section>

            </main>

        </div>

    </body>

</html>