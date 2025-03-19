
import csv
import requests
import time
import os
# Configuration
token = "A_bf072e91"
base_url = "http://172.22.215.130"
ports = {
    "8100": {"filename": "info.csv", "headers": ["ID", "Date_Hour", "Date", "Seasons", "Holiday", "Functioning_Day"]},
    "8090": {"filename": "temperature.csv", "headers": ["ID", "Date", "Temperature", "Humidity", "Wind_speed"]},
    "8080": {"filename": "location.csv", "headers": ["ID", "Date_Hour"]}
}
# Fonction pour récupérer les données
def fetch_data(port, id, token):
    url = f"{base_url}:{port}?id={id}&token={token}"
    try:
        response = requests.get(url, timeout=5)
        print(f"[INFO] Port {port} - ID {id} - Status {response.status_code}")
        if response.status_code == 425:
            print(f"[STOP] Arrêt des requêtes pour le port {port} (code 425).")
            return "STOP"
        return response.text.strip()
    except requests.RequestException as e:
        print(f"[ERREUR] Échec requête sur Port {port}, ID {id}: {e}")
        return None
# Fonction pour lire les données existantes dans un fichier CSV
def read_existing_data(filename):
    existing_data = {}
    if os.path.exists(filename):
        with open(filename, mode='r', newline='', encoding='utf-8') as file:
            reader = csv.reader(file)
            next(reader, None)  # Ignorer l'en-tête
            for row in reader:
                if row:
                    existing_data[int(row[0])] = tuple(row)
    return existing_data
# Fonction pour sauvegarder les données dans un fichier CSV
def save_data(filename, headers, data, existing_data):
    file_exists = False
    try:
        file_exists = os.path.exists(filename)
        with open(filename, mode='a', newline='', encoding='utf-8') as file:
            writer = csv.writer(file)
            if not file_exists:
                writer.writerow(headers)
            for row in data:
                if tuple(row) not in existing_data.values():
                    writer.writerow(row)
    except Exception as e:
        print(f"[ERREUR] Échec lors de l'écriture dans {filename}: {e}")
# Boucle pour chaque port
def process_port(port, config):
    filename = config["filename"]
    headers = config["headers"]
    id = 1
    print(f"[DEBUT] Traitement du port {port}...")
    existing_data = read_existing_data(filename)
    while True:
        if id in existing_data:
            print(f"[INFO] Port {port} - ID {id} déjà écrit, passage à l'ID suivant.")
            id += 1
            continue
        result = fetch_data(port, id, token)
        if result == "STOP":
            print(f"[FIN] Arrêt des requêtes pour le port {port} (code 425).")
            break
        if result:
            lines = result.split('\n')
            if port == "8080":
                # Supprimer "Date :" de la première ligne
                if lines and "Date :" in lines[0]:
                    lines[0] = lines[0].replace("Date :", "").strip()
                data = [[id, line] for line in lines if line.strip()]
            else:
                if len(lines) > 1:  # Vérification pour éviter l'erreur d'index
                    data = [[id] + lines[1].split()]
                else:
                    print(f"[ERREUR] Réponse inattendue pour le port {port}, ID {id}: {result}")
                    data = []
            save_data(filename, headers, data, existing_data)
            print(f"[INFO] Port {port} - ID {id} enregistré avec succès.")
        time.sleep(0.01)  # Pause pour éviter la surcharge du serveur
        id += 1
# Fonction principale
def main():
    for port, config in ports.items():
        process_port(port, config)
        print(f"[INFO] Passage au port suivant...")
    print("[FIN] Tous les ports ont été traités.")
if __name__ == "__main__":
    main()
