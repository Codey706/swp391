<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>User Detail - Light Ticket</title>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/css/admin.css">

        <style>
            .detail-container {
                max-width: 1050px;
                margin: auto;
            }

            .breadcrumb {
                color: #8290A7;
                font-size: 13px;
                margin-bottom: 22px;
            }

            .detail-card {
                background: #FFFFFF;
                border: 1px solid #E9EDF6;
                border-radius: 16px;
                padding: 30px;
                box-shadow: 0 5px 20px rgba(40, 55, 90, 0.04);
            }

            .profile-header {
                display: flex;
                align-items: center;
                gap: 20px;
                padding-bottom: 25px;
                border-bottom: 1px solid #EDF0F7;
                margin-bottom: 28px;
            }

            .avatar {
                width: 75px;
                height: 75px;
                border-radius: 22px;
                background: #FFE3D9;
                color: #E95427;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 30px;
                font-weight: bold;
                flex-shrink: 0;
            }

            .profile-info h2 {
                margin: 0 0 8px;
                font-size: 23px;
            }

            .profile-info p {
                color: #8290A7;
                margin: 0 0 12px;
                font-size: 14px;
            }

            .section-title {
                font-size: 17px;
                margin: 0 0 20px;
            }

            .detail-grid {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 20px;
            }

            .detail-item {
                background: #F8F9FD;
                border: 1px solid #EDF0F7;
                border-radius: 11px;
                padding: 17px;
                min-width: 0;
            }

            .detail-label {
                display: block;
                color: #8290A7;
                font-size: 12px;
                margin-bottom: 9px;
            }

            .detail-value {
                color: #202B3C;
                font-size: 14px;
                font-weight: 600;
                overflow-wrap: anywhere;
            }

            /* Status dropdown */
            .status-form {
                margin: 0;
            }

            .status-select {
                border: 1px solid #DDE3EE;
                border-radius: 8px;
                padding: 8px 12px;
                background: #FFFFFF;
                color: #202B3C;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                outline: none;
            }

            .status-select:focus {
                border-color: #FF7043;
                box-shadow: 0 0 0 3px rgba(255, 112, 67, 0.12);
            }

            .detail-actions {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 12px;
                margin-top: 28px;
                padding-top: 22px;
                border-top: 1px solid #EDF0F7;
            }

            .action-left {
                display: flex;
                gap: 10px;
            }

            .back-button,
            .update-button {
                text-decoration: none;
                padding: 12px 20px;
                border-radius: 9px;
                font-size: 13px;
                font-weight: bold;
                transition: 0.2s;
            }

            .back-button {
                background: #F1F3F8;
                color: #596579;
            }

            .back-button:hover {
                background: #E5E8EF;
                color: #202B3C;
            }

            .update-button {
                background: #FF7043;
                color: #FFFFFF;
            }

            .update-button:hover {
                background: #E95427;
                color: #FFFFFF;
            }

            @media (max-width: 650px) {

                .detail-card {
                    padding: 18px;
                }

                .detail-grid {
                    grid-template-columns: 1fr;
                    gap: 12px;
                }

                .profile-header {
                    align-items: flex-start;
                }

                .avatar {
                    width: 58px;
                    height: 58px;
                    font-size: 23px;
                }

                .profile-info h2 {
                    font-size: 19px;
                }

                .detail-actions {
                    flex-direction: column;
                    align-items: stretch;
                }

                .action-left {
                    flex-direction: column;
                }

                .back-button,
                .update-button {
                    text-align: center;
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

                <div class="brand">🎟 Light Ticket</div>

                <nav class="menu">

                    <a href="#">⌂ &nbsp; Dashboard</a>

                    <div class="menu-group">

                        <a href="<%= request.getContextPath()%>/admin/users"
                           class="menu-parent open">
                            <span>♟ &nbsp; Users</span>
                            <span class="arrow">▼</span>
                        </a>

                        <div class="submenu">

                            <a href="<%= request.getContextPath()%>/admin/users">
                                ▪ &nbsp; Users List
                            </a>

                            <a href="<%= request.getRequestURI()%>"
                               class="active">
                                ▪ &nbsp; User Detail
                            </a>

                        </div>

                    </div>

                    <a href="#">▣ &nbsp; Events</a>
                    <a href="#">▤ &nbsp; Categories</a>
                    <a href="#">⌖ &nbsp; Venues</a>
                    <a href="#">🎟 &nbsp; Vouchers</a>
                    <a href="#">☆ &nbsp; Reviews</a>
                    <a href="#">♙ &nbsp; My Profile</a>

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

                    <div class="detail-container">

                        <div class="breadcrumb">
                            Home &nbsp; / &nbsp; User Management
                            &nbsp; / &nbsp; User Detail
                        </div>

                        <div class="page-heading">

                            <div>
                                <h1>User Detail</h1>

                                <p>
                                    Thông tin chi tiết của người dùng trong Light Ticket
                                </p>
                            </div>

                        </div>

                        <div class="detail-card">

                            <!-- Profile -->
                            <div class="profile-header">

                                <div class="avatar">
                                    <%= user.getFullName() != null
                                            && !user.getFullName().isEmpty()
                                            ? user.getFullName()
                                                    .substring(0, 1)
                                                    .toUpperCase()
                                            : "U"%>
                                </div>

                                <div class="profile-info">

                                    <h2>
                                        <%= user.getFullName()%>
                                    </h2>

                                    <p>
                                        @<%= user.getUsername()%>
                                    </p>

                                    <span class="role <%= user.getRole().toLowerCase()%>">
                                        <%= user.getRole()%>
                                    </span>

                                    &nbsp;

                                    <span class="status <%= user.getStatus().toLowerCase()%>">
                                        <%= user.getStatus()%>
                                    </span>

                                </div>

                            </div>

                            <!-- Personal Information -->
                            <h3 class="section-title">
                                Personal Information
                            </h3>

                            <div class="detail-grid">

                                <div class="detail-item">

                                    <span class="detail-label">
                                        User ID
                                    </span>

                                    <div class="detail-value">
                                        #<%= user.getUserId()%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Username
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getUsername()%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Full Name
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getFullName()%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Email Address
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getEmail()%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Phone Number
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getPhone() != null
                                                ? user.getPhone()
                                                : "Not provided"%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Address
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getAddress() != null
                                                ? user.getAddress()
                                                : "Not provided"%>
                                    </div>

                                </div>

                            </div>

                            <!-- Account Information -->
                            <h3 class="section-title"
                                style="margin-top: 30px;">
                                Account Information
                            </h3>

                            <div class="detail-grid">

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Role
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getRole()%>
                                    </div>

                                </div>

                                <!-- Quick Status Update -->
                                <div class="detail-item">

                                    <span class="detail-label">
                                        Account Status
                                    </span>

                                    <form class="status-form"
                                          method="post"
                                          action="<%= request.getContextPath()%>/admin/user-detail">

                                        <input type="hidden"
                                               name="id"
                                               value="<%= user.getUserId()%>">

                                        <select class="status-select"
                                                name="status"
                                                onchange="this.form.submit()">

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

                                    </form>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Created At
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getCreatedAt() != null
                                                ? user.getCreatedAt()
                                                : "Not available"%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Updated At
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getUpdatedAt() != null
                                                ? user.getUpdatedAt()
                                                : "Not available"%>
                                    </div>

                                </div>

                            </div>

                            <!-- Buttons -->
                            <div class="detail-actions">

                                <div class="action-left">

                                    <a class="back-button"
                                       href="<%= request.getContextPath()%>/admin/users">
                                        ← Back to User List
                                    </a>

                                </div>

                                <a class="update-button"
                                   href="<%= request.getContextPath()%>/admin/user-edit?id=<%= user.getUserId()%>">
                                    Update Information
                                </a>

                            </div>

                        </div>

                    </div>

                </section>

            </main>

        </div>

    </body>
</html>