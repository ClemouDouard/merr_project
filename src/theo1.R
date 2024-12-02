data <- read.csv("../data/support2.csv")

data$pafi[is.na(data$pafi)] <- 333.3
data$alb[is.na(data$alb)] <- 3.5
data$bun[is.na(data$bun)] <- 6.51
data$urine[is.na(data$urine)] <- 2502

data[] <- lapply(data, function(x) {
  if (is.numeric(x)) {
    x[is.na(x)] <- median(x, na.rm = TRUE) 
  }
  return(x)
})
head(data)

colonnes_chaine <- sapply(data, is.character)

nombres_vides <- sapply(data[, colonnes_chaine], function(x) sum(x == ""))

# Afficher les résultats
resultats <- data.frame(
  colonne = names(nombres_vides),
  nombre_vides = nombres_vides
)
resultats


data <- data[, !names(data) %in% "income"]
#data <- data[, !names(data) %in% "sfdm2"]
data <- data[!(is.na(data$sfdm2) | data$sfdm2 == ""), ]
data <- data[!(is.na(data$race) | data$race == ""), ]
data <- data[!(is.na(data$dnr) | data$dnr == ""), ]

colonnes_chaine <- sapply(data, is.character)

nombres_vides <- sapply(data[, colonnes_chaine], function(x) sum(x == ""))

# Afficher les résultats
resultats <- data.frame(
  colonne = names(nombres_vides),
  nombre_vides = nombres_vides
)
resultats



modreg <- glm(hospdead ~ ., data=data, family = binomial)
summary(modreg)

data$hatY  <- predict(modreg, type="response")
predicted_classes <- ifelse(data$hatY > 0.5, 1, 0)
confusion_matrix <- table(Predicted = predicted_classes, Actual = data$hospdead)
confusion_matrix

ggplot(data, aes(x = hospdead, y = hatY)) +
  geom_point(alpha = 0.5, color = "blue") +  # Nuage de points
  geom_smooth(method = "glm", method.args = list(family = "binomial"), color = "red") + # Courbe ajustée
  ggtitle("Régression Logistique : Probabilité prédite vs hospdead") +
  xlab("Hospdead (réel)") +
  ylab("Probabilité prédite")

false_positive_rate <- confusion_matrix[2,1] / sum(confusion_matrix[, 1])
print(false_positive_rate)

false_negative_rate <- confusion_matrix[1, 2] / sum(confusion_matrix[, 2])
print(false_negative_rate)


accuracy <- sum(diag(confusion_matrix)) / sum(confusion_matrix)
print(accuracy)


regboth = step(lm(hospdead~., data=data), direction='both')


modreg2 <- glm(hospdead ~ death + slos + d.time + dzgroup + num.co + edu + scoma + charges + totcst + totmcst + avtisst + race + sps + aps + surv2m + surv6m + prg2m + prg6m + dnr + dnrday + adlp + adls + sfdm2 + adlsc, data=data, family = binomial)
summary(modreg2)

data$hatY  <- predict(modreg2, type="response")
predicted_classes <- ifelse(data$hatY > 0.5, 1, 0)
confusion_matrix <- table(Predicted = predicted_classes, Actual = data$hospdead)
confusion_matrix

ggplot(data, aes(x = hospdead, y = hatY)) +
  geom_point(alpha = 0.5, color = "blue") +  # Nuage de points
  geom_smooth(method = "glm", method.args = list(family = "binomial"), color = "red") + # Courbe ajustée
  ggtitle("Régression Logistique : Probabilité prédite vs hospdead") +
  xlab("Hospdead (réel)") +
  ylab("Probabilité prédite")

train_index <- sample(1:nrow(data), size = 0.7 * nrow(data))

train_data1 <- data[train_index, ]
test_data1 <- data[setdiff(1:nrow(data), train_index), ]

dim(train_data1)
dim(test_data1)

modreg <- glm(hospdead ~ death + slos + d.time + dzgroup + num.co + edu + scoma + charges + totcst + totmcst + avtisst + race + sps + aps + surv2m + surv6m + prg2m + prg6m + dnr + dnrday + adlp + adls + sfdm2 + adlsc, data = train_data1, family=binomial)
summary(modreg)

test_data1$pred <- predict(modreg, newdata=test_data1, type="response")
predictions_class <- ifelse(test_data1$pred > 0.5, 1, 0)
confusion_matrix <- table(test_data1$hospdead, predictions_class)
print(confusion_matrix)

accuracy <- sum(diag(confusion_matrix)) / sum(confusion_matrix)
print(paste("Précision:", accuracy))

ggplot(test_data1, aes(x = hospdead, y = pred)) +
  geom_point(alpha = 0.5, color = "blue") +  # Nuage de points
  geom_smooth(method = "glm", method.args = list(family = "binomial"), color = "red") + # Courbe ajustée
  ggtitle("Régression Logistique : Probabilité prédite vs hospdead") +
  xlab("Hospdead (réel)") +
  ylab("Probabilité prédite")


A <- ifelse(data$hospdead > 0.5, 1, 0)
A <- A[A == 1]
B <- ifelse(data$hospdead < 0.5, 1, 0)
B <- B[B == 1]

A_t = length(A)/nrow(data)
B_t = length(B)/nrow(data)

inv_At = 1/A_t *B_t
inv_Bt = 1

inv_At


library(caret)

set.seed(123)
index <- createDataPartition(data$hospdead, p = 0.7, list = FALSE)

