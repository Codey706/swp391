package controller.Event;

import com.google.gson.Gson;
import com.google.gson.JsonParseException;
import dao.SeatMapDAO.TicketChange;
import model.EventTicket;
import model.EventZone;
import utils.Constants;
import utils.ValidationUtils;

import java.math.BigDecimal;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.regex.Pattern;

/**
 * Đọc, kiểm tra và dựng dữ liệu cho trình thiết kế sơ đồ ghế. Dùng chung cho
 * trang thiết kế riêng (SeatMapController) và bước 3 của form tạo sự kiện
 * (EventCreateController) để hai nơi luôn áp dụng cùng một bộ quy tắc.
 */
public final class SeatMapSupport {

    private static final Pattern COLOR_PATTERN = Pattern.compile("^#[0-9A-Fa-f]{6}$");
    private static final Pattern BLOCKED_PATTERN = Pattern.compile("^\\d{1,2}:\\d{1,2}$");

    // Gson mặc định đã escape <, >, & nên nhúng JSON vào <script> an toàn
    private static final Gson GSON = new Gson();

    private SeatMapSupport() {
    }

    /** Hạng vé do trình thiết kế gửi lên (id &lt;= 0: hạng vé mới chưa lưu). */
    public static class TicketDraft {

        public int id;
        public String name;
        public long price;
    }

    /** Toàn bộ dữ liệu trình thiết kế gửi lên khi lưu. */
    public static class LayoutRequest {

        public List<TicketDraft> tickets;
        public List<EventZone> zones;
    }

    /** @return dữ liệu đã chuẩn hóa; null nếu JSON sai cấu trúc. */
    public static LayoutRequest parse(String json) {
        if (ValidationUtils.isNullOrBlank(json)) {
            return null;
        }
        try {
            LayoutRequest layout = GSON.fromJson(json, LayoutRequest.class);
            if (layout == null) {
                return null;
            }
            if (layout.tickets == null) {
                layout.tickets = new ArrayList<>();
            }
            if (layout.zones == null) {
                layout.zones = new ArrayList<>();
            }
            for (TicketDraft ticket : layout.tickets) {
                if (ticket == null) {
                    return null;
                }
                ticket.name = ticket.name == null ? "" : ticket.name.trim();
            }
            for (EventZone zone : layout.zones) {
                if (zone == null) {
                    return null;
                }
                zone.setZoneName(zone.getZoneName() == null ? "" : zone.getZoneName().trim());
                zone.setZoneType(zone.getZoneType() == null ? "" : zone.getZoneType().trim().toUpperCase(Locale.ROOT));
                zone.setZoneId(0); // id luôn do database cấp
            }
            return layout;
        } catch (JsonParseException | NumberFormatException e) {
            return null;
        }
    }

