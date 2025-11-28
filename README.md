# Tugas Besar Analisis Data Statistika
# Kelompok 6 – Kelas RA – 2025  
Jeremia Halim · Audina Fitria · Suci Aulia · Edsel Adya Pradipta

## 1. Cara Menjalankan Script

1. Pastikan struktur folder repository sudah benar:
/data/
/code/
/output/
/poster/
README.md

2. Download dataset pada folder:
data/Dataset Tugas Besar ADS 2025.xlsx

3. Download script R utama pada folder:
code/codeR_6_RA.R

4. Buka script di RStudio lalu install paket yang dibutuhkan:
   
- install.packages(c("readxl","dplyr","ggplot2","tidyr","broom"))
- Pada baris ## IMPORT DATA data_raw <- read_excel("C:/Main File Location/Downloads/Dataset Tugas Besar ADS 2025.xlsx") ##, jangan lupa untuk mengganti path sesuai dengan direktori masing-masing
- Jalankan script dengan menekan:
- Ctrl + Shift + Enter, atau
- klik Run All

## 2. Paket R yang Digunakan 
library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)
library(broom)

## 3. Penjelasan Singkat Dataset 
- Dataset berasal dari Survei Karakteristik Mahasiswa ITERA (N = 445) yang berisi:
- Jumlah Anggota Keluarga (X) Variabel Independen
- Uang Saku (Y) dalam bentuk kategori (dikonversi menjadi nilai midpoint) Variabel Dependen
- Dataset digunakan untuk analisis deskriptif, korelasi Pearson, dan regresi linear sederhana.

## 4. Struktur Repository
/data/     → dataset mentah & hasil cleaning  
/code/     → script R (codeR_6_RA.R)  
/output/   → grafik, tabel, hasil olahan statistik  
/poster/   → poster A1 (PDF)  
README.md  → dokumentasi proyek  