train_data2 <- data[index, ]
test_data2 <- data[-index, ]


weights <- ifelse(train_data2$hospdead == 1, 1, inv_At)
modreg <- glm(hospdead ~ death + slos + d.time + dzgroup + num.co + edu + scoma + charges + totcst + totmcst + avtisst + race + sps + aps + surv2m + surv6m + prg2m + prg6m + dnr + dnrday + adlp + adls + sfdm2 + adlsc, data = train_data2, family=binomial(link = "logit"), weights = weights)
summary(modreg)


# Ajouter les prédictions directement au dataset de test
test_data2$pred <- predict(modreg, newdata=test_data2, type="response")

predictions_class <- ifelse(test_data2$pred > 0.5, 1, 0)
confusion_matrix <- table(test_data2$hospdead, predictions_class)
print(confusion_matrix)


accuracy <- sum(diag(confusion_matrix)) / sum(confusion_matrix)
print(paste("Précision:", accuracy))


# Créer le graphique avec les données de test
ggplot(test_data2, aes(x = hospdead, y = pred)) +
  geom_point(alpha = 0.5, color = "blue") +  # Nuage de points
  geom_smooth(method = "glm", method.args = list(family = "binomial"), color = "red") + # Courbe ajustée
  ggtitle("Régression Logistique : Probabilité prédite vs hospdead") +
  xlab("Hospdead (réel)") +
  ylab("Probabilité prédite")

# Partition des données en train et test
set.seed(123)
index <- createDataPartition(data$hospdead, p = 0.7, list = FALSE)

train_data2 <- data[index, ]
test_data2 <- data[-index, ]

# Utiliser le même modèle pour créer des matrices d'entraînement et de test
formula <- hospdead ~ . - 1  # Supprimer l'intercept

x_train <- model.matrix(formula, data = train_data2)
y_train <- train_data2$hospdead

x_test <- model.matrix(formula, data = test_data2)
y_test <- test_data2$hospdead


# Régression Ridge
ridge_model <- glmnet(x_train, y_train, family = "binomial", alpha = 0)

# Validation croisée pour trouver le meilleur lambda
cv_ridge <- cv.glmnet(x_train, y_train, family = "binomial", alpha = 0)

# Meilleur lambda
best_lambda_ridge <- cv_ridge$lambda.min
print(paste("Best lambda for Ridge:", best_lambda_ridge))

# Modèle final Ridge avec le meilleur lambda
final_ridge_model <- glmnet(x_train, y_train, family = "binomial", alpha = 0, lambda = best_lambda_ridge)


# Régression Lasso
lasso_model <- glmnet(x_train, y_train, family = "binomial", alpha = 1)

# Validation croisée pour trouver le meilleur lambda
cv_lasso <- cv.glmnet(x_train, y_train, family = "binomial", alpha = 1)

# Meilleur lambda
best_lambda_lasso <- cv_lasso$lambda.min
print(paste("Best lambda for Lasso:", best_lambda_lasso))

# Modèle final Lasso avec le meilleur lambda
final_lasso_model <- glmnet(x_train, y_train, family = "binomial", alpha = 1, lambda = best_lambda_lasso)


# Prédictions Ridge
ridge_preds <- predict(final_ridge_model, s = best_lambda_ridge, newx = x_test, type = "response")
ridge_classes <- ifelse(ridge_preds > 0.5, 1, 0)

# Prédictions Lasso
lasso_preds <- predict(final_lasso_model, s = best_lambda_lasso, newx = x_test, type = "response")
lasso_classes <- ifelse(lasso_preds > 0.5, 1, 0)

# Matrices de confusion
conf_matrix_ridge <- table(Actual = y_test, Predicted = ridge_classes)
conf_matrix_lasso <- table(Actual = y_test, Predicted = lasso_classes)

print("Confusion Matrix for Ridge:")
print(conf_matrix_ridge)

print("Confusion Matrix for Lasso:")
print(conf_matrix_lasso)

# Calcul de la précision
accuracy_ridge <- sum(diag(conf_matrix_ridge)) / sum(conf_matrix_ridge)
accuracy_lasso <- sum(diag(conf_matrix_lasso)) / sum(conf_matrix_lasso)

print(paste("Accuracy for Ridge:", accuracy_ridge))
print(paste("Accuracy for Lasso:", accuracy_lasso))


# Créer un data frame pour les prédictions Ridge
ridge_plot_data <- data.frame(
  Actual = y_test,
  Predicted = as.numeric(ridge_preds)  # Convertir en numérique si nécessaire
)

# Visualisation des prédictions Ridge
ggplot(ridge_plot_data, aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.5, color = "blue") +
  geom_smooth(method = "glm", method.args = list(family = "binomial"), color = "red") +
  ggtitle("Ridge Regression: Predicted Probability vs Actual") +
  xlab("Actual hospdead") +
  ylab("Predicted Probability")

# Créer un data frame pour les prédictions Lasso
lasso_plot_data <- data.frame(
  Actual = y_test,
  Predicted = as.numeric(lasso_preds)
)

# Visualisation des prédictions Lasso
ggplot(lasso_plot_data, aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.5, color = "green") +
  geom_smooth(method = "glm", method.args = list(family = "binomial"), color = "red") +
  ggtitle("Lasso Regression: Predicted Probability vs Actual") +
  xlab("Actual hospdead") +
  ylab("Predicted Probability")

