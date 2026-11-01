<%-- 
    Document   : review-list
    Created on : Oct 23, 2026, 3:30:42 PM
    Author     : BT
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Review" %>
<%!
    private String escReview(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#x27;");
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Review Management - Light Ticket</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css?v=3">
        <style>
            /* Main content follows the Admin layout */
            .review-content {
                padding: 32px;
                min-width: 0;
                width: 100%;
            }

            /* Review page heading */
            .review-heading {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 15px;
                margin-bottom: 30px;
            }

            .review-heading h1 {
                margin: 0 0 8px;
                font-size: 28px;
                color: #202B3C;
            }

            .review-heading p {
                margin: 0;
                color: #8290A7;
                font-size: 14px;
            }

            .review-summary {
                color: #526078;
                white-space: nowrap;
            }

            /* Review table container */
            .review-card {
                background: #FFFFFF;
                border: 1px solid #E9EDF6;
                border-radius: 16px;
                padding: 22px;
                box-shadow: 0 5px 20px rgba(40, 55, 90, 0.04);
                min-width: 0;
            }

            .review-table-wrapper {
                width: 100%;
                overflow-x: auto;
            }

            .review-table {
                width: 100%;
                min-width: 1000px;
                border-collapse: collapse;
            }

            .review-table th {
                background: #F2F5FC;
                color: #526078;
                font-size: 12px;
                font-weight: 600;
                text-align: left;
                padding: 16px 12px;
            }

            .review-table td {
                padding: 17px 12px;
                border-bottom: 1px solid #EDF0F7;
                font-size: 13px;
                vertical-align: top;
            }

            .review-table tbody tr:hover {
                background: #FFFAF8;
            }

            .review-table small {
                display: inline-block;
                margin-top: 5px;
                color: #8290A7;
            }

            .review-stars {
                color: #F59E0B;
                white-space: nowrap;
            }

            .review-status {
                display: inline-block;
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 11px;
                font-weight: bold;
            }

            .status-active {
                background: #E2F7EF;
                color: #13966D;
            }

            .status-hidden {
                background: #FFE9E9;
                color: #D94B4B;
            }

            .review-action {
                border: none;
                border-radius: 8px;
                padding: 9px 13px;
                color: white;
                cursor: pointer;
                font-size: 12px;
                white-space: nowrap;
            }

            .action-hide {
                background: #E94B4B;
            }

            .action-show {
                background: #20B486;
            }

            .review-action:hover {
                opacity: 0.85;
            }

            .review-comment {
                max-width: 260px;
                white-space: pre-wrap;
                overflow-wrap: anywhere;
            }

            .review-alert {
                padding: 12px 15px;
                border-radius: 8px;
                margin-bottom: 16px;
                background: #E2F7EF;
                color: #13966D;
            }

            .review-empty {
                text-align: center;
                padding: 30px;
                color: #8290A7;
            }

            @media (max-width: 768px) {
                .review-content {
                    padding: 18px;
                }

                .review-heading {
                    align-items: flex-start;
                    flex-direction: column;
                }

                .review-card {
                    padding: 12px;
                }
            }
        </style>
    </head>
    <body>
        <%
            List<Review> reviews = (List<Review>) request.getAttribute("reviews");
            String contextPath = request.getContextPath();
            String message = request.getParameter("message");
            int total = reviews == null ? 0 : reviews.size();
            int active = 0;
            if (reviews != null)
                for (Review r : reviews)
                    if ("ACTIVE".equalsIgnoreCase(r.getStatus()))
                        active++;
        %>

        <div class="layout">

            <!-- Sidebar -->
            <aside class="sidebar">
                <div class="brand">🎟 Light Ticket</div>

                <nav class="menu">
                    <a href="<%=contextPath%>/admin">
                        <i class="fa-solid fa-chart-line"></i>
                        Dashboard
                    </a>

                    <a href="<%=contextPath%>/admin/users">
                        <i class="fa-solid fa-users"></i>
                        Users
                    </a>

                    <!-- Giữ đường dẫn Events nếu dự án đã có controller -->
                    <a href="<%=contextPath%>/admin/events">
                        <i class="fa-solid fa-calendar-days"></i>
                        Events
                    </a>

                    <a href="<%=contextPath%>/admin/categories">
                        <i class="fa-solid fa-folder"></i>
                        Categories
                    </a>

                    <a href="<%=contextPath%>/admin/venues">
                        <i class="fa-solid fa-location-dot"></i>
                        Venues
                    </a>

                    <a href="<%=contextPath%>/admin/vouchers">
                        <i class="fa-solid fa-ticket"></i>
                        Vouchers
                    </a>

                    <a href="<%=contextPath%>/admin/reviews" class="active">
                        <i class="fa-solid fa-star"></i>
                        Reviews
                    </a>

                    <a href="<%=contextPath%>/admin/profile">
                        <i class="fa-solid fa-user"></i>
                        My Profile
                    </a>
                </nav>
            </aside>

            <!-- Main content -->
            <main class="main">

                <!-- Topbar giống Dashboard -->
                <header class="topbar">
                    <input type="text" class="search" placeholder="Search...">

                    <a class="admin"
                       href="<%=contextPath%>/admin/profile">
                        <img class="admin-avatar"
                             src="<%=contextPath%>/assets/icons/user_icon.png"
                             alt="Admin Avatar">
                        <span>Admin</span>
                    </a>
                </header>

                <section class="content">

                    <div class="page-heading review-heading">
                        <div>
                            <h1>Review Management</h1>
                            <p>View customer feedback and manage review visibility.</p>
                        </div>

                        <div class="review-summary">
                            <strong><%=total%></strong> reviews
                            &nbsp; | &nbsp;
                            <strong><%=active%></strong> active
                        </div>
                    </div>

                    <% if ("updated".equals(message)) { %>
                    <div class="review-alert">
                        Review status updated successfully.
                    </div>
                    <% } %>

                    <% if ("notfound".equals(message)) { %>
                    <div class="review-alert">
                        The selected review was not found.
                    </div>
                    <% } %>

                    <section class="review-card">
                        <div class="review-table-wrapper">
                            <table class="review-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Customer</th>
                                        <th>Event</th>
                                        <th>Rating</th>
                                        <th>Comment</th>
                                        <th>Created at</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <% if (reviews == null || reviews.isEmpty()) { %>
                                    <tr>
                                        <td colspan="8" class="review-empty">
                                            No reviews are available.
                                        </td>
                                    </tr>
                                    <% } else {
                                        for (Review r : reviews) {
                                            boolean isActive
                                                    = "ACTIVE".equalsIgnoreCase(r.getStatus());
                                    %>
                                    <tr>
                                        <td>#<%=r.getReviewId()%></td>

                                        <td>
                                            <%=escReview(r.getCustomerName())%><br>
                                            <small>Customer ID: <%=r.getCustomerId()%></small>
                                        </td>

                                        <td>
                                            <%=escReview(r.getEventName())%><br>
                                            <small>Event ID: <%=r.getEventId()%></small>
                                        </td>

                                        <td>
                                            <span class="review-stars">
                                                <%= "★".repeat(
                                                        Math.max(0, Math.min(5, r.getRating()))
                                                )%>
                                            </span>
                                            <%=r.getRating()%>/5
                                        </td>

                                        <td>
                                            <div class="review-comment">
                                                <%=escReview(r.getComment())%>
                                            </div>
                                        </td>

                                        <td>
                                            <%=r.getCreatedAt() == null
                                                ? "—"
                                                : r.getCreatedAt().toString().replace('T', ' ')%>
                                        </td>

                                        <td>
                                            <span class="review-status
                                                  <%=isActive ? "status-active" : "status-hidden"%>">
                                                <%=escReview(r.getStatus())%>
                                            </span>
                                        </td>

                                        <td>
                                            <form method="post"
                                                  action="<%=contextPath%>/admin/reviews"
                                                  onsubmit="return confirm('Are you sure you want to change this review status?');">

                                                <input type="hidden" name="action"
                                                       value="changeStatus">

                                                <input type="hidden" name="reviewId"
                                                       value="<%=r.getReviewId()%>">

                                                <input type="hidden" name="status"
                                                       value="<%=isActive ? "HIDDEN" : "ACTIVE"%>">

                                                <button class="review-action
                                                        <%=isActive ? "action-hide" : "action-show"%>"
                                                        type="submit">
                                                    <%=isActive ? "Hide review" : "Show review"%>
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                    <% }
                                }%>
                                </tbody>
                            </table>
                        </div>
                    </section>

                </section>
            </main>
        </div>
    </body>
</html>
