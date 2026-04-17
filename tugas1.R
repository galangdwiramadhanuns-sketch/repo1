# ===============================
# CLUSTERING WILAYAH BERDASARKAN PERFORMA PRODUK
# ===============================

# 0. Load data
library(openxlsx)
Coffee_Chain_Datasets <- read.xlsx("C:/Users/User/OneDrive/Documents/UNS/SIM/Coffee_Chain_Datasets.xlsx")

# 1. Load package
if(!require(dplyr)) install.packages("dplyr")
if(!require(tidyr)) install.packages("tidyr")
if(!require(factoextra)) install.packages("factoextra")
remove.packages("rlang")
install.packages("rlang")
library(dplyr)
library(tidyr)
library(factoextra)

# ===============================
# 2. AGREGASI DATA
# ===============================
data_cluster <- Coffee_Chain_Datasets %>%
  group_by(State, `Product.Line`) %>%
  summarise(total_laba = sum(Profit, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = `Product.Line`,
              values_from = total_laba,
              values_fill = 0)

# ===============================
# 3. SIMPAN NAMA STATE
# ===============================
state_names <- data_cluster$State


# ===============================
# 4. HAPUS KOLOM STATE
# ===============================
data_cluster <- data_cluster[, -1]

# ===============================
# 5. FILTER NUMERIK
# ===============================
data_cluster <- data_cluster[, sapply(data_cluster, is.numeric)]

# ===============================
# 6. CEK STRUKTUR DATA
# ===============================
cat("Dimensi data sebelum cleaning:", dim(data_cluster), "\n")
print(head(data_cluster))

# ===============================
# 7. HAPUS VARIANSI NOL
# ===============================
var_cols <- apply(data_cluster, 2, var)

if(all(var_cols == 0)){
  stop("SEMUA VARIABEL MEMILIKI VARIANSI NOL")
}

data_cluster <- data_cluster[, var_cols != 0, drop = FALSE]

# ===============================
# 8. TRANSFORMASI
# ===============================
data_cluster <- log1p(data_cluster)

# ===============================
# 9. CEK NA SEBELUM SCALING
# ===============================
cat("Jumlah NA sebelum scaling:", sum(is.na(data_cluster)), "\n")

# ===============================
# 10. NORMALISASI
# ===============================
data_scaled <- scale(data_cluster)

# ===============================
# 11. HANDLE NA (AMAN)
# ===============================
idx <- complete.cases(data_scaled)

cat("Jumlah data valid:", sum(idx), "dari", length(idx), "\n")

if(sum(idx) == 0){
  stop("SEMUA DATA TERHAPUS KARENA NA - CEK DATA!")
}

data_scaled <- data_scaled[idx, , drop = FALSE]
data_cluster <- data_cluster[idx, , drop = FALSE]
state_names <- state_names[idx]

# ===============================
# 12. ELBOW METHOD
# ===============================
n <- nrow(data_scaled)
max_k <- min(10, n - 1)

wss <- sapply(1:max_k, function(k){
  kmeans(data_scaled, centers = k, nstart = 25)$tot.withinss
})

plot(1:max_k, wss, type="b", pch=19,
     xlab="Jumlah Cluster",
     ylab="Total Within Sum of Squares",
     main="Elbow Method")

# ===============================
# 13. K-MEANS CLUSTERING
# ===============================
set.seed(123)

k <- min(3, n - 1)
kmeans_result <- kmeans(data_scaled, centers = k, nstart = 25)

# ===============================
# 14. HASIL CLUSTER (FIX FINAL)
# ===============================
hasil_cluster <- data.frame(
  State = state_names,
  data_cluster,
  cluster = kmeans_result$cluster
)

print(hasil_cluster)

# ===============================
# 15. INTERPRETASI CLUSTER
# ===============================
cluster_summary <- aggregate(data_cluster,
                             by = list(cluster = kmeans_result$cluster),
                             mean)

print(cluster_summary)

# ===============================
# 16. VISUALISASI
# ===============================
fviz_cluster(kmeans_result,
             data = data_scaled,
             geom = "point",
             repel = TRUE) +
  labs(title = "Clustering State Berdasarkan Performa Produk")

# ===============================
# 17. TAMBAHAN ANALISIS
# ===============================
cat("\nDistribusi cluster:\n")
print(table(hasil_cluster$cluster))

cat("\nData per cluster:\n")
print(hasil_cluster %>% arrange(cluster))

