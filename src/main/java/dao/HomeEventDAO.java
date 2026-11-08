package dao;

import java.math.BigDecimal;
import java.sql.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import utils.DBContext;

/** Read-only data access for the public homepage. */
public class HomeEventDAO {
    /** "19:30 · 15/11/2026" — how dates read on event cards. */
    private static final DateTimeFormatter CARD_TIME = DateTimeFormatter.ofPattern("HH:mm '·' dd/MM/yyyy");
    private static final String BASE =
        " FROM Events e JOIN Categories c ON c.category_id=e.category_id " +
        "JOIN Venues v ON v.venue_id=e.venue_id " +
        "WHERE e.status='ACTIVE' AND e.end_time > GETDATE() ";
    private static final String FIELDS =
        "SELECT e.event_id, e.event_name, e.event_image, e.start_time, e.end_time, " +
        "e.description, c.category_name, v.venue_name, v.address, " +
        "(SELECT MIN(t.price) FROM Event_Tickets t WHERE t.event_id=e.event_id AND t.status='ACTIVE') AS min_price, " +
        "(SELECT COALESCE(SUM(t.available_quantity),0) FROM Event_Tickets t " +
        "WHERE t.event_id=e.event_id AND t.status='ACTIVE') AS remaining_tickets ";

    /** Bộ lọc trang chủ (UC-09/UC-10). Trường null = không lọc. */
    public static class Filter {
        public String keyword;
        public Integer categoryId;
        public Integer venueId;
        /** Sự kiện diễn ra (giao nhau) trong khoảng [dateFrom, dateTo] */
        public java.time.LocalDate dateFrom;
        public java.time.LocalDate dateTo;
        /** Có ít nhất một hạng vé đang bán với giá trong khoảng [priceMin, priceMax] */
        public java.math.BigDecimal priceMin;
        public java.math.BigDecimal priceMax;
    }

    private String filters(Filter f, List<Object> params) {
        StringBuilder sql = new StringBuilder(BASE);
        if (f.keyword != null && !f.keyword.trim().isEmpty()) {
            sql.append(" AND e.event_name LIKE ? ");
            params.add("%" + f.keyword.trim() + "%");
        }
        if (f.categoryId != null && f.categoryId > 0) {
            sql.append(" AND e.category_id = ? ");
            params.add(f.categoryId);
        }
        if (f.venueId != null && f.venueId > 0) {
            sql.append(" AND e.venue_id = ? ");
            params.add(f.venueId);
        }
        if (f.dateFrom != null) {
            sql.append(" AND e.end_time >= ? ");
            params.add(java.sql.Timestamp.valueOf(f.dateFrom.atStartOfDay()));
        }
        if (f.dateTo != null) {
            sql.append(" AND e.start_time < ? ");
            params.add(java.sql.Timestamp.valueOf(f.dateTo.plusDays(1).atStartOfDay()));
        }
        if (f.priceMin != null || f.priceMax != null) {
            sql.append(" AND EXISTS (SELECT 1 FROM Event_Tickets t WHERE t.event_id = e.event_id AND t.status = 'ACTIVE'");
            if (f.priceMin != null) {
                sql.append(" AND t.price >= ?");
                params.add(f.priceMin);
            }
            if (f.priceMax != null) {
                sql.append(" AND t.price <= ?");
                params.add(f.priceMax);
            }
            sql.append(") ");
        }
        return sql.toString();
    }

    private void bind(PreparedStatement st, List<Object> params) throws SQLException {
        for (int i=0; i<params.size(); i++) st.setObject(i+1, params.get(i));
    }

    private Map<String,Object> row(ResultSet rs) throws SQLException {
        Map<String,Object> e = new HashMap<>();
        e.put("eventId", rs.getInt("event_id"));
        e.put("eventName", rs.getString("event_name"));
        e.put("eventImage", rs.getString("event_image"));
        e.put("startTime", rs.getTimestamp("start_time").toLocalDateTime());
        e.put("endTime", rs.getTimestamp("end_time").toLocalDateTime());
        e.put("startLabel", ((java.time.LocalDateTime) e.get("startTime")).format(CARD_TIME));
        e.put("description", rs.getString("description"));
        e.put("categoryName", rs.getString("category_name"));
        e.put("venueName", rs.getString("venue_name"));
        e.put("address", rs.getString("address"));
        e.put("minPrice", rs.getBigDecimal("min_price"));
        e.put("remainingTickets", rs.getInt("remaining_tickets"));
        return e;
    }

    public List<Map<String,Object>> list(Filter filter, String sort, int page, int size) throws SQLException {
        List<Object> params = new ArrayList<>();
        String where = filters(filter, params);
        String order = "e.start_time ASC, e.event_id DESC";
        if ("newest".equals(sort)) order = "e.created_at DESC, e.event_id DESC";
        else if ("price-asc".equals(sort)) order = "min_price ASC, e.event_id DESC";
        else if ("price-desc".equals(sort)) order = "min_price DESC, e.event_id DESC";
        String sql = FIELDS + where + " ORDER BY " + order + " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add((page-1)*size);
        params.add(size);
        List<Map<String,Object>> rows = new ArrayList<>();
        try (Connection c=DBContext.getConnection(); PreparedStatement st=c.prepareStatement(sql)) {
            bind(st, params);
            try(ResultSet rs=st.executeQuery()) { while(rs.next()) rows.add(row(rs)); }
        }
        return rows;
    }

