
document.addEventListener("DOMContentLoaded", () => {
    const openBtn = document.getElementById("openQrScanner");
    const closeBtn = document.getElementById("closeQrScanner");
    const reader = document.getElementById("qr-reader");
    const message = document.getElementById("qrMessage");
    const codeInput = document.getElementById("qrTicketCode");
    const form = document.getElementById("qrCheckinForm");

    if (!openBtn || !closeBtn || !reader || !message || !codeInput || !form) {
        console.error("Khong tim thay cac phan tu QR Scanner.");
        return;
    }

    let scanner = null;
    let processing = false;
    let starting = false;

    async function startScanner() {
        if (processing || starting)
            return;

        if (scanner && scanner.isScanning) {
            message.textContent = "Camera dang quet QR...";
            return;
        }

        if (typeof Html5Qrcode === "undefined") {
            message.textContent = "Khong tai duoc thu vien html5-qrcode.";
            console.error("Html5Qrcode chua duoc tai.");
            return;
        }

        starting = true;
        openBtn.disabled = true;
        message.textContent = "Dang khoi dong camera...";

        try {
            if (!scanner) {
                scanner = new Html5Qrcode("qr-reader");
            }

            await scanner.start(
                    {facingMode: "environment"},
                    {
                        fps: 10,
                        qrbox: (width, height) => {
                            const size = Math.floor(Math.min(width, height) * 0.9);
                            return {width: size, height: size};
                        },
                        disableFlip: false
                    },
                    async (decodedText) => {
                if (processing)
                    return;
                processing = true;

                message.textContent = "Da doc QR: " + decodedText;
                codeInput.value = decodedText.trim();

                try {
                    await scanner.stop();
                } catch (error) {
                    console.warn("Khong dung duoc camera:", error);
                }

                form.requestSubmit();
            },
                    () => {
                // Khong doc duoc QR o mot khung hinh la binh thuong.
            }
            );

            message.textContent =
                    "Camera dang quet. Dua ma QR vao khung hinh.";

        } catch (error) {
            console.error("Loi khoi dong QR:", error);

            message.textContent =
                    "Khong khoi dong duoc: " +
                    (error.message || String(error));

            openBtn.disabled = false;
        } finally {
            starting = false;
        }
    }

    openBtn.addEventListener("click", startScanner);

    closeBtn.addEventListener("click", async () => {
        try {
            if (scanner && scanner.isScanning) {
                await scanner.stop();
            }

            message.textContent = "Da dung quet QR.";
        } catch (error) {
            console.error("Loi dung camera:", error);
            message.textContent = "Khong dung duoc camera.";
        } finally {
            openBtn.disabled = false;
            processing = false;
        }
    });

    // Tu dong mo camera khi vao trang Check-in.
    startScanner();
});
