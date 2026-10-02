<%-- 
    Document   : profile
    Created on : Oct 2, 2026, 6:58:46 PM
    Author     : TRUC MAI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Light Ticket - Hồ sơ cá nhân</title>

    <!-- Google Font -->
    <link rel="preconnect"
          href="https://fonts.googleapis.com">

    <link rel="preconnect"
          href="https://fonts.gstatic.com"
          crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap"
          rel="stylesheet">

    <!-- Material Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0"
          rel="stylesheet">

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>

    <script>
        tailwind.config = {
            theme: {
                extend: {

                    colors: {
                        primary: "#ac3509",
                        primaryContainer: "#ff7043",

                        surface: "#f8f9ff",
                        surfaceContainer: "#e9eefa",
                        surfaceContainerLow: "#eff4ff",
                        surfaceContainerLowest: "#ffffff",

                        onSurface: "#161c24",
                        onSurfaceVariant: "#59413a",

                        outline: "#8d7169",

                        tertiary: "#934a2a",
                        tertiaryFixed: "#ffdbce"
                    },

                    fontFamily: {
                        jakarta: [
                            "Plus Jakarta Sans",
                            "sans-serif"
                        ]
                    }
                }
            }
        };
    </script>

    <style>

        html,
        body {
            margin: 0;
            padding: 0;
        }

        body {
            font-family: "Plus Jakarta Sans", sans-serif;
            background: #f8f9ff;
            color: #161c24;
        }

        ::-webkit-scrollbar {
            display: none;
        }

        .material-symbols-outlined {
            font-variation-settings:
                'FILL' 0,
                'wght' 400,
                'GRAD' 0,
                'opsz' 24;
        }

        .toast-show {
            transform: translateY(0) !important;
            opacity: 1 !important;
            pointer-events: auto !important;
        }

    </style>

</head>


<body class="bg-[#f8f9ff] text-[#161c24]">


<!-- =========================================================
     HEADER
========================================================= -->

