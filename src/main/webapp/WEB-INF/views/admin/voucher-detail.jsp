
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Voucher" %>

<%
    Voucher voucher = (Voucher) request.getAttribute("voucher");
    String contextPath = request.getContextPath();

    if (voucher == null) {
        response.sendError(404);
        return;
    }

    String status = voucher.getStatus() == null
            ? "unknown" : voucher.getStatus().toLowerCase();
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Voucher Detail - Light Ticket</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <link rel="stylesheet"
              href="<%= contextPath%>/css/admin.css?v=3">
    </head>

    <body>
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

                    <div class="menu-group">
                        <a href="<%= contextPath%>/admin/categories">
                            <i class="fa-solid fa-folder"></i>
                            Categories
                        </a>
                    </div>

                    <a href="<%= contextPath%>/admin/venues">
                        <i class="fa-solid fa-location-dot"></i>
                        Venues
                    </a>

                    <!-- Vouchers -->
                    <div class="menu-group">

                        <a href="<%= contextPath%>/admin/vouchers"
                           class="menu-parent open">

                            <span>
                                <i class="fa-solid fa-ticket"></i>
                                Vouchers
                            </span>

                            <span class="arrow">▼</span>
                        </a>

                        <div class="submenu">

                            <a href="<%= contextPath%>/admin/vouchers">
                                Vouchers List
                            </a>

                            

                            <a href="<%= contextPath%>/admin/voucher-detail?id=<%= voucher.getVoucherId()%>"
                               class="active">
                                Voucher Detail
                            </a>

                        </div>
                    </div>

                    <a href="#">
                        <i class="fa-solid fa-star"></i>
                        Reviews
                    </a>

                    <a href="<%= contextPath%>/admin/profile">
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
                           placeholder="⌕ Search...">

                    <div class="admin">
                        🔔 &nbsp; Admin &nbsp;⌄
                    </div>

                </header>

                <section class="content">

                    <div class="detail-container">

                        <!-- Page Heading -->
                        <div class="page-heading">
                            <div>
                                <h1>Voucher Detail</h1>
                                <p>
                                    Thông tin chi tiết mã giảm giá
                                    trong Light Ticket
                                </p>
                            </div>
                        </div>

                        <!-- Detail Card -->
                        <div class="detail-card">

                            <!-- Voucher Profile -->
                            <div class="profile-header">

                                <div class="avatar">
                                    <i class="fa-solid fa-ticket"></i>
                                </div>

                                <div class="profile-info">

                                    <h2>
                                        <%= voucher.getVoucherName() != null
                                                ? voucher.getVoucherName() : ""%>
                                    </h2>

                                    <p>
                                        Voucher ID: #<%= voucher.getVoucherId()%>
                                    </p>

                                    <span class="status <%= status%>">
                                        <%= voucher.getStatus() != null
                                                ? voucher.getStatus() : "Unknown"%>
                                    </span>

                                </div>
                            </div>

                            <!-- Voucher Information -->
                            <h3 class="section-title">
                                <i class="fa-solid fa-circle-info"></i>
                                Voucher Information
                            </h3>

                            <div class="detail-grid">

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Voucher ID
                                    </span>
                                    <div class="detail-value">
                                        #<%= voucher.getVoucherId()%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Voucher Code
                                    </span>
                                    <div class="detail-value">
                                        <%= voucher.getVoucherCode() != null
                                                ? voucher.getVoucherCode() : ""%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Voucher Name
                                    </span>
                                    <div class="detail-value">
                                        <%= voucher.getVoucherName() != null
                                                ? voucher.getVoucherName() : ""%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Discount Type
                                    </span>
                                    <div class="detail-value">
                                        <%= voucher.getDiscountType() != null
                                                ? voucher.getDiscountType() : ""%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Discount Value
                                    </span>
                                    <div class="detail-value">
                                        <%= voucher.getDiscountValue() != null
                                                ? voucher.getDiscountValue().toPlainString() : "0"%>
                                        <%= "Percentage".equals(voucher.getDiscountType())
                                                ? "%" : ""%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Minimum Order Amount
                                    </span>
                                    <div class="detail-value">
                                        <%= voucher.getMinOrderAmount() != null
                                                ? voucher.getMinOrderAmount().toPlainString() : "0"%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Maximum Discount Amount
                                    </span>
                                    <div class="detail-value">
                                        <%= voucher.getMaxDiscountAmount() != null
                                                ? voucher.getMaxDiscountAmount().toPlainString()
                                                : "No limit"%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Status
                                    </span>
                                    <div class="detail-value">
                                        <span class="status <%= status%>">
                                            <%= voucher.getStatus() != null
                                                    ? voucher.getStatus() : "Unknown"%>
                                        </span>
                                    </div>
                                </div>

                            </div>

                            <!-- Usage Information -->
                            <h3 class="section-title account-section-title">
                                <i class="fa-solid fa-chart-column"></i>
                                Usage Information
                            </h3>

                            <div class="detail-grid">

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Usage Limit
                                    </span>
                                    <div class="detail-value">
                                        <%= voucher.getUsageLimit()%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Used Count
                                    </span>
                                    <div class="detail-value">
                                        <%= voucher.getUsedCount()%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Remaining Uses
                                    </span>
                                    <div class="detail-value">
                                        <%= Math.max(0,
                                                voucher.getUsageLimit()
                                                - voucher.getUsedCount())%>
                                    </div>
                                </div>

                            </div>

                            <!-- Validity Information -->
                            <h3 class="section-title account-section-title">
                                <i class="fa-solid fa-calendar-days"></i>
                                Validity Information
                            </h3>

                            <div class="detail-grid">

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Start Time
                                    </span>
                                    <div class="detail-value">
                                        <%= voucher.getStartTime() != null
                                                ? voucher.getStartTime() : "Not available"%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        End Time
                                    </span>
                                    <div class="detail-value">
                                        <%= voucher.getEndTime() != null
                                                ? voucher.getEndTime() : "Not available"%>
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
                                        <%= voucher.getCreatedAt() != null
                                                ? voucher.getCreatedAt() : "Not available"%>
                                    </div>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Updated At
                                    </span>
                                    <div class="detail-value">
                                        <%= voucher.getUpdatedAt() != null
                                                ? voucher.getUpdatedAt() : "Not available"%>
                                    </div>
                                </div>

                            </div>

                            <!-- Actions -->
                            <div class="detail-actions">

                                <a class="back-button"
                                   href="<%= contextPath%>/admin/vouchers">
                                    <i class="fa-solid fa-arrow-left"></i>
                                    Back to Vouchers
                                </a>

                                <a class="back-button"
                                   href="<%= contextPath%>/admin/vouchers?action=edit&id=<%= voucher.getVoucherId()%>"
                                   style="background: #FF7043; color: white;">
                                    <i class="fa-solid fa-pen-to-square"></i>
                                    Update Voucher
                                </a>

                            </div>

                        </div>
                    </div>
                </section>
            </main>
        </div>
    </body>
</html>