    public int count(Filter filter) throws SQLException {
        List<Object> params = new ArrayList<>();
        String sql = "SELECT COUNT(*)" + filters(filter, params);
        try(Connection c=DBContext.getConnection(); PreparedStatement st=c.prepareStatement(sql)) {
            bind(st,params);
            try(ResultSet rs=st.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        }
    }

    public List<Map<String,Object>> featured(int limit) throws SQLException {
        List<Map<String,Object>> rows = new ArrayList<>();
        String sql = FIELDS.replaceFirst("SELECT ", "SELECT TOP (" + Math.max(1, Math.min(limit, 20)) + ") ")
                   + BASE + " ORDER BY e.start_time ASC, e.event_id DESC";
        try(Connection c=DBContext.getConnection(); PreparedStatement st=c.prepareStatement(sql);
            ResultSet rs=st.executeQuery()) { while(rs.next()) rows.add(row(rs)); }
        return rows;
    }

    public List<Map<String,Object>> categories() throws SQLException {
        String sql = "SELECT c.category_id, c.category_name, COUNT(e.event_id) AS total " +
            "FROM Categories c LEFT JOIN Events e ON e.category_id=c.category_id " +
            "AND e.status='ACTIVE' AND e.end_time>GETDATE() " +
            "WHERE c.status='ACTIVE' GROUP BY c.category_id,c.category_name ORDER BY c.category_name";
        List<Map<String,Object>> rows=new ArrayList<>();
        try(Connection c=DBContext.getConnection(); PreparedStatement st=c.prepareStatement(sql);
            ResultSet rs=st.executeQuery()) {
            while(rs.next()) { Map<String,Object> m=new HashMap<>();
                m.put("id",rs.getInt(1));m.put("name",rs.getString(2));m.put("total",rs.getInt(3));rows.add(m); }
        }
        return rows;
    }

    /**
     * Các mức giá gợi ý cho bộ lọc trang chủ, tính từ giá vé thực tế của các sự kiện đang mở bán.
     * Ranh giới lấy theo tứ phân vị của các mức giá rồi làm tròn cho dễ đọc.
     * Mỗi phần tử: value ("min-max", vế trống = không giới hạn), label, count (số sự kiện có vé trong khoảng).
     */
    public List<Map<String,Object>> priceRanges() throws SQLException {
        String sql = "SELECT DISTINCT e.event_id, t.price FROM Events e JOIN Event_Tickets t ON t.event_id=e.event_id " +
            "WHERE e.status='ACTIVE' AND e.end_time > GETDATE() AND t.status='ACTIVE' AND t.price IS NOT NULL";
        List<long[]> rows = new ArrayList<>();          // {eventId, price}
        try(Connection c=DBContext.getConnection(); PreparedStatement st=c.prepareStatement(sql);
            ResultSet rs=st.executeQuery()) {
            while(rs.next()) rows.add(new long[]{rs.getInt(1), rs.getBigDecimal(2).longValue()});
        }
        List<Map<String,Object>> ranges = new ArrayList<>();
        if (rows.isEmpty()) return ranges;

        boolean hasFree = rows.stream().anyMatch(r -> r[1] == 0);
        long[] paid = rows.stream().mapToLong(r -> r[1]).filter(p -> p > 0).distinct().sorted().toArray();
        if (hasFree) ranges.add(range(rows, 0L, 0L, "Miễn phí"));
        if (paid.length == 0) return ranges;

        long lo = paid[0], hi = paid[paid.length - 1];
        TreeSet<Long> bounds = new TreeSet<>();
        for (double q : new double[]{0.25, 0.5, 0.75}) {
            long b = niceRound(paid[(int) Math.floor(q * (paid.length - 1) + 0.5)]);
            if (b > lo && b <= hi) bounds.add(b);
        }
        if (bounds.isEmpty()) {
            ranges.add(range(rows, 1L, null, "Có phí (" + vnd(lo) + (lo == hi ? "" : " – " + vnd(hi)) + ")"));
            return ranges;
        }
        Long prev = null;
        for (Long b : bounds) {
            ranges.add(prev == null
                ? range(rows, hasFree ? 1L : null, b - 1, "Dưới " + vnd(b))
                : range(rows, prev, b - 1, vnd(prev) + " – dưới " + vnd(b)));
            prev = b;
        }
        ranges.add(range(rows, prev, null, "Từ " + vnd(prev) + " trở lên"));
        return ranges;
    }

    private static Map<String,Object> range(List<long[]> rows, Long min, Long max, String label) {
        long count = rows.stream()
            .filter(r -> (min == null || r[1] >= min) && (max == null || r[1] <= max))
            .mapToLong(r -> r[0]).distinct().count();
        Map<String,Object> m = new HashMap<>();
        m.put("value", (min == null ? "" : min.toString()) + "-" + (max == null ? "" : max.toString()));
        m.put("label", label);
        m.put("count", count);
        return m;
    }

    /** Làm tròn về bội của nửa bậc độ lớn: 637.000 → 650.000, 1.230.000 → 1.000.000. */
    private static long niceRound(long x) {
        if (x < 10) return x;
        long step = (long) Math.pow(10, Math.floor(Math.log10(x))) / 2;
        return Math.max(step, Math.round((double) x / step) * step);
    }

    private static String vnd(long amount) {
        return String.format(Locale.US, "%,d", amount).replace(',', '.') + " ₫";
    }

    public List<Map<String,Object>> venues() throws SQLException {
        String sql="SELECT venue_id,venue_name FROM Venues WHERE status='ACTIVE' ORDER BY venue_name";
        List<Map<String,Object>> rows=new ArrayList<>();
        try(Connection c=DBContext.getConnection(); PreparedStatement st=c.prepareStatement(sql);
            ResultSet rs=st.executeQuery()) {
            while(rs.next()) { Map<String,Object> m=new HashMap<>();
                m.put("id",rs.getInt(1));m.put("name",rs.getString(2));rows.add(m); }
        }
        return rows;
    }
}
