<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="vi">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>My Profile - Light Ticket</title>

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Material Symbols -->
    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">

</head>


<body class="bg-[#f8f9fc] min-h-screen text-gray-800">


<!-- =========================================================
     HEADER
========================================================= -->

<header class="bg-white border-b border-gray-100 sticky top-0 z-40">

    <div class="max-w-7xl mx-auto px-6 lg:px-10">

        <div class="h-20 flex items-center justify-between">

            <!-- LOGO -->

            <a href="${pageContext.request.contextPath}/"
               class="flex items-center gap-3">

                <div class="w-10 h-10
                            rounded-xl
                            bg-[#ff7043]
                            flex items-center
                            justify-center
                            shadow-sm">

                    <span class="material-symbols-outlined text-white">
                        confirmation_number
                    </span>

                </div>

                <div>

                    <div class="text-xl font-bold text-gray-900">
                        Light Ticket
                    </div>

                    <div class="text-xs text-gray-400">
                        Event Ticket Platform
                    </div>

                </div>

            </a>


            <!-- NAVIGATION -->

            <nav class="hidden md:flex items-center gap-8">

                <a href="${pageContext.request.contextPath}/"
                   class="text-sm
                          font-medium
                          text-gray-500
                          hover:text-[#ff7043]
                          transition">

                    Trang chủ

                </a>

                <a href="#"
                   class="text-sm
                          font-medium
                          text-gray-500
                          hover:text-[#ff7043]
                          transition">

                    Sự kiện

                </a>

                <a href="#"
                   class="text-sm
                          font-medium
                          text-gray-500
                          hover:text-[#ff7043]
                          transition">

                    Vé của tôi

                </a>

                <a href="#"
                   class="text-sm
                          font-medium
                          text-[#ff7043]">

                    Hồ sơ

                </a>

            </nav>


            <!-- USER -->

            <div class="flex items-center gap-3">

                <button type="button"
                        class="hidden sm:flex
                               w-10 h-10
                               rounded-full
                               bg-gray-50
                               items-center
                               justify-center
                               hover:bg-[#fff1ec]
                               transition">

                    <span class="material-symbols-outlined text-gray-600">
                        notifications
                    </span>

                </button>


                <div class="h-9 w-px bg-gray-200 hidden sm:block"></div>


                <div class="flex items-center gap-3">

                    <div class="w-10 h-10
                                rounded-full
                                bg-[#ff7043]
                                text-white
                                flex items-center
                                justify-center">

                        <span class="material-symbols-outlined">
                            person
                        </span>

                    </div>

                    <div class="hidden sm:block">

                        <p class="text-sm font-semibold">
                            ${user.fullName}
                        </p>

                        <p class="text-xs text-gray-400">
                            ${user.role}
                        </p>

                    </div>

                </div>

            </div>

        </div>

    </div>

</header>



<!-- =========================================================
     MAIN
========================================================= -->

<main class="max-w-7xl mx-auto px-6 lg:px-10 py-10">


    <!-- PAGE HEADER -->

    <div class="mb-8">

        <div class="flex items-center gap-2
                    text-sm
                    text-gray-400
                    mb-3">

            <span>Trang chủ</span>

            <span class="material-symbols-outlined text-sm">
                chevron_right
            </span>

            <span class="text-[#ff7043]">
                Hồ sơ cá nhân
            </span>

        </div>


        <div class="flex flex-col
                    md:flex-row
                    md:items-end
                    md:justify-between
                    gap-4">

            <div>

                <h1 class="text-3xl
                           lg:text-4xl
                           font-bold
                           text-gray-900">

                    Hồ sơ cá nhân

                </h1>

                <p class="text-gray-500 mt-2">

                    Quản lý và xem thông tin tài khoản của bạn.

                </p>

            </div>

        </div>

    </div>



    <!-- =====================================================
         PROFILE LAYOUT
    ====================================================== -->

    <div class="grid
                grid-cols-1
                lg:grid-cols-12
                gap-6">


        <!-- =================================================
             LEFT SIDEBAR
        ================================================== -->

        <aside class="lg:col-span-4">


            <!-- PROFILE SUMMARY -->

            <div class="bg-white
                        rounded-2xl
                        border
                        border-gray-100
                        shadow-sm
                        overflow-hidden">


                <!-- COVER -->

                <div class="h-28
                            bg-gradient-to-r
                            from-[#ff7043]
                            to-[#ff9678]
                            relative">

                    <div class="absolute
                                -bottom-10
                                left-1/2
                                -translate-x-1/2">

                        <div class="w-20 h-20
                                    rounded-full
                                    bg-white
                                    p-1
                                    shadow-lg">

                            <div class="w-full h-full
                                        rounded-full
                                        bg-[#fff1ec]
                                        flex items-center
                                        justify-center">

                                <span class="material-symbols-outlined
                                             text-4xl
                                             text-[#ff7043]">

                                    person

                                </span>

                            </div>

                        </div>

                    </div>

                </div>


                <!-- USER INFO -->

                <div class="pt-14 px-6 pb-6 text-center">

                    <h2 class="text-xl font-bold text-gray-900">

                        ${user.fullName}

                    </h2>

                    <p class="text-sm text-gray-400 mt-1">

                        @${user.username}

                    </p>


                    <!-- STATUS -->

                    <div class="inline-flex
                                items-center
                                gap-2
                                mt-4
                                px-3 py-1.5
                                rounded-full
                                bg-emerald-50
                                text-emerald-600
                                text-xs
                                font-semibold">

                        <span class="w-2 h-2
                                     rounded-full
                                     bg-emerald-500">
                        </span>

                        ${user.status}

                    </div>


                    <!-- DIVIDER -->

                    <div class="border-t
                                border-gray-100
                                my-6">
                    </div>


                    <!-- CONTACT -->

                    <div class="space-y-4 text-left">


                        <!-- EMAIL -->

                        <div class="flex items-start gap-3">

                            <div class="w-9 h-9
                                        rounded-lg
                                        bg-[#fff1ec]
                                        flex items-center
                                        justify-center
                                        shrink-0">

                                <span class="material-symbols-outlined
                                             text-[#ff7043]
                                             text-lg">

                                    mail

                                </span>

                            </div>

                            <div class="min-w-0">

                                <p class="text-xs text-gray-400">
                                    Email
                                </p>

                                <p class="text-sm
                                          font-medium
                                          text-gray-800
                                          break-all">

                                    ${user.email}

                                </p>

                            </div>

                        </div>


                        <!-- PHONE -->

                        <div class="flex items-start gap-3">

                            <div class="w-9 h-9
                                        rounded-lg
                                        bg-[#fff1ec]
                                        flex items-center
                                        justify-center
                                        shrink-0">

                                <span class="material-symbols-outlined
                                             text-[#ff7043]
                                             text-lg">

                                    phone

                                </span>

                            </div>

                            <div>

                                <p class="text-xs text-gray-400">
                                    Số điện thoại
                                </p>

                                <p class="text-sm
                                          font-medium
                                          text-gray-800">

                                    ${empty user.phone
                                        ? "Chưa cập nhật"
                                        : user.phone}

                                </p>

                            </div>

                        </div>


                        <!-- ADDRESS -->

                        <div class="flex items-start gap-3">

                            <div class="w-9 h-9
                                        rounded-lg
                                        bg-[#fff1ec]
                                        flex items-center
                                        justify-center
                                        shrink-0">

                                <span class="material-symbols-outlined
                                             text-[#ff7043]
                                             text-lg">

                                    location_on

                                </span>

                            </div>

                            <div>

                                <p class="text-xs text-gray-400">
                                    Địa chỉ
                                </p>

                                <p class="text-sm
                                          font-medium
                                          text-gray-800">

                                    ${empty user.address
                                        ? "Chưa cập nhật"
                                        : user.address}

                                </p>

                            </div>

                        </div>

                    </div>

                </div>

            </div>



            <!-- ACCOUNT MENU -->

            <div class="bg-white
                        rounded-2xl
                        border
                        border-gray-100
                        shadow-sm
                        mt-6
                        p-3">


                <div class="px-3 py-2">

                    <p class="text-xs
                              font-semibold
                              text-gray-400
                              uppercase
                              tracking-wider">

                        Tài khoản

                    </p>

                </div>


                <!-- ACTIVE -->

                <a href="#"
                   class="flex items-center
                          gap-3
                          px-3 py-3
                          rounded-xl
                          bg-[#fff1ec]
                          text-[#ff7043]
                          font-semibold
                          text-sm">

                    <span class="material-symbols-outlined">
                        person
                    </span>

                    Thông tin cá nhân

                </a>


                <a href="#"
                   class="flex items-center
                          gap-3
                          px-3 py-3
                          rounded-xl
                          text-gray-500
                          hover:bg-gray-50
                          hover:text-[#ff7043]
                          text-sm
                          transition">

                    <span class="material-symbols-outlined">
                        confirmation_number
                    </span>

                    Vé của tôi

                </a>


                <a href="#"
                   class="flex items-center
                          gap-3
                          px-3 py-3
                          rounded-xl
                          text-gray-500
                          hover:bg-gray-50
                          hover:text-[#ff7043]
                          text-sm
                          transition">

                    <span class="material-symbols-outlined">
                        favorite
                    </span>

                    Sự kiện yêu thích

                </a>


                <a href="#"
                   class="flex items-center
                          gap-3
                          px-3 py-3
                          rounded-xl
                          text-gray-500
                          hover:bg-gray-50
                          hover:text-[#ff7043]
                          text-sm
                          transition">

                    <span class="material-symbols-outlined">
                        settings
                    </span>

                    Cài đặt

                </a>

            </div>

        </aside>



        <!-- =================================================
             RIGHT CONTENT
        ================================================== -->

        <section class="lg:col-span-8 space-y-6">


            <!-- WELCOME BANNER -->

            <div class="relative
                        overflow-hidden
                        rounded-2xl
                        bg-gradient-to-r
                        from-[#ff7043]
                        to-[#ff9678]
                        p-7
                        text-white">


                <div class="relative z-10">

                    <div class="flex items-center gap-2
                                text-sm
                                opacity-90
                                mb-2">

                        <span class="material-symbols-outlined text-lg">
                            waving_hand
                        </span>

                        Chào mừng trở lại!

                    </div>


                    <h2 class="text-2xl
                               font-bold">

                        Xin chào, ${user.fullName}!

                    </h2>


                    <p class="mt-2
                              text-sm
                              opacity-90
                              max-w-lg">

                        Đây là khu vực quản lý thông tin
                        cá nhân của bạn trên Light Ticket.

                    </p>

                </div>


                <!-- DECORATION -->

                <div class="absolute
                            -right-10
                            -bottom-16
                            w-48 h-48
                            rounded-full
                            bg-white/10">
                </div>

                <div class="absolute
                            right-20
                            -top-12
                            w-28 h-28
                            rounded-full
                            bg-white/10">
                </div>


                <span class="material-symbols-outlined
                             absolute
                             right-8
                             bottom-7
                             text-7xl
                             text-white/20">

                    confirmation_number

                </span>

            </div>



            <!-- PERSONAL INFORMATION -->

            <section class="bg-white
                            rounded-2xl
                            border
                            border-gray-100
                            shadow-sm
                            p-6 lg:p-8">


                <!-- SECTION HEADER -->

                <div class="flex flex-col
                            sm:flex-row
                            sm:items-center
                            sm:justify-between
                            gap-4
                            mb-7">


                    <div>

                        <div class="flex items-center gap-3">

                            <div class="w-10 h-10
                                        rounded-xl
                                        bg-[#fff1ec]
                                        flex items-center
                                        justify-center">

                                <span class="material-symbols-outlined
                                             text-[#ff7043]">

                                    badge

                                </span>

                            </div>

                            <div>

                                <h2 class="text-xl
                                           font-bold
                                           text-gray-900">

                                    Thông tin cá nhân

                                </h2>

                                <p class="text-sm
                                          text-gray-400
                                          mt-0.5">

                                    Thông tin tài khoản hiện tại

                                </p>

                            </div>

                        </div>

                    </div>


                    <!-- EDIT -->

                    <a href="${pageContext.request.contextPath}/UpdateCustomerProfileController"
                       class="inline-flex
                              items-center
                              justify-center
                              gap-2
                              px-4 py-2.5
                              rounded-xl
                              bg-[#ff7043]
                              hover:bg-[#e85d32]
                              text-white
                              text-sm
                              font-semibold
                              shadow-sm
                              transition">

                        <span class="material-symbols-outlined text-lg">
                            edit
                        </span>

                        Chỉnh sửa thông tin

                    </a>

                </div>



                <!-- INFORMATION GRID -->

                <div class="grid
                            grid-cols-1
                            md:grid-cols-2
                            gap-5">


                    <!-- FULL NAME -->

                    <div class="rounded-xl
                                border
                                border-gray-100
                                bg-gray-50/70
                                p-4">

                        <div class="flex items-center gap-2 mb-2">

                            <span class="material-symbols-outlined
                                         text-gray-400
                                         text-lg">

                                person

                            </span>

                            <p class="text-xs
                                      font-semibold
                                      text-gray-400
                                      uppercase">

                                Họ và tên

                            </p>

                        </div>

                        <p class="font-semibold text-gray-800">

                            ${user.fullName}

                        </p>

                    </div>



                    <!-- USERNAME -->

                    <div class="rounded-xl
                                border
                                border-gray-100
                                bg-gray-50/70
                                p-4">

                        <div class="flex items-center gap-2 mb-2">

                            <span class="material-symbols-outlined
                                         text-gray-400
                                         text-lg">

                                alternate_email

                            </span>

                            <p class="text-xs
                                      font-semibold
                                      text-gray-400
                                      uppercase">

                                Tên đăng nhập

                            </p>

                        </div>

                        <p class="font-semibold text-gray-800">

                            ${user.username}

                        </p>

                    </div>



                    <!-- EMAIL -->

                    <div class="rounded-xl
                                border
                                border-gray-100
                                bg-gray-50/70
                                p-4">

                        <div class="flex items-center gap-2 mb-2">

                            <span class="material-symbols-outlined
                                         text-gray-400
                                         text-lg">

                                mail

                            </span>

                            <p class="text-xs
                                      font-semibold
                                      text-gray-400
                                      uppercase">

                                Email

                            </p>

                        </div>

                        <p class="font-semibold
                                  text-gray-800
                                  break-all">

                            ${user.email}

                        </p>

                    </div>



                    <!-- PHONE -->

                    <div class="rounded-xl
                                border
                                border-gray-100
                                bg-gray-50/70
                                p-4">

                        <div class="flex items-center gap-2 mb-2">

                            <span class="material-symbols-outlined
                                         text-gray-400
                                         text-lg">

                                phone

                            </span>

                            <p class="text-xs
                                      font-semibold
                                      text-gray-400
                                      uppercase">

                                Số điện thoại

                            </p>

                        </div>

                        <p class="font-semibold text-gray-800">

                            ${empty user.phone
                                ? "Chưa cập nhật"
                                : user.phone}

                        </p>

                    </div>



                    <!-- ADDRESS -->

                    <div class="md:col-span-2
                                rounded-xl
                                border
                                border-gray-100
                                bg-gray-50/70
                                p-4">

                        <div class="flex items-center gap-2 mb-2">

                            <span class="material-symbols-outlined
                                         text-gray-400
                                         text-lg">

                                location_on

                            </span>

                            <p class="text-xs
                                      font-semibold
                                      text-gray-400
                                      uppercase">

                                Địa chỉ

                            </p>

                        </div>

                        <p class="font-semibold text-gray-800">

                            ${empty user.address
                                ? "Chưa cập nhật"
                                : user.address}

                        </p>

                    </div>



                    <!-- ROLE -->

                    <div class="rounded-xl
                                border
                                border-gray-100
                                bg-gray-50/70
                                p-4">

                        <div class="flex items-center gap-2 mb-2">

                            <span class="material-symbols-outlined
                                         text-gray-400
                                         text-lg">

                                manage_accounts

                            </span>

                            <p class="text-xs
                                      font-semibold
                                      text-gray-400
                                      uppercase">

                                Vai trò

                            </p>

                        </div>

                        <p class="font-semibold text-gray-800">

                            ${user.role}

                        </p>

                    </div>



                    <!-- STATUS -->

                    <div class="rounded-xl
                                border
                                border-gray-100
                                bg-gray-50/70
                                p-4">

                        <div class="flex items-center gap-2 mb-2">

                            <span class="material-symbols-outlined
                                         text-gray-400
                                         text-lg">

                                verified_user

                            </span>

                            <p class="text-xs
                                      font-semibold
                                      text-gray-400
                                      uppercase">

                                Trạng thái

                            </p>

                        </div>


                        <div class="flex items-center gap-2">

                            <span class="w-2.5 h-2.5
                                         rounded-full
                                         bg-emerald-500">
                            </span>

                            <p class="font-semibold
                                      text-emerald-600">

                                ${user.status}

                            </p>

                        </div>

                    </div>

                </div>

            </section>



            <!-- ACCOUNT SECURITY -->

            <section class="bg-white
                            rounded-2xl
                            border
                            border-gray-100
                            shadow-sm
                            p-6 lg:p-8">


                <div class="flex items-center gap-3 mb-6">

                    <div class="w-10 h-10
                                rounded-xl
                                bg-blue-50
                                flex items-center
                                justify-center">

                        <span class="material-symbols-outlined text-blue-500">
                            security
                        </span>

                    </div>

                    <div>

                        <h2 class="text-lg
                                   font-bold
                                   text-gray-900">

                            Bảo mật tài khoản

                        </h2>

                        <p class="text-sm text-gray-400">

                            Thông tin liên quan đến tài khoản của bạn.

                        </p>

                    </div>

                </div>


                <div class="grid
                            grid-cols-1
                            md:grid-cols-2
                            gap-4">


                    <div class="flex items-center
                                justify-between
                                p-4
                                rounded-xl
                                bg-gray-50
                                border
                                border-gray-100">

                        <div class="flex items-center gap-3">

                            <span class="material-symbols-outlined
                                         text-gray-500">

                                lock

                            </span>

                            <div>

                                <p class="text-sm font-semibold">
                                    Mật khẩu
                                </p>

                                <p class="text-xs text-gray-400">
                                    Được bảo vệ
                                </p>

                            </div>

                        </div>

                        <span class="text-xs
                                     font-semibold
                                     text-emerald-600">

                            Đã thiết lập

                        </span>

                    </div>


                    <div class="flex items-center
                                justify-between
                                p-4
                                rounded-xl
                                bg-gray-50
                                border
                                border-gray-100">

                        <div class="flex items-center gap-3">

                            <span class="material-symbols-outlined
                                         text-gray-500">

                                verified

                            </span>

                            <div>

                                <p class="text-sm font-semibold">
                                    Tài khoản
                                </p>

                                <p class="text-xs text-gray-400">
                                    Trạng thái hiện tại
                                </p>

                            </div>

                        </div>

                        <span class="text-xs
                                     font-semibold
                                     text-emerald-600">

                            ${user.status}

                        </span>

                    </div>

                </div>

            </section>



            <!-- QUICK ACTION -->

            <section class="bg-[#fff8f5]
                            border
                            border-[#ffe0d6]
                            rounded-2xl
                            p-6">


                <div class="flex
                            flex-col
                            sm:flex-row
                            sm:items-center
                            sm:justify-between
                            gap-4">


                    <div class="flex items-center gap-4">

                        <div class="w-12 h-12
                                    rounded-xl
                                    bg-[#ff7043]
                                    text-white
                                    flex items-center
                                    justify-center">

                            <span class="material-symbols-outlined">
                                edit_note
                            </span>

                        </div>


                        <div>

                            <h3 class="font-bold
                                       text-gray-900">

                                Cập nhật thông tin

                            </h3>

                            <p class="text-sm
                                      text-gray-500
                                      mt-1">

                                Thay đổi email, họ tên,
                                số điện thoại hoặc địa chỉ.

                            </p>

                        </div>

                    </div>


                    <a href="${pageContext.request.contextPath}/UpdateCustomerProfileController"
                       class="inline-flex
                              items-center
                              justify-center
                              gap-2
                              px-5 py-2.5
                              rounded-xl
                              bg-white
                              border
                              border-[#ff7043]
                              text-[#ff7043]
                              hover:bg-[#ff7043]
                              hover:text-white
                              text-sm
                              font-semibold
                              transition">

                        Cập nhật ngay

                        <span class="material-symbols-outlined text-lg">
                            arrow_forward
                        </span>

                    </a>

                </div>

            </section>

        </section>

    </div>

</main>



<!-- =========================================================
     FOOTER
========================================================= -->

<footer class="border-t
               border-gray-100
               bg-white
               mt-10">

    <div class="max-w-7xl
                mx-auto
                px-6 lg:px-10
                py-8">

        <div class="flex
                    flex-col
                    md:flex-row
                    md:items-center
                    md:justify-between
                    gap-4">

            <div class="flex items-center gap-2">

                <div class="w-8 h-8
                            rounded-lg
                            bg-[#ff7043]
                            flex items-center
                            justify-center">

                    <span class="material-symbols-outlined
                                 text-white
                                 text-lg">

                        confirmation_number

                    </span>

                </div>

                <span class="font-bold text-gray-800">

                    Light Ticket

                </span>

            </div>


            <p class="text-xs text-gray-400">

                © 2025 Light Ticket Joint Stock Co.
                Bảo lưu mọi quyền.

            </p>


            <div class="flex items-center gap-5">

                <a href="#"
                   class="text-xs
                          text-gray-400
                          hover:text-[#ff7043]">

                    Điều khoản

                </a>

                <a href="#"
                   class="text-xs
                          text-gray-400
                          hover:text-[#ff7043]">

                    Chính sách bảo mật

                </a>

                <a href="#"
                   class="text-xs
                          text-gray-400
                          hover:text-[#ff7043]">

                    Liên hệ

                </a>

            </div>

        </div>

    </div>

</footer>


</body>

</html>