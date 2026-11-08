package utils;

import dao.TicketBookingDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Tác vụ nền của ứng dụng:
 * - Mỗi phút hủy các đơn Pending đã quá hạn giữ chỗ và trả vé/ghế/voucher
 *   (TicketBookingDAO.releaseExpiredHolds).
 * Tất cả được tắt khi undeploy/stop để không rò rỉ luồng.
 */
@WebListener
public class AppLifecycleListener implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(AppLifecycleListener.class.getName());
    private static final long RELEASE_HOLDS_PERIOD_MINUTES = 1;

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent event) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread thread = new Thread(r, "ltm-release-expired-holds");
            thread.setDaemon(true);
            return thread;
        });
        TicketBookingDAO ticketBookingDAO = new TicketBookingDAO();
        scheduler.scheduleWithFixedDelay(() -> {
            try {
                ticketBookingDAO.releaseExpiredHolds();
            } catch (Exception e) {
                // Bắt mọi lỗi: nếu ném ra ngoài, ScheduledExecutorService sẽ dừng lịch chạy
                LOGGER.log(Level.WARNING, "Cannot release expired booking holds", e);
            }
        }, RELEASE_HOLDS_PERIOD_MINUTES, RELEASE_HOLDS_PERIOD_MINUTES, TimeUnit.MINUTES);
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        if (scheduler != null) {
            scheduler.shutdownNow();
            try {
                scheduler.awaitTermination(10, TimeUnit.SECONDS);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
        EmailService.shutdown();
    }
}
