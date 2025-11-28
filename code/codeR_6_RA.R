library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)
library(broom)

# 2. IMPORT DATA 
data_raw <- read_excel("C:/Main File Location/Downloads/Dataset Tugas Besar ADS 2025.xlsx")

# Cek nama kolom 
colnames(data_raw)

# 3. BERSIHKAN DATA 
# Pakai nama kolom PERSIS seperti di output colnames()
data_clean <- data_raw %>%
  transmute(
    uang_saku_kat = `Uang Saku : \n(yang diberikan oleh orangtua)`,
    jml_keluarga  = as.numeric(`Jumlah Anggota Keluarga :`)
  ) %>%
  # buang baris yang jumlah keluarganya tidak bisa dikonversi ke angka
  filter(!is.na(jml_keluarga))

# 4. KONVERSI UANG SAKU (KATEGORI → NUMERIK) 
# Nilai tengah tiap range
data_clean <- data_clean %>%
  mutate(
    uang_saku_num = case_when(
      uang_saku_kat == "500k s.d 1 jt"      ~ 750000,
      uang_saku_kat == "1 jt s.d 1,5 jt"    ~ 1250000,
      uang_saku_kat == "1,5 jt s.d 2 jt"    ~ 1750000,
      uang_saku_kat == "> 2 jt"             ~ 2250000,  # bisa 2500000 kalau mau
      TRUE                                  ~ NA_real_
    ),
    uang_saku_kat = factor(
      uang_saku_kat,
      levels = c("500k s.d 1 jt",
                 "1 jt s.d 1,5 jt",
                 "1,5 jt s.d 2 jt",
                 "> 2 jt"),
      ordered = TRUE
    )
  ) %>%
  filter(!is.na(uang_saku_num))

# Cek ringkas data
summary(data_clean)

# 5. TABEL DESKRIPTIF

## 5a. Distribusi jumlah anggota keluarga
tab_jml_keluarga <- data_clean %>%
  count(jml_keluarga) %>%
  mutate(prop = round(100 * n / sum(n), 1))

tab_jml_keluarga

## 5b. Distribusi kategori uang saku
tab_uang_saku <- data_clean %>%
  count(uang_saku_kat) %>%
  mutate(prop = round(100 * n / sum(n), 1))

tab_uang_saku

## 5c. Tabulasi silang (keluarga x uang saku)
tab_cross <- data_clean %>%
  count(jml_keluarga, uang_saku_kat) %>%
  pivot_wider(names_from = uang_saku_kat,
              values_from = n,
              values_fill = 0) %>%
  arrange(jml_keluarga)

tab_cross

# 6. KORELASI PEARSON

cor_test <- cor.test(
  data_clean$jml_keluarga,
  data_clean$uang_saku_num,
  method = "pearson"
)

cor_test

# Fungsi kecil untuk label kekuatan korelasi
strength_label <- function(r){
  ar <- abs(r)
  if (ar < 0.2) "sangat lemah"
  else if (ar < 0.4) "lemah"
  else if (ar < 0.6) "sedang"
  else if (ar < 0.8) "kuat"
  else "sangat kuat"
}

# INTERPRETASI KORELASI
r_val    <- unname(cor_test$estimate)
p_val    <- cor_test$p.value
arah     <- ifelse(r_val > 0, "searah (positif)", "berlawanan arah (negatif)")
kekuatan <- strength_label(r_val)

cat("\n=== INTERPRETASI KORELASI ===\n")
cat("Koefisien korelasi Pearson (r) =", round(r_val, 3),
    "dengan p-value =", signif(p_val, 3), "\n")
cat("Artinya, hubungan antara jumlah anggota keluarga dan uang saku bersifat",
    arah, "dengan kekuatan", kekuatan, ".\n")
if(p_val < 0.05){
  cat("Secara statistik, korelasi ini SIGNIFIKAN pada taraf 5%.\n")
} else {
  cat("Secara statistik, korelasi ini TIDAK signifikan pada taraf 5%.\n")
}

# 7. REGRESI LINEAR SEDERHANA

model_lm <- lm(uang_saku_num ~ jml_keluarga, data = data_clean)
summary(model_lm)

# Ambil koefisien & R-squared
coef_lm  <- coef(model_lm)
beta0    <- coef_lm[1]
beta1    <- coef_lm[2]
R2       <- summary(model_lm)$r.squared
p_beta1  <- summary(model_lm)$coefficients["jml_keluarga", "Pr(>|t|)"]

# INTERPRETASI REGRESI
cat("\n=== INTERPRETASI REGRESI ===\n")
cat("Persamaan garis regresi: Y =",
    round(beta0, 1), "+", round(beta1, 1), "* X\n")
