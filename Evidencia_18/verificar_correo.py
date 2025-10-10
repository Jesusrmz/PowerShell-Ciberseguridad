import sys, requests, time, os, getpass, logging, csv

logging.basicConfig(
    filename="registro.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
 
if not os.path.exists("apikey.txt"):
    print("No se encontró el archivo apikey.txt.")
    try:
        clave = getpass.getpass("Ingresa tu API key de Have I Been Pwned: ")
        with open("apikey.txt", "w") as archivo:
            archivo.write(clave.strip())
        print("API key guardada exitosamente en apikey.txt.")
    except Exception as e:
        print(f"Error al guardar la API key: {e}")
        logging.error(f"Error al escribir el archivo apikey.txt: {e}")
        sys.exit(1)

try:
    with open("apikey.txt", "r") as archivo:
        api_key = archivo.read().strip()
except FileNotFoundError:
    print("Error: No se pudo encontrar apikey.txt. Ejecuta de nuevo para crearlo.")
    logging.error("No se encontró apikey.txt después del intento de creación.")
    sys.exit(1)
except Exception as e:
    print(f"Error crítico al leer la API key: {e}")
    logging.error(f"Error al leer el archivo apikey.txt: {e}")
    sys.exit(1)
 
if len(sys.argv) != 2:
    print("Uso: python verificar_correo.py correo@dominio.com")
    sys.exit(1)
 
correo = sys.argv[1]
url = f"https://haveibeenpwned.com/api/v3/breachedaccount/{correo}"
headers = {
    "hibp-api-key": api_key,
    "user-agent": "ProfessionalVerificationScript"
}
 
print(f"Verificando el correo: {correo}...")
 
try:
    response = requests.get(url, headers=headers)
 
    if response.status_code == 200:
        brechas = response.json()
        mensaje = f"Consulta exitosa para {correo}. Brechas encontradas: {len(brechas)}"
        print(f"¡Atención! La cuenta ha sido comprometida en {len(brechas)} brechas de seguridad.")
        logging.info(mensaje)
 

        try:
            with open("reporte.csv", "w", newline='', encoding="utf-8") as archivo_csv:
                writer = csv.writer(archivo_csv)
                writer.writerow([
                    "Titulo", "Dominio", "Fecha de Brecha",
                    "Datos Comprometidos", "Verificada", "Sensible"
                ])
                print(" Generando reporte.csv con los detalles...")

                for i, brecha in enumerate(brechas[:3]):
                    nombre_brecha = brecha['Name']
                    detalle_url = f"https://haveibeenpwned.com/api/v3/breach/{nombre_brecha}"
                    detalle_resp = requests.get(detalle_url, headers=headers)
 
                    if detalle_resp.status_code == 200:
                        detalle = detalle_resp.json()
                        writer.writerow([
                            detalle.get('Title', 'N/A'),
                            detalle.get('Domain', 'N/A'),
                            detalle.get('BreachDate', 'N/A'),
                            ', '.join(detalle.get('DataClasses', [])),
                            detalle.get('IsVerified', False),
                            detalle.get('IsSensitive', False)
                        ])
                    else:
                        logging.error(f"No se obtuvo detalle de la brecha '{nombre_brecha}'. Código: {detalle_resp.status_code}")
 
                    if i < len(brechas[:3]) - 1:
                        print("Esperando 10 segundos para la siguiente consulta...")
                        time.sleep(10)
            print("Reporte 'reporte.csv' generado exitosamente.")
 
        except Exception as e:
            print(f"Error al escribir el archivo de reporte: {e}")
            logging.error(f"Error al escribir reporte.csv: {e}")
 
    elif response.status_code == 404:
        print(f"La cuenta {correo} no aparece en ninguna brecha de seguridad conocida.")
        logging.info(f"Consulta exitosa para {correo}. No se encontraron brechas.")
 
    elif response.status_code == 401:
        print("Error 401: La API key es inválida. Revisa tu archivo apikey.txt.")
        logging.error("Error 401: API key inválida.")
 
    else:
        mensaje_error = f"Error inesperado. Código de estado: {response.status_code}"
        print(f"{mensaje_error}")
        logging.error(mensaje_error)
 
except requests.exceptions.RequestException as e:
    print(f"Error de conexión: No se pudo contactar al servidor de HIBP. Revisa tu conexión a internet.")
    logging.error(f"Error de conexión al consultar la API: {e}")