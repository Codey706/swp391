package controller;

import dao.EventDAO;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonPrimitive;
import controller.Staff.SeatStatusSupport;
import dao.ReviewDAO;
import dao.SeatMapDAO;
import dao.StaffSeatStatusDAO;
import dao.VenueDAO;
import java.util.List;
import model.EventZone;
import model.Venue;
import dao.TicketBookingDAO;
import jakarta.servlet.http.HttpSession;
import java.util.Map;
import model.Auth;
import utils.Constants;
import utils.CsrfUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Event;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;

/**
 * Controller for displaying a public event's detail page.
 * URL pattern: /event/detail?id=123
 */
@WebServlet("/event/detail")
public class EventDetailController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        int eventId = 0;
        try {
            eventId = Integer.parseInt(idParam);
        } catch (NumberFormatException ignored) {
        }
        if (eventId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid event id");
            return;
        }
        EventDAO dao = new EventDAO();
        Event event = dao.getPublicEventById(eventId);
        if (event == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Event not found");
            return;
        }
        try {
            request.setAttribute("tickets", new TicketBookingDAO().getActiveTickets(eventId));
            loadReviews(request, eventId);
            loadVenueAndSeatMap(request, event);
        } catch (SQLException e) {
            throw new ServletException("Cannot load event tickets", e);
        }
        // Chỉ mở đặt vé khi sự kiện chưa bắt đầu (cùng điều kiện với TicketBookingDAO.getBookableEvent)
        boolean bookable = event.getStartTime() != null && event.getStartTime().isAfter(LocalDateTime.now());
        request.setAttribute("event", event);
        request.setAttribute("bookable", bookable);
        request.getRequestDispatcher("/WEB-INF/views/event/event-detail.jsp")
                .forward(request, response);
    }

    /** UC-19: đánh giá công khai + quyền đánh giá của khách đang đăng nhập. */
    private void loadReviews(HttpServletRequest request, int eventId) throws SQLException {
        ReviewDAO reviewDAO = new ReviewDAO();
        double[] summary = reviewDAO.summary(eventId);
        request.setAttribute("reviewAverage", summary[0]);
        request.setAttribute("reviewCount", (int) summary[1]);
        request.setAttribute("reviews", reviewDAO.findPublic(eventId, 20));

        HttpSession session = request.getSession(false);
        Object user = session == null ? null : session.getAttribute(Constants.SESSION_USER);
        if (user instanceof Auth auth && Constants.ROLE_CUSTOMER.equalsIgnoreCase(auth.getRole())) {
            Map<String, Object> mine = reviewDAO.findByCustomerAndEvent(auth.getUserId(), eventId);
            request.setAttribute("myReview", mine);
            request.setAttribute("canReview", mine == null && reviewDAO.findCheckedInTicket(auth.getUserId(), eventId) > 0);
            CsrfUtils.expose(request);
        }
        if (session != null && session.getAttribute("reviewMessage") != null) {
            request.setAttribute("reviewMessage", session.getAttribute("reviewMessage"));
            request.setAttribute("reviewOk", session.getAttribute("reviewOk"));
            session.removeAttribute("reviewMessage");
            session.removeAttribute("reviewOk");
        }
    }

    /**
     * UC-11: địa chỉ địa điểm và sơ đồ ghế chỉ xem. Dùng lại SeatStatusSupport của trang Staff,
     * nhưng gộp "đang giữ / đã đặt / đã check-in" thành một trạng thái "đã bán" cho khách.
     */
    private void loadVenueAndSeatMap(HttpServletRequest request, Event event) throws SQLException {
        Venue venue = new VenueDAO().getVenueById(event.getVenueId());
        request.setAttribute("venueAddress", venue == null ? null : venue.getAddress());

        List<EventZone> zones = new SeatMapDAO().getZones(event.getEventId());
        if (zones.isEmpty()) {
            return;
        }
        StaffSeatStatusDAO seatDAO = new StaffSeatStatusDAO();
        SeatStatusSupport.View view = SeatStatusSupport.build(zones,
                seatDAO.findSeats(event.getEventId()), seatDAO.findStandingTickets(event.getEventId()));
        if (view.seated.isEmpty()) {
            return;
        }
        JsonObject map = JsonParser.parseString(view.mapJson).getAsJsonObject();
        for (JsonElement zone : map.getAsJsonArray("zones")) {
            JsonArray seats = zone.getAsJsonObject().getAsJsonArray("seats");
            if (seats == null) {
                continue;
            }
            for (JsonElement seat : seats) {
                JsonArray cell = seat.getAsJsonArray();
                int status = cell.get(2).getAsInt();
                if (status == 1 || status == 3) {
                    cell.set(2, new JsonPrimitive(2));
                }
            }
        }
        // Chèn vào <script type="application/json">: chặn chuỗi "</script>" trong tên khu
        request.setAttribute("seatMapJson", map.toString().replace("</", "<\\/"));
        request.setAttribute("seatAvailable", view.seatedAvailable);
        request.setAttribute("seatTotal", view.seatedTotal);
    }
}
