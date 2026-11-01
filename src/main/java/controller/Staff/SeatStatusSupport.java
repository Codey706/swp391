package controller.Staff;

import com.google.gson.Gson;
import model.EventZone;
import model.SeatStatusRow;
import model.SeatZoneStat;
import utils.Constants;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Dựng số liệu từng khu và JSON sơ đồ (chỉ xem) cho trang Staff - Seat Status từ dữ liệu
 * thật: Event_Zones, Event_Seats và Tickets. Không sinh ghế hay số liệu nào không có trong DB.
 */
public final class SeatStatusSupport {

    // Mã trạng thái ghế gửi xuống trình duyệt (khớp staff-seats.js)
    static final int AVAILABLE = 0;
    static final int HELD = 1;
    static final int BOOKED = 2;
    static final int USED = 3;
    static final int UNAVAILABLE = 4;

    // Hình học khu ngồi, khớp trình thiết kế sơ đồ (seatmap.js) để giữ đúng vị trí đã vẽ
    private static final int PITCH = 24, PAD = 10, HEAD = 24, LEFT = 16;

    // Gson mặc định escape <, >, & nên nhúng JSON vào <script> an toàn
    private static final Gson GSON = new Gson();

    private SeatStatusSupport() {
    }

    /** Kết quả cho JSP. */
    public static final class View {

        public final List<SeatZoneStat> seated = new ArrayList<>();
        public final List<SeatZoneStat> standing = new ArrayList<>();
        public boolean hasStage;
        public boolean noLayout;          // sự kiện chưa có khu nào
        public int unassignedSeats;       // ghế chưa gắn khu nên không có trên sơ đồ
        public int unmappedSeats;         // ghế có khu nhưng nhãn hàng/ghế không khớp lưới của khu
        public String mapJson = "{}";
        // Tổng khu ngồi
        public int seatedTotal, seatedAvailable, seatedHeld, seatedSold;
        public boolean standingUnknown;   // có khu đứng không tách được số liệu riêng
    }

    public static View build(List<EventZone> zones, List<SeatStatusRow> seats, Map<Integer, int[]> standingTickets) {
        View view = new View();
        view.noLayout = zones.isEmpty();

        Map<Integer, List<SeatStatusRow>> seatsByZone = new HashMap<>();
        for (SeatStatusRow seat : seats) {
            if (seat.getZoneId() == null) {
                view.unassignedSeats++;
            } else {
                seatsByZone.computeIfAbsent(seat.getZoneId(), k -> new ArrayList<>()).add(seat);
            }
        }

        // Số khu đứng dùng chung từng hạng vé: > 1 thì không tách được số vé riêng từng khu
        Map<Integer, Integer> standingPerTicket = new HashMap<>();
        for (EventZone zone : zones) {
            if (zone.isStanding() && zone.getEventTicketId() != null) {
                standingPerTicket.merge(zone.getEventTicketId(), 1, Integer::sum);
            }
        }

        List<Map<String, Object>> mapZones = new ArrayList<>();
        for (EventZone zone : zones) {
            if (zone.isStage()) {
                view.hasStage = true;
                mapZones.add(stageJson(zone));
            } else if (zone.isSeated()) {
                SeatZoneStat stat = new SeatZoneStat();
                stat.setZoneId(zone.getZoneId());
                stat.setZoneName(zone.getZoneName());
                stat.setZoneType(zone.getZoneType());
                stat.setCapacity(zone.getCapacity());

                List<int[]> cells = new ArrayList<>();
                for (SeatStatusRow seat : seatsByZone.getOrDefault(zone.getZoneId(), List.of())) {
                    int code = statusCode(seat);
                    stat.setTotalSeats(stat.getTotalSeats() + 1);
                    switch (code) {
                        case AVAILABLE -> stat.setAvailableSeats(stat.getAvailableSeats() + 1);
                        case HELD -> stat.setHeldSeats(stat.getHeldSeats() + 1);
                        case BOOKED -> stat.setBookedSeats(stat.getBookedSeats() + 1);
                        case USED -> stat.setUsedSeats(stat.getUsedSeats() + 1);
                        default -> {
                        }
                    }
                    int row = rowIndex(seat.getRowLabel());
                    int col = seat.getSeatNumber() - 1;
                    if (row < 0 || row >= zone.getRowCount() || col < 0 || col >= zone.getSeatsPerRow()) {
                        view.unmappedSeats++;
                        continue;
                    }
                    cells.add(new int[]{row, col, code, isVip(seat) ? 1 : 0});
                }
                view.seated.add(stat);
                view.seatedTotal += stat.getTotalSeats();
                view.seatedAvailable += stat.getAvailableSeats();
                view.seatedHeld += stat.getHeldSeats();
                view.seatedSold += stat.getSoldSeats();
                mapZones.add(seatedJson(zone, cells));
            } else if (zone.isStanding()) {
                SeatZoneStat stat = new SeatZoneStat();
                stat.setZoneId(zone.getZoneId());
                stat.setZoneName(zone.getZoneName());
                stat.setZoneType(zone.getZoneType());
                stat.setCapacity(zone.getCapacity());
                Integer ticketId = zone.getEventTicketId();
                int[] tickets = standingTickets.get(zone.getZoneId());
                boolean separable = ticketId != null && tickets != null && standingPerTicket.get(ticketId) == 1;
                if (separable) {
                    stat.setTicketsSold(tickets[0]);
                    stat.setTicketsCheckedIn(tickets[1]);
                } else {
                    view.standingUnknown = true;
                }
                view.standing.add(stat);
            }
        }

        Map<String, Object> root = new LinkedHashMap<>();
        root.put("zones", mapZones);
        root.put("pitch", PITCH);
        view.mapJson = GSON.toJson(root);
        return view;
    }

