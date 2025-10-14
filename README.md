# Verificador de correos comprometidos – Have I Been Pwned

Este script permite verificar si una cuenta de correo electrónico ha sido comprometida en brechas
de seguridad conocidas, utilizando la API oficial de Have I Been Pwned.

## Requisitos

- Python 3.8 o superior  
- API key válida de Have I Been Pwned  
- Conexión a internet  

## Instalación

1. Clona o descarga el proyecto en tu equipo.  
2. Instala las dependencias usando `requirements.txt`:

```bash
pip install -r requirements.txt
## Uso 
 
Ejecuta el script desde la terminal, indicando el correo a verificar y opcionalmente el nombre del 
archivo CSV de salida: 
 
```bash 
python verificar_correo.py correo@example.com -o salida.csv``` 
 
## Archivos generados 
- `reporte.csv`: contiene los detalles de hasta 3 brechas encontradas para el correo consultado. 
- `registro.log`: archivo de registro con información de cada consulta realizada y errores 
detectados. 
- `apikey.txt`: archivo local que almacena la API key ingresada por el usuario.
- `requirements.txt`: archivo generado automáticamente con las dependencias del proyecto. 
 
## Estructura del proyecto 
 
```plaintext 
verificar_correo.py 
apikey.txt 
registro.log 
requirements.txt
reporte.csv  
README.md``` 
 
## Créditos 
 
Desarrollado por **Jesus Alejandro**   
Materia: *Programación para Ciberseguridad*   
Grupo: *[061]* 
 
## Licencia 
 
Este proyecto se distribuye con fines educativos. El uso de la API de Have I Been Pwned está sujeto 
a sus [términos de servicio](https://haveibeenpwned.com/API/v3#AcceptableUse). 
 
## Contacto 
 
Para dudas técnicas o sugerencias, puedes dejar comentarios en el repositorio de GitHub. 