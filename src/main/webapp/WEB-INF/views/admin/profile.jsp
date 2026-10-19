<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%@ page import="java.util.Map" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>My Profile - Light Ticket</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css?v=3">
    </head>
    <body>
        <%
            User admin = (User) request.getAttribute("admin");
            Map<String, String> errors
                    = (Map<String, String>) request.getAttribute("errors");
            String cp = request.getContextPath();
        %>
        <div class="layout">
            <aside class="sidebar">
                <div class="brand">🎟 Light Ticket</div>
                <nav class="menu">
                    <a href="<%=cp%>/admin">
                        <i class="fa-solid fa-chart-line"></i> Dashboard
                    </a>
                    <a href="<%=cp%>/admin/users">
                        <i class="fa-solid fa-users"></i> Users
                    </a>
                    <a href="#">
                        <i class="fa-solid fa-calendar-days"></i> Events
                    </a>
                    <a href="<%=cp%>/admin/categories">
                        <i class="fa-solid fa-folder"></i> Categories
                    </a>
                    <a href="<%=cp%>/admin/venues">
                        <i class="fa-solid fa-location-dot"></i> Venues
                    </a>
                    <a href="<%=cp%>/admin/vouchers">
                        <i class="fa-solid fa-ticket"></i> Vouchers
                    </a>
                    <a href="#">
                        <i class="fa-solid fa-star"></i> Reviews
                    </a>
                    <a class="active" href="<%=cp%>/admin/profile">
                        <i class="fa-solid fa-user"></i> My Profile
                    </a>
                </nav>
            </aside>

            <main class="main">
                <header class="topbar">
                    <span class="admin-profile-top">
                        <i class="fa-solid fa-user-shield"></i>
                        <c:out value="${admin.fullName}"/>
                    </span>
                </header>

                <section class="content">
                    <div class="page-heading">
                        <div>
                            <h1>My Profile</h1>
                            <p>View and update your admin account information.</p>
                        </div>
                    </div>

                    <c:if test="${not empty successMessage}">
                        <div class="profile-alert success">
                            <c:out value="${successMessage}"/>
                        </div>
                    </c:if>

                    <c:if test="${not empty profileError}">
                        <div class="profile-alert error">
                            <c:out value="${profileError}"/>
                        </div>
                    </c:if>

                    <div class="admin-profile-grid">
                        <!-- Personal Information -->
                        <section class="panel admin-profile-panel">
                            <div class="admin-profile-panel-title">
                                <i class="fa-solid fa-id-card"></i>
                                <div>
                                    <h2>Personal Information</h2>
                                    <p>Update your contact details below.</p>
                                </div>
                            </div>

                            <form method="post"
                                  action="<%=cp%>/admin/profile"
                                  class="admin-profile-form">

                                <input type="hidden" name="csrfToken"
                                       value="<c:out value='${csrfToken}'/>"/>

                                <input type="hidden" name="action"
                                       value="updateProfile"/>

                                <div class="admin-profile-field">
                                    <label>Username</label>
                                    <input value="<c:out value='${admin.username}'/>"
                                           readonly>
                                    <small>Username cannot be changed.</small>
                                </div>

                                <div class="admin-profile-field">
                                    <label>Role</label>
                                    <input value="<c:out value='${admin.role}'/>"
                                           readonly>
                                </div>

                                <div class="admin-profile-field">
                                    <label for="fullName">Full name</label>
                                    <input id="fullName"
                                           name="fullName"
                                           maxlength="100"
                                           required
                                           value="<c:out value='${admin.fullName}'/>">

                                    <c:if test="${not empty errors.fullName}">
                                        <small class="field-error">
                                            <c:out value="${errors.fullName}"/>
                                        </small>
                                    </c:if>
                                </div>

                                <div class="admin-profile-field">
                                    <label for="email">Email</label>
                                    <input id="email"
                                           name="email"
                                           type="email"
                                           maxlength="255"
                                           required
                                           value="<c:out value='${admin.email}'/>">

                                    <c:if test="${not empty errors.email}">
                                        <small class="field-error">
                                            <c:out value="${errors.email}"/>
                                        </small>
                                    </c:if>
                                </div>

                                <div class="admin-profile-field">
                                    <label for="phone">Phone</label>
                                    <input id="phone"
                                           name="phone"
                                           maxlength="20"
                                           required
                                           value="<c:out value='${admin.phone}'/>">

                                    <c:if test="${not empty errors.phone}">
                                        <small class="field-error">
                                            <c:out value="${errors.phone}"/>
                                        </small>
                                    </c:if>
                                </div>

                                <div class="admin-profile-field full-width">
                                    <label for="address">Address</label>
                                    <input id="address"
                                           name="address"
                                           maxlength="255"
                                           value="<c:out value='${admin.address}'/>">

                                    <c:if test="${not empty errors.address}">
                                        <small class="field-error">
                                            <c:out value="${errors.address}"/>
                                        </small>
                                    </c:if>
                                </div>

                                <div class="admin-profile-field">
                                    <label>Account status</label>
                                    <input value="<c:out value='${admin.status}'/>"
                                           readonly>
                                </div>

                                <div class="admin-profile-actions status-save-actions">
                                    <button class="admin-profile-btn" type="submit">
                                        <i class="fa-solid fa-floppy-disk"></i>
                                        Save Changes
                                    </button>
                                </div>
                            </form>
                        </section>

                        <!-- Change Password -->
                        <section class="panel admin-profile-panel">
                            <div class="admin-profile-panel-title">
                                <i class="fa-solid fa-shield-halved"></i>
                                <div>
                                    <h2>Change Password</h2>
                                    <p>Confirm your current password to set a new one.</p>
                                </div>
                            </div>

                            <c:if test="${not empty passwordError}">
                                <div class="profile-alert error">
                                    <c:out value="${passwordError}"/>
                                </div>
                            </c:if>

                            <form method="post"
                                  action="<%=cp%>/admin/profile"
                                  class="admin-profile-form password-form">

                                <input type="hidden" name="csrfToken"
                                       value="<c:out value='${csrfToken}'/>"/>

                                <input type="hidden" name="action"
                                       value="changePassword"/>

                                <div class="admin-profile-field full-width">
                                    <label for="currentPassword">
                                        Current password
                                    </label>
                                    <input id="currentPassword"
                                           name="currentPassword"
                                           type="password"
                                           autocomplete="current-password"
                                           required>
                                </div>

                                <div class="admin-profile-field full-width">
                                    <label for="newPassword">New password</label>
                                    <input id="newPassword"
                                           name="newPassword"
                                           type="password"
                                           minlength="8"
                                           maxlength="72"
                                           autocomplete="new-password"
                                           required>
                                    <small>Use 8–72 characters.</small>
                                </div>

                                <div class="admin-profile-field full-width">
                                    <label for="confirmPassword">
                                        Confirm new password
                                    </label>
                                    <input id="confirmPassword"
                                           name="confirmPassword"
                                           type="password"
                                           minlength="8"
                                           maxlength="72"
                                           autocomplete="new-password"
                                           required>
                                </div>

                                <div class="admin-profile-actions">
                                    <button class="admin-profile-btn" type="submit">
                                        <i class="fa-solid fa-key"></i>
                                        Change Password
                                    </button>
                                </div>
                            </form>
                        </section>
                    </div>
                </section>
            </main>
        </div>
    </body>
</html>