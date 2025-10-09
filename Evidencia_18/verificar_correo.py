import sys, requests, time

# Validar argumento
if len(sys.argv) != 2:
    print("Uso: python verificar_correo.py correo@example.com")
    sys.exit(1)

correo = sys.argv[1]

# Leer API key
try:
    with open("apikey.txt", "r") as archivo:
        api_key = archivo.read().strip()
except FileNotFoundError:
    print("Error: No se encontró el archivo apikey.txt")
    sys.exit(1)

# Consulta principal
url = f"https://haveibeenpwned.com/api/v3/breachedaccount/{correo}"
headers = {
    "hibp-api-key": api_key,
    "user-agent": "PythonScript"
}

response = requests.get(url, headers=headers)

# Procesar respuesta
if response.status_code == 200:
    brechas = response.json()
    print(f"\nLa cuenta {correo} ha sido comprometida en {len(brechas)} brechas.")
    print("Generando reporte...\n")

    with open(f"reporte_{correo.replace('@','_at_')}.txt", "w", encoding="utf-8") as reporte:
        reporte.write(f"Reporte de brechas para: {correo}\n")
        reporte.write(f"Total de brechas: {len(brechas)}\n\n")

        for i, brecha in enumerate(brechas[:3]):
            nombre = brecha['Name']
            detalle_url = f"https://haveibeenpwned.com/api/v3/breach/{nombre}"
            detalle_resp = requests.get(detalle_url, headers=headers)

            if detalle_resp.status_code == 200:
                detalle = detalle_resp.json()
                reporte.write(f"Brecha {i+1}: {detalle.get('Title')}\n")
                reporte.write(f"Dominio: {detalle.get('Domain')}\n")
                reporte.write(f"Fecha de brecha: {detalle.get('BreachDate')}\n")
                reporte.write(f"Fecha registrada: {detalle.get('AddedDate')}\n")
                reporte.write(f"Datos comprometidos: {', '.join(detalle.get('DataClasses', []))}\n")
                reporte.write(f"Descripción: {detalle.get('Description')[:300]}...\n")
                reporte.write("-" * 60 + "\n\n")
            else:
                reporte.write(f"No se pudo obtener detalles de la brecha: {nombre}\n\n")

            if i < 2:
                print("Esperando 10 segundos antes de la siguiente consulta...\n")
                time.sleep(10)

    print(f"Reporte guardado como: reporte_{correo.replace('@','_at_')}.txt")

elif response.status_code == 404:
    print(f"La cuenta {correo} no aparece en ninguna brecha conocida.")
elif response.status_code == 401:
    print("Error de autenticación: revisa tu API key.")
else:
    print(f"Error inesperado. Código de estado: {response.status_code}")
