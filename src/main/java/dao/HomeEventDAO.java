package dao;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import utils.DBContext;

/** Read-only data access for the public homepage. */
public class HomeEventDAO {
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

    private String filters(String keyword, Integer categoryId, Integer venueId, List<Object> params) {
        StringBuilder sql = new StringBuilder(BASE);
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND e.event_name LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND e.category_id = ? ");
            params.add(categoryId);
        }
        if (venueId != null && venueId > 0) {
            sql.append(" AND e.venue_id = ? ");
            params.add(venueId);
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
        e.put("description", rs.getString("description"));
        e.put("categoryName", rs.getString("category_name"));
        e.put("venueName", rs.getString("venue_name"));
        e.put("address", rs.getString("address"));
        e.put("minPrice", rs.getBigDecimal("min_price"));
        e.put("remainingTickets", rs.getInt("remaining_tickets"));
        return e;
    }

    public List<Map<String,Object>> list(String keyword, Integer categoryId, Integer venueId,
                                         String sort, int page, int size) throws SQLException {
        List<Object> params = new ArrayList<>();
        String where = filters(keyword, categoryId, venueId, params);
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

    public int count(String keyword, Integer categoryId, Integer venueId) throws SQLException {
        List<Object> params = new ArrayList<>();
        String sql = "SELECT COUNT(*)" + filters(keyword, categoryId, venueId, params);
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
