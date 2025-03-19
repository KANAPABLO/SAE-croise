info <- read.csv("C:\\Users\\nsoul\\Downloads\\info.csv")
#View(info)
location <- read.csv("C:\\Users\\nsoul\\Downloads\\location.csv")
#View(location)
temperature <- read.csv("C:\\Users\\nsoul\\Downloads\\temperature.csv")


# ---- 1. Chargement des packages ----
library(dplyr)
library(ggplot2)
library(car)   # Vérification de la multicolinéarité
library(lmtest)  # Test de Breusch-Pagan
library(MASS)  # Pour le test de normalité des résidus
library(lubridate)  # Manipulation des dates



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

# ---- 5. Modélisation avec Régression Linéaire Multiple ----

## Conversion des variables catégorielles
data$saison <- as.factor(data$saison)
data$vacance <- as.factor(data$vacance)
data$jour_ferie <- as.factor(data$jour_ferie)

## Modèle linéaire multiple
modele <- lm(Nb_Locations ~ saison + vacance + jour_ferie + Temperature + Humidity + Wind_speed + Visibility + Solar_Radiation + Rainfall + Snowfall, data = data)


## Résumé du modèle
summary(modele)

