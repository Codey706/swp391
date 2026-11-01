/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;

/**
 *
 * @author TRUC MAI
 */
public class CurrencyUtils {

    private CurrencyUtils() {
    }

    public static String formatVND(BigDecimal amount) {
        DecimalFormat format = new DecimalFormat("#,##0",
                DecimalFormatSymbols.getInstance(new Locale("vi", "VN")));
        return format.format(amount == null ? BigDecimal.ZERO : amount) + " ₫";
    }
}