cat("Koefisien slope (beta1) =", round(beta1, 1),
    "bermakna bahwa setiap kenaikan 1 anggota keluarga\n",
    "diestimasikan mengubah uang saku rata-rata sekitar",
    round(beta1, 1), "rupiah.\n")
cat("Nilai R-squared =", round(R2, 3),
    "menunjukkan bahwa sekitar",
    round(100 * R2, 1),
    "% variasi uang saku dapat dijelaskan oleh variasi jumlah anggota keluarga.\n")
if(p_beta1 < 0.05){
  cat("Secara statistik, pengaruh jumlah anggota keluarga TERBILANG SIGNIFIKAN (p-value < 0,05).\n")
} else {
  cat("Secara statistik, pengaruh jumlah anggota keluarga TIDAK signifikan (p-value ≥ 0,05).\n")
}

# 8. GRAFIK UNTUK POSTER

# Scatter Plot 
ggplot(data_clean, aes(x = jml_keluarga, y = uang_saku_num)) +
  geom_point(color = "#2E86C1", alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = FALSE, color = "#E67E22", size = 1.2) +
  labs(
    title = "Hubungan Jumlah Anggota Keluarga dengan Uang Saku",
    x = "Jumlah Anggota Keluarga",
    y = "Uang Saku (Rupiah)"
  ) +
  theme_minimal(base_size = 14)




## 8b. Boxplot uang saku per jumlah anggota keluarga
ggplot(data_clean, aes(x = factor(jml_keluarga), y = uang_saku_num)) +
  geom_boxplot() +
  labs(
    title = "Boxplot Uang Saku per Jumlah Anggota Keluarga",
    x = "Jumlah Anggota Keluarga",
    y = "Uang Saku (rupiah)"
  ) +
  theme_minimal()

## 8c. Bar chart distribusi kategori uang saku
ggplot(tab_uang_saku, aes(x = uang_saku_kat, y = n)) +
  geom_col() +
  labs(
    title = "Distribusi Kategori Uang Saku",
    x = "Kategori Uang Saku",
    y = "Frekuensi"
  ) +
  theme_minimal()

## 8d. Korelasi Bar Gauge 

r_true <- r_val  
r_plot <- r_val - 0.03   # offset visual kecil

cor_zone <- data.frame(
  zone = c("Sangat lemah", "Lemah", "Sedang", "Kuat", "Sangat kuat"),
  xmin = c(-1.0, -0.6, -0.2, 0.2, 0.6),
  xmax = c(-0.6, -0.2, 0.2, 0.6, 1.0),
  fill = c("#FAD7A0", "#F8C471", "#F5B041", "#EB984E", "#DC7633")
)

ggplot() +
  geom_rect(data = cor_zone,
            aes(xmin = xmin, xmax = xmax, ymin = 0, ymax = 1, fill = zone),
            color = "white") +

  geom_vline(xintercept = r_plot, color = "#2E86C1", linewidth = 2) +
  geom_point(aes(x = r_plot, y = 1.02), color = "#2E86C1", size = 3) +


  annotate("text",
           x = r_plot + 0.10,  
           y = 1.08,
           label = paste0("r = ", round(r_true, 3)),
           fontface = "bold",
           size = 4,
           hjust = 0) +

  scale_x_continuous(
    breaks = c(-1, -0.5, 0, 0.5, 1),
    labels = c("-1.0", "-0.5", "0", "0.5", "1.0")
  ) +

  coord_cartesian(xlim = c(-1,1), ylim = c(0,1.2)) +
  scale_fill_manual(values = cor_zone$fill) +
  labs(
    title = "Visualisasi Kekuatan Korelasi",
    subtitle = paste0("Korelasi ", kekuatan, 
                      " (r = ", round(r_true, 3), 
                      "; p-value = ", signif(p_val, 3), ")"),
    x = "Kekuatan Korelasi (-1 s.d 1)",
    y = NULL
  ) +
  theme_minimal(base_size = 14) +
  theme(
    axis.text.y   = element_blank(),
    axis.ticks.y  = element_blank(),
    legend.position = "none"
  )


# 9. KESIMPULAN UMUM 

cat("\n=== KESIMPULAN UMUM ===\n")

if (p_beta1 < 0.05 & p_val < 0.05) {
  cat("Terdapat hubungan yang signifikan antara jumlah anggota keluarga dan uang saku.",
      "Namun kekuatan hubungan dikategorikan sebagai", kekuatan, ".\n")
} else {
  cat("Berdasarkan analisis korelasi dan regresi, jumlah anggota keluarga",
      "bukan prediktor yang kuat maupun signifikan secara statistik",
      "untuk menjelaskan variasi uang saku mahasiswa.\n")
}

cat("Hasil ini menunjukkan bahwa faktor lain di luar jumlah anggota keluarga",
    "kemungkinan lebih berperan dalam menentukan besar kecilnya uang saku.\n")

```

