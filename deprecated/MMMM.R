
# ---- 3. Nettoyage des Données ----

## Correction des noms et format des dates
info <- info %>%
  rename(Date = date) %>%
  mutate(Date = as.Date(substr(Date, 1, 10)))

location <- location %>%
  mutate(Date = as.Date(substr(Date_Hour, 1, 10))) %>%
  group_by(Date) %>%
  summarise(Nb_Locations = n())

temperature <- temperature %>%
  mutate(Date = as.Date(Date)) %>%
  group_by(Date) %>%
  summarise(across(Temperature:Snowfall, mean, na.rm = TRUE))

# ---- 4. Fusion des Données ----
data <- location %>%
  left_join(info, by = "Date") %>%
  left_join(temperature, by = "Date") %>%
  na.omit()


# ---- 1. Vérification du Format des Dates ----
print(class(data$Date))  # Vérifier si la colonne est bien en format Date

# ---- 2. Conversion en Date si nécessaire ----
if (!inherits(data$Date, "Date")) {  # Vérifie si ce n'est pas déjà une Date
  data$Date <- as.Date(data$Date)  # Convertir en format Date
}

# ---- 3. Extraire les Jours de la Semaine Correctement ----
data$Jour_Semaine <- weekdays(data$Date, abbreviate = FALSE)  # Extraire le jour complet

# ---- 4. Vérification des valeurs uniques ----
print(unique(data$Jour_Semaine))  # Afficher les valeurs des jours détectés

# ---- 5. Correction de Week_end ----
data$Week_end <- ifelse(data$Jour_Semaine %in% c("samedi", "dimanche", "Saturday", "Sunday"), "Oui", "Non")

# ---- 6. Vérification après correction ----
print(unique(data$Week_end))  # Devrait afficher "Oui" et "Non"
## Modèle basé sur le Temps
modele_temps <- lm(Nb_Locations ~ Jour_Semaine + Week_end + Mois + Heure, data = data)

## Modèle basé sur la Météo
modele_meteo <- lm(Nb_Locations ~ Temperature + Humidity + Wind_speed + Rainfall + Snowfall, data = data)

## Modèle Complet (Temps + Météo)
modele_global <- lm(Nb_Locations ~ Jour_Semaine + Week_end + Mois + Heure + Temperature + Humidity + Wind_speed + Rainfall + Snowfall, data = data)

# ---- 3. Comparaison des Modèles ----

## Calcul du R² ajusté
r2_adj_temps <- summary(modele_temps)$adj.r.squared
r2_adj_meteo <- summary(modele_meteo)$adj.r.squared
r2_adj_global <- summary(modele_global)$adj.r.squared

## Calcul de AIC (plus faible = meilleur modèle)
aic_temps <- AIC(modele_temps)
aic_meteo <- AIC(modele_meteo)
aic_global <- AIC(modele_global)
