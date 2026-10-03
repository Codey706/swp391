<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="vi">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Chỉnh sửa hồ sơ - Light Ticket</title>

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

                <a href="${pageContext.request.contextPath}/CustomerProfileController"
                   class="text-2xl font-bold text-[#ff7043]">

                    Light Ticket

                </a>

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

    <main class="max-w-3xl mx-auto px-6 py-10">


        <!-- Page title -->

        <div class="mb-8">

            <div class="flex items-center gap-3 mb-2">

                <a
                    href="${pageContext.request.contextPath}/CustomerProfileController"
                    class="text-gray-500 hover:text-[#ff7043]">

                    <span class="material-symbols-outlined">

                        arrow_back

                    </span>

                </a>

                <h1 class="text-3xl font-bold text-gray-800">

                    Chỉnh sửa hồ sơ

                </h1>

            </div>

            <p class="text-gray-500">

                Cập nhật thông tin cá nhân của bạn

            </p>

        </div>


        <!-- ================= FORM ================= -->

        <div class="bg-white
                    rounded-2xl
                    shadow-sm
                    border
                    p-8">


            <form
                action="${pageContext.request.contextPath}/UpdateCustomerProfileController"
                method="post">


                <!-- ================= FULL NAME ================= -->

                <div class="mb-6">

                    <label
                        for="fullName"
                        class="block
                               text-sm
                               font-semibold
                               text-gray-700
                               mb-2">

                        Họ và tên

                    </label>

                    <input
                        type="text"
                        id="fullName"
                        name="fullName"
                        value="${user.fullName}"
                        required
                        class="w-full
                               px-4 py-3
                               border
                               rounded-lg
                               outline-none
                               focus:ring-2
                               focus:ring-[#ff7043]">

                </div>


                <!-- ================= USERNAME ================= -->

                <div class="mb-6">

                    <label
                        for="username"
                        class="block
                               text-sm
                               font-semibold
                               text-gray-700
                               mb-2">

                        Tên đăng nhập

                    </label>

                    <input
                        type="text"
                        id="username"
                        value="${user.username}"
                        disabled
                        class="w-full
                               px-4 py-3
                               border
                               rounded-lg
                               bg-gray-100
                               text-gray-500
                               cursor-not-allowed">

                    <p class="text-xs text-gray-500 mt-2">

                        Tên đăng nhập không thể thay đổi.

                    </p>

                </div>


                <!-- ================= EMAIL ================= -->

                <div class="mb-6">

                    <label
                        for="email"
                        class="block
                               text-sm
                               font-semibold
                               text-gray-700
                               mb-2">

                        Email

                    </label>

                    <input
                        type="email"
                        id="email"
                        name="email"
                        value="${user.email}"
                        required
                        class="w-full
                               px-4 py-3
                               border
                               rounded-lg
                               outline-none
                               focus:ring-2
                               focus:ring-[#ff7043]">

                </div>


                <!-- ================= PHONE ================= -->

                <div class="mb-6">

                    <label
                        for="phone"
                        class="block
                               text-sm
                               font-semibold
                               text-gray-700
                               mb-2">

                        Số điện thoại

                    </label>

                    <input
                        type="text"
                        id="phone"
                        name="phone"
                        value="${user.phone}"
                        class="w-full
                               px-4 py-3
                               border
                               rounded-lg
                               outline-none
                               focus:ring-2
                               focus:ring-[#ff7043]">

                </div>


                <!-- ================= ADDRESS ================= -->

                <div class="mb-8">

                    <label
                        for="address"
                        class="block
                               text-sm
                               font-semibold
                               text-gray-700
                               mb-2">

                        Địa chỉ

                    </label>

                    <textarea
                        id="address"
                        name="address"
                        rows="3"
                        class="w-full
                               px-4 py-3
                               border
                               rounded-lg
                               outline-none
                               resize-none
                               focus:ring-2
                               focus:ring-[#ff7043]">${user.address}</textarea>

                </div>


                <!-- ================= BUTTONS ================= -->

                <div class="flex items-center
                            justify-end
                            gap-3">


                    <!-- Cancel -->

                    <a
                        href="${pageContext.request.contextPath}/CustomerProfileController"
                        class="px-5 py-3
                               rounded-lg
                               border
                               border-gray-300
                               text-gray-700
                               font-semibold
                               hover:bg-gray-100
                               transition">

                        Hủy

                    </a>


                    <!-- Save -->

                    <button
                        type="submit"
                        class="flex items-center
                               gap-2
                               px-5 py-3
                               rounded-lg
                               bg-[#ff7043]
                               hover:bg-[#ac3509]
                               text-white
                               font-semibold
                               transition">

                        <span class="material-symbols-outlined">

                            save

                        </span>

                        Lưu thay đổi

                    </button>

                </div>

            </form>

        </div>

    </main>

</body>

</html>