    /**
     * Kiểm tra toàn bộ sơ đồ + hạng vé ở backend. Đồng thời chuẩn hóa dữ liệu
     * (sức chứa khu ngồi, mã khu) và dựng danh sách thay đổi hạng vé để lưu.
     */
    public static void validate(LayoutRequest layout, List<EventTicket> existingTickets, int venueCapacity,
            Function<EventTicket, String> ticketValidator, List<String> errors, List<TicketChange> changes) {
        List<EventZone> zones = layout.zones;

        // ---- Hạng vé: hạng vé hiện có (có thể được sửa tên/giá) + hạng vé mới
        Map<Integer, EventTicket> existingById = new LinkedHashMap<>();
        for (EventTicket t : existingTickets) {
            existingById.put(t.getEventTicketId(), t);
        }
        Map<Integer, TicketDraft> finalTickets = new LinkedHashMap<>();
        for (EventTicket t : existingTickets) {
            TicketDraft draft = new TicketDraft();
            draft.id = t.getEventTicketId();
            draft.name = t.getTicketName();
            draft.price = t.getPrice() == null ? 0 : t.getPrice().longValue();
            finalTickets.put(draft.id, draft);
        }
        for (TicketDraft draft : layout.tickets) {
            if (draft.id > 0 && !existingById.containsKey(draft.id)) {
                errors.add("Hạng vé không thuộc sự kiện này.");
                return;
            }
            if (draft.id <= 0 && (draft.id == 0 || finalTickets.containsKey(draft.id))) {
                errors.add("Dữ liệu hạng vé không hợp lệ.");
                return;
            }
            finalTickets.put(draft.id, draft);
        }
        if (finalTickets.size() > Constants.TICKET_MAX_TYPES) {
            errors.add("Mỗi sự kiện tối đa " + Constants.TICKET_MAX_TYPES + " hạng vé.");
            return;
        }

        // ---- Khu
        if (zones.isEmpty()) {
            errors.add("Sơ đồ chưa có khu nào. Hãy thêm ít nhất một khu ngồi hoặc khu đứng.");
            return;
        }
        if (zones.size() > Constants.SEATMAP_MAX_ZONES) {
            errors.add("Mỗi sơ đồ tối đa " + Constants.SEATMAP_MAX_ZONES + " khu.");
            return;
        }

        Set<String> names = new HashSet<>();
        Set<String> codes = new HashSet<>();
        int stageCount = 0;
        int sellableCount = 0;
        long totalCapacity = 0;

        for (int i = 0; i < zones.size(); i++) {
            EventZone zone = zones.get(i);
            String label = zone.getZoneName().isEmpty() ? "Khu #" + (i + 1) : "Khu \"" + zone.getZoneName() + "\"";

            // Tên
            if (zone.getZoneName().isEmpty()) {
                errors.add(label + ": tên khu không được để trống.");
            } else if (zone.getZoneName().length() > Constants.SEATMAP_ZONE_NAME_MAX_LENGTH) {
                errors.add(label + ": tên khu tối đa " + Constants.SEATMAP_ZONE_NAME_MAX_LENGTH + " ký tự.");
            } else if (!names.add(zone.getZoneName().toLowerCase(Locale.ROOT))) {
                errors.add(label + ": tên khu bị trùng với khu khác.");
            }

            // Loại khu
            if (!zone.isSeated() && !zone.isStanding() && !zone.isStage()) {
                errors.add(label + ": loại khu không hợp lệ.");
                continue;
            }

            // Màu
            if (zone.getColor() == null || !COLOR_PATTERN.matcher(zone.getColor()).matches()) {
                errors.add(label + ": màu không hợp lệ.");
            }

            // Vị trí / kích thước trong khung vẽ
            if (zone.getWidth() < Constants.SEATMAP_MIN_ZONE_SIZE || zone.getHeight() < Constants.SEATMAP_MIN_ZONE_SIZE
                    || zone.getPosX() < 0 || zone.getPosY() < 0
                    || zone.getPosX() + zone.getWidth() > Constants.SEATMAP_CANVAS_WIDTH
                    || zone.getPosY() + zone.getHeight() > Constants.SEATMAP_CANVAS_HEIGHT) {
                errors.add(label + ": khu nằm ngoài khung sơ đồ hoặc quá nhỏ.");
            }

            if (zone.isStage()) {
                stageCount++;
                zone.setEventTicketId(null);
                zone.setRowCount(0);
                zone.setSeatsPerRow(0);
                zone.setCapacity(0);
                zone.setBlockedSeats(null);
            } else {
                sellableCount++;
                validateSellableZone(zone, label, finalTickets, errors);
                totalCapacity += zone.getCapacity();
            }
        }

        if (stageCount > 1) {
            errors.add("Mỗi sơ đồ chỉ có tối đa 1 sân khấu.");
        }
        if (sellableCount == 0) {
            errors.add("Sơ đồ cần ít nhất một khu ngồi hoặc khu đứng để bán vé.");
        }
        if (!errors.isEmpty()) {
            return;
        }

        // Khu chồng lên nhau
        for (int i = 0; i < zones.size(); i++) {
            for (int j = i + 1; j < zones.size(); j++) {
                if (overlaps(zones.get(i), zones.get(j))) {
                    errors.add("Khu \"" + zones.get(i).getZoneName() + "\" và khu \""
                            + zones.get(j).getZoneName() + "\" đang chồng lên nhau.");
                }
            }
        }

        // Sức chứa địa điểm
        if (venueCapacity > 0 && totalCapacity > venueCapacity) {
            errors.add("Tổng số chỗ của sơ đồ (" + totalCapacity + ") vượt quá sức chứa của địa điểm ("
                    + venueCapacity + " chỗ).");
        }

        // Sức chứa các khu gán cho từng hạng vé = số lượng vé mới của hạng đó
        Map<Integer, Integer> capacityByTicket = new HashMap<>();
        for (EventZone zone : zones) {
            if (!zone.isStage()) {
                capacityByTicket.merge(zone.getEventTicketId(), zone.getCapacity(), Integer::sum);
            }
        }

        Set<String> ticketNames = new HashSet<>();
        long totalTickets = 0;
        for (TicketDraft draft : finalTickets.values()) {
            Integer assigned = capacityByTicket.get(draft.id);
            boolean isNew = draft.id <= 0;
            if (isNew && assigned == null) {
                errors.add("Hạng vé \"" + draft.name + "\" chưa được gán cho khu nào. "
                        + "Hãy gán cho một khu hoặc xóa hạng vé này.");
                continue;
            }
            int quantity = assigned != null ? assigned : existingById.get(draft.id).getQuantity();

            EventTicket check = new EventTicket();
            check.setTicketName(draft.name);
            check.setPrice(BigDecimal.valueOf(draft.price));
            check.setQuantity(quantity);
            String ticketError = ticketValidator.apply(check);
            if (ticketError == null && !ticketNames.add(draft.name.toLowerCase(Locale.ROOT))) {
                ticketError = "Tên hạng vé bị trùng với hạng vé khác trong sự kiện.";
            }
            if (ticketError != null) {
                errors.add("Hạng vé \"" + draft.name + "\": " + ticketError);
                continue;
            }
            totalTickets += quantity;
            changes.add(new TicketChange(draft.id, draft.name, check.getPrice(), quantity));
        }
        if (errors.isEmpty() && venueCapacity > 0 && totalTickets > venueCapacity) {
            errors.add("Tổng số vé của tất cả hạng vé sau khi đồng bộ (" + totalTickets
                    + ") vượt quá sức chứa của địa điểm (" + venueCapacity + " chỗ).");
        }

        // Mã ASCII cho nhãn ghế
        for (int i = 0; i < zones.size(); i++) {
            zones.get(i).setCode(buildCode(zones.get(i).getZoneName(), i, codes));
        }
    }

