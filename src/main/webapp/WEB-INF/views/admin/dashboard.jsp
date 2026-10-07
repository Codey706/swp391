<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Admin Dashboard</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/admin.css?v=2">
    </head>

    <body>

        <div class="layout">

            <!-- =========================
                 Sidebar
                 ========================= -->

            <aside class="sidebar">

                <div class="brand">
                    🎟 Light Ticket
                </div>

                <nav class="menu">

                    <!-- Dashboard -->
                    <a href="<%= request.getContextPath()%>/admin"
                       class="active">
                        <i class="fa-solid fa-chart-line"></i>
                        Dashboard
                    </a>

                    <!-- Users -->
                    <div class="menu-group">

                        <a href="<%= request.getContextPath()%>/admin/users">
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
                    <a href="<%= request.getContextPath()%>/admin/categories">
                        <i class="fa-solid fa-folder"></i>
                        Categories
                    </a>

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


            <!-- =========================
                 Main
                 ========================= -->

            <main class="main">

                <!-- Topbar -->
                <header class="topbar">

                    <input type="text"
                           class="search"
                           placeholder="Search...">

                    <div class="admin">
                        Admin
                    </div>

                </header>


                <!-- Content -->
                <section class="content">

                    <div class="page-heading">

                        <div>

                            <h1>Admin Dashboard</h1>

                            <p>
                                Manage your Light Ticket system
                            </p>

                        </div>

                    </div>


                    <!-- =========================
                         Dashboard Cards
                         ========================= -->

                    <div class="dashboard-grid">

                        <!-- Users -->
                        <a href="<%= request.getContextPath()%>/admin/users"
                           class="dashboard-card">

                            <div class="dashboard-icon">
                                <i class="fa-solid fa-users"></i>
                            </div>

                            <div class="dashboard-info">

                                <h2>Users</h2>

                                <p>
                                    Manage system users
                                </p>

                            </div>

                        </a>


                        <!-- Events -->
                        <a href="#"
                           class="dashboard-card">

                            <div class="dashboard-icon">
                                <i class="fa-solid fa-calendar-days"></i>
                            </div>

                            <div class="dashboard-info">

                                <h2>Events</h2>

                                <p>
                                    Manage events
                                </p>

                            </div>

                        </a>


                        <!-- Categories -->
                        <a href="<%= request.getContextPath()%>/admin/categories"
                           class="dashboard-card">

                            <div class="dashboard-icon">
                                <i class="fa-solid fa-folder"></i>
                            </div>

                            <div class="dashboard-info">

                                <h2>Categories</h2>

                                <p>
                                    Manage event categories
                                </p>

                            </div>

                        </a>


                        <!-- Venues -->
                        <a href="#"
                           class="dashboard-card">

                            <div class="dashboard-icon">
                                <i class="fa-solid fa-location-dot"></i>
                            </div>

                            <div class="dashboard-info">

                                <h2>Venues</h2>

                                <p>
                                    Manage event venues
                                </p>

                            </div>

                        </a>


                        <!-- Vouchers -->
                        <a href="#"
                           class="dashboard-card">

                            <div class="dashboard-icon">
                                <i class="fa-solid fa-ticket"></i>
                            </div>

                            <div class="dashboard-info">

                                <h2>Vouchers</h2>

                                <p>
                                    Manage vouchers
                                </p>

                            </div>

                        </a>


                        <!-- Reviews -->
                        <a href="#"
                           class="dashboard-card">

                            <div class="dashboard-icon">
                                <i class="fa-solid fa-star"></i>
                            </div>

                            <div class="dashboard-info">

                                <h2>Reviews</h2>

                                <p>
                                    Manage customer reviews
                                </p>

                            </div>

                        </a>

                    </div>

                </section>

            </main>

        </div>

    </body>
</html>