info <- read.csv("~/SAE-ProjetIntensif/info.csv")
#View(info)
location <- read.csv("~/SAE-ProjetIntensif/location.csv")
#View(location)
temperature <- read.csv("~/SAE-ProjetIntensif/temperature.csv")
#View(temperature)

library(dplyr)
library(lubridate)
library(corrplot)
library(ggplot2)
library(FactoMineR)  # Pour l'ACP
library(factoextra)  # Pour visualiser l'ACP

# Convertir la colonne Date_Hour en objet date-heure
location <- location %>%
  mutate(Date_Hour = ymd_hms(Date_Hour))

# Extraire la date et l'heure dans de nouvelles colonnes
location <- location %>%
  mutate(Date = as.Date(Date_Hour),
         Heure = format(Date_Hour, "%H"))

# Grouper par date et heure, puis compter le nombre d'observations
location_grouped <- location %>%
  group_by(Date, Heure) %>%
  summarise(Nombre_Locations = n()) %>%
  ungroup()

# Afficher le DataFrame groupé
print(location_grouped)


# Vérifiez le nombre de lignes dans chaque DataFrame
nrow_location <- nrow(location_grouped)
nrow_temperature <- nrow(temperature)

# Si location_grouped a moins de lignes, ajoutez des lignes avec des valeurs par défaut
if (nrow_location < nrow_temperature) {
  # Ajoutez des lignes avec des valeurs NA à location_grouped
  location_grouped <- rbind(location_grouped, data.frame(
    Date = rep(NA, nrow_temperature - nrow_location),
    Heure = rep(NA, nrow_temperature - nrow_location),
    Nombre_Locations = rep(NA, nrow_temperature - nrow_location)
  ))
}

# Si temperature a moins de lignes, ajoutez des lignes avec des valeurs par défaut
if (nrow_temperature < nrow_location) {
  # Ajoutez des lignes avec des valeurs NA à temperature
  temperature <- rbind(temperature, data.frame(
    ID = rep(NA, nrow_location - nrow_temperature),
    Date = rep(NA, nrow_location - nrow_temperature),
    Hour = rep(NA, nrow_location - nrow_temperature),
    Temperature = rep(NA, nrow_location - nrow_temperature),
    Humidity = rep(NA, nrow_location - nrow_temperature),
    Wind_speed = rep(NA, nrow_location - nrow_temperature),
    Visibility = rep(NA, nrow_location - nrow_temperature),
    Dew.point.temperature = rep(NA, nrow_location - nrow_temperature),
    Solar_Radiation = rep(NA, nrow_location - nrow_temperature),
    Rainfall = rep(NA, nrow_location - nrow_temperature),
    Snowfall = rep(NA, nrow_location - nrow_temperature)
    
  ))
}

location_grouped$Temperature <- temperature$Temperature
location_grouped$Humidity <- temperature$Humidity
location_grouped$Wind_speed <- temperature$Wind_speed
location_grouped$Visibility <- temperature$Visibility
location_grouped$Dew.point.temperature <- temperature$Dew.point.temperature
location_grouped$Solar_Radiation <- temperature$Solar_Radiation
location_grouped$Rainfall <- temperature$Rainfall
location_grouped$Snowfall <- temperature$Snowfall

# Afficher le DataFrame modifié
print(location_grouped)
#Graphique évolution de la température en fonction du temps
# Moyenne des températures par jour pour lisser les variations horaires
temperature_daily <- location_clean %>%
  group_by(Date) %>%
  summarise(Temperature = mean(Temperature, na.rm = TRUE))
# Graphique avec légende
ggplot(temperature_daily, aes(x = as.Date(Date))) +
  geom_line(aes(y = Temperature, color = "Température réelle"), size = 1) +  # Rouge
  geom_smooth(aes(y = Temperature, color = "Tendance lissée"), method = "loess", se = FALSE, span = 0.2, size = 1) +  # Bleu
  scale_color_manual(values = c("Température réelle" = "red", "Tendance lissée" = "blue")) +  # Définir les couleurs
  labs(title = "Évolution de la Température au Fil du Temps",
       x = "Date", y = "Température ", color = "Légende") +  # Ajout d'un titre de légende
  theme_minimal()