    private static void validateSellableZone(EventZone zone, String label, Map<Integer, TicketDraft> ticketById,
            List<String> errors) {
        // Hạng vé (giá) bắt buộc và phải thuộc sự kiện này
        if (zone.getEventTicketId() == null || !ticketById.containsKey(zone.getEventTicketId())) {
            errors.add(label + ": vui lòng chọn hạng vé (giá) hợp lệ cho khu.");
        }

        if (zone.isSeated()) {
            if (zone.getRowCount() < 1 || zone.getRowCount() > Constants.SEATMAP_MAX_ROWS) {
                errors.add(label + ": số hàng phải từ 1 đến " + Constants.SEATMAP_MAX_ROWS + ".");
                return;
            }
            if (zone.getSeatsPerRow() < 1 || zone.getSeatsPerRow() > Constants.SEATMAP_MAX_SEATS_PER_ROW) {
                errors.add(label + ": số ghế mỗi hàng phải từ 1 đến " + Constants.SEATMAP_MAX_SEATS_PER_ROW + ".");
                return;
            }
            // Ghế bỏ trống: đúng định dạng, nằm trong lưới, không trùng
            Set<String> blocked = zone.blockedSet();
            for (String position : blocked) {
                if (!BLOCKED_PATTERN.matcher(position).matches()) {
                    errors.add(label + ": danh sách ghế bỏ trống không hợp lệ.");
                    return;
                }
                String[] parts = position.split(":");
                if (Integer.parseInt(parts[0]) >= zone.getRowCount()
                        || Integer.parseInt(parts[1]) >= zone.getSeatsPerRow()) {
                    errors.add(label + ": có ghế bỏ trống nằm ngoài lưới ghế.");
                    return;
                }
            }
            zone.setBlockedSeats(blocked.isEmpty() ? null : String.join(",", blocked));
            int seats = zone.getRowCount() * zone.getSeatsPerRow() - blocked.size();
            if (seats < 1) {
                errors.add(label + ": khu cần có ít nhất 1 ghế.");
            }
            zone.setCapacity(seats); // không tin số liệu từ trình duyệt
        } else { // STANDING
            zone.setRowCount(0);
            zone.setSeatsPerRow(0);
            zone.setBlockedSeats(null);
            if (zone.getCapacity() < 1 || zone.getCapacity() > Constants.TICKET_MAX_QUANTITY) {
                errors.add(label + ": sức chứa khu đứng phải từ 1 đến "
                        + String.format(Locale.US, "%,d", Constants.TICKET_MAX_QUANTITY) + ".");
            }
        }
    }

