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

<body class="bg-gray-50 min-h-screen">

    <!-- ================= HEADER ================= -->

    <header class="bg-white border-b">

        <div class="max-w-7xl mx-auto px-6 py-4">

            <div class="flex items-center justify-between">

                <!-- Logo -->
                <a href="${pageContext.request.contextPath}/"
                   class="text-2xl font-bold text-[#ff7043]">

                    Light Ticket

                </a>

                <!-- User -->
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

                    <div>

                        <p class="text-sm font-semibold text-gray-800">
                            ${user.fullName}
                        </p>

                        <p class="text-xs text-gray-500">
                            Customer
                        </p>

                    </div>

                </div>

            </div>

        </div>

    </header>


    <!-- ================= MAIN ================= -->

    <main class="max-w-5xl mx-auto px-6 py-10">

        <!-- Page title -->

        <div class="mb-8">

            <h1 class="text-3xl font-bold text-gray-800">
                Hồ sơ cá nhân
            </h1>

            <p class="text-gray-500 mt-2">
                Xem thông tin tài khoản của bạn
            </p>

        </div>


        <!-- ================= PROFILE CARD ================= -->

        <div class="bg-white rounded-2xl shadow-sm border overflow-hidden">


            <!-- Profile header -->

            <div class="bg-gradient-to-r
                        from-[#ff7043]
                        to-[#ff8a65]
                        px-8 py-8">

                <div class="flex items-center gap-5">

                    <!-- Avatar -->

                    <div class="w-20 h-20
                                rounded-full
                                bg-white
                                flex items-center
                                justify-center
                                shadow">

                        <span class="material-symbols-outlined
                                     text-5xl
                                     text-[#ff7043]">

                            person

                        </span>

                    </div>


                    <!-- Name -->

                    <div class="text-white">

                        <h2 class="text-2xl font-bold">

                            ${user.fullName}

                        </h2>

                        <p class="mt-1 opacity-90">

                            @${user.username}

                        </p>

                    </div>

                </div>

            </div>


            <!-- ================= PROFILE CONTENT ================= -->

            <div class="p-8">


                <!-- Section title -->

                <div class="flex items-center justify-between mb-6">

                    <div>

                        <h3 class="text-xl font-bold text-gray-800">

                            Thông tin cá nhân

                        </h3>

                        <p class="text-sm text-gray-500 mt-1">

                            Thông tin tài khoản hiện tại

                        </p>

                    </div>


                    <!-- EDIT BUTTON -->

                    <a
                        href="${pageContext.request.contextPath}/UpdateCustomerProfileController"
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

                        <span class="material-symbols-outlined text-lg">

                            edit

                        </span>

                        <span>

                            Chỉnh sửa thông tin

                        </span>

                    </a>

                </div>


                <!-- ================= INFORMATION GRID ================= -->

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">


                    <!-- Full Name -->

                    <div>

                        <label class="block
                                      text-sm
                                      font-medium
                                      text-gray-600
                                      mb-2">

                            Họ và tên

                        </label>

                        <div class="w-full
                                    px-4 py-3
                                    bg-gray-50
                                    border
                                    rounded-lg
                                    text-gray-800">

                            ${user.fullName}

                        </div>

                    </div>


                    <!-- Username -->

                    <div>

                        <label class="block
                                      text-sm
                                      font-medium
                                      text-gray-600
                                      mb-2">

                            Tên đăng nhập

                        </label>

                        <div class="w-full
                                    px-4 py-3
                                    bg-gray-50
                                    border
                                    rounded-lg
                                    text-gray-800">

                            ${user.username}

                        </div>

                    </div>


                    <!-- Email -->

                    <div>

                        <label class="block
                                      text-sm
                                      font-medium
                                      text-gray-600
                                      mb-2">

                            Email

                        </label>

                        <div class="w-full
                                    px-4 py-3
                                    bg-gray-50
                                    border
                                    rounded-lg
                                    text-gray-800">

                            ${user.email}

                        </div>

                    </div>


                    <!-- Phone -->

                    <div>

                        <label class="block
                                      text-sm
                                      font-medium
                                      text-gray-600
                                      mb-2">

                            Số điện thoại

                        </label>

                        <div class="w-full
                                    px-4 py-3
                                    bg-gray-50
                                    border
                                    rounded-lg
                                    text-gray-800">

                            ${empty user.phone ? "Chưa cập nhật" : user.phone}

                        </div>

                    </div>


                    <!-- Address -->

                    <div class="md:col-span-2">

                        <label class="block
                                      text-sm
                                      font-medium
                                      text-gray-600
                                      mb-2">

                            Địa chỉ

                        </label>

                        <div class="w-full
                                    px-4 py-3
                                    bg-gray-50
                                    border
                                    rounded-lg
                                    text-gray-800">

                            ${empty user.address ? "Chưa cập nhật" : user.address}

                        </div>

                    </div>


                    <!-- Role -->

                    <div>

                        <label class="block
                                      text-sm
                                      font-medium
                                      text-gray-600
                                      mb-2">

                            Vai trò

                        </label>

                        <div class="w-full
                                    px-4 py-3
                                    bg-gray-50
                                    border
                                    rounded-lg
                                    text-gray-800">

                            ${user.role}

                        </div>

                    </div>


                    <!-- Status -->

                    <div>

                        <label class="block
                                      text-sm
                                      font-medium
                                      text-gray-600
                                      mb-2">

                            Trạng thái

                        </label>

                        <div class="flex items-center gap-2
                                    w-full
                                    px-4 py-3
                                    bg-gray-50
                                    border
                                    rounded-lg">

                            <span class="w-2.5 h-2.5
                                         rounded-full
                                         bg-green-500">
                            </span>

                            <span class="text-gray-800">

                                ${user.status}

                            </span>

                        </div>

                    </div>

                </div>

            </div>

        </div>

    </main>


    <!-- ================= JAVASCRIPT ================= -->

    <script>

        function showToast(message) {

            const toast =
                document.createElement("div");

            toast.className =
                "fixed bottom-6 right-6 " +
                "bg-gray-900 text-white " +
                "px-5 py-3 rounded-lg shadow-lg " +
                "text-sm z-50";

            toast.textContent = message;

            document.body.appendChild(toast);

            setTimeout(function () {

                toast.remove();

            }, 3000);

        }

    </script>

</body>

</html>