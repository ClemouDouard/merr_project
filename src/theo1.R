# Charger les données
data <- read.csv(file = "../data/support2.csv", header = TRUE)

# Aperçu des données
print(data)
summary(data)

# Identifier les colonnes avec des valeurs manquantes
missing_data_summary <- sapply(data, function(x) sum(is.na(x)))
missing_data_summary <- sort(missing_data_summary[missing_data_summary > 0], decreasing = TRUE)
print("Colonnes avec des valeurs manquantes :")
print(missing_data_summary)

# Supprimer les colonnes contenant des valeurs manquantes
data_cleaned <- data[, !sapply(data, function(x) any(is.na(x)))]

# Identifier les valeurs aberrantes
find_outliers <- function(series) {
  q1 <- quantile(series, 0.25, na.rm = TRUE)
  q3 <- quantile(series, 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  lower_bound <- q1 - 1.5 * iqr
  upper_bound <- q3 + 1.5 * iqr
  return(series < lower_bound | series > upper_bound)
}

# Créer un masque pour détecter les lignes contenant des valeurs aberrantes
outlier_mask <- apply(data_cleaned[, sapply(data_cleaned, is.numeric)], 1, function(row) {
  any(find_outliers(row))
})

# Supprimer les lignes contenant des valeurs aberrantes
data_cleaned <- data_cleaned[!outlier_mask, ]

# Aperçu des données nettoyées
print("Dimensions des données après suppression des colonnes avec données manquantes et lignes aberrantes :")
print(dim(data_cleaned))
summary(data_cleaned)

# Re-intégration des colonnes avec remplacement des valeurs manquantes
# Valeurs par défaut à utiliser
fill_values <- list(
  alb = 3.5,        # Serum albumin
  pafi = 333.3,     # PaO2/FiO2 ratio
  bili = 1.01,      # Bilirubin
  crea = 1.01,      # Creatinine
  bun = 6.51,       # Blood Urea Nitrogen
  wblc = 9          # White blood count
)

# Ajouter chaque colonne supprimée une par une avec remplacement des NA
for (col in names(fill_values)) {
  if (col %in% colnames(data)) {
    # Ajouter la colonne avec remplacement des NA par la valeur définie
    data_cleaned[[col]] <- ifelse(is.na(data[[col]]), fill_values[[col]], data[[col]])
    print(paste("Colonne ajoutée :", col))
    summary(data_cleaned[[col]])
  } else {
    print(paste("Colonne manquante dans le dataset :", col))
  }
}

# Aperçu des données finales
print("Dimensions des données finales après réintégration des colonnes :")
print(dim(data_cleaned))
summary(data_cleaned)


