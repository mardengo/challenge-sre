# Challenge SRE
## API REST
Se utilizó el lenguaje python con el framework flask para exponer en un endpoint el modelo serializado, con el cual se puede predecir enviando una serie de valores para determinar si corresponde a 0 'No Atraso' o a 1 'Atraso'. 
En el repositorio se utilizó el archivo `test.py` para realizar esta solicitud contra la API.

## Automatización
Se utilizó un Dockerfile para crear una imagen y subirla al container registry de GCP. Luego para disponibilizar la API se utilizó el servicio de GCP Cloud Run.
La creación y el envío de la imagen se automatizó con un Workflow de Github Action el cual cuando se detecta un push en la rama master ejecuta el proceso y disponibiliza la nueva versión.
En la definición de creación de ramas se utilizó Gitflow utilizando realease para nuevas features, hotfix para arreglos y support para documentación.
En la imagen se puede observar un diagrama del flujo que se sigue.

![image](https://user-images.githubusercontent.com/48531782/203163528-564d31fc-3849-4834-aea7-1e5c4c9032d9.png)

## Pruebas de performance
Para tener un endpoint para poder realizar una prueba de strees se disponibilizó  health con el método GET, y los valores obtenidos son los siguientes.
```
wrk  -c50000 -d45s https://acidlabs-api-3654syeneq-uc.a.run.app/health
Running 45s test @ https://acidlabs-api-3654syeneq-uc.a.run.app/health
  2 threads and 50000 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   564.13ms  204.77ms   1.29s    72.93%
    Req/Sec   274.85    248.81     0.85k    55.00%
  1510 requests in 1.76m, 563.45KB read
  Socket errors: connect 48981, read 26, write 11, timeout 919
  Non-2xx or 3xx responses: 53
Requests/sec:     14.27
Transfer/sec:      5.33KB
```
Para poder tener una mejora en los rendimientos se podría implementar un escalamiento vertical el cual se le da mas recursos a Cloud Run en este caso o al servicio que se esté utlizando, o el mas recomendado que podría ser un escalamiento horizontal en base a métricas y que vaya creando nuevas réplicas a medida que las vaya necesitando.

## Creación infraestructura
Para la creación de la infraestructura se utilizó terraform, se creó un directorio tf y se automatizó la creación con un workflow de Github Action, el cual cuando se realiza un push a un brach que no es master realiza un plan, y cuando se hace un push a la rama master ejecuta el apply.
El diagrama del flujo es el siguiente:

![image](https://user-images.githubusercontent.com/48531782/203168094-3aef1c96-aefc-460a-8375-58e4f45f193f.png)

## Autorización
Para que solo los sistemas y/o personas autorizadas puedan acceder a la API expuesta se puede utlizar algún mecanismo en el microservicio como JWT o algún token, u otra opción bastante utilizada es un servicio de autenticación/autorización externo como auth0.
En todos los casos al agregar una capa de autorización/autenticación el flujo va a sufrir una pequeña latencia en los mejores casos, esto es porque se tiene que validar datos para poder operar con el microservicio y todo eso es tiempo de procesamiento.

## SLI SLO
Para elegir el SLI SLO podemos elegir dos métricas bastante utlizadas como puede ser la latencia y la disponibilidad del servicio. 
En el caso de la latencia podemos definir que el 5% de las solicitudes no puede ser superior a 1s en una ventana de 5 minutos.
En el caso de la disponibilidad podemos definir que solamente el 0.5% de las solicitudes pueden ser códigos de respuesta que no sean 2XX en una ventana de 5 minutos.
En base a estos SLI podemos definir que nuestro SLO es el cumplimiento del  99.5% en el mes.