    private static boolean overlaps(EventZone a, EventZone b) {
        return a.getPosX() < b.getPosX() + b.getWidth() && b.getPosX() < a.getPosX() + a.getWidth()
                && a.getPosY() < b.getPosY() + b.getHeight() && b.getPosY() < a.getPosY() + a.getHeight();
    }

    /** Mã ASCII tối đa 8 ký tự từ tên khu (bỏ dấu), duy nhất trong sơ đồ. */
    private static String buildCode(String name, int index, Set<String> used) {
        String ascii = Normalizer.normalize(name.replace('đ', 'd').replace('Đ', 'D'), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replaceAll("[^A-Za-z0-9]", "")
                .toUpperCase(Locale.ROOT);
        String base = ascii.isEmpty() ? "Z" : ascii;
        if (base.length() > 6) {
            base = base.substring(0, 6);
        }
        String code = base;
        int suffix = index + 1;
        while (!used.add(code)) {
            code = base + suffix++;
        }
        return code;
    }


    // ------------------------------------------------------------------ Dữ liệu cho trình thiết kế (JSON)
    /** Hạng vé từ database -> dữ liệu cho trình thiết kế. */
    public static List<Map<String, Object>> ticketData(List<EventTicket> tickets) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (EventTicket t : tickets) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", t.getEventTicketId());
            item.put("name", t.getTicketName());
            item.put("price", t.getPrice() == null ? 0 : t.getPrice().longValue());
            list.add(item);
        }
        return list;
    }

    /** Hạng vé đang vẽ (khi hiển thị lại form sau lỗi) -> dữ liệu cho trình thiết kế. */
    public static List<Map<String, Object>> draftData(List<TicketDraft> drafts) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (TicketDraft t : drafts) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", t.id);
            item.put("name", t.name);
            item.put("price", t.price);
            list.add(item);
        }
        return list;
    }

    /**
     * JSON khởi tạo cho seatmap.js.
     *
     * @param venueCapacities sức chứa theo địa điểm (form tạo sự kiện, để trình
     * thiết kế theo dõi địa điểm đang chọn); null ở trang thiết kế riêng
     */
    public static String buildDataJson(int eventId, boolean readOnly, int venueCapacity,
            Map<Integer, Integer> venueCapacities, List<Map<String, Object>> tickets, List<EventZone> zones) {
        Map<String, Object> canvas = new LinkedHashMap<>();
        canvas.put("width", Constants.SEATMAP_CANVAS_WIDTH);
        canvas.put("height", Constants.SEATMAP_CANVAS_HEIGHT);

        Map<String, Object> limits = new LinkedHashMap<>();
        limits.put("maxZones", Constants.SEATMAP_MAX_ZONES);
        limits.put("maxRows", Constants.SEATMAP_MAX_ROWS);
        limits.put("maxSeatsPerRow", Constants.SEATMAP_MAX_SEATS_PER_ROW);
        limits.put("minZoneSize", Constants.SEATMAP_MIN_ZONE_SIZE);
        limits.put("maxTickets", Constants.TICKET_MAX_TYPES);
        limits.put("maxPrice", Constants.TICKET_MAX_PRICE);
        limits.put("maxQuantity", Constants.TICKET_MAX_QUANTITY);

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("eventId", eventId);
        data.put("readOnly", readOnly);
        data.put("venueCapacity", venueCapacity);
        if (venueCapacities != null) {
            data.put("venueCapacities", venueCapacities);
        }
        data.put("canvas", canvas);
        data.put("limits", limits);
        data.put("tickets", tickets);
        data.put("zones", zones);
        return GSON.toJson(data);
    }
}
