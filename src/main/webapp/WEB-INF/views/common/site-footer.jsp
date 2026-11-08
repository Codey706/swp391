<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
  Footer chung cho mọi trang công khai / khách hàng (style trong assets/css/theme.css → .sg-footer).
  Dùng: <jsp:include page="/WEB-INF/views/common/site-footer.jsp"/>
--%>
<c:set var="sfCtx" value="${pageContext.request.contextPath}"/>
<footer class="sg-footer">
    <div class="sg-footer-inner">
        <div class="sg-footer-grid">
            <div class="sg-footer-col-brand">
                <a class="sg-footer-brand" href="${sfCtx}/home">
                    <img src="${sfCtx}/assets/images/logo.svg" alt="" width="28" height="28">
                    <span>Light Ticket</span>
                </a>
                <p class="sg-footer-about">Mua vé concert, kịch và workshop trực tuyến. Thanh toán qua VNPay, nhận vé QR qua email.</p>
            </div>
            <div>
                <h2>Khám phá</h2>
                <ul>
                    <li><a href="${sfCtx}/home#events">Tất cả sự kiện</a></li>
                    <li><a href="${sfCtx}/customer/booking-history">Vé của tôi</a></li>
                </ul>
            </div>
            <div>
                <h2>Tài khoản</h2>
                <ul>
                    <c:choose>
                        <c:when test="${empty sessionScope.user}">
                            <li><a href="${sfCtx}/Auth?action=login">Đăng nhập</a></li>
                            <li><a href="${sfCtx}/Auth?action=register">Đăng ký</a></li>
                        </c:when>
                        <c:otherwise>
                            <li><a href="${sfCtx}/CustomerProfileController">Hồ sơ của tôi</a></li>
                            <li><a href="${sfCtx}/customer/e-tickets">Vé điện tử</a></li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>
            <div>
                <h2>Hỗ trợ</h2>
                <ul>
                    <li>Hỗ trợ khách hàng</li>
                    <li>Bảo mật thông tin</li>
                    <li>Điều khoản sử dụng</li>
                </ul>
            </div>
        </div>
        <div class="sg-footer-bottom">
            <span>© 2025 Light Ticket Joint Stock Co. Bảo lưu mọi quyền.</span>
            <span class="sg-footer-pay"><i class="ph ph-shield-check" aria-hidden="true"></i>Thanh toán bảo mật qua VNPay</span>
        </div>
    </div>
</footer>
