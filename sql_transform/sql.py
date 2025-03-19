import os
import pandas as pd
import sqlite3

# Répertoire où sont stockés les CSV
repertoire = "./"
fichiers_csv = [f for f in os.listdir(repertoire) if f.endswith(".csv")]

# Connexion SQLite en mémoire
conn = sqlite3.connect("location_database.db")
cursor = conn.cursor()

# Fonction pour deviner les types SQL d'un dataframe
def inferer_types_sql(df):
    type_map = {
        "int64": "INTEGER",
        "float64": "REAL",
        "object": "TEXT",
        "bool": "BOOLEAN"
    }
    return [type_map.get(str(dtype), "TEXT") for dtype in df.dtypes]

# Conversion de chaque CSV en table SQLite
for fichier in fichiers_csv:
    chemin_csv = os.path.join(repertoire, fichier)
    nom_table = os.path.splitext(fichier)[0]  # Nom de la table = nom du fichier sans extension

    df = pd.read_csv(chemin_csv)
    types_sql = inferer_types_sql(df)

    # Création de la table SQL
    colonnes_sql = ", ".join([f'"{col}" {type_sql}' for col, type_sql in zip(df.columns, types_sql)])
    sql_create = f'CREATE TABLE "{nom_table}" ({colonnes_sql});'
    cursor.execute(sql_create)

    # Insérer les données
    df.to_sql(nom_table, conn, if_exists="append", index=False)

# Sauvegarde du script SQL
with open("location_database.sql", "w", encoding="utf-8") as f:
    for ligne in conn.iterdump():
        f.write(f"{ligne}\n")

# Fermeture de la connexion
conn.close()

print("Fichier SQL généré : location_database.sql")