    private static int statusCode(SeatStatusRow seat) {
        String status = seat.getStatus() == null ? "" : seat.getStatus().trim();
        if (Constants.SEAT_AVAILABLE.equalsIgnoreCase(status)) {
            return AVAILABLE;
        }
        if (Constants.SEAT_HELD.equalsIgnoreCase(status)) {
            return HELD;
        }
        if (Constants.SEAT_SOLD.equalsIgnoreCase(status)) {
            return seat.isCheckedIn() ? USED : BOOKED;
        }
        return UNAVAILABLE;
    }

    private static boolean isVip(SeatStatusRow seat) {
        return seat.getSeatType() != null && "VIP".equalsIgnoreCase(seat.getSeatType().trim());
    }

    /** row_label dạng "{mã khu}-{chữ hàng}" (VD VIPA-B): lấy chữ cuối, A=0; -1 nếu không đọc được. */
    private static int rowIndex(String rowLabel) {
        if (rowLabel == null) {
            return -1;
        }
        String tail = rowLabel.substring(rowLabel.lastIndexOf('-') + 1).trim();
        if (tail.length() != 1) {
            return -1;
        }
        char c = Character.toUpperCase(tail.charAt(0));
        return c >= 'A' && c <= 'Z' ? c - 'A' : -1;
    }

    private static Map<String, Object> stageJson(EventZone zone) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("type", EventZone.TYPE_STAGE);
        m.put("name", zone.getZoneName());
        m.put("x", zone.getPosX());
        m.put("y", zone.getPosY());
        m.put("w", zone.getWidth());
        m.put("h", zone.getHeight());
        return m;
    }

    private static Map<String, Object> seatedJson(EventZone zone, List<int[]> cells) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("type", EventZone.TYPE_SEATED);
        m.put("name", zone.getZoneName());
        m.put("color", zone.getColor());
        m.put("x", zone.getPosX());
        m.put("y", zone.getPosY());
        m.put("w", LEFT + zone.getSeatsPerRow() * PITCH + 2 * PAD);
        m.put("h", HEAD + zone.getRowCount() * PITCH + 2 * PAD);
        m.put("rows", zone.getRowCount());
        m.put("cols", zone.getSeatsPerRow());
        m.put("seats", cells);
        return m;
    }
}