<header
    class="fixed top-0 left-0 right-0 z-50
           bg-[#f8f9ff]/90 backdrop-blur-xl
           shadow-[0_1px_8px_rgba(0,0,0,0.04)]">

    <div
        class="h-20 w-full px-6 lg:px-12
               flex items-center justify-between gap-6">

        <!-- LOGO -->
        <div class="flex items-center gap-10">

            <a href="#"
               class="flex items-center gap-2">

                <div
                    class="w-9 h-9 rounded-lg
                           bg-[#ff7043]
                           flex items-center justify-center">

                    <span
                        class="material-symbols-outlined text-white">
                        confirmation_number
                    </span>

                </div>

                <span
                    class="text-2xl font-bold tracking-tight">
                    Light Ticket
                </span>

            </a>


            <!-- NAVIGATION -->
            <nav class="hidden xl:flex items-center gap-2">

                <a href="#"
                   class="px-4 py-2 rounded-lg
                          text-sm font-semibold
                          text-[#59413a]
                          hover:bg-[#e9eefa]
                          transition">
                    Sự kiện
                </a>

                <a href="#"
                   class="px-4 py-2 rounded-lg
                          text-sm font-semibold
                          text-[#59413a]
                          hover:bg-[#e9eefa]
                          transition">
                    Địa điểm
                </a>

                <a href="#"
                   class="px-4 py-2 rounded-lg
                          text-sm font-semibold
                          text-[#59413a]
                          hover:bg-[#e9eefa]
                          transition">
                    Tin tức
                </a>

                <a href="#"
                   class="px-4 py-2 rounded-lg
                          text-sm font-semibold
                          bg-[#ff7043]
                          text-white">
                    Vé của tôi
                </a>

            </nav>

        </div>


        <!-- SEARCH -->
        <div class="flex-1 max-w-md hidden md:block">

            <div class="relative flex items-center">

                <span
                    class="material-symbols-outlined
                           absolute left-4
                           text-[#8d7169]
                           pointer-events-none">
                    search
                </span>

                <input
                    type="text"
                    placeholder="Tìm kiếm buổi hòa nhạc, lễ hội, rạp hát..."
                    class="w-full
                           bg-white
                           pl-11 pr-4 py-2.5
                           rounded-lg
                           text-sm
                           outline-none
                           focus:ring-2
                           focus:ring-[#ff7043]
                           shadow-sm">

            </div>

        </div>


        <!-- HEADER RIGHT -->
        <div class="flex items-center gap-3">

            <!-- Theme -->
            <button
                type="button"
                class="p-2 rounded-full
                       text-[#59413a]
                       hover:bg-[#e9eefa]
                       transition">

                <span class="material-symbols-outlined">
                    light_mode
                </span>

            </button>


            <!-- Notification -->
            <button
                type="button"
                class="relative p-2 rounded-full
                       text-[#59413a]
                       hover:bg-[#e9eefa]
                       transition">

                <span class="material-symbols-outlined">
                    notifications
                </span>

                <span
                    class="absolute top-1 right-1
                           w-2 h-2
                           rounded-full
                           bg-[#ff7043]">
                </span>

            </button>


            <!-- Avatar -->
            <div
                class="w-9 h-9 rounded-full
                       bg-[#ac3509]
                       flex items-center justify-center">

                <span
                    class="material-symbols-outlined text-white">
                    person
                </span>

            </div>

        </div>

    </div>

</header>



<!-- =========================================================
     MAIN
========================================================= -->

<main class="pt-20 min-h-screen">


    <!-- PAGE CONTAINER -->

    <div
        class="w-full
               px-5 lg:px-12
               py-10">


        <div
            class="grid
                   grid-cols-1
                   lg:grid-cols-12
                   gap-6">


            <!-- =================================================
                 LEFT COLUMN
            ================================================== -->

            <aside
                class="lg:col-span-4 xl:col-span-3
                       flex flex-col gap-6">


                <!-- PROFILE SUMMARY -->

                <div
                    class="bg-white
                           rounded-xl
                           p-6
                           shadow-sm
                           flex flex-col
                           items-center
                           text-center
                           relative
                           overflow-hidden">


                    <!-- Background decoration -->

                    <div
                        class="absolute
                               -top-12
                               -right-12
                               w-32 h-32
                               rounded-full
                               bg-[#ff7043]/10
                               blur-2xl">
                    </div>


                    <!-- AVATAR -->

                    <div class="relative mb-5">

                        <div
                            class="w-24 h-24
                                   rounded-full
                                   bg-[#ff7043]
                                   flex items-center
                                   justify-center
                                   shadow-md
                                   ring-4
                                   ring-[#ffdbce]">

                            <span
                                class="material-symbols-outlined
                                       text-white
                                       text-[48px]">
                                person
                            </span>

                        </div>


                        <!-- GOLD BADGE -->

                        <div
                            class="absolute
                                   -bottom-2
                                   left-1/2
                                   -translate-x-1/2
                                   flex items-center
                                   gap-1
                                   bg-gradient-to-r
                                   from-amber-500
                                   to-amber-600
                                   text-white
                                   text-xs
                                   font-semibold
                                   px-3 py-1
                                   rounded-full
                                   shadow-sm
                                   whitespace-nowrap">

                            <span
                                class="material-symbols-outlined text-sm">
                                stars
                            </span>

                            Gold Member

                        </div>

                    </div>


                    <!-- NAME -->

                    <h2
                        class="text-xl
                               font-semibold
                               mt-2">

                        ${user.fullName}

                    </h2>


                    <!-- EMAIL -->

                    <p
                        class="text-sm
                               text-[#59413a]
                               flex items-center
                               gap-1
                               mt-1">

                        <span
                            class="material-symbols-outlined text-base">
                            mail
                        </span>

                        ${user.email}

                    </p>


                    <!-- PHONE -->

                    <p
                        class="text-sm
                               text-[#59413a]
                               flex items-center
                               gap-1">

                        <span
                            class="material-symbols-outlined text-base">
                            call
                        </span>

                        ${user.phone}

                    </p>


                    <!-- JOIN DATE -->

                    <div
                        class="w-full
                               mt-5
                               px-4 py-3
                               bg-[#eff4ff]
                               rounded-lg
                               flex items-center
                               justify-between">

                        <span
                            class="text-sm
                                   text-[#59413a]">

                            Gia nhập:

                        </span>

                        <span
                            class="text-sm
                                   font-semibold">

                            Thành viên

                        </span>

                    </div>


                    <!-- QUICK STATS -->

                    <div
                        class="grid
                               grid-cols-3
                               gap-1
                               w-full
                               mt-4">


                        <div
                            class="bg-[#eff4ff]
                                   p-3
                                   rounded-lg
                                   flex flex-col
                                   items-center">

                            <span
                                class="text-xl
                                       font-bold
                                       text-[#ac3509]">

                                12

                            </span>

                            <span
                                class="text-[11px]
                                       text-[#59413a]">

                                Vé đã mua

                            </span>

                        </div>


                        <div
                            class="bg-[#eff4ff]
                                   p-3
                                   rounded-lg
                                   flex flex-col
                                   items-center">

                            <span
                                class="text-xl
                                       font-bold
                                       text-[#ff7043]">

                                3

                            </span>

                            <span
                                class="text-[11px]
                                       text-[#59413a]">

                                Sắp tới

                            </span>

                        </div>


                        <div
                            class="bg-[#eff4ff]
                                   p-3
                                   rounded-lg
                                   flex flex-col
                                   items-center">

                            <span
                                class="text-xl
                                       font-bold
                                       text-[#934a2a]">

                                1.250

                            </span>

                            <span
                                class="text-[11px]
                                       text-[#59413a]">

                                Điểm tích

                            </span>

                        </div>

                    </div>

                </div>



                <!-- =================================================
                     PROFILE MENU
                ================================================== -->

                <nav
                    class="bg-white
                           rounded-xl
                           p-2
                           shadow-sm
                           flex flex-col
                           gap-1">


                    <!-- ACTIVE -->

                    <button
                        type="button"
                        class="profile-tab
                               w-full
                               flex items-center
                               justify-between
                               px-4 py-3
                               rounded-lg
                               bg-[#ff7043]
                               text-white
                               text-sm
                               font-semibold">

                        <div class="flex items-center gap-2">

                            <span
                                class="material-symbols-outlined text-xl">
                                person
                            </span>

                            <span>
                                Thông tin cá nhân
                            </span>

                        </div>

                        <span
                            class="material-symbols-outlined text-lg">
                            chevron_right
                        </span>

                    </button>


                    <!-- TICKETS -->

                    <button
                        type="button"
                        class="profile-tab
                               w-full
                               flex items-center
                               justify-between
                               px-4 py-3
                               rounded-lg
                               text-[#59413a]
                               text-sm
                               font-semibold
                               hover:bg-[#e9eefa]
                               transition">

                        <div class="flex items-center gap-2">

                            <span
                                class="material-symbols-outlined text-xl">
                                confirmation_number
                            </span>

                            <span>
                                Vé của tôi
                            </span>

                        </div>

                        <span
                            class="bg-[#ffdbce]
                                   text-[#7f2b01]
                                   px-2
                                   py-0.5
                                   rounded-full
                                   text-xs">

                            3

                        </span>

                    </button>


                    <!-- ORDERS -->

                    <button
                        type="button"
                        class="profile-tab
                               w-full
                               flex items-center
                               justify-between
                               px-4 py-3
                               rounded-lg
                               text-[#59413a]
                               text-sm
                               font-semibold
                               hover:bg-[#e9eefa]
                               transition">

                        <div class="flex items-center gap-2">

                            <span
                                class="material-symbols-outlined text-xl">
                                receipt_long
                            </span>

                            <span>
                                Lịch sử giao dịch & Hóa đơn
                            </span>

                        </div>

                        <span
                            class="material-symbols-outlined text-lg">
                            chevron_right
                        </span>

                    </button>


                    <!-- SAVED -->

                    <button
                        type="button"
                        class="profile-tab
                               w-full
                               flex items-center
                               justify-between
                               px-4 py-3
                               rounded-lg
                               text-[#59413a]
                               text-sm
                               font-semibold
                               hover:bg-[#e9eefa]
                               transition">

                        <div class="flex items-center gap-2">

                            <span
                                class="material-symbols-outlined text-xl">
                                bookmark
                            </span>

                            <span>
                                Sự kiện đã lưu
                            </span>

                        </div>

                        <span
                            class="bg-[#e9eefa]
                                   text-[#59413a]
                                   px-2
                                   py-0.5
                                   rounded-full
                                   text-xs">

                            5

                        </span>

                    </button>


                    <!-- REWARD -->

                    <button
                        type="button"
                        class="profile-tab
                               w-full
                               flex items-center
                               justify-between
                               px-4 py-3
                               rounded-lg
                               text-[#59413a]
                               text-sm
                               font-semibold
                               hover:bg-[#e9eefa]
                               transition">

                        <div class="flex items-center gap-2">

                            <span
                                class="material-symbols-outlined text-xl">
                                loyalty
                            </span>

                            <span>
                                Điểm thưởng & Voucher
                            </span>

                        </div>

                        <span
                            class="bg-[#ff7043]/10
                                   text-[#ac3509]
                                   px-2
                                   py-0.5
                                   rounded-full
                                   text-xs">

                            1.250 pts

                        </span>

                    </button>


                    <!-- SECURITY -->

                    <button
                        type="button"
                        class="profile-tab
                               w-full
                               flex items-center
                               justify-between
                               px-4 py-3
                               rounded-lg
                               text-[#59413a]
                               text-sm
                               font-semibold
                               hover:bg-[#e9eefa]
                               transition">

                        <div class="flex items-center gap-2">

                            <span
                                class="material-symbols-outlined text-xl">
                                shield
                            </span>

                            <span>
                                Bảo mật & Đổi mật khẩu
                            </span>

                        </div>

                        <span
                            class="material-symbols-outlined text-lg">
                            chevron_right
                        </span>

                    </button>

                </nav>

            </aside>



            <!-- =================================================
                 RIGHT COLUMN
            ================================================== -->

            <section
                class="lg:col-span-8 xl:col-span-9
                       flex flex-col gap-6">


                <!-- =================================================
                     ACCOUNT INFORMATION
                ================================================== -->

                <section
                    class="bg-white
                           rounded-xl
                           p-6
                           shadow-sm">


                    <!-- TITLE -->

                    <div
                        class="flex flex-col
                               sm:flex-row
                               sm:items-center
                               justify-between
                               gap-4
                               mb-6">

                        <div>

                            <h1
                                class="text-2xl
                                       font-bold">

                                Thông tin tài khoản

                            </h1>

                            <p
                                class="text-sm
                                       text-[#59413a]
                                       mt-1">

                                Quản lý thông tin cá nhân của bạn.

                            </p>

                        </div>


                        <!-- EDIT BUTTON -->

                        <button
                            type="button"
                            id="toggleEditBtn"
                            class="flex items-center
                                   justify-center
                                   gap-2
                                   px-4 py-2.5
                                   rounded-lg
                                   bg-[#ff7043]
                                   hover:bg-[#ac3509]
                                   text-white
                                   text-sm
                                   font-semibold
                                   transition">

                            <span
                                id="editIcon"
                                class="material-symbols-outlined text-lg">
                                edit
                            </span>

                            <span id="editText">
                                Chỉnh sửa thông tin
                            </span>

                        </button>

                    </div>



                    <!-- PROFILE FORM -->

                    <form
                        id="profileForm"
                        method="post"
                        action="${pageContext.request.contextPath}/CustomerProfileController">


                        <div
                            class="grid
                                   grid-cols-1
                                   md:grid-cols-2
                                   gap-5">


                            <!-- FULL NAME -->

                            <div>

                                <label
                                    class="block
                                           text-sm
                                           font-semibold
                                           mb-2">

                                    Họ và tên

                                </label>

                                <input
                                    id="fullName"
                                    name="fullName"
                                    type="text"
                                    value="${user.fullName}"
                                    disabled
                                    class="form-input
                                           w-full
                                           px-4 py-3
                                           rounded-lg
                                           bg-[#eff4ff]
                                           border-0
                                           text-sm
                                           outline-none
                                           transition
                                           disabled:cursor-not-allowed">

                            </div>


                            <!-- USERNAME -->

                            <div>

                                <label
                                    class="block
                                           text-sm
                                           font-semibold
                                           mb-2">

                                    Tên đăng nhập

                                </label>

                                <input
                                    id="username"
                                    name="username"
                                    type="text"
                                    value="${user.username}"
                                    disabled
                                    class="form-input
                                           w-full
                                           px-4 py-3
                                           rounded-lg
                                           bg-[#eff4ff]
                                           border-0
                                           text-sm
                                           outline-none
                                           transition
                                           disabled:cursor-not-allowed">

                            </div>


                            <!-- EMAIL -->

                            <div>

                                <label
                                    class="block
                                           text-sm
                                           font-semibold
                                           mb-2">

                                    Email

                                </label>

                                <input
                                    id="email"
                                    name="email"
                                    type="email"
                                    value="${user.email}"
                                    disabled
                                    class="form-input
                                           w-full
                                           px-4 py-3
                                           rounded-lg
                                           bg-[#eff4ff]
                                           border-0
                                           text-sm
                                           outline-none
                                           transition
                                           disabled:cursor-not-allowed">

                            </div>


                            <!-- PHONE -->

                            <div>

                                <label
                                    class="block
                                           text-sm
                                           font-semibold
                                           mb-2">

                                    Số điện thoại

                                </label>

                                <input
                                    id="phone"
                                    name="phone"
                                    type="text"
                                    value="${user.phone}"
                                    disabled
                                    class="form-input
                                           w-full
                                           px-4 py-3
                                           rounded-lg
                                           bg-[#eff4ff]
                                           border-0
                                           text-sm
                                           outline-none
                                           transition
                                           disabled:cursor-not-allowed">

                            </div>


                            <!-- ADDRESS -->

                            <div class="md:col-span-2">

                                <label
                                    class="block
                                           text-sm
                                           font-semibold
                                           mb-2">

                                    Địa chỉ

                                </label>

                                <input
                                    id="address"
                                    name="address"
                                    type="text"
                                    value="${user.address}"
                                    disabled
                                    class="form-input
                                           w-full
                                           px-4 py-3
                                           rounded-lg
                                           bg-[#eff4ff]
                                           border-0
                                           text-sm
                                           outline-none
                                           transition
                                           disabled:cursor-not-allowed">

                            </div>


                            <!-- ROLE -->

                            <div>

                                <label
                                    class="block
                                           text-sm
                                           font-semibold
                                           mb-2">

                                    Vai trò

                                </label>

                                <input
                                    type="text"
                                    value="${user.role}"
                                    disabled
                                    class="w-full
                                           px-4 py-3
                                           rounded-lg
                                           bg-[#eff4ff]
                                           border-0
                                           text-sm
                                           outline-none">

                            </div>


                            <!-- STATUS -->

                            <div>

                                <label
                                    class="block
                                           text-sm
                                           font-semibold
                                           mb-2">

                                    Trạng thái

                                </label>

                                <div
                                    class="flex items-center
                                           gap-2
                                           px-4 py-3
                                           rounded-lg
                                           bg-[#eff4ff]
                                           text-sm">

                                    <span
                                        class="w-2 h-2
                                               rounded-full
                                               bg-emerald-500">
                                    </span>

                                    ${user.status}

                                </div>

                            </div>

                        </div>



                        <!-- FORM ACTIONS -->

                        <div
                            id="formActions"
                            class="hidden
                                   items-center
                                   justify-end
                                   gap-3
                                   mt-6
                                   pt-5
                                   border-t
                                   border-gray-100">


                            <button
                                type="button"
                                id="cancelEditBtn"
                                class="px-5 py-2.5
                                       rounded-lg
                                       bg-[#e9eefa]
                                       text-[#59413a]
                                       text-sm
                                       font-semibold
                                       hover:bg-[#dde3ee]
                                       transition">

                                Hủy

                            </button>


                            <button
                                type="submit"
                                id="saveProfileBtn"
                                class="px-5 py-2.5
                                       rounded-lg
                                       bg-[#ff7043]
                                       text-white
                                       text-sm
                                       font-semibold
                                       hover:bg-[#ac3509]
                                       transition">

                                Lưu thay đổi

                            </button>

                        </div>

                    </form>

                </section>



                <!-- =================================================
                     VOUCHER
                ================================================== -->

                <section
                    class="bg-white
                           rounded-xl
                           p-6
                           shadow-sm">

                    <div class="mb-5">

                        <h2
                            class="text-xl
                                   font-semibold">

                            Ưu đãi dành cho bạn

                        </h2>

                        <p
                            class="text-sm
                                   text-[#59413a]
                                   mt-1">

                            Voucher và ưu đãi hiện có trong tài khoản.

                        </p>

                    </div>


                    <div
                        class="grid
                               grid-cols-1
                               md:grid-cols-2
                               gap-4">


                        <!-- VOUCHER 1 -->

                        <div
                            class="border
                                   border-[#ffdbce]
                                   bg-[#fff8f5]
                                   rounded-xl
                                   p-5
                                   flex
                                   items-center
                                   justify-between
                                   gap-4">

                            <div class="flex items-center gap-4">

                                <div
                                    class="w-12 h-12
                                           rounded-lg
                                           bg-[#ff7043]
                                           text-white
                                           flex items-center
                                           justify-center">

                                    <span
                                        class="material-symbols-outlined">
                                        confirmation_number
                                    </span>

                                </div>

                                <div>

                                    <h3
                                        class="font-semibold">

                                        Giảm 20%

                                    </h3>

                                    <p
                                        class="text-sm
                                               text-[#59413a]">

                                        Áp dụng cho sự kiện âm nhạc

                                    </p>

                                    <span
                                        class="text-xs
                                               font-bold
                                               text-[#ac3509]">

                                        LT20OFF

                                    </span>

                                </div>

                            </div>


                            <button
                                type="button"
                                class="copy-voucher-btn
                                       shrink-0
                                       px-3 py-2
                                       bg-white
                                       text-[#ac3509]
                                       rounded-lg
                                       text-xs
                                       font-semibold
                                       shadow-sm"
                                data-code="LT20OFF">

                                Sao chép

                            </button>

                        </div>



                        <!-- VOUCHER 2 -->

                        <div
                            class="border
                                   border-[#ffdbce]
                                   bg-[#fff8f5]
                                   rounded-xl
                                   p-5
                                   flex
                                   items-center
                                   justify-between
                                   gap-4">

                            <div class="flex items-center gap-4">

                                <div
                                    class="w-12 h-12
                                           rounded-lg
                                           bg-[#ff7043]
                                           text-white
                                           flex items-center
                                           justify-center">

                                    <span
                                        class="material-symbols-outlined">
                                        published_with_changes
                                    </span>

                                </div>

                                <div>

                                    <h3
                                        class="font-semibold">

                                        Miễn phí đổi vé

                                    </h3>

                                    <p
                                        class="text-sm
                                               text-[#59413a]">

                                        Áp dụng cho workshop

                                    </p>

                                    <span
                                        class="text-xs
                                               font-bold
                                               text-[#ac3509]">

                                        FREESWAP

                                    </span>

                                </div>

                            </div>


                            <button
                                type="button"
                                class="copy-voucher-btn
                                       shrink-0
                                       px-3 py-2
                                       bg-white
                                       text-[#ac3509]
                                       rounded-lg
                                       text-xs
                                       font-semibold
                                       shadow-sm"
                                data-code="FREESWAP">

                                Sao chép

                            </button>

                        </div>

                    </div>

                </section>



                <!-- =================================================
                     RECENT TICKETS
                ================================================== -->

                <section
                    class="bg-white
                           rounded-xl
                           p-6
                           shadow-sm">


                    <div
                        class="flex flex-col
                               sm:flex-row
                               sm:items-center
                               justify-between
                               gap-4
                               mb-6">

                        <div>

                            <h2
                                class="text-xl
                                       font-semibold">

                                Danh sách vé gần đây

                            </h2>

                            <p
                                class="text-sm
                                       text-[#59413a]
                                       mt-1">

                                Theo dõi các đơn đặt vé gần đây.

                            </p>

                        </div>


                        <div class="flex gap-2">

                            <button
                                type="button"
                                class="px-3 py-1.5
                                       rounded-full
                                       text-xs
                                       font-semibold
                                       bg-[#ff7043]
                                       text-white">

                                Tất cả

                            </button>

                            <button
                                type="button"
                                class="px-3 py-1.5
                                       rounded-full
                                       text-xs
                                       font-semibold
                                       bg-[#e9eefa]
                                       text-[#59413a]">

                                Đã xác nhận

                            </button>

                        </div>

                    </div>



                    <!-- TABLE -->

                    <div class="overflow-x-auto">

                        <table class="w-full text-left">

                            <thead>

                                <tr
                                    class="bg-[#eff4ff]
                                           text-[#59413a]
                                           text-xs
                                           uppercase">

                                    <th class="py-3 px-4">
                                        Sự kiện
                                    </th>

                                    <th class="py-3 px-4">
                                        Thời gian
                                    </th>

                                    <th class="py-3 px-4">
                                        Hạng vé
                                    </th>

                                    <th class="py-3 px-4">
                                        Tổng tiền
                                    </th>

                                    <th class="py-3 px-4">
                                        Trạng thái
                                    </th>

                                </tr>

                            </thead>


                            <tbody>


                                <!-- ROW 1 -->

                                <tr
                                    class="border-b
                                           border-gray-100
                                           hover:bg-[#f8f9ff]">

                                    <td class="py-4 px-4">

                                        <div
                                            class="flex items-center gap-3">

                                            <div
                                                class="w-11 h-11
                                                       rounded-lg
                                                       bg-[#ffdbce]
                                                       flex items-center
                                                       justify-center">

                                                <span
                                                    class="material-symbols-outlined
                                                           text-[#ac3509]">
                                                    music_note
                                                </span>

                                            </div>

                                            <div>

                                                <div
                                                    class="text-sm
                                                           font-semibold">

                                                    Chuyến Bay Hoàng Hôn

                                                </div>

                                                <div
                                                    class="text-xs
                                                           text-gray-500">

                                                    #LT-881920

                                                </div>

                                            </div>

                                        </div>

                                    </td>


                                    <td
                                        class="py-4 px-4
                                               text-sm
                                               text-[#59413a]">

                                        15/05/2025

                                    </td>


                                    <td class="py-4 px-4">

                                        <span
                                            class="px-2.5 py-1
                                                   rounded-full
                                                   bg-[#ff7043]/10
                                                   text-[#ac3509]
                                                   text-xs
                                                   font-semibold">

                                            VIP x2

                                        </span>

                                    </td>


                                    <td
                                        class="py-4 px-4
                                               text-sm
                                               font-semibold">

                                        3.600.000 ₫

                                    </td>


                                    <td class="py-4 px-4">

                                        <span
                                            class="inline-flex
                                                   items-center
                                                   gap-1
                                                   px-2.5 py-1
                                                   rounded-full
                                                   bg-emerald-500/10
                                                   text-emerald-600
                                                   text-xs
                                                   font-semibold">

                                            <span
                                                class="w-1.5 h-1.5
                                                       rounded-full
                                                       bg-emerald-500">
                                            </span>

                                            Đã xác nhận

                                        </span>

                                    </td>

                                </tr>



                                <!-- ROW 2 -->

                                <tr
                                    class="border-b
                                           border-gray-100
                                           hover:bg-[#f8f9ff]">

                                    <td class="py-4 px-4">

                                        <div
                                            class="flex items-center gap-3">

                                            <div
                                                class="w-11 h-11
                                                       rounded-lg
                                                       bg-[#e9eefa]
                                                       flex items-center
                                                       justify-center">

                                                <span
                                                    class="material-symbols-outlined
                                                           text-[#59413a]">
                                                    theater_comedy
                                                </span>

                                            </div>

                                            <div>

                                                <div
                                                    class="text-sm
                                                           font-semibold">

                                                    Kịch Nghệ Thuật

                                                </div>

                                                <div
                                                    class="text-xs
                                                           text-gray-500">

                                                    #LT-773412

                                                </div>

                                            </div>

                                        </div>

                                    </td>


                                    <td
                                        class="py-4 px-4
                                               text-sm
                                               text-[#59413a]">

                                        20/04/2025

                                    </td>


                                    <td class="py-4 px-4">

                                        <span
                                            class="px-2.5 py-1
                                                   rounded-full
                                                   bg-[#e9eefa]
                                                   text-[#59413a]
                                                   text-xs
                                                   font-semibold">

                                            Standard x1

                                        </span>

                                    </td>


                                    <td
                                        class="py-4 px-4
                                               text-sm
                                               font-semibold">

                                        450.000 ₫

                                    </td>


                                    <td class="py-4 px-4">

                                        <span
                                            class="inline-flex
                                                   items-center
                                                   gap-1
                                                   px-2.5 py-1
                                                   rounded-full
                                                   bg-gray-100
                                                   text-gray-600
                                                   text-xs
                                                   font-semibold">

                                            <span
                                                class="w-1.5 h-1.5
                                                       rounded-full
                                                       bg-gray-400">
                                            </span>

                                            Đã tham gia

                                        </span>

                                    </td>

                                </tr>



                                <!-- ROW 3 -->

                                <tr
                                    class="hover:bg-[#f8f9ff]">

                                    <td class="py-4 px-4">

                                        <div
                                            class="flex items-center gap-3">

                                            <div
                                                class="w-11 h-11
                                                       rounded-lg
                                                       bg-[#ffdbce]
                                                       flex items-center
                                                       justify-center">

                                                <span
                                                    class="material-symbols-outlined
                                                           text-[#ac3509]">
                                                    festival
                                                </span>

                                            </div>

                                            <div>

                                                <div
                                                    class="text-sm
                                                           font-semibold">

                                                    EDM Ignite Fest

                                                </div>

                                                <div
                                                    class="text-xs
                                                           text-gray-500">

                                                    #LT-612093

                                                </div>

                                            </div>

                                        </div>

                                    </td>


                                    <td
                                        class="py-4 px-4
                                               text-sm
                                               text-[#59413a]">

                                        08/03/2025

                                    </td>


                                    <td class="py-4 px-4">

                                        <span
                                            class="px-2.5 py-1
                                                   rounded-full
                                                   bg-[#e9eefa]
                                                   text-[#59413a]
                                                   text-xs
                                                   font-semibold">

                                            Early Bird x2

                                        </span>

                                    </td>


                                    <td
                                        class="py-4 px-4
                                               text-sm
                                               font-semibold">

                                        1.800.000 ₫

                                    </td>


                                    <td class="py-4 px-4">

                                        <span
                                            class="inline-flex
                                                   items-center
                                                   gap-1
                                                   px-2.5 py-1
                                                   rounded-full
                                                   bg-gray-100
                                                   text-gray-600
                                                   text-xs
                                                   font-semibold">

                                            <span
                                                class="w-1.5 h-1.5
                                                       rounded-full
                                                       bg-gray-400">
                                            </span>

                                            Đã tham gia

                                        </span>

                                    </td>

                                </tr>

                            </tbody>

                        </table>

                    </div>

                </section>

            </section>

        </div>

    </div>

</main>



<!-- =========================================================
     FOOTER
========================================================= -->

<footer
    class="w-full
           bg-[#eff4ff]
           mt-10">


    <div
        class="w-full
               px-6 lg:px-12
               py-12
               grid
               grid-cols-1
               md:grid-cols-2
               lg:grid-cols-5
               gap-8">


        <!-- BRAND -->

        <div class="lg:col-span-2">

            <div
                class="flex items-center gap-2
                       mb-4">

                <div
                    class="w-8 h-8
                           rounded-lg
                           bg-[#ff7043]
                           flex items-center
                           justify-center">

                    <span
                        class="material-symbols-outlined
                               text-white
                               text-lg">

                        confirmation_number

                    </span>

                </div>

                <span
                    class="text-xl
                           font-bold">

                    Light Ticket

                </span>

            </div>


            <p
                class="text-sm
                       text-[#59413a]
                       max-w-md">

                Nền tảng mua vé sự kiện trực tiếp hàng đầu:
                hòa nhạc, lễ hội âm nhạc, kịch sân khấu
                và workshop truyền cảm hứng.

            </p>

        </div>



        <!-- EXPLORE -->

        <div>

            <h3
                class="text-sm
                       font-bold
                       uppercase
                       tracking-wider
                       mb-4">

                Khám phá

            </h3>

            <div class="flex flex-col gap-2">

                <a href="#"
                   class="text-sm text-[#59413a]
                          hover:text-[#ac3509]">

                    Tất cả sự kiện

                </a>

                <a href="#"
                   class="text-sm text-[#59413a]
                          hover:text-[#ac3509]">

                    Địa điểm & Sân khấu

                </a>

                <a href="#"
                   class="text-sm text-[#59413a]
                          hover:text-[#ac3509]">

                    Cẩm nang giải trí

                </a>

                <a href="#"
                   class="text-sm text-[#59413a]
                          hover:text-[#ac3509]">

                    Vé của tôi

                </a>

            </div>

        </div>



        <!-- SUPPORT -->

        <div>

            <h3
                class="text-sm
                       font-bold
                       uppercase
                       tracking-wider
                       mb-4">

                Hỗ trợ

            </h3>

            <div class="flex flex-col gap-2">

                <a href="#"
                   class="text-sm text-[#59413a]
                          hover:text-[#ac3509]">

                    Trung tâm trợ giúp

                </a>

                <a href="#"
                   class="text-sm text-[#59413a]
                          hover:text-[#ac3509]">

                    Chính sách hoàn vé

                </a>

                <a href="#"
                   class="text-sm text-[#59413a]
                          hover:text-[#ac3509]">

                    Dành cho Ban tổ chức

                </a>

                <a href="#"
                   class="text-sm text-[#59413a]
                          hover:text-[#ac3509]">

                    Quy chế bảo mật

                </a>

            </div>

        </div>



        <!-- NEWSLETTER -->

        <div>

            <h3
                class="text-sm
                       font-bold
                       uppercase
                       tracking-wider
                       mb-4">

                Đăng ký nhận tin

            </h3>

            <p
                class="text-sm
                       text-[#59413a]
                       mb-3">

                Nhận ưu đãi vé sớm và thông báo
                sự kiện nổi bật mỗi tuần.

            </p>


            <div
                class="flex gap-2">

                <input
                    type="email"
                    placeholder="Email của bạn"
                    class="min-w-0
                           flex-1
                           px-3 py-2.5
                           rounded-lg
                           bg-white
                           border-0
                           outline-none
                           text-sm
                           focus:ring-2
                           focus:ring-[#ff7043]">

                <button
                    type="button"
                    class="px-4
                           py-2.5
                           rounded-lg
                           bg-[#ff7043]
                           hover:bg-[#ac3509]
                           text-white
                           text-sm
                           font-semibold">

                    Gửi

                </button>

            </div>

        </div>

    </div>



    <!-- COPYRIGHT -->

    <div
        class="px-6 lg:px-12
               py-4
               bg-[#e9eefa]
               flex flex-col
               md:flex-row
               items-center
               justify-between
               gap-3
               text-xs
               text-[#59413a]">

        <p>
            © 2025 Light Ticket Joint Stock Co.
            Bảo lưu mọi quyền.
        </p>

        <div class="flex gap-5">

            <a href="#">
                Điều khoản sử dụng
            </a>

            <a href="#">
                Chính sách dữ liệu
            </a>

            <a href="#">
                Liên hệ hợp tác
            </a>

        </div>

    </div>

</footer>



<!-- =========================================================
     TOAST
========================================================= -->

<div
    id="toast"
    class="fixed
           bottom-6
           right-6
           z-50
           translate-y-32
           opacity-0
           pointer-events-none
           transition-all
           duration-300
           bg-white
           rounded-xl
           shadow-xl
           px-5 py-4
           flex items-center
           gap-3">


    <div
        class="w-9 h-9
               rounded-full
               bg-emerald-500/10
               text-emerald-600
               flex items-center
               justify-center">

        <span class="material-symbols-outlined">
            check_circle
        </span>

    </div>


    <div>

        <h4
            id="toastTitle"
            class="font-semibold
                   text-sm">

            Thao tác thành công

        </h4>

        <p
            id="toastMessage"
            class="text-xs
                   text-[#59413a]">

            Dữ liệu đã được cập nhật.

        </p>

    </div>

</div>



<!-- =========================================================
     JAVASCRIPT
========================================================= -->

<script>

    // =====================================================
    // EDIT PROFILE
    // =====================================================

    const editButton =
        document.getElementById("toggleEditBtn");

    const cancelButton =
        document.getElementById("cancelEditBtn");

    const editText =
        document.getElementById("editText");

    const editIcon =
        document.getElementById("editIcon");

    const formActions =
        document.getElementById("formActions");

    const inputs =
        document.querySelectorAll(
            "#profileForm .form-input"
        );


    let isEditing = false;

    let originalValues = {};


    // Save original values

    inputs.forEach(function (input) {

        originalValues[input.id] =
            input.value;

    });



    // Change edit state

    function setEditState(editing) {

        isEditing = editing;


        inputs.forEach(function (input) {

            input.disabled = !editing;

            if (editing) {

                input.classList.remove(
                    "bg-[#eff4ff]"
                );

                input.classList.add(
                    "bg-white",
                    "ring-2",
                    "ring-[#ff7043]/30"
                );

            } else {

                input.classList.remove(
                    "bg-white",
                    "ring-2",
                    "ring-[#ff7043]/30"
                );

                input.classList.add(
                    "bg-[#eff4ff]"
                );

            }

        });


        if (editing) {

            formActions.classList.remove(
                "hidden"
            );

            formActions.classList.add(
                "flex"
            );

            editText.textContent =
                "Đang chỉnh sửa...";

            editIcon.textContent =
                "edit_note";

            if (inputs.length > 0) {
                inputs[0].focus();
            }

        } else {

            formActions.classList.add(
                "hidden"
            );

            formActions.classList.remove(
                "flex"
            );

            editText.textContent =
                "Chỉnh sửa thông tin";

            editIcon.textContent =
                "edit";

        }

    }



    // Click Edit

    if (editButton) {

        editButton.addEventListener(
            "click",
            function () {

                setEditState(!isEditing);

            }
        );

    }



    // Cancel

    if (cancelButton) {

        cancelButton.addEventListener(
            "click",
            function () {

                inputs.forEach(
                    function (input) {

                        if (
                            originalValues[input.id]
                            !== undefined
                        ) {

                            input.value =
                                originalValues[input.id];

                        }

                    }
                );


                setEditState(false);


                showToast(
                    "Đã hủy thao tác",
                    "Thông tin cá nhân được giữ nguyên."
                );

            }
        );

    }



    // =====================================================
    // FORM SUBMIT
    // =====================================================

    const profileForm =
        document.getElementById("profileForm");


    if (profileForm) {

        profileForm.addEventListener(
            "submit",
            function (event) {

                /*
                 * Tạm thời cho UI.
                 *
                 * Sau này khi làm task
                 * Update Customer Profile,
                 * Controller sẽ xử lý POST.
                 */

                showToast(
                    "Đang cập nhật",
                    "Thông tin đang được gửi đến hệ thống."
                );

            }
        );

    }



    // =====================================================
    // PROFILE TAB
    // =====================================================

    const profileTabs =
        document.querySelectorAll(
            ".profile-tab"
        );


    profileTabs.forEach(
        function (tab) {

            tab.addEventListener(
                "click",
                function () {

                    profileTabs.forEach(
                        function (item) {

                            item.classList.remove(
                                "bg-[#ff7043]",
                                "text-white"
                            );

                            item.classList.add(
                                "text-[#59413a]"
                            );

                        }
                    );


                    tab.classList.remove(
                        "text-[#59413a]"
                    );

                    tab.classList.add(
                        "bg-[#ff7043]",
                        "text-white"
                    );


                    const text =
                        tab.innerText.trim();


                    showToast(
                        "Chuyển mục",
                        "Bạn đã chọn: " + text
                    );

                }
            );

        }
    );



    // =====================================================
    // COPY VOUCHER
    // =====================================================

    const voucherButtons =
        document.querySelectorAll(
            ".copy-voucher-btn"
        );


    voucherButtons.forEach(
        function (button) {

            button.addEventListener(
                "click",
                function () {

                    const code =
                        button.dataset.code;


                    if (
                        navigator.clipboard
                    ) {

                        navigator.clipboard
                            .writeText(code);

                    }


                    showToast(
                        "Đã sao chép mã",
                        "Mã " + code +
                        " đã được sao chép."
                    );

                }
            );

        }
    );



    // =====================================================
    // TOAST
    // =====================================================

    function showToast(title, message) {

        const toast =
            document.getElementById("toast");

        const toastTitle =
            document.getElementById("toastTitle");

        const toastMessage =
            document.getElementById("toastMessage");


        toastTitle.textContent =
            title;

        toastMessage.textContent =
            message;


        toast.classList.add(
            "toast-show"
        );


        setTimeout(
            function () {

                toast.classList.remove(
                    "toast-show"
                );

            },
            3000
        );

    }

</script>


</body>
</html>